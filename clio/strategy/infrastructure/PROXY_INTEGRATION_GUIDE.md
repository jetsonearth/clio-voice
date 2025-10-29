# Clio Proxy Integration Guide

This guide explains how to update the Clio macOS app to use the new Vercel proxy endpoints instead of direct API connections.

## Overview

The proxy architecture provides:
- Secure API key management (keys stay on server)
- Usage tracking and rate limiting
- Dynamic account management
- Cost monitoring

## API Endpoints

### Base URL
```swift
let API_BASE = ProcessInfo.processInfo.environment["CLIO_API_URL"] ?? "https://cliovoice.com"
```

### Endpoints
1. **Authentication**: `POST /api/auth/session`
2. **LLM Enhancement**: `POST /api/llm/clean`
3. **ASR Streaming**: `WSS /api/asr/stream-edge`
4. **Usage Tracking**: `GET /api/usage/track`

## Implementation Steps

### 1. Add Token Management

Create a new `TokenManager` class:

```swift
// Clio/Services/Auth/TokenManager.swift
import Foundation
import KeychainAccess

@MainActor
class TokenManager: ObservableObject {
    static let shared = TokenManager()
    
    @Published var token: String?
    @Published var tokenExpiry: Date?
    
    private let keychain = Keychain(service: "com.jetsonai.clio")
    private let apiBase = ProcessInfo.processInfo.environment["CLIO_API_URL"] ?? "https://api.tryclio.com"
    
    init() {
        loadToken()
    }
    
    private func loadToken() {
        token = keychain["auth_token"]
        if let expiryString = keychain["token_expiry"],
           let expiryTime = Double(expiryString) {
            tokenExpiry = Date(timeIntervalSince1970: expiryTime)
        }
    }
    
    func authenticate() async throws -> String {
        // Check if token is still valid
        if let token = token, let expiry = tokenExpiry, expiry > Date() {
            return token
        }
        
        // Get new token
        let deviceId = getOrCreateDeviceId()
        let url = URL(string: "\(apiBase)/api/auth/session")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["deviceId": deviceId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AuthError.authenticationFailed
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        // Store token
        keychain["auth_token"] = authResponse.token
        keychain["token_expiry"] = String(Date().timeIntervalSince1970 + Double(authResponse.expiresIn))
        
        token = authResponse.token
        tokenExpiry = Date().addingTimeInterval(Double(authResponse.expiresIn))
        
        return authResponse.token
    }
    
    private func getOrCreateDeviceId() -> String {
        if let deviceId = keychain["device_id"] {
            return deviceId
        }
        let newId = UUID().uuidString
        keychain["device_id"] = newId
        return newId
    }
}

struct AuthResponse: Codable {
    let token: String
    let expiresIn: Int
    let session: SessionInfo
}

struct SessionInfo: Codable {
    let id: String
    let plan: String
    let dailyUsage: DailyUsage
}

struct DailyUsage: Codable {
    let audioSeconds: Int
    let llmTokens: Int
    let lastReset: String
}

enum AuthError: LocalizedError {
    case authenticationFailed
    
    var errorDescription: String? {
        "Failed to authenticate with Clio servers"
    }
}
```

### 2. Update SonioxStreamingService

Update the WebSocket connection to use the proxy:

```swift
// In SonioxStreamingService.swift

private func connectWebSocket() async throws {
    // Get auth token
    let token = try await TokenManager.shared.authenticate()
    
    // Use proxy endpoint
    let apiBase = ProcessInfo.processInfo.environment["CLIO_API_URL"] ?? "https://api.tryclio.com"
    let proxyEndpoint = "\(apiBase.replacingOccurrences(of: "https://", with: "wss://"))/api/asr/stream-edge"
    
    // Add token and language to URL
    let selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "auto"
    guard var urlComponents = URLComponents(string: proxyEndpoint) else {
        throw SonioxError.invalidEndpoint
    }
    
    urlComponents.queryItems = [
        URLQueryItem(name: "token", value: token),
        URLQueryItem(name: "language", value: selectedLanguage)
    ]
    
    guard let url = urlComponents.url else {
        throw SonioxError.invalidEndpoint
    }
    
    webSocket = urlSession.webSocketTask(with: url)
    webSocket?.resume()
    
    // No need to send API key - proxy handles it
    logger.notice("✅ Connected to Clio proxy for ASR")
    
    // ... rest of the connection logic
}
```

### 3. Update AIEnhancementService

Update the LLM calls to use the proxy:

```swift
// In AIEnhancementService.swift

private func makeRequest(text: String, mode: EnhancementPrompt, retryCount: Int = 0) async throws -> String {
    // Get auth token
    let token = try await TokenManager.shared.authenticate()
    
    // Use proxy endpoint
    let apiBase = ProcessInfo.processInfo.environment["CLIO_API_URL"] ?? "https://api.tryclio.com"
    let url = URL(string: "\(apiBase)/api/llm/clean")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.timeoutInterval = baseTimeout
    
    let requestBody: [String: Any] = [
        "text": text,
        "model": aiService.currentModel,
        "systemPrompt": getSystemMessage(for: mode)
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    
    let (data, response) = try await urlSession.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw EnhancementError.invalidResponse
    }
    
    switch httpResponse.statusCode {
    case 200:
        guard let jsonResponse = try? JSONDecoder().decode(LLMResponse.self, from: data) else {
            throw EnhancementError.enhancementFailed
        }
        return jsonResponse.text
        
    case 401:
        // Token expired, retry with new token
        TokenManager.shared.token = nil
        if retryCount < 1 {
            return try await makeRequest(text: text, mode: mode, retryCount: retryCount + 1)
        }
        throw EnhancementError.authenticationFailed
        
    case 402:
        throw EnhancementError.usageLimitExceeded
        
    case 429:
        throw EnhancementError.rateLimitExceeded
        
    default:
        throw EnhancementError.serverError
    }
}

struct LLMResponse: Codable {
    let text: String
    let usage: LLMUsage?
}

struct LLMUsage: Codable {
    let inputTokens: Int?
    let outputTokens: Int?
    let totalTokens: Int?
}
```

### 4. Remove API Keys from App

Update the configuration files to remove hardcoded API keys:

```swift
// Remove from AIService.swift
// DELETE: private let groqAPIKey = "..."

// Remove from SonioxStreamingService.swift  
// DELETE: private var apiKey: String { ... }

// Remove from Info.plist or config files
// DELETE: Any API key entries
```

### 5. Add Usage Tracking

Create a usage monitoring service:

```swift
// Clio/Services/UsageService.swift
import Foundation

@MainActor
class UsageService: ObservableObject {
    static let shared = UsageService()
    
    @Published var dailyUsage: DailyUsage?
    @Published var remaining: UsageRemaining?
    
    private let apiBase = ProcessInfo.processInfo.environment["CLIO_API_URL"] ?? "https://api.tryclio.com"
    
    func fetchUsage() async {
        do {
            let token = try await TokenManager.shared.authenticate()
            let url = URL(string: "\(apiBase)/api/usage/track")!
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(UsageResponse.self, from: data)
            
            dailyUsage = response.usage
            remaining = response.remaining
        } catch {
            logger.error("Failed to fetch usage: \(error)")
        }
    }
}

struct UsageResponse: Codable {
    let usage: DailyUsage
    let limits: UsageLimits
    let remaining: UsageRemaining
    let plan: String
    let resetAt: TimeInterval
}

struct UsageLimits: Codable {
    let audioSeconds: Int
    let llmTokens: Int
}

struct UsageRemaining: Codable {
    let audioSeconds: String
    let llmTokens: String
}
```

### 6. Environment Configuration

Add to your Xcode scheme environment variables:

```
CLIO_API_URL = https://api.tryclio.com  # Production
CLIO_API_URL = http://localhost:3000    # Local development
```

## Testing

1. **Local Testing**: Run `vercel dev` in the clio-landing directory
2. **Staging**: Deploy to Vercel preview branch
3. **Production**: Deploy to main Vercel project

## Migration Checklist

- [ ] Add TokenManager class
- [ ] Update SonioxStreamingService to use proxy
- [ ] Update AIEnhancementService to use proxy  
- [ ] Remove all hardcoded API keys
- [ ] Add usage tracking UI
- [ ] Test with local Vercel dev server
- [ ] Test with Vercel preview deployment
- [ ] Deploy to production

## Benefits

1. **Security**: API keys never exposed to clients
2. **Flexibility**: Add/remove accounts without app updates
3. **Monitoring**: Track usage and costs per user
4. **Control**: Rate limiting and usage caps
5. **Scalability**: Easy to add more providers

## Notes

- The proxy adds ~10-30ms latency (negligible for ASR/LLM)
- WebSocket support requires Vercel Edge Runtime
- Consider implementing token refresh 5 minutes before expiry
- Add retry logic for transient network failures