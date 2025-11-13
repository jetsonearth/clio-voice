# Clio

**Transform your voice into text at the speed of thought**

Clio is an advanced macOS voice transcription application that lets you speak at 200 words per minute instead of typing at 50 wpm. Built with privacy-first design and powered by local AI, Clio processes everything on your device without sending data to the cloud.

> **Community Edition**  
> This open-source build removes hosted authentication, licensing, and payment dependencies. Bring your own Groq + Soniox API keys (stored locally in the Keychain) and start using every feature immediately—no accounts, no trials, no paywalls.

[![License](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Platform](https://img.shields.io/badge/platform-macOS%2014.0%2B-brightgreen)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

---

## ✨ Features

### 🎙️ **Lightning-Fast Transcription**
- **4x productivity boost**: Speak at 200 wpm vs typing at 50 wpm
- Near-instant local AI transcription using Whisper models
- Support for multiple languages with auto-detection

### 🔒 **Privacy by Design**
- **100% offline processing** - your voice never leaves your device
- No cloud dependencies, no data collection
- Complete control over your sensitive information

### 🧠 **Intelligent Context Awareness**
- **PowerMode**: Automatically adapts to different apps and websites
- Smart screen context integration for enhanced accuracy
- AI-powered text enhancement with local and cloud options

### ⚡ **Seamless Workflow Integration**
- Global hotkeys for instant recording
- Push-to-talk functionality
- Automatic text insertion at cursor position
- Custom dictionary for technical terms and names

### 🎯 **Advanced AI Capabilities**
- Multiple AI providers (OpenAI, Anthropic, Ollama, etc.)
- Context-aware text enhancement
- Custom prompts and writing styles
- Real-time voice activity detection
- Bring-your-own Groq & Soniox API keys, stored securely in the macOS Keychain

---

## 🚀 Quick Start

### Requirements
- macOS 14.0 or later
- Apple Silicon (M1/M2/M3/M4) or Intel Mac

### Installation

#### Option 1: Download Release
1. Download the latest release from [Releases](https://github.com/studio-kensense/clio/releases)
2. Open the `.dmg` file and drag Clio to Applications
3. Launch Clio and grant necessary permissions

#### Option 2: Build from Source
```bash
git clone https://github.com/studio-kensense/clio.git
cd Clio
open Clio.xcodeproj
```

Build and run in Xcode (⌘+R)

---

## 🛠️ Setup

### 1. Permissions
Clio requires the following permissions to function:
- **Microphone**: For voice recording
- **Accessibility**: For automatic text insertion
- **Screen Recording**: For context-aware features (optional)

### 2. Download Models
On first launch, Clio will help you download Whisper models:
- **Flash Model** (130MB) - Fast, good quality
- **Turbo Model** (1.6GB) - Highest accuracy
- **Custom Models** - Upload your own fine-tuned models

### 3. Configure Hotkeys
Set up global keyboard shortcuts:
- **Toggle Recording** (default: ⌘+⇧+Space)
- **Push to Talk** (customizable)

### 4. Add API Keys
- Open **Settings → Cloud API Keys** inside Clio
- Paste your **Groq** key for AI enhancement and your **Soniox** key for streaming transcription
- Keys are saved locally in the macOS Keychain; feel free to leave either field blank if you are testing offline-only flows

---

## 🎯 Usage

### Basic Recording
1. Press your hotkey to start recording
2. Speak naturally
3. Press hotkey again to stop and transcribe
4. Text appears at your cursor automatically

### PowerMode (Context-Aware)
Configure different settings for specific apps:
- **Writing Apps**: Enhanced grammar and style
- **Code Editors**: Technical terminology focus
- **Browsers**: URL-specific configurations
- **Email/Slack**: Professional tone adjustment

### AI Enhancement
Enable AI enhancement for:
- Grammar and style improvements
- Context-aware suggestions
- Professional tone adjustment
- Technical writing optimization

---

## 🔧 Architecture

### Core Components
- **WhisperState**: Central transcription coordinator
- **AIEnhancementService**: Multi-provider AI integration
- **PowerMode System**: Context-aware configuration
- **VAD (Voice Activity Detection)**: Intelligent audio processing

### AI Providers Supported
- OpenAI (GPT-4, GPT-3.5)
- Anthropic (Claude)
- Google (Gemini)
- Ollama (Local models)
- Groq (Ultra-fast inference)

### Local Processing
- **whisper.cpp**: High-performance local transcription
- **Metal acceleration**: Optimized for Apple Silicon
- **CoreML integration**: Native iOS/macOS AI frameworks

---

## 🔒 Privacy & Security

### Data Handling
- **Voice recordings**: Processed locally, automatically deleted
- **Transcripts**: Stored locally in encrypted format
- **AI enhancement**: Optional, user-controlled
- **No telemetry**: Zero data collection

### Open Source Benefits
- Full code transparency
- Community security audits
- No hidden data collection
- Complete user control

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
1. Clone the repository
2. Install dependencies (Xcode 15.0+)
3. Build whisper.cpp framework (see [BUILDING.md](BUILDING.md))
4. Run tests: `⌘+U` in Xcode

### Areas for Contribution
- New AI provider integrations
- Language model improvements
- UI/UX enhancements
- Performance optimizations
- Documentation

---

## 📄 License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

### Core Technologies
- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - High-performance Whisper inference
- [Sparkle](https://github.com/sparkle-project/Sparkle) - Automatic updates
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Global hotkey management

---

<div align="center">

**Speak faster. Think clearer. Work smarter.**

[⭐ Star us on GitHub](https://github.com/studio-kensense/clio) • [🐛 Report Issues](https://github.com/studio-kensense/clio/issues) • [💬 Discussions](https://github.com/studio-kensense/clio/discussions)

</div>
