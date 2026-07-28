#!/bin/bash

# 1. Pre-clean custom trees from previous runs
rm -rf device/oneplus/larry
rm -rf device/oneplus/sm6375-common
rm -rf hardware/oplus
rm -rf kernel/oneplus/sm6375
rm -rf vendor/oneplus/larry
rm -rf vendor/oneplus/sm6375-common
rm -rf vendor/lineage-priv

# 2. Rom source repo initialization
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# 3. Sync the base platform repositories FIRST
/opt/crave/resync.sh
# For Safety
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
echo "============ Base Repo Sync Successfull ==============="

# Ensure local_manifests directory exists
mkdir -p .repo/local_manifests

# Write the XML configuration into custom.xml
cat << 'EOF' > .repo/local_manifests/custom.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="gitlab" fetch="https://gitlab.com/" />
  <remote name="github" fetch="https://github.com/" />

  <project path="vendor/pixel/gms" name="thecloverproject/vendor_pixel_gms" remote="gitlab" revision="16-qpr2" />
  <project path="vendor/pixel/launcher" name="thecloverproject/vendor_pixel_launcher" remote="gitlab" revision="16-qpr2" />
  <project path="vendor/pixel/themepicker" name="thecloverproject/vendor_pixel_themepicker" remote="gitlab" revision="16-qpr2" />
  <project path="vendor/pixel/sounds" name="thecloverproject/vendor_pixel_sounds" remote="gitlab" revision="16-qpr2" />
  
  <project path="vendor/pixel-style" name="Evolution-X/vendor_pixel-style" remote="github" revision="bka" />
  <project path="vendor/gms_spoof" name="Neoteric-OS/android_vendor_gms_spoof" remote="github" revision="master" />
</manifest>
EOF

echo "=== Manifest custom.xml created successfully! ==="

# 4. NOW inject your custom device trees (Safe from being pruned!)
git clone -b los https://github.com/sreepadmarat/android_device_oneplus_larry device/oneplus/larry --depth=1
git clone -b los https://github.com/sreepadmarat/android_device_oneplus_sm6375-common device/oneplus/sm6375-common --depth=1
git clone -b lineage-23.2 https://github.com/LineageOS/android_hardware_oplus hardware/oplus --depth=1
git clone -b 16.2-resukisu https://github.com/sreepadmarat/android_kernel_oneplus_sm6375 kernel/oneplus/sm6375 --depth=1
git clone -b lineage-23.2 https://github.com/TheMuppets/vendor_oneplus_larry vendor/oneplus/larry --depth=1
git clone -b lineage-23.2 https://github.com/TheMuppets/vendor_oneplus_sm6375-common vendor/oneplus/sm6375-common --depth=1
echo "============ Custom Trees Cloned Successfully ==============="

# Download lfs Artifacts
repo forall -c 'git lfs pull'

# Clean Signing Keys & absolute path Symlinking
mkdir -p vendor/lineage-priv
git clone --depth 1 https://github.com/sreepadmarat/buildscripts.git vendor/lineage-priv/buildscripts_tmp
mv vendor/lineage-priv/buildscripts_tmp/keys vendor/lineage-priv/keys
rm -rf vendor/lineage-priv/buildscripts_tmp

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
