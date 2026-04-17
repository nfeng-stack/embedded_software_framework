/**
 * @file    fatfs_service.c
 * @brief   FATFS Service Layer implementation
 */

#define LOG_TAG "fatfs_svc"
#include <stdio.h>
#include <string.h>
#include "fatfs_service.h"
#include "ff.h"
#include "diskio.h"
#include "elog.h"
#include "osal.h"

/* FATFS volume mount point */
#define FATFS_VOLUME_PATH	"0:/"	/* Physical drive 0 */
#define FATFS_ROOT_PATH		"0:/"

/* Maximum number of open files */
#define MAX_OPEN_FILES		FF_FS_LOCK

/* File handle structure */
typedef struct {
	FIL fp;					/* FATFS file object */
	char path[256];			/* File path */
	uint8_t in_use;			/* Handle in use flag */
} file_handle_t;

/* Service state */
static FATFS fs;			/* FATFS filesystem object */
static uint8_t mounted = 0;	/* Volume mounted flag */
static file_handle_t file_handles[MAX_OPEN_FILES];

/* Forward declarations */
static int alloc_file_handle(void);
static void free_file_handle(int fh);
static const char* translate_fr_error(FRESULT fr);

/*-----------------------------------------------------------------------*/
/* Translate FATFS error code to service error code                      */
/*-----------------------------------------------------------------------*/
static const char* translate_fr_error(FRESULT fr)
{
	switch (fr) {
		case FR_OK:					return "Succeeded";
		case FR_DISK_ERR:			return "A hard error occurred in the low level disk I/O layer";
		case FR_INT_ERR:			return "Assertion failed";
		case FR_NOT_READY:			return "The physical drive cannot work";
		case FR_NO_FILE:			return "Could not find the file";
		case FR_NO_PATH:			return "Could not find the path";
		case FR_INVALID_NAME:		return "The path name format is invalid";
		case FR_DENIED:				return "Access denied due to prohibited access or directory full";
		case FR_EXIST:				return "Access denied due to prohibited access";
		case FR_INVALID_OBJECT:		return "The file/directory object is invalid";
		case FR_WRITE_PROTECTED:	return "The physical drive is write protected";
		case FR_INVALID_DRIVE:		return "The logical drive number is invalid";
		case FR_NOT_ENABLED:		return "The volume has no work area";
		case FR_NO_FILESYSTEM:		return "There is no valid FAT volume";
		case FR_MKFS_ABORTED:		return "The f_mkfs() aborted due to any problem";
		case FR_TIMEOUT:			return "Could not get a grant to access the volume within defined period";
		case FR_LOCKED:				return "The operation is rejected according to the file sharing policy";
		case FR_NOT_ENOUGH_CORE:	return "LFN working buffer could not be allocated";
		case FR_TOO_MANY_OPEN_FILES:return "Number of open files > FF_FS_LOCK";
		case FR_INVALID_PARAMETER:	return "Given parameter is invalid";
		default:					return "Unknown error";
	}
}

/*-----------------------------------------------------------------------*/
/* Allocate file handle from pool                                        */
/*-----------------------------------------------------------------------*/
static int alloc_file_handle(void)
{
	for (int i = 0; i < MAX_OPEN_FILES; i++) {
		if (!file_handles[i].in_use) {
			file_handles[i].in_use = 1;
			memset(&file_handles[i].fp, 0, sizeof(FIL));
			file_handles[i].path[0] = '\0';
			return i;
		}
	}
	
	return -1; /* No free handles */
}

/*-----------------------------------------------------------------------*/
/* Free file handle                                                      */
/*-----------------------------------------------------------------------*/
static void free_file_handle(int fh)
{
	if (fh >= 0 && fh < MAX_OPEN_FILES) {
		file_handles[fh].in_use = 0;
	}
}

/*-----------------------------------------------------------------------*/
/* Initialize file handle pool                                           */
/*-----------------------------------------------------------------------*/
static void init_file_handles(void)
{
	for (int i = 0; i < MAX_OPEN_FILES; i++) {
		file_handles[i].in_use = 0;
	}
}

/*-----------------------------------------------------------------------*/
/* Initialize FATFS service                                              */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_init(void)
{
	FRESULT fr;
	
	if (mounted) {
		log_w("FATFS already initialized");
		return FATFS_OK;
	}
	
	// log_i("Initializing FATFS service...");
	
	/* Initialize file handle pool */
	init_file_handles();
	
	/* Mount the volume */
	fr = f_mount(&fs, FATFS_VOLUME_PATH, 1);
	if (fr != FR_OK) {
		log_w("Mount failed: %s", translate_fr_error(fr));
		
		/* Try to format if no filesystem found */
		if (fr == FR_NO_FILESYSTEM) {
			// log_i("No filesystem found, formatting...");
			/* Work buffer for formatting */
			BYTE work[FF_MAX_SS];
			fr = f_mkfs(FATFS_VOLUME_PATH, NULL, work, sizeof(work));
			if (fr != FR_OK) {
				log_e("Format failed: %s", translate_fr_error(fr));
				return FATFS_ERR_INIT;
			}
			
			/* Remount after formatting */
			fr = f_mount(&fs, FATFS_VOLUME_PATH, 1);
			if (fr != FR_OK) {
				log_e("Remount after format failed: %s", translate_fr_error(fr));
				return FATFS_ERR_INIT;
			}
		} else {
			return FATFS_ERR_INIT;
		}
	}
	
	mounted = 1;
	// log_i("FATFS service initialized successfully");
	
	return FATFS_OK;
}

/*-----------------------------------------------------------------------*/
/* Deinitialize FATFS service                                            */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_deinit(void)
{
	if (!mounted) {
		return FATFS_OK;
	}
	
	/* Close all open files */
	for (int i = 0; i < MAX_OPEN_FILES; i++) {
		if (file_handles[i].in_use) {
			f_close(&file_handles[i].fp);
			file_handles[i].in_use = 0;
		}
	}
	
	/* Unmount volume */
	FRESULT fr = f_mount(NULL, FATFS_VOLUME_PATH, 0);
	if (fr != FR_OK) {
		log_e("Unmount failed: %s", translate_fr_error(fr));
		return FATFS_ERR_CLOSE;
	}
	
	mounted = 0;
	// log_i("FATFS service deinitialized");
	
	return FATFS_OK;
}

/*-----------------------------------------------------------------------*/
/* Get file system status                                                */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_status(uint32_t *total_kb, uint32_t *free_kb)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	FATFS *fs_ptr;
	DWORD free_clusters, total_clusters;
	
	FRESULT fr = f_getfree(FATFS_VOLUME_PATH, &free_clusters, &fs_ptr);
	if (fr != FR_OK) {
		log_e("Get free space failed: %s", translate_fr_error(fr));
		return FATFS_ERR_PARAM;
	}
	
	/* Calculate total and free space in KB */
	total_clusters = fs_ptr->n_fatent - 2;
	uint32_t sectors_per_cluster = fs_ptr->csize;
	uint32_t bytes_per_sector = 512; /* FF_MAX_SS */
	
	*total_kb = (total_clusters * sectors_per_cluster * bytes_per_sector) / 1024;
	*free_kb = (free_clusters * sectors_per_cluster * bytes_per_sector) / 1024;
	
	return FATFS_OK;
}

/*-----------------------------------------------------------------------*/
/* Open a file                                                           */
/*-----------------------------------------------------------------------*/
int32_t fatfs_service_open(const char *path, fatfs_mode_t mode)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	if (!path || strlen(path) == 0) {
		return FATFS_ERR_PARAM;
	}
	
	/* Allocate file handle */
	int fh = alloc_file_handle();
	if (fh < 0) {
		log_e("No free file handles");
		return FATFS_ERR_PARAM;
	}
	
	/* Translate open mode to FATFS flags */
	BYTE flags = 0;
	switch (mode) {
		case FATFS_MODE_READ:
			flags = FA_READ | FA_OPEN_EXISTING;
			break;
		case FATFS_MODE_WRITE:
			flags = FA_WRITE | FA_CREATE_ALWAYS;
			break;
		case FATFS_MODE_APPEND:
			flags = FA_WRITE | FA_OPEN_APPEND;
			break;
		default:
			free_file_handle(fh);
			return FATFS_ERR_PARAM;
	}
	
	/* Open the file */
	FRESULT fr = f_open(&file_handles[fh].fp, path, flags);
	if (fr != FR_OK) {
		log_e("Open file '%s' failed: %s", path, translate_fr_error(fr));
		free_file_handle(fh);
		
		switch (fr) {
			case FR_NO_FILE:
			case FR_NO_PATH:
				return FATFS_ERR_NO_FILE;
			case FR_EXIST:
				return FATFS_ERR_EXISTS;
			case FR_DENIED:
				return FATFS_ERR_NO_SPACE;
			default:
				return FATFS_ERR_OPEN;
		}
	}
	
	/* Store file path */
	strncpy(file_handles[fh].path, path, sizeof(file_handles[fh].path) - 1);
	file_handles[fh].path[sizeof(file_handles[fh].path) - 1] = '\0';
	
	log_v("File opened: %s (handle=%d, mode=%d)", path, fh, mode);
	return fh;
}

/*-----------------------------------------------------------------------*/
/* Read from file                                                        */
/*-----------------------------------------------------------------------*/
int32_t fatfs_service_read(int32_t fh, void *buffer, uint32_t size)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	if (fh < 0 || fh >= MAX_OPEN_FILES || !file_handles[fh].in_use) {
		return FATFS_ERR_PARAM;
	}
	
	if (!buffer || size == 0) {
		return FATFS_ERR_PARAM;
	}
	
	UINT bytes_read = 0;
	FRESULT fr = f_read(&file_handles[fh].fp, buffer, size, &bytes_read);
	
	if (fr != FR_OK) {
		log_e("Read failed (handle=%d): %s", fh, translate_fr_error(fr));
		return FATFS_ERR_READ;
	}
	
	return (int32_t)bytes_read;
}

/*-----------------------------------------------------------------------*/
/* Write to file                                                         */
/*-----------------------------------------------------------------------*/
int32_t fatfs_service_write(int32_t fh, const void *buffer, uint32_t size)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	if (fh < 0 || fh >= MAX_OPEN_FILES || !file_handles[fh].in_use) {
		return FATFS_ERR_PARAM;
	}
	
	if (!buffer || size == 0) {
		return FATFS_ERR_PARAM;
	}
	
	UINT bytes_written = 0;
	FRESULT fr = f_write(&file_handles[fh].fp, buffer, size, &bytes_written);
	
	if (fr != FR_OK) {
		log_e("Write failed (handle=%d): %s", fh, translate_fr_error(fr));
		return FATFS_ERR_WRITE;
	}
	
	return (int32_t)bytes_written;
}

/*-----------------------------------------------------------------------*/
/* Close file                                                            */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_close(int32_t fh)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	if (fh < 0 || fh >= MAX_OPEN_FILES || !file_handles[fh].in_use) {
		return FATFS_ERR_PARAM;
	}
	
	FRESULT fr = f_close(&file_handles[fh].fp);
	if (fr != FR_OK) {
		log_e("Close failed (handle=%d): %s", fh, translate_fr_error(fr));
		return FATFS_ERR_CLOSE;
	}
	
	free_file_handle(fh);
	log_v("File closed: handle=%d", fh);
	return FATFS_OK;
}

/*-----------------------------------------------------------------------*/
/* Delete file                                                           */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_delete(const char *path)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	if (!path || strlen(path) == 0) {
		return FATFS_ERR_PARAM;
	}
	
	FRESULT fr = f_unlink(path);
	if (fr != FR_OK) {
		log_e("Delete file '%s' failed: %s", path, translate_fr_error(fr));
		
		switch (fr) {
			case FR_NO_FILE:
			case FR_NO_PATH:
				return FATFS_ERR_NO_FILE;
			case FR_DENIED:
				return FATFS_ERR_PARAM; /* Directory not empty or read-only */
			default:
				return FATFS_ERR_PARAM;
		}
	}
	
	log_i("File deleted: %s", path);
	return FATFS_OK;
}

/*-----------------------------------------------------------------------*/
/* Create directory                                                      */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_mkdir(const char *path)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	if (!path || strlen(path) == 0) {
		return FATFS_ERR_PARAM;
	}
	
	FRESULT fr = f_mkdir(path);
	if (fr != FR_OK) {
		log_e("Create directory '%s' failed: %s", path, translate_fr_error(fr));
		
		switch (fr) {
			case FR_EXIST:
				return FATFS_ERR_EXISTS;
			case FR_NO_PATH:
				return FATFS_ERR_PARAM;
			case FR_DENIED:
				return FATFS_ERR_NO_SPACE;
			default:
				return FATFS_ERR_PARAM;
		}
	}
	
	log_i("Directory created: %s", path);
	return FATFS_OK;
}

/*-----------------------------------------------------------------------*/
/* Remove directory                                                      */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_rmdir(const char *path)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	if (!path || strlen(path) == 0) {
		return FATFS_ERR_PARAM;
	}
	
	/* Check if directory is empty */
	DIR dir;
	FILINFO fno;
	
	FRESULT fr = f_opendir(&dir, path);
	if (fr != FR_OK) {
		log_e("Open directory '%s' failed: %s", path, translate_fr_error(fr));
		return FATFS_ERR_PARAM;
	}
	
	/* Try to read first entry */
	fr = f_readdir(&dir, &fno);
	f_closedir(&dir);
	
	if (fr != FR_OK) {
		log_e("Read directory '%s' failed: %s", path, translate_fr_error(fr));
		return FATFS_ERR_PARAM;
	}
	
	/* If fno.fname[0] is not null, directory is not empty */
	if (fno.fname[0] != '\0') {
		log_e("Directory '%s' is not empty", path);
		return FATFS_ERR_PARAM;
	}
	
	/* Remove directory */
	fr = f_unlink(path);
	if (fr != FR_OK) {
		log_e("Remove directory '%s' failed: %s", path, translate_fr_error(fr));
		return FATFS_ERR_PARAM;
	}
	
	log_i("Directory removed: %s", path);
	return FATFS_OK;
}

/*-----------------------------------------------------------------------*/
/* Check if file or directory exists                                     */
/*-----------------------------------------------------------------------*/
bool fatfs_service_exists(const char *path)
{
	if (!mounted) {
		return false;
	}
	
	if (!path || strlen(path) == 0) {
		return false;
	}
	
	FILINFO fno;
	FRESULT fr = f_stat(path, &fno);
	
	return (fr == FR_OK);
}

/*-----------------------------------------------------------------------*/
/* Get file information                                                  */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_stat(const char *path, fatfs_fileinfo_t *info)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	if (!path || !info) {
		return FATFS_ERR_PARAM;
	}
	
	FILINFO fno;
	FRESULT fr = f_stat(path, &fno);
	
	if (fr != FR_OK) {
		log_e("Stat file '%s' failed: %s", path, translate_fr_error(fr));
		return FATFS_ERR_NO_FILE;
	}
	
	/* Fill info structure */
	strncpy(info->name, path, sizeof(info->name) - 1);
	info->name[sizeof(info->name) - 1] = '\0';
	info->size = fno.fsize;
	info->date = fno.fdate;
	info->time = fno.ftime;
	info->attr = fno.fattrib;
	
	return FATFS_OK;
}

/*-----------------------------------------------------------------------*/
/* Format the file system                                                */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_format(void)
{
	if (mounted) {
		/* Unmount first */
		fatfs_service_deinit();
	}
	
	// log_i("Formatting FATFS volume...");
	
	/* Format the volume as FAT32 */
	MKFS_PARM mkfs_parm = {
		.fmt = FM_FAT32,	/* FAT32 format */
		.n_fat = 1,			/* Single FAT */
		.align = 0,			/* Auto alignment */
		.n_root = 512,		/* Root directory entries */
		.au_size = 0		/* Auto cluster size */
	};
	FRESULT fr = f_mkfs(FATFS_VOLUME_PATH, &mkfs_parm, NULL, 0);
	if (fr != FR_OK) {
		log_e("Format failed: %s", translate_fr_error(fr));
		return FATFS_ERR_FLASH;
	}
	
	// log_i("Format completed successfully");
	
	/* Remount */
	return fatfs_service_init();
}

/*-----------------------------------------------------------------------*/
/* Synchronize file system                                               */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_sync(void)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	/* Sync all open files */
	for (int i = 0; i < MAX_OPEN_FILES; i++) {
		if (file_handles[i].in_use) {
			FRESULT fr = f_sync(&file_handles[i].fp);
			if (fr != FR_OK) {
				log_e("Sync failed for handle %d: %s", i, translate_fr_error(fr));
			}
		}
	}
	
	/* Sync disk */
	disk_ioctl(0, CTRL_SYNC, NULL);
	
	return FATFS_OK;
}

/*-----------------------------------------------------------------------*/
/* Move or rename a file or directory                                    */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_rename(const char *old_path, const char *new_path)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	if (!old_path || !new_path || strlen(old_path) == 0 || strlen(new_path) == 0) {
		return FATFS_ERR_PARAM;
	}
	
	/* Check if source exists */
	if (!fatfs_service_exists(old_path)) {
		log_e("Rename failed: source '%s' does not exist", old_path);
		return FATFS_ERR_NO_FILE;
	}
	
	/* Check if destination already exists */
	if (fatfs_service_exists(new_path)) {
		log_e("Rename failed: destination '%s' already exists", new_path);
		return FATFS_ERR_EXISTS;
	}
	
	/* Perform rename operation */
	FRESULT fr = f_rename(old_path, new_path);
	if (fr != FR_OK) {
		log_e("Rename '%s' to '%s' failed: %s", old_path, new_path, translate_fr_error(fr));
		
		switch (fr) {
			case FR_NO_FILE:
			case FR_NO_PATH:
				return FATFS_ERR_NO_FILE;
			case FR_EXIST:
				return FATFS_ERR_EXISTS;
			case FR_DENIED:
				return FATFS_ERR_PARAM; /* Source is read-only or destination path invalid */
			case FR_INVALID_NAME:
				return FATFS_ERR_PARAM;
			default:
				return FATFS_ERR_PARAM;
		}
	}
	
	log_i("Renamed '%s' to '%s'", old_path, new_path);
	return FATFS_OK;
}

/*-----------------------------------------------------------------------*/
/* List directory contents (array version)                               */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_listdir(const char *path, \
                                 fatfs_fileinfo_t *entries, \
                                 uint32_t max_entries, \
                                 uint32_t *count)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	if (!path || !entries || !count || max_entries == 0) {
		return FATFS_ERR_PARAM;
	}
	
	DIR dir;
	FILINFO fno;
	uint32_t entry_count = 0;
	
	/* Open directory */
	FRESULT fr = f_opendir(&dir, path);
	if (fr != FR_OK) {
		log_e("Open directory '%s' failed: %s", path, translate_fr_error(fr));
		return FATFS_ERR_NO_FILE;
	}
	
	/* Read directory entries */
	while (entry_count < max_entries) {
		fr = f_readdir(&dir, &fno);
		if (fr != FR_OK) {
			log_e("Read directory '%s' failed: %s", path, translate_fr_error(fr));
			f_closedir(&dir);
			return FATFS_ERR_PARAM;
		}
		
		/* End of directory? */
		if (fno.fname[0] == '\0') {
			break;
		}
		
		/* Skip "." and ".." entries */
		if (strcmp(fno.fname, ".") == 0 || strcmp(fno.fname, "..") == 0) {
			continue;
		}
		
		/* Fill entry information */
		fatfs_fileinfo_t *entry = &entries[entry_count];
		
		/* Build full path safely */
		char full_path[256];
		
		if (strcmp(path, "/") == 0) {
			/* Special case for root directory */
			size_t name_len = strlen(fno.fname);
			if (name_len + 2 <= sizeof(full_path)) { /* '/' + name + null */
				full_path[0] = '/';
				strcpy(full_path + 1, fno.fname);
			} else {
				/* Truncate name */
				full_path[0] = '/';
				strncpy(full_path + 1, fno.fname, sizeof(full_path) - 2);
				full_path[sizeof(full_path) - 1] = '\0';
				log_w("Name truncated in root: %s", full_path);
			}
		} else {
			/* Build path/path/name */
			size_t path_len = strlen(path);
			size_t name_len = strlen(fno.fname);
			size_t total_len = path_len + 1 + name_len; /* path + '/' + name */
			
			if (total_len + 1 <= sizeof(full_path)) { /* +1 for null terminator */
				/* Safe to concatenate */
				strcpy(full_path, path);
				full_path[path_len] = '/';
				strcpy(full_path + path_len + 1, fno.fname);
			} else {
				/* Truncate: keep as much of the name as possible */
				if (path_len + 2 <= sizeof(full_path)) {
					/* At least we can copy path and '/' */
					strncpy(full_path, path, sizeof(full_path) - 1);
					full_path[sizeof(full_path) - 1] = '\0';
					
					size_t copied_path_len = strlen(full_path);
					if (copied_path_len + 1 < sizeof(full_path)) {
						full_path[copied_path_len] = '/';
						full_path[copied_path_len + 1] = '\0';
						
						size_t available = sizeof(full_path) - copied_path_len - 2;
						if (available > 0) {
							strncat(full_path, fno.fname, available);
						}
					}
				} else {
					/* Even path alone is too long, just copy path */
					strncpy(full_path, path, sizeof(full_path) - 1);
					full_path[sizeof(full_path) - 1] = '\0';
				}
				log_w("Path truncated: %s/%s -> %s", path, fno.fname, full_path);
			}
		}
		
		/* Copy to entry->name (guaranteed to fit because both are 256 bytes) */
		strncpy(entry->name, full_path, sizeof(entry->name) - 1);
		entry->name[sizeof(entry->name) - 1] = '\0';
		entry->size = fno.fsize;
		entry->date = fno.fdate;
		entry->time = fno.ftime;
		entry->attr = fno.fattrib;
		
		entry_count++;
	}
	
	f_closedir(&dir);
	
	*count = entry_count;
	log_v("Listed directory '%s': %u entries", path, entry_count);
	return FATFS_OK;
}

/*-----------------------------------------------------------------------*/
/* Copy a file                                                           */
/*-----------------------------------------------------------------------*/
fatfs_err_t fatfs_service_copy(const char *src_path, 
                               const char *dst_path, 
                               uint32_t buffer_size)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	if (!src_path || !dst_path || strlen(src_path) == 0 || strlen(dst_path) == 0) {
		return FATFS_ERR_PARAM;
	}
	
	/* Check if source exists and is a file (not directory) */
	fatfs_fileinfo_t src_info;
	fatfs_err_t err = fatfs_service_stat(src_path, &src_info);
	if (err != FATFS_OK) {
		log_e("Copy failed: source '%s' does not exist", src_path);
		return err;
	}
	
	if (fatfs_is_directory(&src_info)) {
		log_e("Copy failed: source '%s' is a directory (use recursive copy)", src_path);
		return FATFS_ERR_PARAM;
	}
	
	/* Default buffer size 4KB (aligned with Flash block size) */
	if (buffer_size == 0) {
		buffer_size = 4096;
	}
	
	/* Allocate buffer for copying */
	uint8_t *buffer = osal_malloc(buffer_size);
	if (!buffer) {
		log_e("Copy failed: cannot allocate %u bytes buffer", buffer_size);
		return FATFS_ERR_PARAM;
	}
	
	/* Open source file for reading */
	int32_t src_fh = fatfs_service_open(src_path, FATFS_MODE_READ);
	if (src_fh < 0) {
		osal_free(buffer);
		log_e("Copy failed: cannot open source file '%s'", src_path);
		return (fatfs_err_t)src_fh;
	}
	
	/* Open destination file for writing (overwrite if exists) */
	int32_t dst_fh = fatfs_service_open(dst_path, FATFS_MODE_WRITE);
	if (dst_fh < 0) {
		fatfs_service_close(src_fh);
		osal_free(buffer);
		log_e("Copy failed: cannot create destination file '%s'", dst_path);
		return (fatfs_err_t)dst_fh;
	}
	
	/* Copy file content */
	uint32_t total_copied = 0;
	uint32_t src_size = src_info.size;
	fatfs_err_t result = FATFS_OK;
	
	while (total_copied < src_size) {
		uint32_t remaining = src_size - total_copied;
		uint32_t to_read = (remaining < buffer_size) ? remaining : buffer_size;
		
		int32_t bytes_read = fatfs_service_read(src_fh, buffer, to_read);
		if (bytes_read <= 0) {
			log_e("Copy failed: read error at offset %u", total_copied);
			result = FATFS_ERR_READ;
			break;
		}
		
		int32_t bytes_written = fatfs_service_write(dst_fh, buffer, bytes_read);
		if (bytes_written != bytes_read) {
			log_e("Copy failed: write error at offset %u", total_copied);
			result = FATFS_ERR_WRITE;
			break;
		}
		
		total_copied += bytes_read;
	}
	
	/* Close files and free buffer */
	fatfs_err_t close_err1 = fatfs_service_close(src_fh);
	fatfs_err_t close_err2 = fatfs_service_close(dst_fh);
	osal_free(buffer);
	
	if (result != FATFS_OK) {
		/* Delete partially copied destination file */
		fatfs_service_delete(dst_path);
		return result;
	}
	
	/* Check for close errors */
	if (close_err1 != FATFS_OK || close_err2 != FATFS_OK) {
		log_w("Copy completed but file close had errors");
		return FATFS_ERR_CLOSE;
	}
	
	log_i("Copied '%s' to '%s' (%u bytes)", src_path, dst_path, total_copied);
	return FATFS_OK;
}

/*-----------------------------------------------------------------------*/
/* Remove file or directory recursively                                  */
/*-----------------------------------------------------------------------*/
static fatfs_err_t remove_recursive_internal(const char *path)
{
	fatfs_fileinfo_t info;
	fatfs_err_t err = fatfs_service_stat(path, &info);
	if (err != FATFS_OK) {
		return err;
	}
	
	if (fatfs_is_directory(&info)) {
		DIR dir;
		FILINFO fno;
		
		/* Open directory */
		FRESULT fr = f_opendir(&dir, path);
		if (fr != FR_OK) {
			log_e("Open directory '%s' failed: %s", path, translate_fr_error(fr));
			return FATFS_ERR_PARAM;
		}
		
		/* Process all directory entries */
		while (1) {
			fr = f_readdir(&dir, &fno);
			if (fr != FR_OK) {
				log_e("Read directory '%s' failed: %s", path, translate_fr_error(fr));
				f_closedir(&dir);
				return FATFS_ERR_PARAM;
			}
			
			/* End of directory? */
			if (fno.fname[0] == '\0') {
				break;
			}
			
			/* Skip "." and ".." entries */
			if (strcmp(fno.fname, ".") == 0 || strcmp(fno.fname, "..") == 0) {
				continue;
			}
			
			/* Build full path of entry safely */
			char entry_path[256];
			if (strcmp(path, "/") == 0) {
				/* Root directory */
				size_t name_len = strlen(fno.fname);
				if (name_len + 2 <= sizeof(entry_path)) {
					entry_path[0] = '/';
					strcpy(entry_path + 1, fno.fname);
				} else {
					/* Truncate name */
					entry_path[0] = '/';
					strncpy(entry_path + 1, fno.fname, sizeof(entry_path) - 2);
					entry_path[sizeof(entry_path) - 1] = '\0';
					log_w("Name truncated in root: %s", entry_path);
				}
			} else {
				/* Subdirectory */
				size_t path_len = strlen(path);
				size_t name_len = strlen(fno.fname);
				size_t total_len = path_len + 1 + name_len;
				
				if (total_len + 1 <= sizeof(entry_path)) {
					strcpy(entry_path, path);
					entry_path[path_len] = '/';
					strcpy(entry_path + path_len + 1, fno.fname);
				} else {
					/* Truncate: keep as much of name as possible */
					if (path_len + 2 <= sizeof(entry_path)) {
						strncpy(entry_path, path, sizeof(entry_path) - 1);
						entry_path[sizeof(entry_path) - 1] = '\0';
						
						size_t copied_path_len = strlen(entry_path);
						if (copied_path_len + 1 < sizeof(entry_path)) {
							entry_path[copied_path_len] = '/';
							entry_path[copied_path_len + 1] = '\0';
							
							size_t available = sizeof(entry_path) - copied_path_len - 2;
							if (available > 0) {
								strncat(entry_path, fno.fname, available);
							}
						}
					} else {
						/* Even path alone is too long */
						strncpy(entry_path, path, sizeof(entry_path) - 1);
						entry_path[sizeof(entry_path) - 1] = '\0';
					}
					log_w("Path truncated in recursive delete: %s/%s -> %s", 
						  path, fno.fname, entry_path);
				}
			}
			
			/* Recursively remove entry */
			err = remove_recursive_internal(entry_path);
			if (err != FATFS_OK) {
				f_closedir(&dir);
				return err;
			}
		}
		
		f_closedir(&dir);
		
		/* Remove empty directory */
		return fatfs_service_rmdir(path);
	} else {
		/* Remove file */
		return fatfs_service_delete(path);
	}
}

fatfs_err_t fatfs_service_remove_recursive(const char *path)
{
	if (!mounted) {
		return FATFS_ERR_INIT;
	}
	
	if (!path || strlen(path) == 0) {
		return FATFS_ERR_PARAM;
	}
	
	/* Protect root directory */
	if (strcmp(path, "/") == 0 || strcmp(path, "0:/") == 0) {
		log_e("Remove recursive failed: cannot remove root directory");
		return FATFS_ERR_PARAM;
	}
	
	log_i("Removing '%s' recursively...", path);
	fatfs_err_t err = remove_recursive_internal(path);
	
	if (err == FATFS_OK) {
		log_i("Successfully removed '%s' recursively", path);
	} else {
		log_e("Failed to remove '%s' recursively: %d", path, err);
	}
	
	return err;
}


/**
 * @brief Initialize FATFS file system
 * 
 * This function initializes the FATFS service on W25Q128JV Flash.
 * It mounts the filesystem (formats if needed) and prints capacity info.
 * 
 * @return 0 on success, -1 on failure
 */
int32_t fatfs_init(void) {
    // log_i("Initializing FATFS file system...");
    
    // Initialize FATFS service
    fatfs_err_t err = fatfs_service_init();
    if (err != FATFS_OK) {
        log_e("FATFS initialization failed: %d", err);
        return -1;
    }
    // log_i("FATFS initialized successfully");
    
    // Get and display filesystem status
    uint32_t total_kb, free_kb;
    err = fatfs_service_status(&total_kb, &free_kb);
    if (err == FATFS_OK) {
        log_i("Flash capacity: %lu KB, Free: %lu KB", total_kb, free_kb);
    } else {
        log_w("Failed to get filesystem status: %d", err);
    }
    
    return 0;
}


/**
 * @brief Test advanced FATFS APIs (rename, listdir, copy, remove_recursive)
 */
static void test_fatfs_advanced_apis(void)
{
    log_i("Testing advanced FATFS APIs...");
    
    /* Test 1: Create test directory and files */
    fatfs_err_t err = fatfs_service_mkdir("/test");
    if (err != FATFS_OK && err != FATFS_ERR_EXISTS) {
        log_e("Failed to create test directory: %d", err);
        return;
    }
    
    err = fatfs_service_mkdir("/test/subdir");
    if (err != FATFS_OK && err != FATFS_ERR_EXISTS) {
        log_e("Failed to create subdirectory: %d", err);
        return;
    }
    
    /* Create a test file */
    int32_t fh = fatfs_service_open("/test/file1.txt", FATFS_MODE_WRITE);
    if (fh < 0) {
        log_e("Failed to create test file: %d", fh);
        return;
    }
    
    const char *test_data = "Hello, FATFS! This is test data for advanced API testing.";
    int32_t written = fatfs_service_write(fh, test_data, strlen(test_data));
    if (written != (int32_t)strlen(test_data)) {
        log_e("Failed to write test data: wrote %d of %zu bytes", written, strlen(test_data));
        fatfs_service_close(fh);
        return;
    }
    
    fatfs_service_close(fh);
    log_i("Created test structure: /test/subdir/, /test/file1.txt");
    
    /* Test 2: listdir - list contents of /test */
    fatfs_fileinfo_t entries[16];
    uint32_t count = 0;
    err = fatfs_service_listdir("/test", entries, 16, &count);
    if (err != FATFS_OK) {
        log_e("listdir failed: %d", err);
    } else {
        log_i("listdir found %u entries in /test:", count);
        for (uint32_t i = 0; i < count; i++) {
            log_i("  [%u] %s (%s, %u bytes)", i, entries[i].name,
                  fatfs_is_directory(&entries[i]) ? "DIR" : "FILE", entries[i].size);
        }
    }
    
    /* Test 3: rename - move file1.txt to file2.txt */
    err = fatfs_service_rename("/test/file1.txt", "/test/file2.txt");
    if (err != FATFS_OK) {
        log_e("rename failed: %d", err);
    } else {
        log_i("rename successful: file1.txt -> file2.txt");
        
        /* Verify rename worked */
        if (fatfs_service_exists("/test/file1.txt")) {
            log_e("rename verification failed: source still exists");
        }
        if (!fatfs_service_exists("/test/file2.txt")) {
            log_e("rename verification failed: destination doesn't exist");
        }
    }
    
    /* Test 4: copy - copy file2.txt to file3.txt */
    err = fatfs_service_copy("/test/file2.txt", "/test/file3.txt", 0); /* 0 = default 4KB buffer */
    if (err != FATFS_OK) {
        log_e("copy failed: %d", err);
    } else {
        log_i("copy successful: file2.txt -> file3.txt");
        
        /* Verify copy worked */
        fatfs_fileinfo_t src_info, dst_info;
        if (fatfs_service_stat("/test/file2.txt", &src_info) == FATFS_OK &&
            fatfs_service_stat("/test/file3.txt", &dst_info) == FATFS_OK) {
            if (src_info.size == dst_info.size) {
                log_i("copy verification: both files have same size (%u bytes)", src_info.size);
            } else {
                log_e("copy verification failed: sizes differ (%u vs %u)", 
                      src_info.size, dst_info.size);
            }
        }
    }
    
    /* Test 5: remove_recursive - remove /test/subdir (empty) */
    err = fatfs_service_remove_recursive("/test/subdir");
    if (err != FATFS_OK) {
        log_e("remove_recursive (empty dir) failed: %d", err);
    } else {
        log_i("remove_recursive successful: /test/subdir removed");
        
        /* Verify removal */
        if (fatfs_service_exists("/test/subdir")) {
            log_e("remove_recursive verification failed: directory still exists");
        }
    }
    
    /* Test 6: Create more files for recursive delete test */
    /* First create the deep directory */
    err = fatfs_service_mkdir("/test/deep");
    if (err != FATFS_OK && err != FATFS_ERR_EXISTS) {
        log_e("Failed to create /test/deep directory: %d", err);
    } else {
        log_i("Created /test/deep directory for nested file test");
    }
    
    /* Create files in the deep directory */
    fh = fatfs_service_open("/test/deep/fileA.txt", FATFS_MODE_WRITE);
    if (fh >= 0) {
        fatfs_service_write(fh, "File A", 6);
        fatfs_service_close(fh);
        log_i("Created /test/deep/fileA.txt");
    } else {
        log_e("Failed to create /test/deep/fileA.txt: %d", fh);
    }
    
    fh = fatfs_service_open("/test/deep/fileB.txt", FATFS_MODE_WRITE);
    if (fh >= 0) {
        fatfs_service_write(fh, "File B", 6);
        fatfs_service_close(fh);
        log_i("Created /test/deep/fileB.txt");
    } else {
        log_e("Failed to create /test/deep/fileB.txt: %d", fh);
    }
    
    /* Test 7: remove_recursive - remove /test (non-empty) */
    err = fatfs_service_remove_recursive("/test");
    if (err != FATFS_OK) {
        log_e("remove_recursive (non-empty dir) failed: %d", err);
    } else {
        log_i("remove_recursive successful: /test and all contents removed");
        
        /* Verify removal */
        if (fatfs_service_exists("/test")) {
            log_e("remove_recursive verification failed: /test still exists");
        }
    }
    
    /* Test 8: Protect root directory */
    err = fatfs_service_remove_recursive("/");
    if (err == FATFS_ERR_PARAM) {
        log_i("Root directory protection works correctly (expected error: %d)", err);
    } else {
        log_e("Root directory protection failed: got %d, expected FATFS_ERR_PARAM", err);
    }
    
    log_i("Advanced FATFS API testing completed");
}