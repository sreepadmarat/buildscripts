#!/bin/bash

# 1. Pre-clean custom trees from previous runs
rm -rf device/oneplus/larry
rm -rf device/oneplus/sm6375-common
rm -rf hardware/oplus
rm -rf kernel/oneplus/sm6375
rm -rf vendor/oneplus/larry
rm -rf vendor/oneplus/sm6375-common
rm -rf vendor/evolution-priv
rm -rf evolution

# 2. Rom source repo initialization
repo init -u https://github.com/Evolution-X/manifest -b cnb --git-lfs --depth=1
echo "=================="
echo "Repo init success"
echo "=================="

# 3. Sync the base platform repositories FIRST
/opt/crave/resync.sh
# For Safety
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
echo "============ Base Repo Sync Successfull ==============="

# 4. NOW inject your custom device trees (Safe from being pruned!)
git clone -b evolution https://github.com/sreepadmarat/device_oneplus_larry device/oneplus/larry --depth=1
git clone -b evolution https://github.com/sreepadmarat/device_oneplus_sm6375-common device/oneplus/sm6375-common --depth=1
git clone -b evolution https://github.com/sreepadmarat/hardware_oplus hardware/oplus --depth=1
git clone -b 16.2-resukisu https://github.com/sreepadmarat/android_kernel_oneplus_sm6375 kernel/oneplus/sm6375 --depth=1
git clone -b 17.0 https://github.com/Larry-ROM-Archive/vendor_oneplus_larry vendor/oneplus/larry --depth=1
git clone -b 17.0 https://github.com/Larry-ROM-Archive/vendor_oneplus_sm6375-common vendor/oneplus/sm6375-common --depth=1
echo "============ Custom Trees Cloned Successfully ==============="

# Download lfs Artifacts
repo forall -c 'git lfs pull'

# Clean Signing Keys & absolute path Symlinking
mkdir -p vendor/evolution-priv
git clone --depth 1 https://github.com/sreepadmarat/buildscripts.git vendor/evolution-priv/buildscripts_tmp
mv vendor/evolution-priv/buildscripts_tmp/keys vendor/evolution-priv/keys
rm -rf vendor/evolution-priv/buildscripts_tmp
ln -s evolution-priv vendor/lineage-priv

# Set up build environment (gettop handles patches cleanly now)
source build/envsetup.sh
echo "====== Envsetup Done ======="

# Export environmental variables
export WITH_GMS=true
export TZ=Asia/Kolkata
export BUILD_USERNAME=sreepadmarat
export BUILD_HOSTNAME=barbatos
export RELAX_USES_LIBRARY_CHECK=true
echo "======= Export Done ======"

# Lunch 
lunch lineage_larry-cp2a-userdebug
echo "====== Lunch Set ======="

m installclean
m evolution
echo "=== Copying Build Output ==="
mkdir -p evolution
cp out/target/product/larry/EvolutionX*.zip \
   out/target/product/larry/boot.img \
   out/target/product/larry/vendor_boot.img \
   out/target/product/larry/dtbo.img evolution/
