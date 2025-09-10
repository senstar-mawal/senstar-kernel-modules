// SPDX-License-Identifier: GPL-2.0-only WITH Linux-syscall-note
#pragma once

#include <linux/ioctl.h>
#include <stdint.h>

struct senstar_r5_rw32 {
    uint64_t phys;
    uint32_t value;
};

#define SENSTAR_R5_IOC_MAGIC      'S'
#define SENSTAR_R5_IOC_READ32     _IOWR(SENSTAR_R5_IOC_MAGIC, 0, struct senstar_r5_rw32)
#define SENSTAR_R5_IOC_WRITE32    _IOW(SENSTAR_R5_IOC_MAGIC,  1, struct senstar_r5_rw32)
