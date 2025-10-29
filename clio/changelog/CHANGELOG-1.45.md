# Changelog - Version 1.45

**Release Date:** August 31, 2025  
**Branch:** feature/ensure-synchronous-root-rendering-with-placeholder-content-for-windowgroup-dock-menu-restore-20250823-160006

## 🚀 **Advanced AI & Text Processing Pipeline**

### Enhanced AI Services
- **Streaming Toggle Support**: Added streaming toggle with tougher NER JSON schema and tolerant parsing
- **Multi-Provider Integration**: Enhanced ProxySessionManager with support for Fly.io and Cloudflare endpoints  
- **Advanced Prompt Engineering**: Strengthened code-mode and general enhancement prompts with dynamic cross-lingual examples
- **Smart Context Detection**: Refined NER rules with JSON schema validation and YAML fallback support

### Revolutionary Text Normalization
- **TranscriptNormalizer**: Complete multilingual unit/percent/currency handling with comprehensive test coverage
- **PostEnhancementFormatter**: Unified text pipeline for consistent formatting across all enhancement paths
- **DisfluencyCleaner**: Timestamp-aware cleanup for natural speech pattern processing
- **Cross-Lingual Filler Removal**: Dynamic mono/multilingual filler detection with mutually exclusive examples

## 🌐 **Network & Infrastructure Overhaul**

### Proxy & Session Management
- **ProxySessionManager**: Advanced proxy session management with intelligent routing and failover
- **Multi-Endpoint Support**: Consolidated Fly.io and Cloudflare proxy endpoints with warmup capabilities
- **Connection Hardening**: Enhanced URLSession retry recovery and stats collection reliability
- **Gated Logging**: Intelligent full-prompt and NER logging with performance optimization

### Audio & Streaming Improvements
- **Duplicate Prevention**: Fixed duplicate first seconds in audio streaming by optimizing prebuffer flush logic
- **WebSocket Optimization**: Downgraded benign close handling to reduce console noise
- **Short Utterance Enhancement**: Improved ASR finalization and partial merging for brief recordings

## 🎨 **UI/UX & Experience Enhancements**

### Interface Refinements
- **Dynamic Notch Stability**: Stabilized scrolling with bounce suppression for smoother user experience
- **Progress Animations**: Removed implicit animations for smoother progress bar updates
- **Settings Alignment**: Adjusted language section widths for better visual consistency
- **Onboarding Experience**: Enhanced onboarding flow with improved recorder interface integration

### Hands-Free Mode Evolution
- **Core Functionality**: Implemented comprehensive hands-free mode with F5 override support
- **Language Support**: Added zh-ht support for short utterances and multilingual processing
- **License Integration**: Fixed license/plan page view with proper authentication flow

## 🔧 **Context & NER System Revolution**

### Advanced NER Processing
- **Concise Context Summary**: Streamlined NER rules requiring concise paragraph summaries
- **Generic Entity Cleanup**: Dropped generic entity lists from schema for focused context rendering
- **Code Context Detection**: Enhanced Gemini endpoint integration for intelligent code mode detection
- **Entity Category Refinement**: Fixed indentation and improved category classification accuracy

### Smart Context Management
- **JSON Rules Engine**: Advanced rule engine with YAML fallback for robust context processing
- **Detector Prompt Refinement**: Improved context detection with enhanced prompt engineering
- **Prewarm Integration**: Fly.io NER prewarm with code context detection for faster response times

## 🐛 **Critical Fixes & Stability**

### Text Processing Fixes
- **Trailing Space Removal**: Eliminated forced trailing spaces after final punctuation in all completion paths
- **Empty Paste Prevention**: Added intelligent empty text paste detection with proper logging
- **Numeric Normalization**: Temporarily disabled unit normalization in post-enhancement for stability

### Audio & Recording Stability
- **Engine Disconnect Handling**: Improved audio engine disconnect recovery with comprehensive error handling
- **Streaming Reliability**: Enhanced audio streaming with better error recovery and connection management

## 📚 **Documentation & Development**

### Development Infrastructure
- **Contributor Guide**: Added comprehensive contributor guidelines and PR templates
- **MCP Configuration**: Updated local development tooling with improved .mcp.json configuration
- **Bug Documentation**: Enhanced audio engine disconnect documentation and troubleshooting guides
- **Vocabulary Updates**: Added "Tauri" and other modern framework terms to known vocabulary

### Project Organization
- **Changelog Migration**: Moved changelog to top-level directory for better project organization
- **Asset Management**: Added audio assets and updated project configuration files
- **Gitignore Optimization**: Enhanced gitignore for local temp files and development artifacts
- **Package Updates**: Updated Package.resolved with latest dependency versions

---

**Build**: 1.45  
**Compatibility**: macOS 14.0+