#!/usr/bin/env bash
set -euo pipefail

# Build os05a20.ko against the TI kernel build used by Yocto
# Usage: ./build-module.sh [KDIR]
# If KDIR is omitted, it will be auto-detected from the Yocto build tree.

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

if [[ $# -ge 1 ]]; then
  KDIR="$1"
else
  # Auto-detect the kernel build directory
  # Prefer GLIBC tmpdir
  guess=$(ls -d /home/tisdk/tisdk/build/arago-tmp-default-glibc/work/j722s_evm-oe-linux/linux-ti-staging/*/build 2>/dev/null | head -n1 || true)
  if [[ -z "${guess}" ]]; then
    # Fallback to any k3r5/baremetal or other tmp dirs
    guess=$(ls -d /home/tisdk/tisdk/build/arago-tmp-*/work/*-linux/linux-ti-staging/*/build 2>/dev/null | head -n1 || true)
  fi
  if [[ -z "${guess}" ]]; then
    echo "Error: could not auto-detect kernel build directory. Pass it explicitly as:"
    echo "  $0 /path/to/kernel/build"
    exit 1
  fi
  KDIR="${guess}"
fi

echo "Using KDIR=${KDIR}"
if [[ ! -f "${KDIR}/Module.symvers" ]]; then
  echo "Warning: ${KDIR}/Module.symvers not found. Ensure the kernel has been built (bitbake virtual/kernel)."
fi

# Try to use Yocto cross-compiler to match kernel toolchain if available
YOCTO_CC_ROOT="/home/tisdk/tisdk/build/arago-tmp-default-glibc/work/j722s_evm-oe-linux/os05a20/1.0/recipe-sysroot-native/usr/bin"
if [[ -d "${YOCTO_CC_ROOT}/aarch64-oe-linux" ]]; then
  export PATH="${YOCTO_CC_ROOT}/aarch64-oe-linux:${YOCTO_CC_ROOT}:$PATH"
  export CROSS_COMPILE="aarch64-oe-linux-"
  echo "Using Yocto cross-compiler from ${YOCTO_CC_ROOT}/aarch64-oe-linux"
fi

# Prefer building the external module via kernel source with O=<build> like Yocto
KERNEL_SRC_DIR="/home/tisdk/tisdk/build/arago-tmp-default-glibc/work-shared/j722s-evm/kernel-source"
if [[ -d "${KERNEL_SRC_DIR}" ]]; then
  echo "Building via KERNEL_SRC=${KERNEL_SRC_DIR} O=${KDIR}"
  make -C "${KERNEL_SRC_DIR}" O="${KDIR}" M="${SCRIPT_DIR}" ARCH=arm64 CROSS_COMPILE="${CROSS_COMPILE:-}" modules
else
  echo "Kernel source dir not found at ${KERNEL_SRC_DIR}, falling back to -C KDIR"
  make -C "${KDIR}" M="${SCRIPT_DIR}" ARCH=arm64 CROSS_COMPILE="${CROSS_COMPILE:-}" modules
fi

echo "\nBuilt module: ${SCRIPT_DIR}/os05a20.ko"
file "${SCRIPT_DIR}/os05a20.ko" || true
