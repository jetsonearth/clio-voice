# Migrating to Supabase Swift SDK

## Steps to Add Supabase Swift SDK to Clio

### 1. Add Package Dependency in Xcode

1. Open `Clio.xcodeproj` in Xcode
2. Go to **File > Add Package Dependencies...**
3. Enter the package URL: `https://github.com/supabase/supabase-swift`
4. Click **Add Package**
5. Select the following products:
   - ✅ Supabase
   - ✅ Auth
   - ✅ Functions
   - ✅ PostgREST
   - ✅ Realtime
   - ✅ Storage

### 2. Update the App Initialization

Replace the current SupabaseService initialization in `Clio.swift`:

```swift
// Replace this:
@StateObject private var supabaseService = SupabaseService.shared

// With this:
@StateObject private var supabaseService = SupabaseServiceSDK.shared
```

### 3. Benefits of the New Implementation

The new `SupabaseServiceSDK` provides:

1. **Automatic Session Management**
   - Sessions are automatically persisted and restored
   - Tokens are automatically refreshed before expiration
   - No manual refresh token handling needed

2. **Built-in Auth State Listener**
   - Real-time auth state changes
   - Automatic UI updates when auth state changes
   - Proper event handling for sign in/out

3. **Type-Safe API**
   - Strongly typed responses
   - Better error handling
   - No manual JSON parsing

4. **Simplified Code**
   - ~400 lines vs ~1000+ lines
   - No manual HTTP requests
   - No manual token storage

### 4. Key Differences

| Old (Manual) | New (SDK) |
|--------------|-----------|
| Manual URLSession requests | `client.auth.signIn()` |
| Manual token refresh | Automatic with `autoRefreshToken: true` |
| Manual session storage | Automatic with `persistSession: true` |
| Manual error parsing | Typed error handling |
| Complex refresh logic | Built-in auth state listener |

### 5. Testing Automatic Sign-In

With the SDK implementation:
1. Sign in once with email/password
2. Close the app
3. Reopen - you'll be automatically signed in
4. The SDK handles:
   - Loading stored session
   - Checking if it's valid
   - Refreshing if needed
   - Updating UI state

No more "signing in..." stuck state or manual credential management!