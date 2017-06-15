#!/bin/bash
if [ "$1" == "install" ]; then
	# install ubuntu programms
	apt install git bc unzip bc bison build-essential curl flex g++-multilib gcc-multilib git gnupg gperf lib32ncurses5-dev lib32z1-dev libesd0-dev liblz4-tool libncurses5-dev libsdl1.2-dev libxml2 libxml2-utils lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev imagemagick lib32readline6-dev -y

	# install android build tools
	if [[ ! -d "./tools/aarch64-linux-android-4.9" ]]; then
		git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 /tools/aarch64-linux-android-4.9
	fi

	# install kernel
	if [[ ! -d "./kernel" ]]; then
		unzip kernel.zip
	fi

	# install AIK-Kitchen
	if [[ ! -d "./tools/AIK-Linux" ]]; then
		unzip ./tools/AIK-Linux.zip -d ./tools/AIK-Linux
	fi

	# install default Mate9Kernel
	if [[ ! -f "./tools/AIK-Linux/boot.img" ]]; then
		cp ./stock_kernel/B182.img ./tools/AIK-Linux/AIK-Linux/boot.img
	fi
fi

if [ "$1" == "build" ]; then
	export PATH=$PATH:$(pwd)/tools/aarch64-linux-android-4.9/bin
	export CROSS_COMPILE=$(pwd)/tools/aarch64-linux-android-4.9/bin/aarch64-linux-android-

	if [[ -d "./out" ]]; then
		rm -rf out
	else
		mkdir -p out
	fi

	cd kernel

	echo "Start building merge"
	make ARCH=arm64 O=../out merge_hi3660_defconfig

	echo "Start building j8"
	make ARCH=arm64 O=../out -j8

	cd ..

	if [[ -f "./out/arch/arm64/boot/Image.gz" ]]; then
		cp ./out/arch/arm64/boot/Image.gz ./tools/AIK-Linux/boot.img-zImage
	fi
fi