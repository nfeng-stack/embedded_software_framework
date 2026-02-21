# RT-Thread Source Makefile
# Build RT-Thread kernel sources

obj-y += thread.o
obj-y += components.o
obj-y += slab.o
obj-y += timer.o
obj-y += object.o
obj-y += irq.o
obj-y += cpu.o
obj-y += kservice.o
obj-y += mem.o
obj-y += mempool.o
obj-y += clock.o
obj-y += device.o
obj-y += memheap.o
obj-y += signal.o
obj-y += ipc.o
obj-y += scheduler.o
obj-y += idle.o
obj-y += board.o

# RT-Thread source specific flags
EXTRA_CFLAGS += -DRT_THREAD_KERNEL

# Include local configuration if exists
-include local.mk