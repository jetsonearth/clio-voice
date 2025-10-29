#!/bin/bash

# Reset Clio Authentication State
echo "🔄 Resetting Clio authentication state..."

# Kill Clio if running
pkill -f Clio || true

# Clear UserDefaults
echo "📱 Clearing UserDefaults..."
defaults delete com.jetsonai.clio SupabaseSession 2>/dev/null || true
defaults delete com.jetsonai.clio userEmail 2>/dev/null || true
defaults delete com.jetsonai.clio savedCredentials 2>/dev/null || true

# Clear Keychain items
echo "🔐 Clearing Keychain items..."
security delete-generic-password -s "com.jetsonai.clio.auth" -a "userSession" 2>/dev/null || true
security delete-generic-password -s "com.jetsonai.clio.auth" -a "savedCredentials" 2>/dev/null || true

# Clear trial validation cache
echo "🗑️ Clearing trial validation cache..."
defaults delete com.jetsonai.clio cachedTrialValidation 2>/dev/null || true
defaults delete com.jetsonai.clio trialValidationSignature 2>/dev/null || true

echo "✅ Authentication state cleared!"
echo ""
echo "📝 Next steps:"
echo "1. Rebuild and run Clio"
echo "2. Sign in with your credentials again"
echo "3. The app will get a fresh authentication token"