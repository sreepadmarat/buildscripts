#!/bin/bash

# 1. Pre-clean custom trees from previous runs
rm -rf device/oneplus/larry
rm -rf device/oneplus/sm6375-common
rm -rf hardware/oplus
rm -rf kernel/oneplus/sm6375
rm -rf vendor/oneplus/larry
rm -rf vendor/oneplus/sm6375-common
rm -rf vendor/lineage-priv
rm -rf .repo/local_manifests/custom.xml
rm -rf vendor/oplus/camera
rm -rf packages/apps/TouchServices
rm -rf packages/apps/GameBar
rm -rf vendor/revanced
rm -rf packages/apps/KProfiles

# 2. Rom source repo initialization
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Ensure local_manifests directory exists
mkdir -p .repo/local_manifests

# Write the XML configuration into custom.xml
cat << 'EOF' > .repo/local_manifests/custom.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="gitlab" fetch="https://gitlab.com/" />
  <remote name="github" fetch="https://github.com/" />

  <project path="vendor/pixel/gms" name="thecloverproject/vendor_pixel_gms" remote="gitlab" revision="16-qpr2" clone-depth="1" />
  <project path="vendor/pixel/launcher" name="thecloverproject/vendor_pixel_launcher" remote="gitlab" revision="16-qpr2" clone-depth="1" />
  <project path="vendor/pixel/themepicker" name="thecloverproject/vendor_pixel_themepicker" remote="gitlab" revision="16-qpr2" clone-depth="1" />
  <project path="vendor/pixel/sounds" name="thecloverproject/vendor_pixel_sounds" remote="gitlab" revision="16-qpr2" clone-depth="1" />
  <project path="vendor/pixel-style" name="Evolution-X/vendor_pixel-style" remote="github" revision="bka" clone-depth="1" />
  <project path="vendor/gms_spoof" name="Neoteric-OS/android_vendor_gms_spoof" remote="github" revision="master" clone-depth="1" />

  <project path="vendor/oplus/camera" name="sreepadmarat/vendor-oplus-camera" remote="github" revision="lineage-23.2" clone-depth="1" />
  <project path="device/oneplus/larry" name="sreepadmarat/android_device_oneplus_larry" remote="github" revision="los" clone-depth="1" />
  <project path="device/oneplus/sm6375-common" name="sreepadmarat/android_device_oneplus_sm6375-common" remote="github" revision="los" clone-depth="1" />
  <project path="hardware/oplus" name="LineageOS/android_hardware_oplus" remote="github" revision="lineage-23.2" clone-depth="1" />
  <project path="kernel/oneplus/sm6375" name="sreepadmarat/android_kernel_oneplus_sm6375" remote="github" revision="16.2-resukisu" clone-depth="1" />
  <project path="vendor/oneplus/larry" name="TheMuppets/vendor_oneplus_larry" remote="github" revision="lineage-23.2" clone-depth="1" />
  <project path="vendor/oneplus/sm6375-common" name="TheMuppets/vendor_oneplus_sm6375-common" remote="github" revision="lineage-23.2" clone-depth="1" />
  <project path="packages/apps/TouchServices" name="sreepadmarat/packages_apps_TouchServices" remote="github" revision="lineage-23.2" clone-depth="1" />
  <project path="packages/apps/GameBar" name="sreepadmarat/packages_apps_GameBar" remote="github" revision="lineage-23.2" clone-depth="1" />
  <project path="vendor/revanced" name="sreepadmarat/vendor_revanced" remote="github" revision="sixteen-qpr2" clone-depth="1" />
  <project path="packages/apps/KProfiles" name="KProfiles/android_packages_apps_Kprofiles" remote="github" revision="main" clone-depth="1" />
</manifest>
EOF

echo "=== Manifest custom.xml created successfully! ==="

# 3. Sync the base platform repositories FIRST
/opt/crave/resync.sh
# For Safety
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
echo "============ Base Repo Sync Successfull ==============="

# Download lfs Artifacts
repo forall -c 'git lfs pull'

# Clean Signing Keys & absolute path Symlinking
mkdir -p vendor/lineage-priv
git clone --depth 1 https://github.com/sreepadmarat/buildscripts.git vendor/lineage-priv/buildscripts_tmp
mv vendor/lineage-priv/buildscripts_tmp/keys vendor/lineage-priv/keys
rm -rf vendor/lineage-priv/buildscripts_tmp

# --- ReVanced Cherry-Picks ---
    echo "Applying ReVanced framework patches..."
    cd frameworks/base
    git fetch https://github.com/PixelLineage/frameworks_base.git bc71449a25b6b0d16d2b4e611cdc9939bd89bb54 && git cherry-pick FETCH_HEAD
    cd ../..
  
    cd packages/apps/Settings
    git fetch https://github.com/PixelLineage/packages_apps_Settings.git 38def62c73e175bf65708137c3e9e281c476ba84 && git cherry-pick FETCH_HEAD
    cd ../../..

# Set up build environment (gettop handles patches cleanly now)
source build/envsetup.sh
echo "====== Envsetup Done ======="

# Export environmental variables
export TZ=Asia/Kolkata
export BUILD_USERNAME=sreepadmarat
export BUILD_HOSTNAME=barbatos
export RELAX_USES_LIBRARY_CHECK=true
echo "======= Export Done ======"

# Lunch 
lunch lineage_larry-bp4a-userdebug
echo "====== Lunch Set ======="

m installclean
m bacon
echo "=== Copying Build Output ==="
mkdir -p los
cp out/target/product/larry/lineage-23.2*.zip \
   out/target/product/larry/boot.img \
   out/target/product/larry/vendor_boot.img \
   out/target/product/larry/dtbo.img los/
