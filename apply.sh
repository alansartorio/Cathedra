#!/bin/bash

SCRIPT_PATH=$(realpath $0)
CATHEDRA_PATH=$(dirname $SCRIPT_PATH)
PATCH_TYPE=$1
BASE_BUILD_DIR=$(pwd)

case "$PATCH_TYPE" in
	dcos | dcosx) echo "[i] Applying patches for $PATCH_TYPE" ;;
	*) echo "[e] $PATCH_TYPE is not a valid patch type, use dcos or dcosx" ;;
esac

if [ "$PATCH_TYPE" = "dcos" ] ; then
	echo "[i] Fetching latest Adrian Clang build for the kernel build..."
	# fresh kernel building clang toolchain by Adrian
	rm -rf prebuilts/clang/host/linux-x86/adrian-clang
	mkdir -p prebuilts/clang/host/linux-x86/adrian-clang
	cd prebuilts/clang/host/linux-x86/adrian-clang
	# in case of automated builds, please host a mirror
	curl https://ftp.travitia.xyz/clang/clang-latest.tar.xz | tar -xJ
	cd $BASE_BUILD_DIR
	# Used to build the ROM
	rm -rf prebuilts/clang/host/linux-x86/adrian-clang-2
	mkdir -p prebuilts/clang/host/linux-x86/adrian-clang-2
	cd prebuilts/clang/host/linux-x86/adrian-clang-2
	curl https://ftp.travitia.xyz/clang/clang-r459371.tar.xz | tar -xJ
	cd $BASE_BUILD_DIR

	echo "[i] Fetching is done. Patching sources..."

	$CATHEDRA_PATH/apply.py $CATHEDRA_PATH/dcos/patches
	$CATHEDRA_PATH/apply.py $CATHEDRA_PATH/dcos/patches/clang-15

	echo "[i] Installing boot animation..."
	cp -f $CATHEDRA_PATH/dcos/assets/bootanimation.zip vendor/aosp/bootanimation/bootanimation_1080.zip
fi

if [ "$PATCH_TYPE" = "dcosx" ] ; then
	echo "[i] Preparing DavinciCodeOSX branding..."
	sed -i "s|DavinciCodeOS_|DavinciCodeOSX_|" vendor/aosp/config/branding.mk
	sed -i "s|DavinciCodeOS|DavinciCodeOSX|" build/tools/releasetools/edify_generator.py

	$CATHEDRA_PATH/apply.py $CATHEDRA_PATH/dcosx/patches
fi
