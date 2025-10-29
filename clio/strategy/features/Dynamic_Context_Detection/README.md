# ⏺ Dynamic Context Detection System - Developer Handoff

## 🎯 Overview

This handoff document provides complete technical details for extending the Dynamic Context Detection System implemented in Clio. The system automatically detects user context (email, code, meetings, etc.) and applies appropriate AI enhancement prompts.

## 📁 Architecture Overview

### Core Components

```
Clio/Services/Context/
├── DynamicContextDetector.swift     # Main service (646 lines)
│
Clio/Services/AI/
├── AIEnhancementService.swift       # Integration layer
│
Clio/Services/System/
├── ScreenCaptureService.swift       # Window info provider
```

### Data Flow

```
User Records → Screen Capture → Window Detection → Pattern Matching → Context Detection → Layered AI Enhancement → Enhanced Output
```

## 🛠️ Current Implementation

### Supported Context Types

- ✅ **Email**: Gmail, Outlook, Apple Mail, etc.
- ❌ **Code**: VS Code, Cursor, Terminal, Xcode (not implemented)
- ❌ **Meeting**: Zoom, Teams, Meet (not implemented)
- ❌ **Document**: Google Docs, Word (not implemented)
- ❌ **Social**: Twitter, LinkedIn (not implemented)

### Key Files Modified

**1. DynamicContextDetector.swift (NEW - Main Service)**

```swift
// Core enums and structures
enum DetectedContextType: String, CaseIterable {
    case email = "email"
    case meeting = "meeting"    // TODO: Implement
    case document = "document"  // TODO: Implement  
    case code = "code"         // TODO: Implement
    case social = "social"     // TODO: Implement
    case none = "none"
}

struct DetectedContext {
    let type: DetectedContextType
    let confidence: Double // 0.0 to 1.0
    let matchedPatterns: [String]
    let source: DetectionSource
}
```

**Key Methods:**
- `detectContext()` - Main detection entry point
- `detectEmailContext()` - Email-specific detection (IMPLEMENTED)
- `isValidEmailApp()` - Bundle ID validation (IMPLEMENTED)
- `getPromptEnhancement()` - Context-specific prompts (IMPLEMENTED for email)

**2. AIEnhancementService.swift (ENHANCED)**

```swift
// New methods added:
func enhanceWithDynamicContext(_ text: String, windowTitle: String?, windowContent: String?) async throws -> String

func enhanceWithDynamicContextTracking(_ text: String, windowTitle: String?, windowContent: String?) async throws -> EnhancementResult
```

**3. ScreenCaptureService.swift (ENHANCED)**

```swift
// New method added:
func getCurrentWindowInfo() -> (title: String?, content: String?)
```

## 🎯 Implementation Guide for New Context Types

### Step 1: Add New Context Type

```swift
// In DynamicContextDetector.swift
enum DetectedContextType: String, CaseIterable {
    case email = "email"
    case code = "code"          // ADD THIS
    case meeting = "meeting"    // ADD THIS
    case document = "document"  // ADD THIS
    case social = "social"      // ADD THIS
    case none = "none"
}
```

### Step 2: Create Detection Patterns

```swift
// Example for Code Detection
private let codeWindowTitlePatterns = [
    // VS Code
    ".*Visual Studio Code.*",
    ".*\\.py.*VS Code.*",
    ".*\\.js.*VS Code.*",
    ".*\\.swift.*VS Code.*",
    ".*\\.tsx?.*VS Code.*",
    
    // Cursor
    ".*Cursor.*",
    ".*\\.py.*Cursor.*",
    ".*\\.js.*Cursor.*",
    
    // Terminal/CLI
    "^Terminal.*",
    "^iTerm.*",
    ".*zsh.*",
    ".*bash.*",
    
    // Xcode
    ".*Xcode.*",
    ".*\\.xcodeproj.*",
    ".*\\.swift.*Xcode.*",
    
    // Other IDEs
    ".*IntelliJ IDEA.*",
    ".*PyCharm.*",
    ".*WebStorm.*",
    ".*Android Studio.*"
]

private let codeContentPatterns = [
    // Programming languages
    "(?i)\\bfunction\\s+\\w+",
    "(?i)\\bclass\\s+\\w+",
    "(?i)\\bimport\\s+\\w+",
    "(?i)\\bfrom\\s+\\w+\\s+import",
    "(?i)\\bdef\\s+\\w+",
    "(?i)\\bvar\\s+\\w+",
    "(?i)\\blet\\s+\\w+",
    "(?i)\\bconst\\s+\\w+",
    
    // Code-specific UI elements
    "(?i)\\bdebug\\b",
    "(?i)\\bconsole\\b",
    "(?i)\\bterminal\\b",
    "(?i)\\bcommand\\s+palette",
    "(?i)\\bgit\\s+(commit|push|pull)",
    "(?i)\\bnpm\\s+(install|run)",
    "(?i)\\bpip\\s+install",
    
    // File extensions in content
    "\\.py\\b",
    "\\.js\\b",
    "\\.ts\\b",
    "\\.swift\\b",
    "\\.java\\b",
    "\\.cpp\\b",
    "\\.h\\b"
]
```

### Step 3: Add App Validation

```swift
private func isValidCodeApp(_ bundleId: String) -> Bool {
    let validCodeApps = [
        "com.microsoft.VSCode",           // VS Code
        "com.todesktop.230313mzl4w4u92", // Cursor
        "com.apple.Terminal",            // Terminal
        "com.googlecode.iterm2",         // iTerm2
        "com.apple.dt.Xcode",           // Xcode
        "com.jetbrains.intellij",        // IntelliJ IDEA
        "com.jetbrains.pycharm",         // PyCharm
        "com.jetbrains.webstorm",        // WebStorm
        "com.jetbrains.appcode",         // AppCode
        "com.sublimetext.4",             // Sublime Text
        "com.github.atom",               // Atom (if still used)
        "com.google.android.studio"      // Android Studio
    ]
    return validCodeApps.contains { $0.lowercased() == bundleId.lowercased() }
}
```

### Step 4: Implement Detection Logic

```swift
/// Detect code context from window title and content
private func detectCodeContext(windowTitle: String?, windowContent: String?) -> DetectedContext? {
    var matchedPatterns: [String] = []
    var confidence: Double = 0.0
    var detectionSource: DetectedContext.DetectionSource = .windowTitle
    
    // Check window title patterns
    var titleMatches = 0
    if let title = windowTitle {
        for pattern in codeWindowTitlePatterns {
            if title.range(of: pattern, options: .regularExpression) != nil {
                matchedPatterns.append("title: \(pattern)")
                titleMatches += 1
            }
        }
    }
    
    // Check content patterns
    var contentMatches = 0
    if let content = windowContent {
        for pattern in codeContentPatterns {
            if content.range(of: pattern, options: .regularExpression) != nil {
                matchedPatterns.append("content: \(pattern)")
                contentMatches += 1
            }
        }
    }
    
    // Calculate confidence
    let titleConfidence = min(Double(titleMatches) * 0.5, 1.0)
    let contentConfidence = min(Double(contentMatches) * 0.05, 0.3)
    confidence = titleConfidence + contentConfidence
    
    // Determine detection source
    if titleMatches > 0 && contentMatches > 0 {
        detectionSource = .both
    } else if contentMatches > 0 {
        detectionSource = .windowContent
    }
    
    let minimumConfidence = 0.4
    if confidence >= minimumConfidence {
        logger.notice("💻 [DYNAMIC] Code context detected - Title matches: \(titleMatches), Content matches: \(contentMatches), Confidence: \(confidence)")
        return DetectedContext(
            type: .code,
            confidence: min(confidence, 1.0),
            matchedPatterns: matchedPatterns,
            source: detectionSource
        )
    }
    
    return nil
}
```

### Step 5: Add to Main Detection Logic

```swift
/// Main detection method that analyzes window info and content with validation
func detectContext(windowTitle: String?, windowContent: String?) -> DetectedContext {
    // ... existing code ...
    
    // Check email context first (highest priority) with app validation
    if let emailContext = detectEmailContext(windowTitle: windowTitle, windowContent: windowContent) {
        if isValidEmailApp(appContext) || emailContext.confidence > 0.7 {
            logger.notice("✅ [DYNAMIC] Email context detected with confidence \(emailContext.confidence) in app \(appContext)")
            return emailContext
        }
    }
    
    // Check code context
    if let codeContext = detectCodeContext(windowTitle: windowTitle, windowContent: windowContent) {
        if isValidCodeApp(appContext) || codeContext.confidence > 0.7 {
            logger.notice("✅ [DYNAMIC] Code context detected with confidence \(codeContext.confidence) in app \(appContext)")
            return codeContext
        }
    }
    
    // Add other context types here...
    
    // ... existing fallback logic ...
}
```

### Step 6: Create Context-Specific Prompts

```swift
private func getCodePromptEnhancement() -> String {
    return """
    ADDITIONAL CODE/TECHNICAL FORMATTING INSTRUCTIONS:
    After cleaning the transcript, apply these code-specific enhancements:
    
    1. TECHNICAL STRUCTURE:
       - Format as clear technical documentation or code comments
       - Use bullet points for step-by-step processes
       - Structure commands and code snippets clearly
    
    2. TECHNICAL ACCURACY:
       - Preserve technical terminology exactly as spoken
       - Keep programming language keywords intact
       - Maintain file paths, function names, and variable names
    
    3. CODE FORMATTING:
       - Format code blocks with proper indentation
       - Separate commands from explanations
       - Use numbered steps for complex procedures
    
    4. TECHNICAL PRESERVATION:
       - Keep all technical jargon and abbreviations
       - Preserve spoken code syntax and structure
       - Don't add code that wasn't actually spoken
       - Maintain the speaker's technical language level
    
    Return formatted technical content suitable for documentation or code comments.
    """
}

private func getMeetingPromptEnhancement() -> String {
    return """
    ADDITIONAL MEETING NOTES FORMATTING:
    Structure the transcript as professional meeting notes with:
    - Key discussion points with clear headers
    - Decisions made and action items
    - Follow-up tasks with responsible parties
    - Next steps and deadlines
    - Meeting outcomes and conclusions
    """
}

private func getDocumentPromptEnhancement() -> String {
    return """
    ADDITIONAL DOCUMENT FORMATTING:
    Format as structured document content with:
    - Clear headings and logical sections
    - Bullet points for lists and key points
    - Proper paragraph structure for readability
    - Professional documentation style
    - Consistent formatting throughout
    """
}

private func getSocialPromptEnhancement() -> String {
    return """
    ADDITIONAL SOCIAL MEDIA FORMATTING:
    Format as appropriate social media content with:
    - Engaging but professional tone
    - Appropriate length for the platform context
    - Clear and concise messaging
    - Hashtag-friendly structure if applicable
    - Conversational yet polished style
    """
}
```

### Step 7: Update Prompt Enhancement Router

```swift
func getPromptEnhancement(for context: DetectedContext) -> String? {
    switch context.type {
    case .email:
        return getEmailPromptEnhancement()
    case .code:
        return getCodePromptEnhancement()      // ADD THIS
    case .meeting:
        return getMeetingPromptEnhancement()   // ADD THIS
    case .document:
        return getDocumentPromptEnhancement()  // ADD THIS
    case .social:
        return getSocialPromptEnhancement()    // ADD THIS
    case .none:
        return nil
    }
}
```

## 🧪 Testing Strategy

### Manual Testing Checklist

For each new context type, test:

1. **Pattern Matching:**
```swift
// Test with sample window titles
let detector = DynamicContextDetector()
let context = detector.detectContext(
    windowTitle: "main.py - Visual Studio Code",
    windowContent: "def main():\n    print('hello')"
)
print("Detected: \(context.type), Confidence: \(context.confidence)")
```

2. **App Validation:**
   - Test with correct bundle IDs
   - Test case sensitivity handling
   - Test with unknown apps

3. **Integration Testing:**
   - Record audio while in target apps
   - Verify context detection in logs
   - Confirm appropriate prompt enhancement applied

### Debug Logging

Monitor these log patterns:
```
🔍 [DYNAMIC] Starting context detection
🔍 [APP-VALIDATION] bundleId: 'com.microsoft.VSCode' → valid: true
💻 [DYNAMIC] Code context detected - Title matches: 1, Content matches: 3, Confidence: 0.650000
✅ [DYNAMIC] Code context detected with confidence 0.65 in app com.microsoft.VSCode
```

## ⚠️ Common Pitfalls

### 1. Bundle ID Case Sensitivity
**Problem:** macOS reports `com.microsoft.VSCode` but you have `com.microsoft.vscode`  
**Solution:** Always use case-insensitive comparison (already implemented)

### 2. Overly Broad Patterns
**Problem:** Pattern `.*code.*` matches "decode", "barcode", etc.  
**Solution:** Use specific patterns like `.*Visual Studio Code.*`

### 3. International Applications
**Problem:** Apps may have different titles in different languages  
**Solution:** Focus on bundle IDs and universal patterns (file extensions, URLs)

### 4. Confidence Calibration
**Problem:** Context detection too sensitive or not sensitive enough  
**Solution:** Adjust confidence weights and minimum thresholds based on testing

## 📊 Performance Considerations

- **Pattern Matching:** O(n) where n = number of patterns. Keep patterns focused.
- **Window Detection:** Called on every recording. Minimize expensive operations.
- **Memory Usage:** Large pattern arrays consume memory. Consider lazy loading for rarely used patterns.

## 🔗 Integration Points

### WhisperState Integration

The system is already integrated via:
```swift
// In WhisperState.swift - look for these calls:
enhanceWithDynamicContextTracking(
    transcript,
    windowTitle: windowTitle,
    windowContent: windowContent
)
```

### Future Enhancement Ideas

1. **URL-Based Detection:** For browser-based tools (GitHub, Figma, etc.)
2. **Content Analysis:** Use AI to classify context from screen content
3. **User Learning:** Remember user's preferred contexts for specific apps
4. **Multi-Context Detection:** Handle overlapping contexts (code + meeting)

## 🎯 Next Steps Priority

### 1. Code Detection (Highest Priority)
- Most requested by users
- Clear patterns and apps to detect
- High impact on developer workflows

### 2. Meeting Detection (Medium Priority)
- Zoom, Teams, Meet detection
- Calendar integration possible
- Structured note-taking benefits

### 3. Document Detection (Medium Priority)
- Google Docs, Word, Notion
- Academic and business writing
- Citation and formatting improvements

### 4. Social Media Detection (Lower Priority)
- Twitter, LinkedIn, etc.
- Character limits and engagement optimization
- Less critical for core workflows

---

Good luck with the implementation! The foundation is solid and extensible. 🚀

**Questions?** Check the existing email implementation in `DynamicContextDetector.swift` as a reference - it's fully functional and well-commented.