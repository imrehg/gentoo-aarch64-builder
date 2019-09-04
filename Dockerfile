## Based on https://wiki.gentoo.org/wiki/User:NeddySeagoon/Raspberry_Pi4_64_Bit_Install
## and https://wiki.gentoo.org/wiki/Raspberry_Pi_3_64_bit_Install

FROM gentoo/stage3-amd64

# Update the package database
RUN emerge --sync
# Cross-compiler tool chain
RUN emerge sys-devel/crossdev
# Build the cross-compiler
RUN crossdev -t aarch64-unknown-linux-gnu --ov-output /var/db/repos/gentoo
## Build other reqired tools
# Git (for pulling code in later builds)
RUN emerge dev-vcs/git
# Required by the kernel
RUN emerge sys-devel/bc
