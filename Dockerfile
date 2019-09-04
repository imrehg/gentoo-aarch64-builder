## Based on https://wiki.gentoo.org/wiki/User:NeddySeagoon/Raspberry_Pi4_64_Bit_Install
## and https://wiki.gentoo.org/wiki/Raspberry_Pi_3_64_bit_Install

FROM gentoo/stage3-amd64:20190903

# Update the package database
RUN emerge --sync
# Cross-compiler tool chain
RUN emerge sys-devel/crossdev

# 
RUN crossdev -t aarch64-unknown-linux-gnu --ov-output /var/db/repos/gentoo

# 
RUN emerge dev-vcs/git
RUN emerge sys-devel/bc

#
# git clone -b 1.20190819 --depth=1 https://github.com/raspberrypi/firmware
# git clone -b raspberrypi-kernel_1.20190819-1 --depth=1 https://github.com/raspberrypi/linux
