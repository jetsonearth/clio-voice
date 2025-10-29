# Clio Online Strategy Document

**Project**: Clio Online - AI-Powered Voice Transcription  
**Version**: 2.0 Strategic Transformation  
**Last Updated**: 2025-01-23  
**Status**: In Progress

---

## 🎯 Vision & Strategic Direction

### **Core Philosophy**
**"Smart by Default, Private by Choice"**

Clio Online prioritizes ease-of-use and intelligent defaults while offering privacy-conscious users the option to use local processing. We eliminate decision paralysis through simplified UX while maintaining technical excellence.

### **Key Strategic Principles**
1. **Default to Cloud**: Soniox streaming provides the best out-of-box experience
2. **Simplify Choice**: Binary toggle (Online/Local) instead of complex model selection
3. **Scale Intelligently**: Multi-account routing to handle growth without user impact
4. **Language First**: Fix and prioritize proper language support across all models

---

## 🏗️ Architecture Overview

### **Service Stack**
```
┌─────────────────────────────────────────┐
│             User Interface              │
├─────────────────────────────────────────┤
│  Settings: [Use Local Model] Toggle     │
├─────────────────────────────────────────┤
│    WhisperState (Central Coordinator)   │
├─────────────────────────────────────────┤
│  SonioxStreamingService │ AudioTranscription │
│  (Multi-Account Pool)   │ Service (Local)     │
├─────────────────────────────────────────┤
│     Account Manager     │    Whisper.cpp    │
│    (Load Balancing)     │   (Downloaded)     │
└─────────────────────────────────────────┘
```

### **Default Behavior**
- **Primary**: Soniox Streaming (Clio Ultra) - Fast, cloud-based transcription
- **Fallback**: Local Whisper v3 Turbo - Privacy-focused, offline processing
- **Language**: Respects user's dictation language selection for both modes

---

## 🔄 Model Selection Simplification

### **Before (Complex)**
```
Speech Models Page:
├── Clio Flash (ggml-small)
├── Clio Pro (ggml-large-v3-turbo) 
├── Clio Ultra (soniox-realtime-streaming)
├── Clio Max (paraformer-realtime-v2)
└── Custom model cards...
```

### **After (Simple)**
```
Settings Page:
└── Privacy Card
    ├── [Toggle] Use local model
    ├── Status: "Whisper v3 Turbo" (if downloaded)
    └── [Button] Download for privacy (if needed)
```

### **Implementation Strategy**
1. **Remove**: `ModelManagementView` complex UI
2. **Add**: Simple toggle in Settings
3. **Logic**: `useLocalModel` boolean drives model selection
4. **Detection**: Auto-detect local model availability
5. **Downloads**: Streamlined "Download Whisper v3 Turbo" experience

---

## 🌐 Multi-Account Soniox Architecture

### **Scaling Challenge**
- Soniox limits: ~10 concurrent connections per account
- User growth requires horizontal scaling
- $200 free trial per account provides cost runway

### **Solution: Intelligent Account Pool**

#### **Account Management**
```swift
struct SonioxAccount {
    let id: String
    let apiKey: String
    var activeConnections: Int = 0
    var maxConcurrency: Int = 10
    var dailyUsage: Double = 0
    var isHealthy: Bool = true
    var region: String = "us-east"
}
```

#### **Load Balancing Strategy**
1. **Least Connections**: Route to account with fewest active sessions
2. **Credit Awareness**: Avoid accounts nearing $200 limit
3. **Health Monitoring**: Skip accounts with API errors
4. **Geographic Routing**: Future enhancement for latency optimization

#### **Routing Logic**
```
User Request → Account Manager → Optimal Account Selection → Soniox Connection
     ↓              ↓                    ↓                        ↓
  New Session → Health Check → Load Balance → Stream Audio/Text
```

#### **Account Pool Configuration**
- **Target**: 10+ Soniox accounts initially
- **Capacity**: 100+ concurrent users (10 × 10 accounts)
- **Budget**: $2000+ in free credits ($200 × 10 accounts)
- **Management**: Environment-based API key configuration
- **Note**: May use Paraformer backend for enhanced Chinese language support

---

## 🗣️ Language Selection Architecture

### **Current Issue**
- **Whisper**: Supports 100+ languages via user selection ✅
- **Soniox**: Hardcoded to `["en", "zh"]` - ignores user preference ❌

### **Solution: Unified Language Support**

#### **Language Integration Points**
1. **User Selection**: Menu bar "Select dictation language"
2. **Whisper Integration**: Pass language to `whisper.cpp` engine
3. **Soniox Integration**: Map user selection to `language_hints` parameter
4. **Validation**: Show appropriate language options per model

#### **Soniox Language Mapping**
```swift
func getSonioxLanguageHints(from userLanguage: String) -> [String] {
    let sonioxLanguageMap = [
        "en": ["en"],
        "zh": ["zh"],
        "es": ["es"],
        "fr": ["fr"],
        // Map 60+ Soniox-supported languages
    ]
    return sonioxLanguageMap[userLanguage] ?? ["en"]
}
```

#### **Implementation Plan**
1. **Fix**: Replace hardcoded Soniox language hints
2. **Map**: Create user language → Soniox hints mapping
3. **Validate**: Show compatible languages in UI
4. **Fallback**: Default to English for unsupported languages

---

## 📱 User Experience Flow

### **New User Journey**
1. **Launch Clio** → Defaults to Soniox (fast, online)
2. **First transcription** → Works immediately with user's language
3. **Privacy concern?** → Settings → Toggle "Use local model"
4. **Local not downloaded?** → "Download Whisper v3 Turbo" button
5. **Download complete** → Seamless switch to local processing

### **Key UX Principles**
- **Zero configuration**: Works out of the box
- **Progressive disclosure**: Advanced options hidden by default
- **Clear mental model**: Online (fast) vs Local (private)
- **Smooth transitions**: No interruption when switching modes

---

## 🛠️ Implementation Roadmap

### **Phase 1: Foundation (Week 1-2)**
**Priority: Critical bug fixes and architecture**

- [x] Fix Soniox language selection (replace hardcoded hints)
- [ ] Set Soniox as system default
- [ ] Design multi-account routing architecture
- [ ] Fix microphone shutdown bug (completed)

### **Phase 2: UI Simplification (Week 3-4)**
**Priority: User experience transformation**

- [ ] Remove complex model selection UI
- [ ] Add simple "Use local model" toggle in Settings
- [ ] Implement local model detection logic
- [ ] Create streamlined download experience

### **Phase 3: Scaling Infrastructure (Week 5-6)**
**Priority: Production readiness**

- [ ] Implement multi-account Soniox pool
- [ ] Add load balancing and health monitoring
- [ ] Configure 10+ Soniox accounts
- [ ] Add usage tracking and credit management

### **Phase 4: Polish & Optimization (Week 7-8)**
**Priority: Performance and reliability**

- [ ] Language compatibility validation
- [ ] Error handling and fallback mechanisms  
- [ ] Performance monitoring and analytics
- [ ] User feedback integration

---

## 📊 Success Metrics

### **User Experience Metrics**
- **Time to first transcription**: Target <5 seconds (down from current setup time)
- **User confusion**: Eliminate model selection support tickets
- **Retention**: Improved onboarding through smart defaults

### **Technical Performance Metrics**
- **Concurrent users**: Support 50+ simultaneous transcriptions
- **API reliability**: 99.9% uptime through multi-account redundancy
- **Language accuracy**: Proper language detection for 60+ languages

### **Business Metrics**
- **Cost efficiency**: $2000+ credit pool extends runway
- **Scalability**: Handle 10x user growth without architecture changes
- **Support reduction**: Fewer "how do I..." questions

---

## 🔧 Technical Debt & Future Enhancements

### **Current Technical Debt**
1. **Paraformer Service**: Clio Max model not fully implemented
2. **Language Selection**: Inconsistent behavior across models
3. **Model Management**: Over-engineered for user needs
4. **Error Handling**: Insufficient graceful degradation

### **Future Enhancement Opportunities**
1. **Geographic Routing**: Route to closest Soniox region
2. **Predictive Scaling**: Pre-warm accounts based on usage patterns
3. **Voice Activity Detection**: Better start/stop detection
4. **Custom Vocabulary**: Enhanced domain-specific transcription
5. **Real-time Collaboration**: Multi-user transcription sessions

---

## 🚨 Risk Management

### **Technical Risks**
- **Soniox API Changes**: Monitor for breaking changes, maintain fallbacks
- **Account Suspension**: Health monitoring to detect and route around issues
- **Local Model Dependencies**: Ensure whisper.cpp framework stays updated

### **Business Risks**
- **API Cost Scaling**: Monitor usage patterns, implement cost controls
- **Competitor Features**: Stay current with transcription accuracy improvements
- **User Privacy Expectations**: Maintain clear online/local distinction

### **Mitigation Strategies**
- **Redundancy**: Multiple account pools, local fallback always available
- **Monitoring**: Comprehensive logging and alerting
- **User Communication**: Clear feature explanations and status updates

---

## 🧪 Testing Strategy

### **Integration Testing**
- [ ] Multi-account failover scenarios
- [ ] Language selection across all models
- [ ] Local model download and switching
- [ ] Concurrent user load testing

### **User Acceptance Testing**
- [ ] New user onboarding flow
- [ ] Privacy-conscious user local setup
- [ ] Language switching validation
- [ ] Error recovery scenarios

---

## 📝 Configuration Management

### **Environment Variables**
```bash
# Soniox Account Pool
SONIOX_ACCOUNT_01_KEY=key_1...
SONIOX_ACCOUNT_02_KEY=key_2...
# ... up to 10+ accounts

# Feature Flags
ENABLE_LOCAL_MODEL_TOGGLE=true
DEFAULT_TO_SONIOX=true
SHOW_ADVANCED_SETTINGS=false
```

### **Build Configurations**
- **Debug**: Single Soniox account, full logging
- **Release**: Full account pool, optimized performance
- **Enterprise**: Custom account configurations

---

## 🤝 Integration Points

### **External Dependencies**
- **Soniox WebSocket API**: Real-time streaming transcription
- **whisper.cpp Framework**: Local model processing
- **Apple Speech Framework**: System-level integrations
- **Sparkle**: Automatic updates

### **Internal Service Boundaries**
- **WhisperState**: Central coordination and state management
- **SonioxStreamingService**: Cloud transcription and account management
- **AudioTranscriptionService**: Local processing pipeline
- **HotkeyManager**: Global shortcuts and user interaction

---

## 📚 Documentation & Knowledge Transfer

### **For AI Coding Tools**
This document serves as the canonical reference for:
- **Architecture decisions** and their rationale
- **Implementation priorities** and sequencing
- **User experience principles** and design philosophy
- **Technical constraints** and scaling strategies

### **Key Decision Context**
- **Why Soniox default?** Best accuracy and speed for majority use case
- **Why simple toggle?** User research shows model selection causes confusion
- **Why multi-account?** Horizontal scaling more reliable than vertical optimization
- **Why language-first?** Core functionality must work across user languages

---

**End of Strategy Document**

*This document should be updated as implementation progresses and new requirements emerge. All AI coding tools should reference this document for consistent decision-making and architectural alignment.*