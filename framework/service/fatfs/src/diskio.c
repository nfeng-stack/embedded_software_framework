/*-----------------------------------------------------------------------*/
/* Low level disk I/O module for W25Q128JV SPI Flash                    */
/*-----------------------------------------------------------------------*/

#define LOG_TAG "fatfs_disk"
#include <string.h>
#include "ff.h"			/* Basic definitions of FatFs */
#include "diskio.h"		/* Declarations FatFs MAI */
#include "driver_w25qxx.h"		/* W25QXX constants */
#include "driver_w25qxx_advance.h"	/* W25QXX advanced API */
#include "elog.h"	/* Logging */
#include "osal.h"		/* OS abstraction */

/* External flag indicating MSC callback is active (from msc_disk.c) */
extern bool msc_callback_active;

/* W25Q128JV Specifications */
#define W25Q128_CAPACITY_BYTES		(16UL * 1024UL * 1024UL)	/* 16 MB */
#define W25Q128_SECTOR_SIZE		512							/* FATFS sector size */
#define W25Q128_SECTOR_COUNT		(W25Q128_CAPACITY_BYTES / W25Q128_SECTOR_SIZE)	/* 32768 */
#define W25Q128_ERASE_SIZE		4096						/* 4 KB erase block */
#define W25Q128_SECTORS_PER_BLOCK	(W25Q128_ERASE_SIZE / W25Q128_SECTOR_SIZE)	/* 8 */

/* Cache configuration */
#define CACHE_BLOCK_COUNT		2							/* Number of cache blocks */
#define CACHE_BLOCK_SIZE		W25Q128_ERASE_SIZE			/* 4 KB per cache block */

/* Cache block structure */
typedef struct {
	uint32_t block_addr;			/* Physical block address (aligned to 4KB) */
	uint8_t dirty;				/* Dirty flag (needs to be written back) */
	uint8_t valid;				/* Valid flag (data is loaded) */
	uint8_t lru_counter;			/* LRU counter (higher = more recently used) */
	uint8_t data[CACHE_BLOCK_SIZE];	/* Cache data */
} cache_block_t;

/* Cache management */
static cache_block_t cache[CACHE_BLOCK_COUNT];
static uint8_t cache_initialized = 0;
static uint32_t cache_hits = 0;
static uint32_t cache_misses = 0;

/* Flash status */
static uint8_t flash_initialized = 0;
static uint8_t flash_status = STA_NOINIT;

/* Disk access control */
static osal_mutex_t disk_mutex = NULL;
static uint8_t disk_locked = 0;  /* 1 = locked by USB host, 0 = free */

/* Forward declarations */
static uint8_t wait_flash_ready(void);
static int cache_find_block(uint32_t block_addr);
static int cache_alloc_block(uint32_t block_addr);
static void cache_flush_block(int cache_idx);
static void cache_flush_all(void);
static int disk_check_lock(void);

/* Disk access control functions */
int disk_set_access_lock(bool lock);

/*-----------------------------------------------------------------------*/
/* Wait for Flash operation to complete                                  */
/*-----------------------------------------------------------------------*/
static uint8_t wait_flash_ready(void)
{
	uint8_t status;
	uint32_t timeout = 10000; /* 10 seconds timeout */
	
	while (timeout--) {
		if (w25qxx_advance_get_status1(&status) != 0) {
			return 1; /* Error reading status */
		}
		
		if (!(status & W25QXX_STATUS1_ERASE_WRITE_PROGRESS)) {
			return 0; /* Ready */
		}
		
		osal_task_delay(1); /* Delay 1 ms */
	}
	
	log_e("Flash operation timeout");
	return 1; /* Timeout */
}

/*-----------------------------------------------------------------------*/
/* Find cache block by address                                           */
/*-----------------------------------------------------------------------*/
static int cache_find_block(uint32_t block_addr)
{
	for (int i = 0; i < CACHE_BLOCK_COUNT; i++) {
		if (cache[i].valid && cache[i].block_addr == block_addr) {
			/* Update LRU counter */
			for (int j = 0; j < CACHE_BLOCK_COUNT; j++) {
				if (cache[j].valid && cache[j].lru_counter > cache[i].lru_counter) {
					cache[j].lru_counter--;
				}
			}
			cache[i].lru_counter = CACHE_BLOCK_COUNT - 1;
			cache_hits++;
			return i;
		}
	}
	
	cache_misses++;
	return -1; /* Not found */
}

/*-----------------------------------------------------------------------*/
/* Allocate cache block (LRU replacement)                                */
/*-----------------------------------------------------------------------*/
static int cache_alloc_block(uint32_t block_addr)
{
	int lru_idx = -1;
	uint8_t min_lru = 0xFF;
	
	/* Find LRU block */
	for (int i = 0; i < CACHE_BLOCK_COUNT; i++) {
		if (!cache[i].valid) {
			/* Found empty slot */
			lru_idx = i;
			break;
		}
		
		if (cache[i].lru_counter < min_lru) {
			min_lru = cache[i].lru_counter;
			lru_idx = i;
		}
	}
	
	if (lru_idx == -1) {
		log_e("Cache allocation failed");
		return -1;
	}
	
	/* Flush if dirty */
	if (cache[lru_idx].valid && cache[lru_idx].dirty) {
		cache_flush_block(lru_idx);
	}
	
	/* Initialize new block */
	cache[lru_idx].block_addr = block_addr;
	cache[lru_idx].dirty = 0;
	cache[lru_idx].valid = 1;
	
	/* Update LRU counters */
	for (int i = 0; i < CACHE_BLOCK_COUNT; i++) {
		if (cache[i].valid && i != lru_idx) {
			if (cache[i].lru_counter > 0) {
				cache[i].lru_counter--;
			}
		}
	}
	cache[lru_idx].lru_counter = CACHE_BLOCK_COUNT - 1;
	
	return lru_idx;
}

/*-----------------------------------------------------------------------*/
/* Flush cache block to Flash                                            */
/*-----------------------------------------------------------------------*/
static void cache_flush_block(int cache_idx)
{
	if (!cache[cache_idx].valid || !cache[cache_idx].dirty) {
		return;
	}
	
	uint32_t block_addr = cache[cache_idx].block_addr;
	uint8_t *data = cache[cache_idx].data;
	
	
	/* Erase the 4KB block */
	if (w25qxx_advance_sector_erase_4k(block_addr) != 0) {
		log_e("Block erase failed at 0x%08X", block_addr);
		return;
	}
	
	if (wait_flash_ready() != 0) {
		log_e("Erase timeout at 0x%08X", block_addr);
		return;
	}
	
	/* Write data in 256-byte pages */
	for (uint32_t offset = 0; offset < CACHE_BLOCK_SIZE; offset += 256) {
		uint16_t write_len = (CACHE_BLOCK_SIZE - offset) < 256 ? 
							(CACHE_BLOCK_SIZE - offset) : 256;
		
		if (w25qxx_advance_only_spi_page_program_quad_input(
				block_addr + offset, 
				data + offset, 
				write_len) != 0) {
			log_e("Page program failed at 0x%08X", block_addr + offset);
			return;
		}
		
		if (wait_flash_ready() != 0) {
			log_e("Program timeout at 0x%08X", block_addr + offset);
			return;
		}
	}
	
	cache[cache_idx].dirty = 0;
}

/*-----------------------------------------------------------------------*/
/* Flush all dirty cache blocks                                          */
/*-----------------------------------------------------------------------*/
static void cache_flush_all(void)
{
	for (int i = 0; i < CACHE_BLOCK_COUNT; i++) {
		if (cache[i].valid && cache[i].dirty) {
			cache_flush_block(i);
		}
	}
}

/*-----------------------------------------------------------------------*/
/* Initialize cache                                                      */
/*-----------------------------------------------------------------------*/
static void cache_init(void)
{
	for (int i = 0; i < CACHE_BLOCK_COUNT; i++) {
		cache[i].valid = 0;
		cache[i].dirty = 0;
		cache[i].lru_counter = 0;
	}
	
	cache_hits = 0;
	cache_misses = 0;
	cache_initialized = 1;
	
	// log_i("Cache initialized: %d blocks of %d KB each", 
	// 	  CACHE_BLOCK_COUNT, CACHE_BLOCK_SIZE / 1024);
}

/*-----------------------------------------------------------------------*/
/* Get Drive Status                                                      */
/*-----------------------------------------------------------------------*/
DSTATUS disk_status(BYTE pdrv)
{
	(void)pdrv; /* Only one drive */
	
	if (!flash_initialized) {
		return STA_NOINIT;
	}
	
	return flash_status;
}

/*-----------------------------------------------------------------------*/
/* Initialize a Drive                                                    */
/*-----------------------------------------------------------------------*/
DSTATUS disk_initialize(BYTE pdrv)
{
	(void)pdrv; /* Only one drive */
	
	if (flash_initialized) {
		return flash_status;
	}
	
	// log_i("Initializing W25Q128JV Flash...");
	
	/* Initialize Flash with Quad SPI enabled */
	if (w25qxx_advance_init(W25Q128, W25QXX_INTERFACE_SPI, W25QXX_BOOL_TRUE) != 0) {
		log_e("Flash initialization failed");
		flash_status = STA_NOINIT;
		return flash_status;
	}
	
	/* Check if Flash is ready */
	uint8_t status;
	if (w25qxx_advance_get_status1(&status) != 0) {
		log_e("Failed to read Flash status");
		flash_status = STA_NOINIT;
		return flash_status;
	}
	
	/* Initialize cache */
	cache_init();
	
	/* Create disk access mutex */
	disk_mutex = osal_mutex_create("disk_mutex", 0);
	if (disk_mutex == NULL) {
		log_e("Failed to create disk mutex");
		flash_status = STA_NOINIT;
		return flash_status;
	}
	
	flash_initialized = 1;
	flash_status = 0; /* Clear all status bits */
	
	// log_i("Flash initialized successfully");
	log_i("Capacity: %d MB, Sectors: %d, Sector size: %d", 
		  W25Q128_CAPACITY_BYTES / (1024 * 1024),
		  W25Q128_SECTOR_COUNT,
		  W25Q128_SECTOR_SIZE);
	
	return flash_status;
}

/*-----------------------------------------------------------------------*/
/* Read Sector(s)                                                        */
/*-----------------------------------------------------------------------*/
DRESULT disk_read(BYTE pdrv, BYTE *buff, LBA_t sector, UINT count)
{
	(void)pdrv; /* Only one drive */
	
	if (!flash_initialized) {
		return RES_NOTRDY;
	}
	
	/* Check if disk is locked by USB host */
	DRESULT lock_res = disk_check_lock();
	if (lock_res != RES_OK) {
		return lock_res;
	}
	
	if (sector + count > W25Q128_SECTOR_COUNT) {
		log_e("Read beyond capacity: sector=%lu, count=%u", sector, count);
		return RES_PARERR;
	}
	
	/* Process each sector */
	for (UINT i = 0; i < count; i++) {
		LBA_t current_sector = sector + i;
		uint32_t sector_addr = current_sector * W25Q128_SECTOR_SIZE;
		uint32_t block_addr = sector_addr & ~(CACHE_BLOCK_SIZE - 1);
		uint32_t block_offset = sector_addr & (CACHE_BLOCK_SIZE - 1);
		
		/* Find or load cache block */
		int cache_idx = cache_find_block(block_addr);
		if (cache_idx < 0) {
			/* Cache miss, load block from Flash */
			cache_idx = cache_alloc_block(block_addr);
			if (cache_idx < 0) {
				log_e("Cache allocation failed for block 0x%08X", block_addr);
				return RES_ERROR;
			}
			
			/* Read entire 4KB block using Quad I/O */
			if (w25qxx_advance_only_spi_fast_read_quad_io(
					block_addr, 
					cache[cache_idx].data, 
					CACHE_BLOCK_SIZE) != 0) {
				log_e("Flash read failed at 0x%08X", block_addr);
				cache[cache_idx].valid = 0;
				return RES_ERROR;
			}
		}
		
		/* Copy data from cache */
		uint8_t *src = cache[cache_idx].data + block_offset;
		uint8_t *dst = buff + (i * W25Q128_SECTOR_SIZE);
		memcpy(dst, src, W25Q128_SECTOR_SIZE);
	}
	
	return RES_OK;
}

/*-----------------------------------------------------------------------*/
/* Write Sector(s)                                                       */
/*-----------------------------------------------------------------------*/
#if FF_FS_READONLY == 0
DRESULT disk_write(BYTE pdrv, const BYTE *buff, LBA_t sector, UINT count)
{
	(void)pdrv; /* Only one drive */
	
	if (!flash_initialized) {
		return RES_NOTRDY;
	}
	
	/* Check if disk is locked by USB host */
	DRESULT lock_res = disk_check_lock();
	if (lock_res != RES_OK) {
		return lock_res;
	}
	
	if (sector + count > W25Q128_SECTOR_COUNT) {
		log_e("Write beyond capacity: sector=%lu, count=%u", sector, count);
		return RES_PARERR;
	}
	
	/* Process each sector */
	for (UINT i = 0; i < count; i++) {
		LBA_t current_sector = sector + i;
		uint32_t sector_addr = current_sector * W25Q128_SECTOR_SIZE;
		uint32_t block_addr = sector_addr & ~(CACHE_BLOCK_SIZE - 1);
		uint32_t block_offset = sector_addr & (CACHE_BLOCK_SIZE - 1);
		
		/* Find or load cache block */
		int cache_idx = cache_find_block(block_addr);
		if (cache_idx < 0) {
			/* Cache miss, load block from Flash */
			cache_idx = cache_alloc_block(block_addr);
			if (cache_idx < 0) {
				log_e("Cache allocation failed for block 0x%08X", block_addr);
				return RES_ERROR;
			}
			
			/* Read entire 4KB block using Quad I/O */
			if (w25qxx_advance_only_spi_fast_read_quad_io(
					block_addr, 
					cache[cache_idx].data, 
					CACHE_BLOCK_SIZE) != 0) {
				log_e("Flash read failed at 0x%08X", block_addr);
				cache[cache_idx].valid = 0;
				return RES_ERROR;
			}
		}
		
		/* Copy data to cache and mark dirty */
		uint8_t *dst = cache[cache_idx].data + block_offset;
		const uint8_t *src = buff + (i * W25Q128_SECTOR_SIZE);
		memcpy(dst, src, W25Q128_SECTOR_SIZE);
		cache[cache_idx].dirty = 1;
	}
	
	return RES_OK;
}
#endif /* FF_FS_READONLY == 0 */

/*-----------------------------------------------------------------------*/
/* Miscellaneous Functions                                               */
/*-----------------------------------------------------------------------*/
DRESULT disk_ioctl(BYTE pdrv, BYTE cmd, void *buff)
{
	(void)pdrv; /* Only one drive */
	
	if (!flash_initialized) {
		return RES_NOTRDY;
	}
	
	switch (cmd) {
		case CTRL_SYNC:
			/* Flush all dirty cache blocks */
			cache_flush_all();
			return RES_OK;
			
		case GET_SECTOR_COUNT:
			*(LBA_t*)buff = W25Q128_SECTOR_COUNT;
			return RES_OK;
			
		case GET_SECTOR_SIZE:
			*(WORD*)buff = W25Q128_SECTOR_SIZE;
			return RES_OK;
			
		case GET_BLOCK_SIZE:
			*(DWORD*)buff = W25Q128_SECTORS_PER_BLOCK;
			return RES_OK;
			
		default:
			return RES_PARERR;
	}
}

/*-----------------------------------------------------------------------*/
/* Get current time for file timestamp (dummy implementation)            */
/*-----------------------------------------------------------------------*/
#if !FF_FS_NORTC
DWORD get_fattime(void)
{
	/* Return fixed timestamp: 2025-01-01 00:00:00 */
	return ((2025 - 1980) << 25) |	/* Year from 1980 */
		   (1 << 21) |				/* Month: January */
		   (1 << 16) |				/* Day: 1st */
		   (0 << 11) |				/* Hour: 0 */
		   (0 << 5) |				/* Minute: 0 */
		   (0 >> 1);				/* Second/2: 0 */
}
#endif

/*-----------------------------------------------------------------------*/
/* Set disk access lock (called when USB host connects/disconnects)      */
/*-----------------------------------------------------------------------*/
int disk_set_access_lock(bool lock)
{
    if (!flash_initialized) {
        return RES_NOTRDY;
    }
    
    if (lock) {
        /* Lock disk for USB host access */
        if (osal_mutex_take(disk_mutex, 0) != 0) {
            return RES_ERROR; /* Already locked or error */
        }
        /* Flush any pending cache writes before USB host accesses */
        cache_flush_all();
        disk_locked = 1;
    } else {
        /* Unlock disk for microcontroller access */
        disk_locked = 0;
        if (osal_mutex_release(disk_mutex) != 0) {
            return RES_ERROR;
        }
    }
    
    return RES_OK;
}

/*-----------------------------------------------------------------------*/
/* Internal function to check if disk is locked by USB host              */
/*-----------------------------------------------------------------------*/
static int disk_check_lock(void)
{
    if (disk_locked) {
        /* Disk is locked by USB host - only USB MSC callbacks can access */
        if (msc_callback_active) {
            /* MSC callback is active, allow access */
            return RES_OK;
        }
        /* Other tasks trying to access disk while USB host is connected */
        return RES_NOTRDY;
    }
    return RES_OK;
}