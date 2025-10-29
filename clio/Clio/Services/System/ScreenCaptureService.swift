import Foundation
import AppKit
import Vision
import os

class ScreenCaptureService: ObservableObject {
    @Published var isCapturing = false
    @Published var lastCapturedText: String?
    
    private let logger = Logger(
        subsystem: "com.cliovoice.clio",
        category: "aienhancement"
    )
    
    // Browser bundle identifiers for improved OCR settings
    private func isBrowserApp(_ bundleId: String) -> Bool {
        let browserBundleIds = [
            "com.google.Chrome",
            "com.apple.Safari",
            "org.mozilla.firefox",
            "com.microsoft.edgemac",
            "com.operasoftware.Opera",
            "com.brave.Browser",
            "org.chromium.Chromium"
        ]
        return browserBundleIds.contains(bundleId)
    }
    
    // Convert app language codes to Vision framework language codes
    private func convertToVisionCode(_ appLanguage: String) -> String? {
        let mapping: [String: String] = [
            // Major languages with region codes for Vision framework
            "en": "en-US",
            "zh": "zh-Hans",
            "zh-cn": "zh-Hans",
            "zh-tw": "zh-Hant", 
            "zh-hans": "zh-Hans",
            "zh-hant": "zh-Hant",
            "yue": "zh-HK", // Cantonese
            "ja": "ja-JP",
            "ko": "ko-KR",
            "fr": "fr-FR",
            "de": "de-DE",
            "es": "es-ES",
            "it": "it-IT",
            "pt": "pt-BR",
            "ru": "ru-RU",
            "ar": "ar-SA",
            "hi": "hi-IN",
            "th": "th-TH",
            "vi": "vi-VN",
            "tr": "tr-TR",
            "pl": "pl-PL",
            "nl": "nl-NL",
            "sv": "sv-SE",
            "da": "da-DK",
            "no": "nb-NO",
            "fi": "fi-FI",
            "hu": "hu-HU",
            "cs": "cs-CZ",
            "sk": "sk-SK",
            "uk": "uk-UA",
            "bg": "bg-BG",
            "hr": "hr-HR",
            "ro": "ro-RO",
            "sl": "sl-SI",
            "et": "et-EE",
            "lv": "lv-LV",
            "lt": "lt-LT",
            
            // Additional languages from your dictation list
            "af": "af-ZA", // Afrikaans
            "am": "am-ET", // Amharic
            "as": "as-IN", // Assamese
            "az": "az-AZ", // Azerbaijani
            "be": "be-BY", // Belarusian
            "bn": "bn-BD", // Bengali
            "bs": "bs-BA", // Bosnian
            "ca": "ca-ES", // Catalan
            "cy": "cy-GB", // Welsh
            "el": "el-GR", // Greek
            "eu": "eu-ES", // Basque
            "fa": "fa-IR", // Persian
            "gl": "gl-ES", // Galician
            "gu": "gu-IN", // Gujarati
            "he": "he-IL", // Hebrew
            "hy": "hy-AM", // Armenian
            "id": "id-ID", // Indonesian
            "is": "is-IS", // Icelandic
            "ka": "ka-GE", // Georgian
            "kk": "kk-KZ", // Kazakh
            "km": "km-KH", // Khmer
            "kn": "kn-IN", // Kannada
            "la": "la-VA", // Latin
            "lo": "lo-LA", // Lao
            "mk": "mk-MK", // Macedonian
            "ml": "ml-IN", // Malayalam
            "mn": "mn-MN", // Mongolian
            "mr": "mr-IN", // Marathi
            "ms": "ms-MY", // Malay
            "mt": "mt-MT", // Maltese
            "my": "my-MM", // Myanmar
            "ne": "ne-NP", // Nepali
            "pa": "pa-IN", // Punjabi
            "ps": "ps-AF", // Pashto
            "sa": "sa-IN", // Sanskrit
            "sd": "sd-PK", // Sindhi
            "si": "si-LK", // Sinhala
            "sq": "sq-AL", // Albanian
            "sr": "sr-RS", // Serbian
            "sw": "sw-KE", // Swahili
            "ta": "ta-IN", // Tamil
            "te": "te-IN", // Telugu
            "tg": "tg-TJ", // Tajik
            "tk": "tk-TM", // Turkmen
            "tl": "tl-PH", // Tagalog
            "tt": "tt-RU", // Tatar
            "ur": "ur-PK", // Urdu
            "uz": "uz-UZ", // Uzbek
            "yi": "yi-US", // Yiddish
            "yo": "yo-NG"  // Yoruba
        ]
        return mapping[appLanguage.lowercased()]
    }
    
    // Get Vision framework languages based on user selection
    private func getVisionLanguages() -> [String] {
        let selectedLanguages = MultilingualPrompts.getSelectedLanguages()
        
        // Debug logging for OCR language selection
        // logger.notice("🌐 [OCR DEBUG] Selected languages from settings: \(Array(selectedLanguages).joined(separator: ", "))")
        
        if selectedLanguages.contains("auto") {
            // Auto-select: use system locale + English as smart defaults
            let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
            let autoLanguages = ["en-US", convertToVisionCode(systemLang)]
            let finalLanguages = Array(Set(autoLanguages.compactMap { $0 })).prefix(3).map { $0 }
            // logger.notice("🌐 [OCR DEBUG] Auto-detect mode - using languages: \(finalLanguages.joined(separator: ", "))")
            return finalLanguages
        } else {
            // Convert to Vision framework codes first, then prioritize non-English languages
            let visionLanguages = Array(selectedLanguages.prefix(3)).compactMap { convertToVisionCode($0) }
            
            // Sort to put non-English languages FIRST (like your working Swift test)
            let sortedVisionLanguages = visionLanguages.sorted { first, second in
                // Non-English languages go first
                if first.starts(with: "en") && !second.starts(with: "en") { return false }
                if !first.starts(with: "en") && second.starts(with: "en") { return true }
                return first < second
            }
            
            // logger.notice("🌐 [OCR DEBUG] User selection mode - prioritizing non-English: \(sortedVisionLanguages.joined(separator: ", "))")
            return sortedVisionLanguages
        }
    }
    
    private func getActiveWindowInfo() -> (title: String, ownerName: String, windowID: CGWindowID)? {
        // Use the same frontmost app detection as PowerMode for consistency
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication,
              let bundleIdentifier = frontmostApp.bundleIdentifier else {
            logger.notice("❌ Could not get frontmost application for screen capture")
            return nil
        }
        
        let frontmostAppName = frontmostApp.localizedName ?? "Unknown"
        // logger.notice("🎯 ScreenCapture detected frontmost app: \(frontmostAppName) (\(bundleIdentifier))")
        
        // Now find the window that belongs to this frontmost application
        let windowListInfo = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
        
        // Look for windows belonging to the frontmost application
        if let frontWindow = windowListInfo.first(where: { info in
            let layer = info[kCGWindowLayer as String] as? Int32 ?? 0
            let ownerName = info[kCGWindowOwnerName as String] as? String ?? ""
            let ownerPid = info[kCGWindowOwnerPID as String] as? pid_t ?? -1
            let windowName = info[kCGWindowName as String] as? String ?? ""

            // Prefer PID match for robustness (ownerName can include invisible chars or localization differences)
            let belongsToFrontmostApp = ownerPid == frontmostApp.processIdentifier
            let isValidLayer = layer == 0
            // Accept windows that belong to the app, even if untitled
            let hasValidContent = !windowName.isEmpty || (belongsToFrontmostApp && windowName.isEmpty)

            // Reduced logging: only log matching windows to improve performance
            if belongsToFrontmostApp && isValidLayer && hasValidContent {
                // logger.debug("🎯 Found matching window: \(windowName) (\(ownerName)) - layer:\(layer), pid:\(ownerPid)")
            }

            return belongsToFrontmostApp && isValidLayer && hasValidContent
        }) {
            guard let windowID = frontWindow[kCGWindowNumber as String] as? CGWindowID,
                  let ownerName = frontWindow[kCGWindowOwnerName as String] as? String else {
                return nil
            }
            
            // Handle empty window titles (common for Terminal, code editors)
            let title = frontWindow[kCGWindowName as String] as? String ?? ownerName
            
            // logger.notice("🎯 ScreenCapture found window: \(title) (\(ownerName)) - matches PowerMode detection")
            return (title: title, ownerName: ownerName, windowID: windowID)
        }
        
        // Fallback strategy: some apps (e.g. WhatsApp, Electron apps) use non-zero layers or untitled windows.
        // Choose the largest visible window for the same PID.
        let candidateWindows: [(info: [String: Any], area: Int)] = windowListInfo.compactMap { info in
            let ownerPid = info[kCGWindowOwnerPID as String] as? pid_t ?? -1
            guard ownerPid == frontmostApp.processIdentifier else { return nil }
            let boundsDict = info[kCGWindowBounds as String] as? [String: Any] ?? [:]
            let width = boundsDict["Width"] as? Int ?? 0
            let height = boundsDict["Height"] as? Int ?? 0
            let alpha = info[kCGWindowAlpha as String] as? Double ?? 1.0
            let area = width * height
            // Ignore fully transparent or tiny windows
            guard alpha > 0.01, area > 10_000 else { return nil }
            return (info, area)
        }
        .sorted { $0.area > $1.area }

        if let best = candidateWindows.first {
            let info = best.info
            let windowID = info[kCGWindowNumber as String] as? CGWindowID
            let ownerName = info[kCGWindowOwnerName as String] as? String ?? frontmostAppName
            let title = info[kCGWindowName as String] as? String ?? ownerName
            if let windowID = windowID {
                logger.notice("🎯 [FALLBACK] Selected largest window for PID match: \(title) (\(ownerName))")
                return (title: title, ownerName: ownerName, windowID: windowID)
            }
        }

        logger.notice("⚠️ No window found for frontmost app: \(frontmostAppName)")
        return nil
    }
    
    func captureActiveWindow() -> NSImage? {
        guard let windowInfo = getActiveWindowInfo() else {
            logger.notice("❌ Failed to get window info for capture")
            return captureFullScreen()
        }
        
        // logger.notice("🖼️ Attempting window-specific capture for: \(windowInfo.title) (ID: \(windowInfo.windowID))")
        
        // Try multiple capture strategies for better content capture
        var captureOptions: CGWindowImageOption = []
        
        // For browsers, try without bounds ignore to get actual content
        if windowInfo.ownerName.contains("Chrome") || windowInfo.ownerName.contains("Safari") || 
           windowInfo.ownerName.contains("Firefox") || windowInfo.ownerName.contains("Arc") {
            logger.notice("🌐 Browser detected, using content-optimized capture settings")
            captureOptions = [.bestResolution, .nominalResolution]
        } else {
            captureOptions = [.boundsIgnoreFraming, .bestResolution]
        }
        
        // Capture the specific window
        let cgImage = CGWindowListCreateImage(
            .null,
            .optionIncludingWindow,
            windowInfo.windowID,
            captureOptions
        )
        
        if let cgImage = cgImage {
            let imageSize = NSSize(width: cgImage.width, height: cgImage.height)
            // logger.notice("✅ Successfully captured window: \(imageSize.width)x\(imageSize.height)")
            
            // Validate the captured image has meaningful content
            if cgImage.width < 100 || cgImage.height < 100 {
//                logger.notice("⚠️ Captured window too small (\(imageSize)), trying full screen instead")
                return captureFullScreen()
            }
            
            return NSImage(cgImage: cgImage, size: imageSize)
        } else {
            logger.notice("⚠️ Window-specific capture failed for \(windowInfo.ownerName), trying full screen")
            return captureFullScreen()
        }
    }
    
    private func screenUnderMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        if let screen = NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) }) {
            return screen
        }
        return NSScreen.main
    }

    private func captureFullScreen(on targetScreen: NSScreen? = nil) -> NSImage? {
        let chosenScreen = targetScreen ?? screenUnderMouse()
        logger.notice("📺 Attempting full screen capture")

        if let screen = chosenScreen {
            let rect = screen.frame
            let cgImage = CGWindowListCreateImage(
                rect,
                .optionOnScreenOnly,
                kCGNullWindowID,
                [.bestResolution]
            )

            if let cgImage = cgImage {
                logger.notice("✅ Full screen capture successful")
                return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            }
        }

        logger.notice("❌ All capture methods failed")
        return nil
    }
    
    func extractText(from image: NSImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            logger.notice("❌ Failed to convert NSImage to CGImage for text extraction")
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        // Ensure completion is called exactly once and on the main queue
        var didFinish = false
        let finish: (String?) -> Void = { result in
            if didFinish { return }
            didFinish = true
            DispatchQueue.main.async { completion(result) }
        }

        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self else { return finish(nil) }

            if let error = error {
                self.logger.notice("❌ Text recognition error: \(error.localizedDescription, privacy: .public)")
                return finish(nil)
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                self.logger.notice("❌ No text observations found")
                return finish(nil)
            }
            
            self.logger.notice("🔍 Found \(observations.count, privacy: .public) text observations")
            
            let text = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            if text.isEmpty {
                self.logger.notice("⚠️ Text extraction returned empty result from \(observations.count, privacy: .public) observations")
                // Log detailed debug info about the observations
                for (index, observation) in observations.prefix(5).enumerated() {
                    let candidate = observation.topCandidates(1).first
                    let confidence = candidate?.confidence ?? 0.0
                    let boundingBox = observation.boundingBox
                    self.logger.notice("📊 Observation \(index, privacy: .public): confidence \(confidence, privacy: .public), bounds: \(boundingBox.width, privacy: .public)x\(boundingBox.height, privacy: .public)")
                    if let candidateText = candidate?.string, !candidateText.isEmpty {
                        self.logger.notice("📝 Low-confidence text \(index, privacy: .public): '\(candidateText, privacy: .public)'")
                    }
                }

                // Fallback OCR pass: reduce minimumTextHeight and enable automatic language detection
                let fallbackRequest = VNRecognizeTextRequest { [weak self] req, err in
                    guard let self else { return finish(nil) }
                    if let err = err {
                        self.logger.notice("❌ Fallback text recognition error: \(err.localizedDescription, privacy: .public)")
                        return finish(nil)
                    }
                    guard let fallbackObservations = req.results as? [VNRecognizedTextObservation] else {
                        self.logger.notice("❌ Fallback OCR produced no observations")
                        return finish(nil)
                    }
                    self.logger.notice("🔍 [FALLBACK OCR] Found \(fallbackObservations.count, privacy: .public) text observations")
                    let fallbackText = fallbackObservations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                    if fallbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        return finish(nil)
                    }
                    return finish(fallbackText)
                }
                fallbackRequest.recognitionLevel = .accurate
                fallbackRequest.usesLanguageCorrection = true
                fallbackRequest.minimumTextHeight = 0.003
                fallbackRequest.automaticallyDetectsLanguage = true

                do {
                    try requestHandler.perform([fallbackRequest])
                } catch {
                    self.logger.notice("❌ Failed to perform fallback text recognition: \(error.localizedDescription, privacy: .public)")
                    return finish(nil)
                }
            } else {
                // Validate the quality of extracted text
                let nonWhitespaceCount = text.trimmingCharacters(in: .whitespacesAndNewlines).count
                let wordCount = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
                self.logger.notice("✅ Text extraction successful: \(text.count, privacy: .public) chars, \(nonWhitespaceCount, privacy: .public) non-whitespace, \(wordCount, privacy: .public) words from \(observations.count, privacy: .public) observations")
                let menuKeywords = ["File", "Edit", "View", "History", "Window", "Help", "Bookmarks"]
                let menuMatches = menuKeywords.filter { text.localizedCaseInsensitiveContains($0) }.count
                if menuMatches >= 3 && wordCount <= 10 {
                    self.logger.notice("⚠️ Detected mostly menu bar text (menu keywords: \(menuMatches, privacy: .public)) - may need better window capture")
                }
                return finish(text)
            }
        }
        
        // Configure the recognition level for better text detection
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        // Enhanced settings for web content and terminal/code text recognition
        request.minimumTextHeight = 0.008 // Detect even smaller text (web content varies widely)
        
        // Use selected languages from user preferences instead of auto-detect
        let visionLanguages = getVisionLanguages()
        if !visionLanguages.isEmpty {
            request.recognitionLanguages = visionLanguages
            logger.notice("🌐 Using selected languages for OCR: \(visionLanguages.joined(separator: ", "))")
        } else {
            request.automaticallyDetectsLanguage = true
            logger.notice("🌐 Falling back to automatic language detection")
        }
        
        // Browser-specific optimizations for better webpage content capture
        if let frontmostApp = NSWorkspace.shared.frontmostApplication,
           let bundleId = frontmostApp.bundleIdentifier,
           isBrowserApp(bundleId) {
            logger.notice("🌐 Browser detected - using optimized OCR settings for webpage content")
            // Keep .accurate for proper Chinese character recognition
            // request.recognitionLevel = .fast // This breaks Chinese OCR!
            request.minimumTextHeight = 0.005 // Capture small web text like captions, fine print
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            logger.notice("❌ Failed to perform text recognition: \(error.localizedDescription, privacy: .public)")
            finish(nil)
        }
    }
    
    func captureAndExtractText() async -> String? {
        guard !isCapturing else { 
            logger.notice("⚠️ Screen capture already in progress, skipping")
            return nil 
        }
        
        // Check screen recording permission
        let hasScreenRecordingPermission = CGPreflightScreenCaptureAccess()
        if !hasScreenRecordingPermission {
            logger.notice("❌ Missing screen recording permission - requesting access")
            CGRequestScreenCaptureAccess()
            return nil
        }
        
        isCapturing = true
        defer { 
            DispatchQueue.main.async {
                self.isCapturing = false
            }
        }
        
        logger.notice("🎬 Starting screen capture with verified permissions")
        
        // Attempt to gather metadata about the active window. If this cannot be
        // determined (e.g. the front-most window has no title or is a system
        // window) we *do not* treat it as a fatal error – instead we fall back
        // to a full-screen capture so that downstream services (recording,
        // transcription, AI context) can still proceed.

        let windowInfo = getActiveWindowInfo()

        if let w = windowInfo {
            logger.notice("🎯 \(w.title, privacy: .public)")
        }

        // Assemble initial context text if we have window details.
        var contextText = ""
        if let w = windowInfo {
            contextText += """
            Active Window: \(w.title)
            Application: \(w.ownerName)

            """
        }
        
        // Capture and process window content
        if let capturedImage = captureActiveWindow() {
            let extractedText = await withCheckedContinuation({ continuation in
                extractText(from: capturedImage) { text in
                    continuation.resume(returning: text)
                }
            })

            if let extractedText = extractedText {
                contextText += "Window Content:\n\(extractedText)"
                logger.notice("✅ Captured text successfully")

                await MainActor.run {
                    self.lastCapturedText = contextText
                }

                return contextText
            }
        }

        // Fallback: if window capture or OCR yielded no text, try per-display full-screen OCR
        logger.notice("🔁 [CAPTURE DEBUG] Retrying OCR with per-display captures")
        for screen in NSScreen.screens {
            guard let image = captureFullScreen(on: screen) else { continue }
            if let extractedText = await withCheckedContinuation({ continuation in
                extractText(from: image) { text in
                    continuation.resume(returning: text)
                }
            }) {
                var text = contextText
                text += "Window Content (Display Retry):\n\(extractedText)"
                await MainActor.run {
                    self.lastCapturedText = text
                }
                logger.notice("✅ Captured text successfully on display retry")
                return text
            }
        }

        logger.notice("❌ Capture attempt failed")
        return nil
    }
    
    /// Captures screen context at the end of recording for intelligent context detection
    func captureEndContext() async -> String? {
        let startTime = Date()
        
        guard !isCapturing else { 
            logger.notice("⚠️ Screen capture already in progress, skipping end context")
            return nil 
        }
        
        isCapturing = true
        defer { 
            DispatchQueue.main.async {
                self.isCapturing = false
            }
        }
        
        logger.notice("🎯 Capturing end-of-recording context")
        
        // Get window info
        let windowInfoStart = Date()
        guard let windowInfo = getActiveWindowInfo() else {
            logger.notice("❌ Failed to get window info for end context")
            return nil
        }
        let windowInfoTime = Date().timeIntervalSince(windowInfoStart) * 1000
        print("⏱️ [CONTEXT DETAIL] Window detection: \(String(format: "%.1f", windowInfoTime))ms")
        
        logger.notice("🎯 Found final window: \(windowInfo.title) (\(windowInfo.ownerName)) - \(windowInfo.windowID)")
        
        // Capture the screen
        let captureStart = Date()
        guard let capturedImage = captureActiveWindow() else {
            logger.notice("❌ Failed to capture screen for end context")
            return nil
        }
        let captureTime = Date().timeIntervalSince(captureStart) * 1000
        print("⏱️ [CONTEXT DETAIL] Screen capture: \(String(format: "%.1f", captureTime))ms")
        
        // Extract text from the captured image using continuation for async/await
        let ocrStart = Date()
        let extractedText = await withCheckedContinuation { continuation in
            extractText(from: capturedImage) { text in
                continuation.resume(returning: text)
            }
        }
        let ocrTime = Date().timeIntervalSince(ocrStart) * 1000
        print("⏱️ [CONTEXT DETAIL] OCR processing: \(String(format: "%.1f", ocrTime))ms")
        
        // Combine window information with extracted text
        let textProcessingStart = Date()
        var textContent = ""
        textContent += "Current Application: \(windowInfo.ownerName)\n"
        textContent += "Window Title: \(windowInfo.title)\n"
        
        if let extractedText = extractedText, !extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textContent += "Screen Content:\n\(extractedText)"
            logger.notice("✅ Successfully extracted end context - App: \(windowInfo.ownerName), Text: \(extractedText.prefix(100))...")
        } else {
            logger.notice("⚠️ No text extracted from end context screen capture")
        }
        
        let textProcessingTime = Date().timeIntervalSince(textProcessingStart) * 1000
        let totalTime = Date().timeIntervalSince(startTime) * 1000
        print("⏱️ [CONTEXT DETAIL] Text processing: \(String(format: "%.1f", textProcessingTime))ms")
        print("⏱️ [CONTEXT DETAIL] Total end-context: \(String(format: "%.1f", totalTime))ms")
        
        // Store this as the latest captured text
        await MainActor.run {
            self.lastCapturedText = textContent
        }
        
        return textContent
    }
    
    /// Get current window information for dynamic context detection
    func getCurrentWindowInfo() -> (title: String?, content: String?) {
        // Get active window metadata
        let windowInfo = getActiveWindowInfo()
        let windowTitle = windowInfo?.title
        
        // Get last captured content if available
        let windowContent = lastCapturedText
        
        return (title: windowTitle, content: windowContent)
    }
}
