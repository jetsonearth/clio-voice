# Production API Key Management Strategy for Clio

## Executive Summary

For production deployment of Clio with multiple Soniox accounts, the recommended approach is a **Backend-for-Frontend (BFF) proxy architecture** combined with **remote configuration management**. This provides maximum security, flexibility, and scalability without requiring app updates for API key changes.

## Current Challenge

- Hardcoded API keys require app updates to add/remove accounts
- Direct client-to-API communication exposes keys to potential extraction
- No centralized control over rate limiting or usage monitoring
- Difficult to rotate keys or handle compromised accounts

## Recommended Architecture: BFF Proxy + Remote Config

### 1. **Proxy Server Architecture** (Primary Recommendation)

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│  Clio App   │─────▶│  BFF Proxy   │─────▶│   Soniox    │
│  (Client)   │◀─────│   Server     │◀─────│   WebSocket │
└─────────────┘      └──────────────┘      └─────────────┘
                            │
                     ┌──────▼──────┐
                     │   API Key    │
                     │  Management  │
                     └─────────────┘
```

**Benefits:**
- API keys never leave your server
- Complete control over key rotation
- Add/remove accounts without app updates
- Implement rate limiting and usage analytics
- Monitor all transcription requests
- Add caching layer for repeated requests

**Implementation:**
```swift
// In Clio app - connect to your proxy instead
let proxyEndpoint = "wss://api.tryclio.com/v1/transcribe"
// No API keys in the app!
```

### 2. **Remote Configuration Service** (Supplementary)

For configurations that don't need real-time updates:

```swift
// Fetch config from your secure backend
{
  "sonioxAccounts": [
    {
      "id": "prod-account-1",
      "endpoint": "wss://proxy1.tryclio.com",
      "region": "us-east",
      "isEnabled": true
    }
  ],
  "features": {
    "useProxyServer": true,
    "maxConcurrentStreams": 100
  }
}
```

## Alternative Approaches

### 3. **CloudKit Private Database** (Apple Ecosystem)

**Pros:**
- Native Apple integration
- No server infrastructure needed
- Push notifications for instant updates
- Automatic sync across user devices

**Cons:**
- Apple ecosystem only
- Limited to CloudKit quotas

### 4. **Certificate Pinning + Encrypted Storage**

**Implementation:**
- Store encrypted API keys in app
- Decrypt with keys from your server
- Use certificate pinning for secure communication

**Pros:**
- Works offline after initial setup
- Reduced server dependency

**Cons:**
- Still requires app updates for new keys
- More complex implementation

## Security Best Practices

### 1. **Never Store Keys Client-Side**
- Route all requests through your backend
- Use temporary session tokens for clients

### 2. **Environment Separation**
```bash
# Production
SONIOX_PROD_ACCOUNT_01=key_xxx
SONIOX_PROD_ACCOUNT_02=key_yyy

# Development
SONIOX_DEV_ACCOUNT_01=key_test
```

### 3. **Key Rotation Strategy**
- Rotate keys every 90 days
- Maintain overlap period during rotation
- Monitor for usage on deprecated keys

### 4. **Access Control**
- IP whitelisting for proxy servers
- Rate limiting per user/device
- Usage quotas and monitoring

## Implementation Roadmap

### Phase 1: Proxy Server MVP (Week 1-2)
1. Set up basic proxy server (Node.js/Go)
2. WebSocket proxying for Soniox
3. Basic authentication for Clio clients
4. Deploy to cloud provider (AWS/GCP/Azure)

### Phase 2: Key Management (Week 3)
1. Database for API key storage
2. Admin dashboard for key management
3. Automated health checks
4. Key rotation system

### Phase 3: Analytics & Monitoring (Week 4)
1. Usage tracking per account
2. Cost monitoring dashboard
3. Alerting for anomalies
4. Performance metrics

## Cost Considerations

### Proxy Server Costs (Monthly)
- Small instance: ~$50-100
- WebSocket connections: ~$20-50
- Bandwidth: ~$50-100
- Total: ~$120-250/month

### Benefits vs Costs
- Eliminate risk of key exposure
- Instant account management
- Better user experience
- Professional infrastructure

## Quick Start Implementation

### 1. Simple Node.js Proxy Example

```javascript
const WebSocket = require('ws');
const express = require('express');

const app = express();
const server = require('http').createServer(app);

// WebSocket proxy
server.on('upgrade', async (request, socket, head) => {
  // Authenticate client
  const token = request.headers.authorization;
  if (!validateClient(token)) {
    socket.destroy();
    return;
  }
  
  // Select Soniox account
  const account = await selectAccount();
  
  // Create upstream connection
  const upstream = new WebSocket('wss://stt-rt.soniox.com/transcribe-websocket');
  
  // Proxy configuration with API key
  upstream.on('open', () => {
    upstream.send(JSON.stringify({
      api_key: account.apiKey,
      // ... other config
    }));
  });
  
  // Bidirectional proxying
  socket.pipe(upstream);
  upstream.pipe(socket);
});
```

### 2. Clio App Updates

```swift
// SonioxStreamingService.swift
private let sonioxEndpoint = ProcessInfo.processInfo.environment["CLIO_PROXY_URL"] 
    ?? "wss://api.tryclio.com/v1/transcribe"

// Use device token instead of API key
private var deviceToken: String {
    // Get from keychain or generate
    return KeychainService.shared.deviceToken
}
```

## Monitoring & Alerts

### Key Metrics to Track
1. **Per Account:**
   - Active connections
   - Daily/monthly usage
   - Error rates
   - Response times

2. **System Wide:**
   - Total concurrent streams
   - Geographic distribution
   - Cost per transcription
   - API availability

### Alert Conditions
- Account approaching quota
- Unusual usage patterns
- High error rates
- Slow response times

## Conclusion

The BFF proxy pattern is the industry-standard approach for production API key management in 2025. It provides:

1. **Security**: Keys never exposed to clients
2. **Flexibility**: Add/remove accounts instantly
3. **Control**: Complete usage monitoring
4. **Scalability**: Handle growth seamlessly
5. **Professional**: Enterprise-grade architecture

This approach transforms Clio from a client with hardcoded keys to a professional service with proper backend infrastructure, enabling sustainable growth and enterprise adoption.