#!/usr/bin/env bash

RPI_VERSION=${RPI_VERSION:=4}
BUILD_DIR="/build"

case $RPI_VERSION in
    3) echo "Targeting Raspberry Pi version: 3"
       defconfig="bcmrpi3_defconfig"
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
    4) echo "Targeting Raspberry Pi version: 4"
       defconfig="bcm2711_defconfig"
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
    *) echo "Unknown or empty RPI_VERSION value, bailing"
      #  exit 1
esac

echo "Cleaning up build directory."
rm -rf "${BUILD_DIR:?}/"*

### Firmware
echo "Installing boot firmware"
for bootfile in "${bootfiles[@]}"; do
    install -D "firmware/boot/${bootfile}" "${BUILD_DIR}/boot/${bootfile}"
done
echo "Installing device tree overlays"
pushd firmware/boot/overlays/ || exit
for overlayfile in *; do
   install -D -m755 "${overlayfile}" "${BUILD_DIR}/boot/overlays/${overlayfile}"
done
popd || exit

### Kernel
echo "Compiling kernel from ${defconfig}"
pushd linux || exit
export ARCH=arm64
export CROSS_COMPILE=aarch64-unknown-linux-gnu-
make "${defconfig}"
make -j$(nproc)
install -D -m755 ./arch/arm64/boot/Image "${BUILD_DIR}/boot/kernel8.img"

### Modules
echo "Installing modules"
make modules_install INSTALL_MOD_PATH="${BUILD_DIR}"

### Place compiled dtb files
echo "Copying dtb files"
for dtb_file in "${dtb[@]}"; do
   install -D -m755 "./arch/arm64/boot/dts/broadcom/${dtb_file}" "${BUILD_DIR}/boot/${dtb_file}"
done

popd || exit

## Armstub only needed for Raspberry Pi 4
if [[ $RPI_VERSION == 4 ]]; then
   echo "Installing armstub"
   pushd tools/armstubs || exit
   make CC8=aarch64-unknown-linux-gnu-gcc \
      LD8=aarch64-unknown-linux-gnu-ld \
      OBJCOPY8=aarch64-unknown-linux-gnu-objcopy \
      OBJDUMP8=aarch64-unknown-linux-gnu-objdump \
      armstub8-gic.bin
   install -m755 armstub8-gic.bin "${BUILD_DIR}/boot/"
   popd || exit
fi
echo "Finished."
