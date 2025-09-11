# Simple umbrella Makefile to build all external modules in this tree

# Prefer KERNEL_SRC/KERNEL_DIR from environment (Yocto), fallback to running kernel headers
KDIR ?= $(KERNEL_DIR)
KDIR ?= $(KERNEL_SRC)
KDIR ?= /lib/modules/$(shell uname -r)/build

PWD := $(shell pwd)

# Module objects
obj-m += os05a20.o
obj-m += imx708.o

# Multi-file objects
os05a20-y := drivers/media/i2c/os05a20.o
imx708-y := drivers/media/i2c/imx708.o

# Only build the shmem helper if sources are present
ifneq ($(wildcard drivers/misc/senstar_r5_shmem/senstar_r5_shmem.c),)
obj-m += drivers/misc/senstar_r5_shmem/senstar_r5_shmem.o
endif

# Map legacy/media-next symbol to TI kernel headers without touching sources
EXTRA_CFLAGS += -DMEDIA_BUS_FMT_SENSOR_DATA=MEDIA_BUS_FMT_META_8

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
