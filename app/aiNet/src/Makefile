ifeq ($(findstring -DLIVE_TEST_MODE,$(C_DEFS)),-DLIVE_TEST_MODE)
obj-y += ai_live_test.o
else
obj-y += app_x-cube-ai.o
obj-y += network_data_params.o
obj-y += network_data.o
obj-y += network.o
obj-y += ai_task.o
obj-y += ai_benchmark.o
EXTRA_CFLAGS += -IAI/Inc
endif
EXTRA_CFLAGS += -Iapp/aiNet/inc