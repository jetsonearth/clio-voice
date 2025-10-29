#!/bin/bash

# Notarization Setup Script for Clio
# This script helps you set up the environment variables needed for notarization

echo "🍎 Clio Notarization Setup"
echo "=========================="
echo ""

# Check if already configured
if [ -n "$APPLE_ID" ] && [ -n "$APP_SPECIFIC_PASSWORD" ]; then
    echo "✅ Notarization credentials are already configured:"
    echo "   APPLE_ID: $APPLE_ID"
    echo "   APP_SPECIFIC_PASSWORD: [HIDDEN]"
    echo ""
    echo "Your deploy scripts will automatically notarize apps!"
    exit 0
fi

echo "To enable automatic notarization, you need:"
echo "1. Apple ID (the email for your Developer account)"
echo "2. App-specific password (generated at appleid.apple.com)"
echo ""

echo "📋 Steps to get an app-specific password:"
echo "1. Go to https://appleid.apple.com"
echo "2. Sign in with your Apple ID"
echo "3. Go to 'Sign-In and Security' → 'App-Specific Passwords'"
echo "4. Click '+' to generate a new password"
echo "5. Name it 'Clio Notarization'"
echo "6. Copy the generated password (format: abcd-efgh-ijkl-mnop)"
echo ""

read -p "Enter your Apple ID (email): " apple_id
echo ""
read -s -p "Enter your app-specific password: " app_password
echo ""
echo ""

if [ -z "$apple_id" ] || [ -z "$app_password" ]; then
    echo "❌ Both Apple ID and app-specific password are required."
    exit 1
fi

# Add to shell profile
SHELL_PROFILE=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
fi

if [ -n "$SHELL_PROFILE" ]; then
    echo "" >> "$SHELL_PROFILE"
    echo "# Clio Notarization Credentials" >> "$SHELL_PROFILE"
    echo "export APPLE_ID=\"$apple_id\"" >> "$SHELL_PROFILE"
    echo "export APP_SPECIFIC_PASSWORD=\"$app_password\"" >> "$SHELL_PROFILE"
    
    echo "✅ Notarization credentials added to $SHELL_PROFILE"
    echo ""
    echo "🔄 To activate the changes, run:"
    echo "   source $SHELL_PROFILE"
    echo ""
    echo "Or open a new terminal window."
else
    echo "⚠️  Couldn't detect your shell profile. Please manually add:"
    echo ""
    echo "export APPLE_ID=\"$apple_id\""
    echo "export APP_SPECIFIC_PASSWORD=\"$app_password\""
    echo ""
    echo "to your shell profile (.zshrc, .bash_profile, etc.)"
fi

echo ""
echo "🚀 Once configured, your deploy scripts will automatically:"
echo "   • Sign apps with hardened runtime"
echo "   • Submit to Apple for notarization"
echo "   • Wait for approval (5-15 minutes)"
echo "   • Staple the notarization ticket"
echo "   • Verify Gatekeeper compliance"
echo ""
echo "No more security warnings for your users! 🎉"