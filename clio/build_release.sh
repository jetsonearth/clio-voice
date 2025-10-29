#!/bin/bash

# Clio Release Build Script
# This script creates a release build ready for distribution

set -e  # Exit on any error

# Configuration
PROJECT_NAME="Clio"
SCHEME="Clio"
CONFIGURATION="Release"
ARCHIVE_PATH="./build/Clio.xcarchive"
EXPORT_PATH="./build/Release"
EXPORT_OPTIONS_PLIST="./ExportOptions.plist"  # <–– new (Developer-ID export options)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Clio Release Build Process${NC}"

# Create build directory
mkdir -p build

# Step 1: Clean build folder
echo -e "${YELLOW}📁 Cleaning build folder...${NC}"
xcodebuild clean -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME}" -configuration ${CONFIGURATION}

# Step 2: Create archive with paid developer account
echo -e "${YELLOW}📦 Creating archive with paid developer account MFDGY9T8T9...${NC}"
xcodebuild archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration ${CONFIGURATION} \
    -archivePath "${ARCHIVE_PATH}" \
    -destination "generic/platform=macOS" \
    DEVELOPMENT_TEAM=MFDGY9T8T9 \
    OTHER_CODE_SIGN_FLAGS="--timestamp --options runtime" \
    -allowProvisioningUpdates

# Step 3: Check if archive was created successfully
if [ ! -d "${ARCHIVE_PATH}" ]; then
    echo -e "${RED}❌ Archive creation failed!${NC}"
    exit 1
fi

# Step 4: Export archive with Developer ID signing (preserves entitlements)
# -----------------------------------------------------------------------
# We let Xcode perform the signing so that all embedded frameworks keep their
# original entitlements. The ExportOptions.plist contains:
#   method = developer-id
#   teamID = MFDGY9T8T9
# -----------------------------------------------------------------------

# Create a default ExportOptions.plist if one does not exist
if [ ! -f "$EXPORT_OPTIONS_PLIST" ]; then
  cat > "$EXPORT_OPTIONS_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>MFDGY9T8T9</string>
</dict>
</plist>
EOF
fi

echo -e "${YELLOW}📤 Exporting signed app from archive via xcodebuild...${NC}"
mkdir -p "${EXPORT_PATH}"

# Retry export up to 3 times due to flaky timestamp servers
RETRY_COUNT=0
MAX_RETRIES=3
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if xcodebuild -exportArchive \
        -archivePath "${ARCHIVE_PATH}" \
        -exportPath "${EXPORT_PATH}" \
        -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
        -allowProvisioningUpdates; then
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo -e "${YELLOW}⚠️ Export failed (timestamp server issue?). Retrying in 5 seconds... (Attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)${NC}"
            sleep 5
        fi
    fi
done

# Verify export success
if [ ! -d "${EXPORT_PATH}/Clio.app" ]; then
    echo -e "${RED}❌ Export failed – app not found after exportArchive${NC}"
    exit 1
fi

echo -e "${GREEN}✅ App exported to ${EXPORT_PATH}/Clio.app${NC}"

# Step 5: Strip any bundled Whisper model binaries (safety guard)
echo -e "${YELLOW}🧹 Pruning bundled Whisper models (if any)...${NC}"
APP_BUNDLE="${EXPORT_PATH}/Clio.app"
RES_DIR="${APP_BUNDLE}/Contents/Resources"
# Never ship end-user Whisper .bin/.mlmodelc models inside the app
rm -rf "${RES_DIR}/WhisperModels" 2>/dev/null || true
rm -rf "${APP_BUNDLE}/WhisperModels" 2>/dev/null || true
rm -rf "${APP_BUNDLE}/Contents/SharedSupport/WhisperModels" 2>/dev/null || true
# Remove any ggml *.bin except the VAD model (ggml-silero-*.bin)
if [ -d "${RES_DIR}" ]; then
  find "${RES_DIR}" -type f -name "ggml-*.bin" ! -name "ggml-silero-*" -print -delete || true
  # Remove any accidental large-v3-turbo artifacts anywhere in the bundle
  find "${APP_BUNDLE}" -type f \( -name "*large-v3*" -o -name "*large-v2*" -o -name "*large.bin" -o -name "*.mlmodelc.zip" \) -print -delete || true
fi

# Step 6: Verify code signing
echo -e "${YELLOW}🔍 Verifying code signing...${NC}"
codesign --verify --verbose=2 "${EXPORT_PATH}/Clio.app"
if spctl --assess --verbose=2 "${EXPORT_PATH}/Clio.app" 2>/dev/null; then
    echo -e "${GREEN}✅ App passes Gatekeeper assessment${NC}"
else
    echo -e "${YELLOW}⚠️ App will show security warning (expected for self-signed)${NC}"
    echo -e "${YELLOW}💡 Users can install by right-clicking and selecting 'Open'${NC}"
fi

# Step 7: Self-signed distribution info
echo -e "${YELLOW}📋 Self-signed distribution notes:${NC}"
echo -e "   • Users will see 'unverified developer' warning"
echo -e "   • Installation: Right-click app → Open → Open anyway"
echo -e "   • This is normal for free distribution without Apple Developer Program"

echo -e "${GREEN}🎉 Release build completed successfully!${NC}"
echo -e "${GREEN}📍 Next steps:${NC}"
echo -e "   1. Test the app: ${EXPORT_PATH}/Clio.app"
echo -e "   2. Notarize with Apple (if you have Developer ID certificates)"
echo -e "   3. Create DMG for distribution"
echo -e "   4. Upload to your website"
