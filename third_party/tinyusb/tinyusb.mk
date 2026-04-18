# C source files
TINYUSB_SRC_C += \
	tusb.c \
	common/tusb_fifo.c \
	device/usbd.c \
	device/usbd_control.c \
	typec/usbc.c \
	class/audio/audio_device.c \
	class/cdc/cdc_device.c \
	class/dfu/dfu_device.c \
	class/dfu/dfu_rt_device.c \
	class/hid/hid_device.c \
	class/midi/midi_device.c \
	class/msc/msc_device.c \
	class/mtp/mtp_device.c \
	class/net/ecm_rndis_device.c \
	class/net/ncm_device.c \
	class/printer/printer_device.c \
	class/usbtmc/usbtmc_device.c \
	class/video/video_device.c \
	class/vendor/vendor_device.c \
  host/usbh.c \
  host/hub.c \
  class/cdc/cdc_host.c \
  class/hid/hid_host.c \
  class/midi/midi_host.c \
  class/msc/msc_host.c \
  class/vendor/vendor_host.c \
