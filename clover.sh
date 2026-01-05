#!/bin/bash

# --- 1. Initialize Clover Source (Android 16 QPR1) ---
repo init -u https://github.com/The-Clover-Project/manifest.git -b 16-qpr1 --git-lfs
/opt/crave/resync.sh

# --- 2. Clone Device Trees ---
# Using depth=1 to keep the workspace clean and fast
git clone https://github.com/sreepadmarat/android_device_oneplus_larry.git -b clover device/oneplus/larry --depth=1
git clone https://github.com/LineageOS/android_device_oneplus_sm6375-common.git -b lineage-23.0 device/oneplus/sm6375-common --depth=1
git clone https://github.com/LineageOS/android_kernel_oneplus_sm6375.git -b lineage-23.0 kernel/oneplus/sm6375 --depth=1
git clone https://github.com/LineageOS/android_hardware_oplus.git -b lineage-23.0 hardware/oplus --depth=1
git clone https://github.com/TheMuppets/proprietary_vendor_oneplus_larry.git -b lineage-23.0 vendor/oneplus/larry --depth=1
git clone https://github.com/TheMuppets/proprietary_vendor_oneplus_sm6375-common.git -b lineage-23.0 vendor/oneplus/sm6375-common --depth=1

# --- 3. Ensure Git LFS Binaries are Downloaded ---
# This command goes through every cloned repo and pulls the actual large files
echo "Downloading Git LFS objects for all repositories..."
repo forall -c 'git lfs pull'

# --- 4. Build Execution ---
source build/envsetup.sh

# Lunch the Clover target for larry
lunch clover_larry-bp3a-userdebug

# Wipe previous build artifacts to ensure no 'dirty' files remain
make installclean

# Start compilation of the flashable ZIP
m bacon -j$(nproc --all)
