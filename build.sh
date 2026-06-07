#!/bin/bash

rm -rf device/oneplus/larry
rm -rf device/oneplus/sm6375-common
rm -rf hardware/oplus
rm -rf kernel/oneplus/sm6375
rm -rf vendor/oneplus/larry
rm -rf vendor/oneplus/sm6375-common
rm -rf vendor/oplus/camera
rm -rf hardware/dolby
rm -rf packages/apps/GameBar
rm -rf .repo

# Rom source repo
repo init -u https://github.com/PixelOS-AOSP/android_manifest.git -b sixteen-qpr2 --git-lfs --depth=1
echo "=================="
echo "Repo init success"
echo "=================="

# Clone Trees 
git clone -b pixel https://github.com/sreepadmarat/device_oneplus_larry device/oneplus/larry --depth=1
git clone -b pixel https://github.com/sreepadmarat/device_oneplus_sm6375-common device/oneplus/sm6375-common --depth=1
git clone -b pixel https://github.com/sreepadmarat/hardware_oplus hardware/oplus --depth=1
git clone -b lineage-22.0 https://gitlab.com/larry-rom-archive/vendor-oplus-camera vendor/oplus/camera --depth=1
git clone -b 16.2 https://github.com/Larry-ROM-Archive/hardware_dolby hardware/dolby --depth=1
git clone -b lineage-23.2 https://github.com/Larry-ROM-Archive/packages_apps_GameBar /packages/apps/GameBar --depth=1
git clone -b 16.2 https://gitlab.com/larry-rom-archive/kernel_oneplus_sm6375.git kernel/oneplus/sm6375 --depth=1
git clone -b 16.2 https://github.com/Larry-ROM-Archive/vendor_oneplus_larry vendor/oneplus/larry --depth=1
git clone -b 16.2 https://github.com/Larry-ROM-Archive/vendor_oneplus_sm6375-common vendor/oneplus/sm6375-common --depth=1

# Download lfs Artifacts
repo forall -c 'git lfs pull'

# Sync the repositories
/opt/crave/resync.sh
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
echo "============================"

# Export
export TZ=Asia/Kolkata
export BUILD_USERNAME=sreepadmarat
export BUILD_HOSTNAME=barbatos
export RELAX_USES_LIBRARY_CHECK=true
export WITH_GMS=true
echo "======= Export Done ======"

# Set up build environment
source b*/env*
echo "====== Envsetup Done ======="

# Lunch
lunch custom_larry-bp4a-user
echo "============="

# Make cleaninstall
make installclean
echo "============="

# Build rom
m pixelos
