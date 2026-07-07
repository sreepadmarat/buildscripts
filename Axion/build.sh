#!/bin/bash

# 1. Pre-clean custom trees from previous runs
echo "=== Cleaning previous build directories ==="
rm -rf device/oneplus/larry \
       device/oneplus/sm6375-common \
       hardware/oplus \
       kernel/oneplus/sm6375 \
       vendor/oneplus/larry \
       vendor/oneplus/sm6375-common \
       hardware/dolby \
       packages/apps/GameBar \
       vendor/lineage-priv \
       gapps \
       vanilla

# 2. ROM source repo initialization
echo "=== Initializing ROM Source Manifest ==="
repo init --depth=1 --no-repo-verify --git-lfs \
  -u https://github.com/AxionAOSP/android.git \
  -b lineage-23.2 \
  -g default,-mips,-darwin,-notdefault
echo "Repo init success"

# 3. Sync the base platform repositories FIRST
echo "=== Synchronizing Base Repositories ==="
/opt/crave/resync.sh
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
echo "Base Repo Sync Successful"

rm -rf packages/apps/Updater

# 4. Inject custom device trees
echo "=== Cloning Custom Device Trees ==="
git clone -b axion --depth=1 https://github.com/sreepadmarat/device_oneplus_larry device/oneplus/larry
git clone -b lineage-23.2 --depth=1 https://github.com/sreepadmarat/device_oneplus_sm6375-common device/oneplus/sm6375-common
git clone -b axion --depth=1 https://github.com/sreepadmarat/hardware_oplus hardware/oplus
git clone -b 16.2 --depth=1 https://github.com/Larry-ROM-Archive/hardware_dolby hardware/dolby
git clone -b 16.0 --depth=1 https://github.com/Larry-ROM-Archive/packages_apps_GameBar packages/apps/GameBar
git clone -b axion --depth=1 https://github.com/sreepadmarat/android_kernel_oneplus_sm6375 kernel/oneplus/sm6375
git clone -b lineage-23.2 --depth=1 https://github.com/sreepadmarat/proprietary_vendor_oneplus_larry vendor/oneplus/larry
git clone -b lineage-23.2 --depth=1 https://github.com/sreepadmarat/proprietary_vendor_oneplus_sm6375-common vendor/oneplus/sm6375-common
git clone -b gapps --depth=1 https://github.com/sreepadmarat/android_packages_apps_Updater packages/apps/Updater
echo "Custom Trees Cloned Successfully"

# 5. Apply Patches Safely
echo "=== Applying Code Patches ==="
# Check if file exists before running sed to avoid script breaking
if [ -f hardware/interfaces/camera/device/3.2/default/Android.bp ]; then
    sed -i 's/"true": \["-DTARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED"\]/true: \["-DTARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED"\]/g' hardware/interfaces/camera/device/3.2/default/Android.bp
fi
if [ -f hardware/interfaces/camera/device/3.3/default/Android.bp ]; then
    sed -i 's/"true": \["-DTARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED"\]/true: \["-DTARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED"\]/g' hardware/interfaces/camera/device/3.3/default/Android.bp
fi

# Safe file mutations
rm -f packages/apps/DolbyAtmos/Android.mk
echo "" > packages/apps/DolbyAtmos/Android.bp

# Download Git LFS Artifacts for all tracked repos safely
echo "=== Fetching Git LFS Artifacts ==="
repo forall -c 'git lfs pull || true'

# 6. Set up build environment
echo "=== Loading Environment Setup ==="
. build/envsetup.sh

# 7. Clean Signing Keys Setup
echo "=== Setting Up Build Keys ==="
mkdir -p vendor/lineage-priv
git clone --depth 1 https://github.com/sreepadmarat/buildscripts.git vendor/lineage-priv/buildscripts_tmp
mv vendor/lineage-priv/buildscripts_tmp/keys vendor/lineage-priv/keys
rm -rf vendor/lineage-priv/buildscripts_tmp

# Global build configuration
export TZ=Asia/Kolkata
export BUILD_USERNAME=sreepadmarat
export BUILD_HOSTNAME=barbatos
export RELAX_USES_LIBRARY_CHECK=true
export TARGET_INCLUDES_LOS_PREBUILTS=true

# 9. BUILD VARIANT 1: GApps (With GMS)
echo "=== Preparing GApps Build ==="

axion larry userdebug full

echo "=== Starting GApps Build ==="
ax -br

echo "=== Copying GApps Build Output ==="
mkdir -p gapps
cp out/target/product/larry/axion*.zip \
   out/target/product/larry/boot.img \
   out/target/product/larry/vendor_boot.img \
   out/target/product/larry/dtbo.img \
   out/target/product/larry/system/build.prop gapps/

echo "========================================="
echo "========== GAPPS BUILDS DONE ! =========="
echo "========================================="
