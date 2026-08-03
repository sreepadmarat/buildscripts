#!/bin/bash                                                                                                                                                                                   
                                                                                                                                                                                                  
    # 1. Pre-clean custom trees from previous runs                                                                                                                                                
    rm -rf device/oneplus/larry                                                                                                                                                                   
    rm -rf device/oneplus/sm6375-common                                                                                                                                                           
    rm -rf hardware/oplus                                                                                                                                                                         
    rm -rf kernel/oneplus/sm6375                                                                                                                                                                  
    rm -rf vendor/oneplus/larry                                                                                                                                                                   
    rm -rf vendor/oneplus/sm6375-common                                                                                                                                                           
    rm -rf vendor/custom-priv/keys                                                                                                                                                                
                                                                                                                                                                                                  
    # 2. Initialize Custom ROM / ASCP Manifest                                                                                                                                                    
    repo init -u https://github.com/Pixelify-AOSP/platform_manifest -b 17 --git-lfs --depth=1                                                                                                     
    echo "=================="                                                                                                                                                                     
    echo "Repo init success"                                                                                                                                                                      
    echo "=================="                                                                                                                                                                     
                                                                                                                                                                                                  
    # 3. Sync the base platform repositories FIRST                                                                                                                                                
    /opt/crave/resync.sh                                                                                                                                                                          
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)                                                                                              
    echo "============ Base Repo Sync Successful ==============="                                                                                                                                 
                                                                                                                                                                                                  
    # 4. Clone adapted ASCP trees (--depth=1 for fast cloning)                                                                                                                                    
    git clone --depth=1 -b ascp https://github.com/sreepadmarat/android_device_oneplus_larry.git device/oneplus/larry                                                                             
    git clone --depth=1 -b ascp https://github.com/sreepadmarat/android_device_oneplus_sm6375-common.git device/oneplus/sm6375-common
    git clone --depth=1 -b ascp https://github.com/sreepadmarat/android_hardware_oplus.git hardware/oplus
    git clone --depth=1 -b ascp https://github.com/sreepadmarat/android_kernel_oneplus_sm6375.git kernel/oneplus/sm6375
    git clone --depth=1 -b ascp https://github.com/sreepadmarat/proprietary_vendor_oneplus_larry.git vendor/oneplus/larry
    git clone --depth=1 -b ascp https://github.com/sreepadmarat/proprietary_vendor_oneplus_sm6375-common.git vendor/oneplus/sm6375-common
  
    # 5. Download Git LFS Artifacts
    repo forall -c 'git lfs pull'
  
    # 6. Set up Signing Keys
    mkdir -p vendor/custom-priv/keys
    git clone --depth=1 https://github.com/sreepadmarat/buildscripts.git vendor/custom-priv/keys/buildscripts_tmp
    mv vendor/custom-priv/keys/buildscripts_tmp/keys vendor/custom-priv/keys
    rm -rf vendor/custom-priv/keys/buildscripts_tmp
    sed -i 's|vendor/lineage-priv/keys/releasekey|vendor/custom-priv/keys/releasekey|g' vendor/custom-priv/keys/keys.mk

  
    # 7. Export build environment
    export TZ=Asia/Kolkata
    export BUILD_USERNAME=sreepadmarat
    export BUILD_HOSTNAME=barbatos
    echo "======= Export Done ======"
  
    # 8. Setup environment & start build
    . build/envsetup.sh
    lunch larry-cp2a-userdebug
  
    mka bacon
