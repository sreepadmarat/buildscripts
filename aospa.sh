#!/bin/bash                                                                                                                                                                                   
                                                                                                                                                                                                  
    # 1. Pre-clean custom trees from previous runs                                                                                                                                                
    rm -rf device/oneplus/larry                                                                                                                                                                   
    rm -rf device/oneplus/sm6375-common                                                                                                                                                           
    rm -rf hardware/oplus                                                                                                                                                                         
    rm -rf kernel/oneplus/sm6375                                                                                                                                                                  
    rm -rf vendor/oneplus/larry                                                                                                                                                                   
    rm -rf vendor/oneplus/sm6375-common                                                                                                                                                           
    rm -rf vendor/aospa/signing/keys                                                                                                                                                              
                                                                                                                                                                                                  
    # 2. Initialize AOSPA Beryl (Android 16) Manifest                                                                                                                                             
    repo init -u https://github.com/AOSPA/manifest -b beryl --git-lfs --depth=1                                                                                                                   
    echo "=================="                                                                                                                                                                     
    echo "Repo init success"                                                                                                                                                                      
    echo "=================="
  
    # 3. Sync the base platform repositories FIRST
    /opt/crave/resync.sh
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
    echo "============ Base Repo Sync Successful ==============="
  
    # 4. Clone adapted AOSPA trees (--depth=1 for fast cloning)
    git clone --depth=1 -b aospa https://github.com/sreepadmarat/android_device_oneplus_larry.git device/oneplus/larry
    git clone --depth=1 -b aospa https://github.com/sreepadmarat/android_device_oneplus_sm6375-common.git device/oneplus/sm6375-common
    git clone --depth=1 -b aospa https://github.com/sreepadmarat/android_hardware_oplus.git hardware/oplus
    git clone --depth=1 -b aospa https://github.com/sreepadmarat/android_kernel_oneplus_sm6375.git kernel/oneplus/sm6375
    git clone --depth=1 -b aospa https://github.com/TheMuppets/proprietary_vendor_oneplus_larry.git vendor/oneplus/larry
    git clone --depth=1 -b aospa https://github.com/TheMuppets/proprietary_vendor_oneplus_sm6375-common.git vendor/oneplus/sm6375-common
  
    # 5. Download Git LFS Artifacts
    repo forall -c 'git lfs pull'
  
    # 6. Set up Signing Keys & Modify keys.mk for AOSPA
    mkdir -p vendor/aospa/signing
    git clone --depth=1 https://github.com/sreepadmarat/buildscripts.git vendor/aospa/signing/buildscripts_tmp
    mv vendor/aospa/signing/buildscripts_tmp/keys vendor/aospa/signing/keys
    rm -rf vendor/aospa/signing/buildscripts_tmp
  
    # Patch keys.mk path from lineage-priv to aospa/signing
    if [ -f vendor/aospa/signing/keys/keys.mk ]; then
        sed -i 's|vendor/lineage-priv/keys/releasekey|vendor/aospa/signing/keys/releasekey|g' vendor/aospa/signing/keys/keys.mk
        echo "====== keys.mk path updated for AOSPA ======"
    fi
  
    # 7. Export AOSPA build environment & GMS flags
    export TZ=Asia/Kolkata
    export BUILD_USERNAME=sreepadmarat
    export BUILD_HOSTNAME=barbatos
    export RELAX_USES_LIBRARY_CHECK=true
    export AOSPA_BUILDTYPE=UNOFFICIAL
    export TARGET_PREBUILT_GAPPS=true
    export TARGET_INCLUDE_LIVE_WALLPAPERS=true
    export PRODUCT_DEFAULT_DEV_CERTIFICATE=vendor/aospa/signing/keys/releasekey
    echo "======= Export Done ======"
  
    # 8. Trigger AOSPA's official bundled builder tool for larry
    chmod +x ./rom-build.sh
    ./rom-build.sh larry
