#!/usr/bin/env bash

RPI_VERSION=${RPI_VERSION:=4}
BUILD_DIR="/build"

case $RPI_VERSION in
    3) defconfig="bcmrpi3_defconfig"
       dtb=('bcm2710-rpi-3-b-plus.dtb'
            'bcm2710-rpi-3-b.dtb'
            'bcm2710-rpi-cm3.dtb'
           )
       bootfiles=('start.elf'
                  'start_x.elf'
                  'start_cd.elf'
                  'start_db.elf'
                  'bootcode.bin'
                  'fixup.dat'
                  'fixup_x.dat'
                  'fixup_cd.dat'
                  'fixup_db.dat'
                  'COPYING.linux'
                  'LICENCE.broadcom'
                  )
       ;;
    4) defconfig="bcm2711_defconfig"
       dtb=('bcm2711-rpi-4-b.dtb')
       bootfiles=('start.elf'
                  'start4x.elf'
                  'start4cd.elf'
                  'start4db.elf'
                  'fixup.dat'
                  'fixup4x.dat'
                  'fixup4cd.dat'
                  'fixup4db.dat'
                  'COPYING.linux'
                  'LICENCE.broadcom'
                  )
        ;;
    *) echo "Unknown RPI_VERSION value, bailing"
       exit 1
esac

## Install boot firmware
for bootfile in "${bootfiles[@]}"; do
    install -D "firmware/boot/${bootfile}" "${BUILD_DIR}/boot/${bootfile}"
done

## Compile the kernel
cd linux || exit
export ARCH=arm64
export CROSS_COMPILE=aarch64-unknown-linux-gnu-
make "${defconfig}"
make

install -D -m644 arch/arm64/boot/Image "${BUILD_DIR}/boot/kernel8.img"
make modules_install INSTALL_MOD_PATH="${BUILD_DIR}"