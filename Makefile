# Simple umbrella Makefile to build all external modules in this tree

KDIR ?= $(KERNEL_DIR)
KDIR ?= $(KERNEL_SRC)
KDIR ?= /lib/modules/$(shell uname -r)/build

PWD := $(shell pwd)

obj-m += os05a20.o
obj-m += drivers/misc/senstar_r5_shmem/senstar_r5_shmem.o

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
obj-m += os05a20.o
os05a20-y := drivers/media/i2c/os05a20.o

all:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) clean
