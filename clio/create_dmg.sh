#!/bin/bash

# Simple Clio DMG Creation Script
# Creates a basic DMG without fancy styling

set -e  # Exit on any error

# Configuration
APP_NAME="Clio"
APP_PATH="./build/Release/Clio.app"
# DMG_NAME will be set by deploy_complete.sh via environment variable or default to current version
DMG_NAME=${DMG_NAME:-"$(grep -m 1 "MARKETING_VERSION = " Clio.xcodeproj/project.pbxproj | sed 's/.*MARKETING_VERSION = \([^;]*\);.*/\1/' | xargs | sed 's/^/Clio v/')"}
DMG_PATH="./build/${DMG_NAME}.dmg"
TEMP_DMG_PATH="./build/temp.dmg"
MOUNT_POINT="./build/dmg_mount"
VOLUME_NAME="Clio Installer"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}💿 Starting Simple DMG Creation Process${NC}"

# Check if app exists
if [ ! -d "${APP_PATH}" ]; then
    echo "❌ App not found at ${APP_PATH}"
    exit 1
fi

# Clean up previous builds
rm -rf "${DMG_PATH}" "${TEMP_DMG_PATH}" "${MOUNT_POINT}"
mkdir -p build

# Step 1: Create a temporary DMG
echo -e "${YELLOW}📦 Creating temporary DMG...${NC}"
hdiutil create -size 200m -fs HFS+ -volname "${VOLUME_NAME}" "${TEMP_DMG_PATH}"

# Step 2: Mount the DMG
echo -e "${YELLOW}🔧 Mounting DMG...${NC}"
hdiutil attach "${TEMP_DMG_PATH}" -mountpoint "${MOUNT_POINT}"

# Step 3: Copy the app to the DMG
echo -e "${YELLOW}📁 Copying app to DMG...${NC}"
cp -R "${APP_PATH}" "${MOUNT_POINT}/"

# Step 4: Create Applications symlink
echo -e "${YELLOW}🔗 Creating Applications symlink...${NC}"
ln -s /Applications "${MOUNT_POINT}/Applications"

# Step 5: Unmount the DMG
echo -e "${YELLOW}📤 Unmounting DMG...${NC}"
hdiutil detach "${MOUNT_POINT}"

# Step 6: Convert to final compressed DMG
echo -e "${YELLOW}🗜️ Creating final compressed DMG...${NC}"
hdiutil convert "${TEMP_DMG_PATH}" -format UDZO -o "${DMG_PATH}"

# Step 7: Clean up temporary files
rm -rf "${TEMP_DMG_PATH}" "${MOUNT_POINT}"

# Step 8: Verify the DMG
echo -e "${YELLOW}🔍 Verifying DMG...${NC}"
hdiutil verify "${DMG_PATH}"

echo -e "${GREEN}🎉 DMG created successfully!${NC}"
echo -e "${GREEN}📍 DMG location: ${DMG_PATH}${NC}"
echo -e "${GREEN}📊 DMG size: $(du -h "${DMG_PATH}" | cut -f1)${NC}"

echo -e "${GREEN}🚀 Next steps:${NC}"
echo "   1. Test the DMG by mounting it"
echo "   2. Notarize the DMG (if you have Developer ID certificates)"
echo "   3. Upload to your website for distribution"