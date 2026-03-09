#!/bin/bash

rm -rf .repo/local_manifests

repo init -u https://github.com/DerpFest-AOSP/android_manifest.git -b 16.2 --git-lfs

/opt/crave/resync.sh || repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
#safer sync
/opt/crave/resync.sh || repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

rm -rf device/oneplus/larry
rm -rf device/oneplus/sm6375-common
rm -rf hardware/oplus
rm -rf kernel/oneplus/sm6375
rm -rf vendor/oneplus/larry
rm -rf vendor/oneplus/sm6375-common
rm -rf out/target/product/larry

git clone https://github.com/sreepadmarat/android_device_oneplus_larry device/oneplus/larry -b derpfest --depth 1
git clone https://github.com/sreepadmarat/android_device_oneplus_sm6375-common device/oneplus/sm6375-common -b derpfest --depth 1
git clone https://github.com/sreepadmarat/android_hardware_oplus hardware/oplus -b derpfest --depth 1
git clone https://github.com/LineageOS/android_kernel_oneplus_sm6375 kernel/oneplus/sm6375 -b lineage-23.2 --depth 1
git clone https://github.com/TheMuppets/proprietary_vendor_oneplus_larry vendor/oneplus/larry -b lineage-23.2 --depth 1
git clone https://github.com/TheMuppets/proprietary_vendor_oneplus_sm6375-common vendor/oneplus/sm6375-common -b lineage-23.2 --depth 1

mkdir -p device/oneplus/larry/keys
for file in Android.bp bluetooth.pk8 bluetooth.x509.pem BUILD cts_uicc_2021.pk8 cts_uicc_2021.x509.pem gmscompat_lib.pk8 gmscompat_lib.x509.pem keys.sh make_key.sh media.pk8 media.x509.pem networkstack.pk8 networkstack.x509.pem nfc.pk8 nfc.x509.pem platform.pk8 platform.x509.pem releasekey.pk8 releasekey.x509.pem sdk_sandbox.pk8 sdk_sandbox.x509.pem shared.pk8 shared.x509.pem testkey.pk8 testkey.x509.pem verifiedboot.pk8 verifiedboot.x509.pem; do
  curl -sL "https://raw.githubusercontent.com/sreepadmarat/buildscripts/main/keys/$file" -o "device/oneplus/larry/keys/$file"
done

repo forall -c 'git lfs pull'

export TZ=Asia/Kolkata
export BUILD_USERNAME=SreepadMarat
export BUILD_HOSTNAME=crave
export WITH_GMS=true
export TARGET_BUILD_VARIANT=userdebug

. build/envsetup.sh
lunch lineage_larry-bp4a-userdebug
m installclean
mka derp
