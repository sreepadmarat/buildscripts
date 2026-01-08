#! /bin/bash

rm -rf .repo/local_manifests; \
rm -rf {device,vendor,kernel,hardware}/oneplus && \
rm -rf prebuilts/clang/host/linux-x86 && \
repo init --depth=1 --no-repo-verify -u https://gitlab.e.foundation/e/os/android.git -b a16 --git-lfs -g default,-mips,-darwin,-notdefault && \
/opt/crave/resync.sh && \
repo forall -c 'git lfs pull' && \
git clone https://github.com/sreepadmarat/android_device_oneplus_larry -b eos device/oneplus/larry && \
git clone https://github.com/sreepadmarat/android_device_oneplus_sm6375-common -b lineage-23.0 device/oneplus/sm6375-common && \
git clone https://github.com/sreepadmarat/proprietary_vendor_oneplus_larry -b lineage-23.0 vendor/oneplus/larry && \
git clone https://github.com/sreepadmarat/proprietary_vendor_oneplus_sm6375-common -b lineage-23.0 vendor/oneplus/sm6375-common && \
git clone https://github.com/sreepadmarat/android_kernel_oneplus_sm6375 -b lineage-23.0 kernel/oneplus/sm6375 && \
git clone https://github.com/sreepadmarat/android_hardware_oplus -b lineage-23.0 hardware/oplus && \
# Build
. build/envsetup.sh && \
lunch lineage_larry-bp2a-user && make installclean && m bacon;
