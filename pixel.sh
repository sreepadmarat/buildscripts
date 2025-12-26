#!/bin/bash

# --- 1. Initialize & Sync Base ROM ---
repo init -u https://github.com/PixelOS-AOSP/android_manifest.git -b sixteen-qpr1 --git-lfs
/opt/crave/resync.sh

# --- 2. Clone Your Device & Common Trees ---
# Cloned after sync to ensure they overlay the base source correctly
git clone https://github.com/sreepadmarat/android_device_oneplus_larry -b pixelos device/oneplus/larry
git clone https://github.com/sreepadmarat/android_device_oneplus_sm6375-common -b pixelos device/oneplus/sm6375-common

# --- 3. Clone Vendor, Kernel & Hardware ---
git clone https://github.com/Teamhackneyed/proprietary_vendor_oneplus_larry -b lineage-23.1 vendor/oneplus/larry
git clone https://github.com/Teamhackneyed/proprietary_vendor_oneplus_sm6375-common -b lineage-23.1 vendor/oneplus/sm6375-common
git clone https://github.com/Teamhackneyed/android_kernel_oneplus_sm6375 -b lineage-23.1 kernel/oneplus/sm6375
git clone https://github.com/PixelOS-AOSP/android_hardware_oplus -b sixteen-qpr1 hardware/oplus

# --- 4. Signing Setup (Local Keys) ---
export PRODUCT_DEFAULT_DEV_CERTIFICATE=/crave-devspaces/pixelos/certs/releasekey
export build_with_signing_keys=true
export KEY_RECOVERY_DIR=/crave-devspaces/pixelos/certs

# --- 5. Build Commands (Aligned with PixelOS Docs) ---
source build/envsetup.sh
breakfast larry
make installclean
m pixelos
