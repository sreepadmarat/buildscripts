#!/bin/bash

# --- 1. Workspace Setup ---
mkdir -p e-os && cd e-os

# --- 2. Initialize /e/OS Source (Android 16 Development Branch) ---
repo init -u https://gitlab.e.foundation/e/os/android.git -b a16 --depth=1
/opt/crave/resync.sh

# --- 3. Setup Local Manifest (The OnePlus 'larry' Trees) ---
mkdir -p .repo/local_manifests
cat <<EOF > .repo/local_manifests/larry.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="LineageOS/android_device_oneplus_larry" path="device/oneplus/larry" remote="github" revision="lineage-23.0" />
  <project name="LineageOS/android_device_oneplus_sm6375-common" path="device/oneplus/sm6375-common" remote="github" revision="lineage-23.0" />
  <project name="LineageOS/android_kernel_oneplus_sm6375" path="kernel/oneplus/sm6375" remote="github" revision="lineage-23.0" />
  <project name="LineageOS/android_hardware_oplus" path="hardware/oplus" remote="github" revision="lineage-23.0" />
  <project name="TheMuppets/proprietary_vendor_oneplus_larry" path="vendor/oneplus/larry" remote="github" revision="lineage-23.0" />
  <project name="TheMuppets/proprietary_vendor_oneplus_sm6375-common" path="vendor/oneplus/sm6375-common" remote="github" revision="lineage-23.0" />
</manifest>
EOF

# Sync the specific trees from the local manifest
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

# --- 4. Automated Release Key Generation (India/Karnataka/Bangalore) ---
mkdir -p certs
if [ ! -f certs/releasekey.x509.pem ]; then
    echo "Generating new release keys for Sreepad Marat..."
    subject='/C=IN/ST=Karnataka/L=Bangalore/O=eOS/OU=Sreepad/CN=Sreepad/emailAddress=sreepad.marat@gmail.com'
    
    # Generate the full set of security keys required for Android 16
    for x in releasekey platform shared media networkstack bluetooth sdk_sandbox verifiedboot; do
        ./development/tools/make_key certs/$x "$subject" <<EOF

EOF
    done
fi

# --- 5. Signing & /e/OS Feature Environment ---
export PRODUCT_DEFAULT_DEV_CERTIFICATE=certs/releasekey
export build_with_signing_keys=true
export KEY_RECOVERY_DIR=certs
export SIGNATURE_SPOOFING=true # Enables microG compatibility
export CUSTOM_LOCAL_OUT=true   # Helps Crave track the output files

# --- 6. The "Baking" Process ---
source build/envsetup.sh
croot

# Use the correct Android 16 build target for Larry
lunch lineage_larry-bp2a-userdebug

# Clean up any leftover images to ensure a fresh build
make installclean

# Start the full ROM compilation
m bacon -j$(nproc --all)
