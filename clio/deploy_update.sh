#!/bin/bash

# Clio Online Update Deployment Script
# This script builds a new version and updates your website

set -e

VERSION="$1"
RELEASE_NOTES="$2"

if [ -z "$VERSION" ] || [ -z "$RELEASE_NOTES" ]; then
    echo "Usage: ./deploy_update.sh <version> <release_notes>"
    echo "Example: ./deploy_update.sh 1.30.1 'Added new AI provider support'"
    exit 1
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🚀 Deploying Clio Online v${VERSION}${NC}"

# Step 1: Build the app
echo -e "${YELLOW}📦 Building app...${NC}"
# Create build directory
mkdir -p build
PROJECT_NAME="Clio"
SCHEME="Clio"
CONFIGURATION="Release"
ARCHIVE_PATH="./build/Clio.xcarchive"

# Clean and build
xcodebuild clean -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME}" -configuration ${CONFIGURATION}
xcodebuild archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration ${CONFIGURATION} \
    -archivePath "${ARCHIVE_PATH}" \
    -destination "generic/platform=macOS" \
    DEVELOPMENT_TEAM=MFDGY9T8T9 \
    OTHER_CODE_SIGN_FLAGS="--timestamp --options runtime" \
    -allowProvisioningUpdates

# Extract app from archive (skip export - no provisioning profiles needed!)
echo -e "${YELLOW}📤 Extracting signed app from archive...${NC}"
mkdir -p "./build/Release"
cp -R "${ARCHIVE_PATH}/Products/Applications/Clio.app" "./build/Release/"

# Safety: prune any bundled Whisper models before packaging
APP_PATH="./build/Release/Clio.app"
RES_DIR="${APP_PATH}/Contents/Resources"
echo -e "${YELLOW}🧹 Pruning bundled Whisper models (if any)...${NC}"
rm -rf "${RES_DIR}/WhisperModels" 2>/dev/null || true
rm -rf "${APP_PATH}/WhisperModels" 2>/dev/null || true
rm -rf "${APP_PATH}/Contents/SharedSupport/WhisperModels" 2>/dev/null || true
if [ -d "${RES_DIR}" ]; then
  find "${RES_DIR}" -type f -name "ggml-*.bin" ! -name "ggml-silero-*" -print -delete || true
  find "${APP_PATH}" -type f \( -name "*large-v3*" -o -name "*large-v2*" -o -name "*large.bin" -o -name "*.mlmodelc.zip" \) -print -delete || true
fi

# Step 2: Create DMG
echo -e "${YELLOW}💿 Creating DMG...${NC}"
APP_PATH="./build/Release/Clio.app"
DMG_NAME="Clio-v${VERSION}"
DMG_PATH="./build/${DMG_NAME}.dmg"
TEMP_DMG_PATH="./build/temp.dmg"
MOUNT_POINT="./build/dmg_mount"
VOLUME_NAME="Clio Installer"

# Clean up previous builds
rm -rf "${DMG_PATH}" "${TEMP_DMG_PATH}" "${MOUNT_POINT}"

# Create DMG
hdiutil create -size 200m -fs HFS+ -volname "${VOLUME_NAME}" "${TEMP_DMG_PATH}"
hdiutil attach "${TEMP_DMG_PATH}" -mountpoint "${MOUNT_POINT}"
cp -R "${APP_PATH}" "${MOUNT_POINT}/"
ln -s /Applications "${MOUNT_POINT}/Applications"
hdiutil detach "${MOUNT_POINT}"
hdiutil convert "${TEMP_DMG_PATH}" -format UDZO -o "${DMG_PATH}"
rm -rf "${TEMP_DMG_PATH}" "${MOUNT_POINT}"

# Sign the DMG with Developer ID
echo -e "${YELLOW}🔐 Signing DMG with Developer ID...${NC}"
codesign --timestamp --options runtime --sign "Developer ID Application: Zhaobang Wu (MFDGY9T8T9)" "${DMG_PATH}"

# Notarize the DMG with Apple
echo -e "${YELLOW}🍎 Submitting DMG for notarization...${NC}"
echo -e "${YELLOW}   This may take 5-15 minutes...${NC}"

# Check if notarization credentials are set
if [ -z "$APPLE_ID" ] || [ -z "$APP_SPECIFIC_PASSWORD" ]; then
    echo -e "${YELLOW}⚠️  Notarization credentials not set.${NC}"
    echo -e "${YELLOW}   Set APPLE_ID and APP_SPECIFIC_PASSWORD environment variables.${NC}"
    echo -e "${YELLOW}   DMG is signed but not notarized - users will see security warnings.${NC}"
else
    # Submit for notarization
    SUBMISSION_ID=$(xcrun notarytool submit "${DMG_PATH}" \
        --apple-id "$APPLE_ID" \
        --password "$APP_SPECIFIC_PASSWORD" \
        --team-id "MFDGY9T8T9" \
        --output-format json | jq -r '.id')
    
    if [ "$SUBMISSION_ID" != "null" ] && [ -n "$SUBMISSION_ID" ]; then
        echo -e "${GREEN}✅ Submitted for notarization (ID: $SUBMISSION_ID)${NC}"
        echo -e "${YELLOW}   Waiting for Apple's approval...${NC}"
        
        # Wait for notarization to complete
        xcrun notarytool wait "$SUBMISSION_ID" \
            --apple-id "$APPLE_ID" \
            --password "$APP_SPECIFIC_PASSWORD" \
            --team-id "MFDGY9T8T9"
        
        # Check if notarization succeeded
        STATUS=$(xcrun notarytool info "$SUBMISSION_ID" \
            --apple-id "$APPLE_ID" \
            --password "$APP_SPECIFIC_PASSWORD" \
            --team-id "MFDGY9T8T9" \
            --output-format json | jq -r '.status')
        
        if [ "$STATUS" = "Accepted" ]; then
            echo -e "${GREEN}🎉 Notarization successful!${NC}"
            
            # Staple the notarization ticket
            echo -e "${YELLOW}📎 Stapling notarization ticket...${NC}"
            xcrun stapler staple "${DMG_PATH}"
            
            # Verify the final result
            echo -e "${YELLOW}🔍 Verifying notarized DMG...${NC}"
            if spctl -a -vv "${DMG_PATH}" 2>/dev/null; then
                echo -e "${GREEN}✅ DMG passes Gatekeeper verification!${NC}"
            else
                echo -e "${YELLOW}⚠️  DMG may still show warnings - check Gatekeeper settings${NC}"
            fi
        else
            echo -e "${RED}❌ Notarization failed with status: $STATUS${NC}"
            echo -e "${YELLOW}   DMG is signed but not notarized - users will see security warnings.${NC}"
        fi
    else
        echo -e "${RED}❌ Failed to submit for notarization${NC}"
        echo -e "${YELLOW}   DMG is signed but not notarized - users will see security warnings.${NC}"
    fi
fi

# Step 3: Get file size
FILE_SIZE=$(stat -f%z "$DMG_PATH")

# Step 4: Create online directory structure if it doesn't exist
mkdir -p /Users/ZhaobangJetWu/clio-landing/public/online/downloads

# Step 5: Update appcast.xml
echo -e "${YELLOW}📝 Updating appcast.xml...${NC}"
CURRENT_DATE=$(date -u +"%a, %d %b %Y %H:%M:%S +0000")
VERSION_NUMBER=$(($(echo $VERSION | tr -d '.') + 0))

# Create new appcast entry for online version
cat > temp_appcast.xml << EOF
<?xml version="1.0" standalone="yes"?>
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
    <channel>
        <title>Clio Online Releases</title>
        <description>Updates for Clio Online - AI-powered voice transcription with cloud enhancement</description>
        <language>en</language>
        <link>https://www.cliovoice.com/</link>
        
        <item>
            <title>Clio Online ${VERSION}</title>
            <pubDate>${CURRENT_DATE}</pubDate>
            <sparkle:version>${VERSION_NUMBER}</sparkle:version>
            <sparkle:shortVersionString>${VERSION}</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
            <description><![CDATA[
                <h3>Clio Online ${VERSION} 🚀</h3>
                <p>${RELEASE_NOTES}</p>
            ]]></description>
            <enclosure 
                url="https://www.cliovoice.com/online/downloads/Clio-v${VERSION}.dmg" 
                length="${FILE_SIZE}" 
                type="application/octet-stream" 
                sparkle:version="${VERSION_NUMBER}"
                sparkle:shortVersionString="${VERSION}"
                sparkle:edSignature="SIGNATURE_PLACEHOLDER"
                sparkle:minimumSystemVersion="13.0" />
        </item>
    </channel>
</rss>
EOF

# Step 6: Copy to website and update symlink
echo -e "${YELLOW}🌐 Deploying to website...${NC}"
cp temp_appcast.xml /Users/ZhaobangJetWu/clio-landing/public/online/appcast.xml
cp "$DMG_PATH" "/Users/ZhaobangJetWu/clio-landing/public/online/downloads/"
cd "/Users/ZhaobangJetWu/clio-landing/public/online/downloads/"
ln -sf "Clio-v${VERSION}.dmg" "latest.dmg"
cd - > /dev/null

# Step 7: Symlinks automatically handle latest versions
echo -e "${GREEN}✅ Symlink updated - no need to modify vercel.json${NC}"

# Clean up
rm temp_appcast.xml

echo -e "${GREEN}✅ Deployment complete!${NC}"
echo -e "${GREEN}📁 Files ready in your website project:${NC}"
echo "   - /online/appcast.xml"
echo "   - /online/downloads/Clio-v${VERSION}.dmg"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. cd /Users/ZhaobangJetWu/clio-landing"
echo "2. git add public/online/ vercel.json"
echo "3. git commit -m 'Release Clio Online v${VERSION}'"
echo "4. git push (Vercel will auto-deploy)"
echo ""
echo -e "${GREEN}🚀 Quick deploy commands:${NC}"
echo "cd /Users/ZhaobangJetWu/clio-landing"
echo "git add public/online/ vercel.json && git commit -m 'Release Clio Online v${VERSION}' && git push"
