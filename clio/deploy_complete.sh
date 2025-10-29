#!/bin/bash

# Complete Clio Online Deployment Script
# This script does EVERYTHING: build → sign → notarize → deploy → push to GitHub

set -e  # Exit on any error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 COMPLETE CLIO ONLINE DEPLOYMENT STARTED${NC}"
echo -e "${YELLOW}This will: build → sign → notarize → deploy → push to GitHub${NC}"
echo

# Function to get current version from Xcode project
get_current_version() {
    grep -m 1 "MARKETING_VERSION = " Clio.xcodeproj/project.pbxproj | sed 's/.*MARKETING_VERSION = \([^;]*\);.*/\1/' | xargs
}

# Function to increment version
increment_version() {
    local version=$1
    local type=$2
    
    IFS='.' read -ra VERSION_PARTS <<< "$version"
    local major=${VERSION_PARTS[0]}
    local minor=${VERSION_PARTS[1]}
    local patch=${VERSION_PARTS[2]}
    
    case $type in
        "patch"|"p")
            patch=$((patch + 1))
            ;;
        "minor"|"m")
            minor=$((minor + 1))
            patch=0
            ;;
        "major"|"M")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        *)
            echo "Invalid version type. Use: patch|minor|major"
            exit 1
            ;;
    esac
    
    echo "${major}.${minor}.${patch}"
}

# Get current version
CURRENT_VERSION=$(get_current_version)
echo -e "${BLUE}📋 Current version: ${CURRENT_VERSION}${NC}"

# Special handling for first deployment - reset to 1.0.0
if [ "$CURRENT_VERSION" = "1.30" ]; then
    echo -e "${YELLOW}🔄 Detected legacy version (1.30), resetting to 1.0.0 base${NC}"
    echo -e "${YELLOW}Choose how to start the new versioning:${NC}"
    echo "  [r] reset to 1.0.0 (recommended for first deployment)"
    echo "  [c] continue from current (1.30 → 1.30.1)"
    read -p "Choose [r/c]: " RESET_CHOICE
    
    case $RESET_CHOICE in
        "r"|"reset")
            NEW_VERSION="1.0.0"
            echo -e "${GREEN}🎯 Starting fresh with v1.0.0${NC}"
            ;;
        "c"|"continue")
            NEW_VERSION=$(increment_version $CURRENT_VERSION patch)
            ;;
        *)
            NEW_VERSION="1.0.0"
            echo -e "${GREEN}🎯 Defaulting to v1.0.0${NC}"
            ;;
    esac
else
    # Normal version increment for subsequent deployments
    echo -e "${YELLOW}How do you want to increment the version?${NC}"
    echo "  [p] patch (${CURRENT_VERSION} → $(increment_version $CURRENT_VERSION patch))"
    echo "  [m] minor (${CURRENT_VERSION} → $(increment_version $CURRENT_VERSION minor))"  
    echo "  [M] major (${CURRENT_VERSION} → $(increment_version $CURRENT_VERSION major))"
    echo "  [c] custom version"
    echo "  [s] skip version bump (use current: ${CURRENT_VERSION})"
    read -p "Choose [p/m/M/c/s]: " VERSION_TYPE

    case $VERSION_TYPE in
        "p"|"patch")
            NEW_VERSION=$(increment_version $CURRENT_VERSION patch)
            ;;
        "m"|"minor")
            NEW_VERSION=$(increment_version $CURRENT_VERSION minor)
            ;;
        "M"|"major")
            NEW_VERSION=$(increment_version $CURRENT_VERSION major)
            ;;
        "c"|"custom")
            read -p "Enter custom version (e.g., 2.1.0): " NEW_VERSION
            ;;
        "s"|"skip")
            NEW_VERSION=$CURRENT_VERSION
            ;;
        *)
            echo -e "${RED}Invalid choice. Using patch increment.${NC}"
            NEW_VERSION=$(increment_version $CURRENT_VERSION patch)
            ;;
    esac
fi

echo -e "${GREEN}📈 New version: ${NEW_VERSION}${NC}"

# Ask for release notes
echo -e "${YELLOW}📝 Paste your release notes below. Press Ctrl-D when finished:${NC}"

# Disable bracketed paste temporarily
printf '\e[?2004l'

# Read input
RELEASE_NOTES=$(cat < /dev/tty)

# Re-enable bracketed paste
printf '\e[?2004h'


if [[ -z $RELEASE_NOTES ]]; then
    RELEASE_NOTES="- Bug fixes and improvements"
fi

echo -e "${BLUE}📋 Release notes:${NC}"
echo "$RELEASE_NOTES"
echo

# Update version in project files
echo -e "${GREEN}🔧 Updating version in project files...${NC}"
sed -i '' "s/MARKETING_VERSION = [^;]*/MARKETING_VERSION = $NEW_VERSION/g" Clio.xcodeproj/project.pbxproj
# Update build number to match Sparkle version (remove dots from version)
BUILD_NUMBER=${NEW_VERSION//./}
sed -i '' "s/CURRENT_PROJECT_VERSION = [^;]*/CURRENT_PROJECT_VERSION = $BUILD_NUMBER/g" Clio.xcodeproj/project.pbxproj
echo -e "${GREEN}✅ Updated project.pbxproj with version $NEW_VERSION and build $BUILD_NUMBER${NC}"

# Set DMG_NAME environment variable for create_dmg.sh
export DMG_NAME="Clio-v${NEW_VERSION}"
echo -e "${GREEN}✅ Set DMG_NAME environment variable: ${DMG_NAME}${NC}"

# Step 1: Build and sign the app
echo -e "${GREEN}📦 Step 1: Building and signing app...${NC}"
./build_release.sh

# Step 2: Create and notarize DMG
echo -e "${GREEN}💿 Step 2: Creating and notarizing DMG...${NC}"
export APPLE_ID="darahuang@126.com"
export APP_SPECIFIC_PASSWORD="zzpm-gopa-tyeb-lnre"

./create_dmg.sh

# Define DMG filename (use consistent naming)
DMG_FILE="./build/Clio-v${NEW_VERSION}.dmg"

# Submit for notarization
echo -e "${YELLOW}🍎 Submitting for notarization (this may take 5-15 minutes)...${NC}"
SUBMISSION_ID=$(xcrun notarytool submit "$DMG_FILE" \
    --apple-id "$APPLE_ID" \
    --team-id "MFDGY9T8T9" \
    --password "$APP_SPECIFIC_PASSWORD" \
    --wait \
    --output-format json | jq -r '.id')

# Check if notarization succeeded
NOTARY_STATUS=$(xcrun notarytool info "$SUBMISSION_ID" \
    --apple-id "$APPLE_ID" \
    --team-id "MFDGY9T8T9" \
    --password "$APP_SPECIFIC_PASSWORD" \
    --output-format json | jq -r '.status')

if [ "$NOTARY_STATUS" = "Accepted" ]; then
    echo -e "${GREEN}✅ Notarization successful!${NC}"
    
    # Staple the notarization ticket
    xcrun stapler staple "$DMG_FILE"
    echo -e "${GREEN}✅ Notarization ticket stapled${NC}"
else
    echo -e "${RED}❌ Notarization failed. Status: $NOTARY_STATUS${NC}"
    echo "Check logs with: xcrun notarytool log $SUBMISSION_ID --apple-id $APPLE_ID --team-id MFDGY9T8T9 --password $APP_SPECIFIC_PASSWORD"
    exit 1
fi

# Step 3: Copy to website and update symlink
echo -e "${GREEN}🌐 Step 3: Deploying to website...${NC}"
cp "$DMG_FILE" "/Users/ZhaobangJetWu/clio-landing/public/online/downloads/"
cd "/Users/ZhaobangJetWu/clio-landing/public/online/downloads/"
ln -sf "Clio-v${NEW_VERSION}.dmg" "latest.dmg"
cd - > /dev/null
echo -e "${GREEN}✅ DMG copied and latest.dmg updated${NC}"

# Step 3.5: Update vercel.json redirects to use versioned filename  
echo -e "${GREEN}🔧 Updating vercel.json online redirects...${NC}"
cd "/Users/ZhaobangJetWu/clio-landing"
# Update online redirects to use versioned filename (keeps offline redirects unchanged)
sed -i '' "s|/online/downloads/Clio-v[^\"]*\.dmg|/online/downloads/Clio-v${NEW_VERSION}.dmg|g" vercel.json
sed -i '' "s|/online/downloads/latest\.dmg|/online/downloads/Clio-v${NEW_VERSION}.dmg|g" vercel.json
echo -e "${GREEN}✅ Updated online redirects to v${NEW_VERSION} (offline unchanged)${NC}"

# Step 4: Update version in appcast.xml (for Sparkle auto-updates)
echo -e "${GREEN}📡 Step 4: Updating appcast.xml...${NC}"

# Define DMG filename with absolute path (go back to original Clio directory)
cd - > /dev/null
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DMG_FILE="${SCRIPT_DIR}/build/Clio-v${NEW_VERSION}.dmg"

# Get file size of the DMG
if [ ! -f "$DMG_FILE" ]; then
    echo -e "${RED}❌ DMG file not found at: $DMG_FILE${NC}"
    echo -e "${YELLOW}Available files in build directory:${NC}"
    ls -la "${SCRIPT_DIR}/build/"
    exit 1
fi

DMG_SIZE=$(stat -f%z "$DMG_FILE")

# BEGIN: Generate Sparkle ed25519 signature
echo -e "${GREEN}🔑 Generating Sparkle signature...${NC}"
# Path to the private key that pairs with SUPublicEDKey in Info.plist. Override with SPARKLE_PRIVATE_KEY_PATH if needed.
SPARKLE_PRIVATE_KEY_PATH="${SPARKLE_PRIVATE_KEY_PATH:-$HOME/.sparkle_ed25519_private.pem}"
if [ ! -f "$SPARKLE_PRIVATE_KEY_PATH" ]; then
    echo -e "${RED}❌ Sparkle private key not found at $SPARKLE_PRIVATE_KEY_PATH${NC}"
    echo -e "${YELLOW}   Set SPARKLE_PRIVATE_KEY_PATH to your ed25519 private key or place it at ~/.sparkle_ed25519_private.pem${NC}"
    exit 1
fi

# Use the full path to the sign_update tool from Sparkle installation
SIGN_UPDATE_PATH="/opt/homebrew/Caskroom/sparkle/2.7.1/bin/sign_update"
# Pass the private key via stdin to avoid deprecated -s option
PRIVATE_KEY_CONTENT=$(cat "$SPARKLE_PRIVATE_KEY_PATH")
ED_SIGNATURE=$(echo "$PRIVATE_KEY_CONTENT" | "$SIGN_UPDATE_PATH" --ed-key-file - "$DMG_FILE" 2>/dev/null | grep -o 'sparkle:edSignature="[^"]*"' | cut -d'"' -f2)
if [ -z "$ED_SIGNATURE" ]; then
    echo -e "${RED}❌ Failed to generate Sparkle edSignature${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Sparkle signature generated${NC}"
# END: Generate Sparkle ed25519 signature

echo -e "${GREEN}✅ Found DMG file (${DMG_SIZE} bytes)${NC}"

# Get current date in RFC 2822 format
CURRENT_DATE=$(date -R)

# Create new appcast entry
APPCAST_PATH="/Users/ZhaobangJetWu/clio-landing/public/online/appcast.xml"

# Backup existing appcast
cp "$APPCAST_PATH" "${APPCAST_PATH}.bak"

# Create new appcast entry by writing directly to temp file
TEMP_APPCAST=$(mktemp)

# Escape release notes for XML
ESCAPED_NOTES=$(echo "$RELEASE_NOTES" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')

# Write the appcast update directly without using AWK variables for multiline strings
cat > "$TEMP_APPCAST" << EOF
<?xml version="1.0" standalone="yes"?>
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
    <channel>
        <title>Clio Online Releases</title>
        <description>Updates for Clio Online - AI-powered voice transcription with cloud enhancement</description>
        <language>en</language>
        <link>https://www.cliovoice.com/</link>
        
        <item>
            <title>Clio Online ${NEW_VERSION}</title>
            <pubDate>${CURRENT_DATE}</pubDate>
            <sparkle:version>${NEW_VERSION//./}</sparkle:version>
            <sparkle:shortVersionString>${NEW_VERSION}</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
            <description><![CDATA[
                <h3>Clio Online ${NEW_VERSION} 🚀</h3>
                ${ESCAPED_NOTES}
            ]]></description>
            <enclosure 
                url="https://www.cliovoice.com/online/downloads/Clio-v${NEW_VERSION}.dmg" 
                length="${DMG_SIZE}" 
                type="application/octet-stream" 
                sparkle:version="${NEW_VERSION//./}"
                sparkle:shortVersionString="${NEW_VERSION}"
                sparkle:edSignature="${ED_SIGNATURE}"
                sparkle:minimumSystemVersion="13.0" />
        </item>
EOF

# Add any existing items from the old appcast (skip the header)
sed -n '/<item>/,/<\/item>/p' "$APPCAST_PATH" >> "$TEMP_APPCAST"

# Close the XML
cat >> "$TEMP_APPCAST" << EOF
    </channel>
</rss>
EOF

# Replace the original appcast with the updated one
mv "$TEMP_APPCAST" "$APPCAST_PATH"

echo -e "${GREEN}✅ Updated appcast.xml with version ${NEW_VERSION}${NC}"

# Step 5: Commit and push to GitHub
echo -e "${GREEN}📤 Step 5: Pushing to GitHub...${NC}"
cd "/Users/ZhaobangJetWu/clio-landing"

# Add all changes
git add .

# Create commit message with timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
git commit -m "🚀 Deploy Clio Online v${NEW_VERSION} - $TIMESTAMP

${RELEASE_NOTES}
- Updated notarized DMG
- Ready for distribution without security warnings"

# Push to GitHub (this will auto-deploy to Vercel)
git push origin main

echo
echo -e "${BLUE}🎉 DEPLOYMENT COMPLETE!${NC}"
echo -e "${GREEN}✅ App built and signed${NC}"
echo -e "${GREEN}✅ DMG notarized by Apple${NC}"
echo -e "${GREEN}✅ Deployed to website${NC}"
echo -e "${GREEN}✅ Pushed to GitHub${NC}"
echo -e "${GREEN}✅ Vercel will auto-deploy${NC}"
echo
echo -e "${YELLOW}🌍 Your app will be live at: https://clio.so/download/online${NC}"
echo -e "${YELLOW}📱 Users can now download without security warnings!${NC}"