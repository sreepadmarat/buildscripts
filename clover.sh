#!/bin/bash

# =============================
#   Clover Project Build Script
#   Device: OnePlus Nord CE 3 Lite 5G (SM6375)
#   Codename: Larry
#   Variant: GApps (only)
# =============================

set -e

# Optional: stop on first failing command in a pipeline too
set -o pipefail

# --- Basic config ---
DEVICE=larry
LUNCH_TARGET="clover_${DEVICE}-bp3a-userdebug"
JOBS="$(nproc --all)"

echo "===== Clover Project | Device: ${DEVICE} | Jobs: ${JOBS} ====="

# =============================
#   1. Init & Sync ROM Repo
# =============================

echo "===== Initializing Clover repo ====="
repo init -u https://github.com/The-Clover-Project/manifest.git -b 16-qpr1 --git-lfs

echo "===== Syncing Clover source (this might take a while) ====="
/opt/crave/resync.sh

# If you don’t use crave’s resync, replace the above with:
# repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j${JOBS}

# =============================
#   2. Clone Device-Specific Trees
# =============================

echo "===== Cloning device trees ====="

# --- Device Tree ---
if [ ! -d "device/oneplus/${DEVICE}" ]; then
    git clone https://github.com/sreepadmarat/android_device_oneplus_larry -b clover device/oneplus/larry
fi

# --- Common Device Tree ---
if [ ! -d "device/oneplus/sm6375-common" ]; then
    git clone https://github.com/sreepadmarat/android_device_oneplus_sm6375-common -b clover device/oneplus/sm6375-common
fi

# --- Vendor Tree ---
if [ ! -d "vendor/oneplus/${DEVICE}" ]; then
    git clone https://github.com/Teamhackneyed/proprietary_vendor_oneplus_larry -b lineage-23.0 vendor/oneplus/larry
fi

# --- Common Vendor Tree ---
if [ ! -d "vendor/oneplus/sm6375-common" ]; then
    git clone https://github.com/Teamhackneyed/proprietary_vendor_oneplus_sm6375-common -b lineage-23.0 vendor/oneplus/sm6375-common
fi

# --- Kernel Tree ---
if [ ! -d "kernel/oneplus/sm6375" ]; then
    git clone https://github.com/Teamhackneyed/android_kernel_oneplus_sm6375 -b lineage-23.0 kernel/oneplus/sm6375
fi

# --- Hardware Oplus Tree ---
if [ ! -d "hardware/oplus" ]; then
    git clone https://github.com/LineageOS/android_hardware_oplus -b lineage-23.0 hardware/oplus
fi

# =============================
#   3. Environment & Build
# =============================

echo "===== Setting up build environment ====="
source build/envsetup.sh

echo "===== Lunching target: ${LUNCH_TARGET} ====="
lunch "${LUNCH_TARGET}"

# Optional: enable ccache
# export USE_CCACHE=1
# export CCACHE_EXEC=/usr/bin/ccache
# ccache -M 100G

echo "===== Running installclean ====="
make installclean

echo "===== Starting Clover GApps build ====="
mka clover -j"${JOBS}"

# =============================
#   4. Handle Output
# =============================

OUT_DIR="out/target/product/${DEVICE}"

if [ -d "${OUT_DIR}" ]; then
    echo "===== Build finished. Output directory: ${OUT_DIR} ====="
    ls -lh "${OUT_DIR}"/*.zip 2>/dev/null || echo "No ZIP found, check build logs."
else
    echo "!!! ERROR: Output directory ${OUT_DIR} not found. Build likely failed."
    exit 1
fi

echo "===== Clover build for ${DEVICE} completed successfully! ====="
