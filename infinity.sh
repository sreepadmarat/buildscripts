#!/bin/bash

# ========================================================
#  SCRIPT CONFIGURATION
# ========================================================
START_TIME=$(date +%s)
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ========================================================
#  PHASE 1: CLEANUP & SYNC
# ========================================================
echo -e "\n${BLUE}➜ [PHASE 1/5] Cleaning up old files...${NC}"

# 1. Delete output (CRITICAL to remove poisoned config)
rm -rf out/

# 2. Delete trees to ensure fresh clones
# 3. Clean kernel objects to prevent using old broken files
rm -rf device/oneplus/larry device/oneplus/sm6375-common
rm -rf vendor/oneplus/larry vendor/oneplus/sm6375-common
rm -rf kernel/oneplus/sm6375 hardware/oplus
rm -rf .repo/local_manifests

echo -e "\n${BLUE}➜ [PHASE 2/5] Syncing Repositories...${NC}"
repo init -u https://github.com/ProjectInfinity-X/manifest.git -b 16-QPR2 --git-lfs
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
/opt/crave/resync.sh
echo -e "${GREEN}✔ Sync Complete.${NC}"

# ========================================================
#  PHASE 2: CLONING SOURCES
# ========================================================
echo -e "\n${BLUE}➜ [PHASE 3/5] Downloading Device Trees...${NC}"

# Device & Vendor Trees
git clone https://github.com/sreepadmarat/android_device_oneplus_larry.git -b infinity device/oneplus/larry
git clone https://github.com/sreepadmarat/android_device_oneplus_sm6375-common.git -b infinity device/oneplus/sm6375-common
git clone https://github.com/TheMuppets/proprietary_vendor_oneplus_larry.git -b lineage-23.2 vendor/oneplus/larry
git clone https://github.com/TheMuppets/proprietary_vendor_oneplus_sm6375-common.git -b lineage-23.2 vendor/oneplus/sm6375-common
git clone https://github.com/LineageOS/android_kernel_oneplus_sm6375.git -b lineage-23.2 kernel/oneplus/sm6375
git clone https://github.com/sreepadmarat/android_hardware_oplus.git -b infinity hardware/oplus

echo -e "${GREEN}✔ All downloads finished.${NC}"
echo -e "\n${BLUE}➜ [PHASE 5/5] Starting Build...${NC}"

. build/envsetup.sh
# Using Lineage naming
lunch infinity_larry-bp4a-userdebug

echo "Cleaning old images to apply new tweaks..."
make installclean

echo "========================="
echo "Starting ROM Compilation..."
echo "========================="
m bacon -j$(nproc --all); echo "Build finished"


# ========================================================
#  FINISHED
# ========================================================
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
H=$((ELAPSED / 3600))
M=$(( (ELAPSED % 3600) / 60 ))
echo -e "\n${GREEN}✔ Build Completed in ${H}h ${M}m${NC}"
