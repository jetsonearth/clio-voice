# Changelog - Version 1.43

## 🎙️ **Complete Recorder Architecture Revamp**
1. **Streaming Transcript Support**: Completely redesigned recorder with real-time streaming transcription capabilities
2. **State Machine Implementation**: New recorder state machine for robust session management and input handling
3. **Dynamic Notch Recorder Integration**: Built a new and beautiful design for the recorder, now a notch recorder with streaming transcript display
4. **Real-time Audio Visualization**: Revamped visualizer with dynamic effects and real-time audio response
5. **Notch Recorder Improvements**: boring.notch-inspired design with smooth animations, proper text alignment, and timing fixes

## ⌨️ **Advanced Hotkey & Input Control System**
3. **Dual Hotkey Mode**: Toggle control for hotkey triggering - long hold for dictation mode OR double tap activation
4. **F5 Dictation Override**: Full F5 function key support, no longer limited to modifier buttons for hotkey triggering
5. **Hotkey Conflict Resolution**: Intelligent conflict detection and resolution system
6. **Function Key Support**: Complete hotkey system fixes with proper permissions UI and function key support
7. **Keyboard Shortcut Capture**: Crash-resistant shortcut capture system with F5 key handling
8. **Key Sound Feedback**: Added audio feedback for key interactions

## 🔄 **Websocket & Streaming Reliability Overhaul**
2. **ASR Streaming Enhancements**: Major improvements to websocket retry and resilience
   - Single-flight connection management to prevent duplicate connections
   - Connection lifecycle hardening with proper state management
   - Pre-recording websocket preparation for faster startup
   - Recovery guards and buffering state management
   - Fast cancel implementation to eliminate lag on cancellation
8. **ASR Latency Optimization**: Conditional 250ms audio buffer wait for improved response times
9. **Performance Improvements**: Enhanced AI services with reliability improvements and connection persistence

## 🔐 **Authentication & Onboarding**
5. **Google Social Authentication**: Added Google Sign-In integration for streamlined authentication
6. **Enhanced Onboarding Flow**: Completely improved onboarding experience with better permissions handling
7. **Professional Onboarding**: Enhanced setup process with better UX and permission management
8. **Audio Manager for Onboarding**: Dedicated audio management during onboarding process

## 🌐 **Internationalization & Accessibility**
- **Complete Localization**: Keyboard shortcuts section and modal UX fully localized
- **CJK Text Normalization**: Added Chinese, Japanese, and Korean text processing utilities
- **UI Component Improvements**: Better shortcut capture and recording visualization across languages

## 🎨 **UI/UX Enhancements**
- **Settings Redesign**: Major overhaul of settings interface
- **Hover Effects**: Added hover effects to dictation language dropdown
- **Modal Styling**: Improved modal styling and hotkey display formatting
- **App Focus Reliability**: Fixed unreliable app focus from menu bar actions
- **Trial Expiration System**: Refactored with new modal implementation

## 🔧 **Developer Experience & Testing**
- **Comprehensive Testing**: Added RecorderStateMachine unit tests with 256 test cases
- **Bug Documentation**: Extensive bug reports and documentation improvements
- **Performance Benchmarking**: ASR benchmark updates with corrected provider implementation
- **Debug Logging**: Enhanced logging system with reduced noise and better categorization

## 🚀 **Performance & Stability**
- **Memory Management**: Improved audio file handling and cleanup
- **Connection Resilience**: Robust websocket connection handling with automatic recovery
- **State Synchronization**: Proper state management across all components
- **Fast Operations**: Optimized transcription pipeline with reduced latency

---

**Release Date**: August 22 2025  
**Build**: 1.43  
**Compatibility**: macOS 14.0+