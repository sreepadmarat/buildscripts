#!/bin/bash

# 1. Pre-clean custom trees from previous runs
rm -rf device/oneplus/larry
rm -rf device/oneplus/sm6375-common
rm -rf hardware/oplus
rm -rf kernel/oneplus/sm6375
rm -rf vendor/oneplus/larry
rm -rf vendor/oneplus/sm6375-common
rm -rf hardware/dolby
rm -rf packages/apps/GameBar
rm -rf vendor/infinity-priv
rm -rf vendor/lineage-priv
rm -rf first

# 2. Rom source repo initialization
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefaultecho "=================="
echo "Repo init success"
echo "=================="

# 3. Sync the base platform repositories FIRST
/opt/crave/resync.sh
# For Safety
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
echo "============ Base Repo Sync Successfull ==============="

# 4. NOW inject your custom device trees (Safe from being pruned!)
git clone -b infinity https://github.com/sreepadmarat/device_oneplus_larry device/oneplus/larry --depth=1
git clone -b infinity https://github.com/sreepadmarat/device_oneplus_sm6375-common device/oneplus/sm6375-common --depth=1
git clone -b infinity https://github.com/sreepadmarat/hardware_oplus hardware/oplus --depth=1
git clone -b 16.2 https://github.com/Larry-ROM-Archive/hardware_dolby hardware/dolby --depth=1
git clone -b 16.0 https://github.com/Larry-ROM-Archive/packages_apps_GameBar packages/apps/GameBar --depth=1
git clone -b 16.0 https://github.com/Larry-ROM-Archive/kernel_oneplus_sm6375 kernel/oneplus/sm6375 --depth=1
git clone -b 16.2 https://github.com/Larry-ROM-Archive/vendor_oneplus_larry vendor/oneplus/larry --depth=1
git clone -b 16.2 https://github.com/Larry-ROM-Archive/vendor_oneplus_sm6375-common vendor/oneplus/sm6375-common --depth=1
echo "============ Custom Trees Cloned Successfully ==============="

# Patches
sed -i 's/"true": \["-DTARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED"\]/true: \["-DTARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED"\]/g' hardware/interfaces/camera/device/3.2/default/Android.bp
sed -i 's/"true": \["-DTARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED"\]/true: \["-DTARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED"\]/g' hardware/interfaces/camera/device/3.3/default/Android.bp
rm packages/apps/DolbyAtmos/Android.mk
echo "" > packages/apps/DolbyAtmos/Android.bp

# 5. Set up build environment (gettop handles patches cleanly now)
. build/envsetup.sh
echo "====== Envsetup Done ======="

# Download lfs Artifacts
repo forall -c 'git lfs pull'

# 6. Clean Signing Keys & absolute path Symlinking
mkdir -p vendor/infinity-priv
git clone --depth 1 https://github.com/sreepadmarat/buildscripts.git vendor/infinity-priv/buildscripts_tmp
mv vendor/lineage-priv/buildscripts_tmp/keys vendor/infinity-priv/keys
rm -rf vendor/infinity-priv/buildscripts_tmp
ln -s infinity-priv vendor/lineage-priv

# Export environmental variables
export TZ=Asia/Kolkata
export BUILD_USERNAME=sreepadmarat
export BUILD_HOSTNAME=barbatos
export RELAX_USES_LIBRARY_CHECK=true
export WITH_GAPPS=true
echo "======= Export Done ======"

# Lunch 
lunch infinity_larry-bp4a-user 
echo "====== Lunch Set ======="
m installclean
m bacon
mkdir -p first && cp out/target/product/larry/Project_Infinity-X*.zip out/target/product/larry/boot.img out/target/product/larry/vendor_boot.img out/target/product/larry/dtbo.img out/target/product/larry/system/build.prop first/
m installclean
m updatepackage
