#!/bin/bash                                                                                                                                                                                   
                                                                                                                                                                                                  
    # 1. Pre-clean custom trees from previous runs                                                                                                                                                
    rm -rf device/oneplus/larry                                                                                                                                                                   
    rm -rf device/oneplus/sm6375-common                                                                                                                                                           
    rm -rf hardware/oplus                                                                                                                                                                         
    rm -rf kernel/oneplus/sm6375                                                                                                                                                                  
    rm -rf vendor/oneplus/larry                                                                                                                                                                   
    rm -rf vendor/oneplus/sm6375-common                                                                                                                                                           
    rm -rf vendor/voltage-priv/keys
                                                                                                                                                                                                  
    # 2. Initialize Custom ROM / ASCP Manifest                                                                                                                                                    
    repo init -u https://github.com/VoltageOS/manifest.git -b 17 --git-lfs --depth=1                                                                                                     
    echo "=================="                                                                                                                                                                     
    echo "Repo init success"                                                                                                                                                                      
    echo "=================="                                                                                                                                                                     
                                                                                                                                                                                                  
    # 3. Sync the base platform repositories FIRST                                                                                                                                                
    /opt/crave/resync.sh
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
    rm -rf build/soong
    echo "============ Base Repo Sync Successful ==============="
    
    # 4. Clone adapted VoltageOS trees (--depth=1 for fast cloning)
    git clone --depth=1 -b voltage https://github.com/sreepadmarat/android_device_oneplus_larry.git device/oneplus/larry
    git clone --depth=1 -b voltage https://github.com/sreepadmarat/android_device_oneplus_sm6375-common.git device/oneplus/sm6375-common
    git clone --depth=1 -b voltage https://github.com/sreepadmarat/android_hardware_oplus.git hardware/oplus
    git clone --depth=1 -b voltage https://github.com/sreepadmarat/android_kernel_oneplus_sm6375.git kernel/oneplus/sm6375
    git clone --depth=1 -b lineage-24.0 https://github.com/TheMuppets/proprietary_vendor_oneplus_larry.git vendor/oneplus/larry
    git clone --depth=1 -b lineage-24.0 https://github.com/TheMuppets/proprietary_vendor_oneplus_sm6375-common.git vendor/oneplus/sm6375-common
    git clone --depth=1 -b 17 https://github.com/sreepadmarat/build_soong.git build/soong
  
    # 5. Download Git LFS Artifacts
    repo forall -c 'git lfs pull'
  
    # 6. Set up Signing Keys
    mkdir -p vendor/voltage-priv/keys
    git clone --depth=1 https://github.com/sreepadmarat/buildscripts.git vendor/voltage-priv/keys/buildscripts_tmp
    mv vendor/voltage-priv/keys/buildscripts_tmp/keys/* vendor/voltage-priv/keys/
    rm -rf vendor/voltage-priv/keys/buildscripts_tmp
    
    # 7. Setup environment & start build
    export ROOMSERVICE_BRANCHES=false
    . build/envsetup.sh
  
    # Re-export username/hostname AFTER envsetup.sh
    export TZ=Asia/Kolkata
    export BUILD_USERNAME=sreepadmarat
    export BUILD_HOSTNAME=barbatos
    echo "======= Environment Setup Complete ======"
  
    lunch voltage_larry-cp2a-userdebug
    m installclean
  
    mka updatepackage
