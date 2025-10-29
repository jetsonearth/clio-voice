# Changelog - Version 1.47

**Release Date:** August 27, 2025  
**Branch:** feature/ensure-synchronous-root-rendering-with-placeholder-content-for-windowgroup-dock-menu-restore-20250823-160006

## 🚀 **Major Performance & Reliability Enhancements**

### Advanced Connection Management
- **Warm Socket Reuse**: Implemented intelligent socket connection reuse reducing ASR session startup times
- **Post-Sleep Hardening**: Enhanced system resilience with automatic session refresh on connection timeouts and post-sleep recovery
- **Network Health Monitoring**: Real-time connection monitoring with automatic failover and recovery mechanisms
- **Fast Finalize Configuration**: Optimized finalization timing for sub-100ms response improvements

## 🤖 **AI & Enhancement Service Improvements**

### Model & Context Enhancement
- **Dynamic AI Prompts**: Enhanced prompt system with dynamic filler removal and connection optimization
- **Rule Engine Integration**: Advanced context detection with rule engine and legacy fallback support
- **Code Context Detection**: Streamlined code mode detection with improved pattern matching
- **ASR Error Corrections**: Advanced error correction algorithms for better transcription accuracy


## 🎨 **UI/UX & Visual Improvements**

### Recording Interface
- **Dynamic Notch Enhancements**: Updated recorder UI with improved visual feedback and real-time animations
- **Animation Optimization**: Increased notch recorder open/close duration to 0.6s for smoother transitions
- **Recording Visualizer**: Enhanced real-time audio visualization during recording sessions

### Window & Settings Management
- **Window Management Fixes**: Resolved duplicate window creation by switching to Window scene type
- **Settings Interface**: Added row grouping and improved organization of system preferences
- **Account Management**: Fixed sign-out to re-onboarding flow issues
- **License Page UI**: Modernized license management interface with better user feedback

## ⌨️ **Input & Hotkey System Enhancements**

### Universal Hotkey Support
- **F5 Runtime Override**: Enhanced F5 key support across all Mac models with systemDefined event listening
- **Dictation Hotkey Fixes**: Resolved production user issues with dictation activation
- **Legacy PTT Fallback**: Restored push-to-talk fallback when Finite State Machine is disabled
- **Input Gate Management**: Improved input handling and gate management with better state synchronization

## 🛠️ **Technical Infrastructure**

### Audio & Streaming Systems
- **Unified Audio Manager**: Enhanced audio processing pipeline with better error handling
- **WebSocket Reliability**: Improved WebSocket connection stability and message handling
- **Audio Device Configuration**: Advanced audio device management and configuration
- **Streaming Audio Processor**: Optimized real-time audio processing capabilities

### Logging & Monitoring
- **Structured Logging**: Enhanced logging system with timing metrics and performance monitoring
- **Conditional Debug Flags**: Smart logging verbosity control to reduce console noise
- **Performance Metrics**: Comprehensive timing metrics for performance analysis
- **Debug Cleanup**: Removed verbose startup and sync logging for cleaner output

## 🐛 **Bug Fixes & Stability**

### State Management
- **Window Restoration**: Fixed window restoration by ensuring WindowGroup always has content
- **Recording State Machine**: Improved state transitions and error recovery
- **Authentication Flow**: Corrected sign-out and re-authentication sequences
- **License Synchronization**: Enhanced license sync reliability and error handling

### User Experience Fixes
- **Network Disconnection**: Improved handling of network connectivity issues with UI state sync
- **Animation Glitches**: Resolved animation timing and rendering issues
- **Settings Persistence**: Fixed settings save and restore functionality
- **Audio Cleanup**: Enhanced audio file handling and cleanup processes


**Compatibility**: macOS 14.0+  
