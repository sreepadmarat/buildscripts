#!/bin/bash

# 1. FORCE-CLEAN ENVIRONMENT
# Prevents "hooks is different" and "project already exists" errors
echo "Cleaning up existing directories and stale metadata..."
rm -rf .repo
rm -rf {device,vendor,kernel,hardware}/oneplus
rm -rf hardware/oplus
rm -rf prebuilts/clang/host/linux-x86

# Deep clean git hooks which cause the most 'repo sync' failures on Crave
find .repo/projects -name "hooks" -type d -exec rm -rf {} + 2>/dev/null
find .repo/project-objects -name "hooks" -type d -exec rm -rf {} + 2>/dev/null

# 2. INITIALIZE REPO
echo "Initializing /e/OS Android 16 manifest..."
repo init --depth=1 --no-repo-verify -u https://gitlab.e.foundation/e/os/android.git -b a16 --git-lfs -g default,-mips,-darwin,-notdefault

# 3. SYNC SOURCE
# Using resync.sh is good for Crave, but we add a fallback to ensure completion
/opt/crave/resync.sh || repo sync -c -j$(nproc) --force-sync --no-clone-bundle --no-tags
repo forall -c 'git lfs pull'

# 4. CLONE DEVICE TREES (MANUAL OVERRIDES)
echo "Cloning device-specific repositories..."
git clone https://github.com/sreepadmarat/android_device_oneplus_larry -b eos device/oneplus/larry
git clone https://github.com/sreepadmarat/android_device_oneplus_sm6375-common -b lineage-23.0 device/oneplus/sm6375-common
git clone https://github.com/sreepadmarat/proprietary_vendor_oneplus_larry -b lineage-23.0 vendor/oneplus/larry
git clone https://github.com/sreepadmarat/proprietary_vendor_oneplus_sm6375-common -b lineage-23.0 vendor/oneplus/sm6375-common
git clone https://github.com/sreepadmarat/android_kernel_oneplus_sm6375 -b lineage-23.0 kernel/oneplus/sm6375
git clone https://github.com/sreepadmarat/android_hardware_oplus -b lineage-23.0 hardware/oplus

# 5. THE "CERTS" FOOLPROOF FIX
# This creates the certs directory and populates it with keys named 
# after the module, which is what the Android 16 build system strictly requires.
echo "Injecting dummy certificates for APEX modules..."
# Common list of keys requested by AOSP/Lineage APEX modules
declare -a keys=("com.android.adbd" "com.android.runtime" "com.android.tzdata" "com.android.os.statsd" "com.android.wifi" "com.android.nfcservices" "com.android.tethering" "com.android.bt")

for bp_file in $(find packages/modules system/apex -name "Android.bp" 2>/dev/null | xargs grep -l "path: \"certs\""); do
    cert_dir=$(dirname "$bp_file")/certs
    mkdir -p "$cert_dir"
    
    # Copy generic test keys
    cp build/target/product/security/testkey.x509.pem "$cert_dir/"
    cp build/target/product/security/testkey.pk8 "$cert_dir/"
    
    # Create module-specific filenames to satisfy Soong's strict checking
    module_name=$(basename $(dirname "$cert_dir"))
    cp build/target/product/security/testkey.x509.pem "$cert_dir/$module_name.x509.pem"
    cp build/target/product/security/testkey.pk8 "$cert_dir/$module_name.pk8"
    
    # Also create common aliases just in case
    for k in "${keys[@]}"; do
        cp build/target/product/security/testkey.x509.pem "$cert_dir/$k.x509.pem" 2>/dev/null
        cp build/target/product/security/testkey.pk8 "$cert_dir/$k.pk8" 2>/dev/null
    done
done

# 6. SETUP AND BUILD
echo "Starting build process..."
. build/envsetup.sh

lunch lineage_larry-bp2a-userdebug

# Clean previous build artifacts without deleting the whole 'out' folder
make installclean

# Build the ROM
m bacon
