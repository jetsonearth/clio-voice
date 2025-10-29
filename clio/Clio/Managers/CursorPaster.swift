import Foundation
import AppKit
import os

class CursorPaster {
    private static let pasteCompletionDelay: TimeInterval = 0.3
    private static let throttleInterval: TimeInterval = 0.6
    private static var lastPasteSignature: String?
    private static var lastPasteTime: Date?
    private static let syncQueue = DispatchQueue(label: "com.jetsonai.clio.cursorpaster.guard")
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.cliovoice.clio", category: "CursorPaster")
    
    /// Paste plain text at the cursor. When matchStyle is true, uses the OS-level
    /// "Paste and Match Style" shortcut (⌘⇧⌥V) to avoid importing fonts/formatting
    /// into rich text editors like Notes, Mail, Docs, etc.
    static func pasteAtCursor(_ text: String, matchStyle: Bool = false) {
        let app = NSWorkspace.shared.frontmostApplication
        let target = (app?.localizedName ?? "?")
        let preview = String(text.prefix(12))
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            StructuredLog.shared.log(cat: .transcript, evt: "insert_attempt", lvl: .warn, [
                "target": target,
                "chars": 0,
                "text": "",
                "skipped": true,
                "reason": "empty_text"
            ])
            logger.notice("🔍 [PASTE DEBUG] Skipping paste: empty text")
            return
        }
StructuredLog.shared.log(cat: .transcript, evt: "insert_attempt", lvl: .info, [
            "target": target,
            "chars": text.count,
            "text": text
        ])
        guard AXIsProcessTrusted() else {
            logger.notice("🔍 [PASTE DEBUG] AXIsProcessTrusted() returned false, exiting")
            return
        }
        logger.notice("🔍 [PASTE DEBUG] AXIsProcessTrusted() returned true, proceeding")

        // Throttle identical back-to-back requests
        let throttled = syncQueue.sync { () -> Bool in
            let now = Date()
            let sig = makeSignature(for: text)
            if let lastSig = lastPasteSignature, let last = lastPasteTime,
               lastSig == sig, now.timeIntervalSince(last) < throttleInterval {
                logger.debug("🧯 Throttled duplicate paste request")
                return true
            }
            lastPasteSignature = sig
            lastPasteTime = now
            return false
        }
        if throttled { return }

        // Try direct insertion via Accessibility first to avoid clipboard churn
        let useDirectInsertion = UserDefaults.standard.bool(forKey: "UseDirectTextInsertion")
        logger.notice("🔍 [PASTE DEBUG] UseDirectTextInsertion setting: \(useDirectInsertion)")
        if useDirectInsertion {
            logger.notice("🔍 [PASTE DEBUG] ✏️ Attempting direct AX insertion")
            let insertResult = TextInjector.insertAtCursor(text)
            logger.notice("🔍 [PASTE DEBUG] TextInjector.insertAtCursor() result: \(insertResult)")
            if insertResult {
                logger.notice("🔍 [PASTE DEBUG] ✅ Direct AX insertion succeeded, returning")
                return
            }
            // Fall through to clipboard-based paste if direct insert failed
            logger.notice("🔍 [PASTE DEBUG] ↩️ Direct AX insertion failed, falling back to clipboard paste")
        } else {
            logger.notice("🔍 [PASTE DEBUG] Direct insertion disabled, using clipboard paste")
        }
        
        let pasteboard = NSPasteboard.general
        
        var savedContents: [(NSPasteboard.PasteboardType, Data)] = []
        let currentItems = pasteboard.pasteboardItems ?? []
        
        for item in currentItems {
            for type in item.types {
                if let data = item.data(forType: type) {
                    savedContents.append((type, data))
                }
            }
        }
        
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        if UserDefaults.standard.bool(forKey: "UseAppleScriptPaste") {
            logger.debug("📜 Using AppleScript-based paste (matchStyle=\(matchStyle))")
            TimingMetrics.shared.pasteStartTs = Date()
            if matchStyle {
                _ = pasteUsingAppleScriptMatchStyle()
            } else {
                _ = pasteUsingAppleScript()
            }
        } else {
            logger.debug("⌨️ Using CGEvent-based paste (matchStyle=\(matchStyle))")
            TimingMetrics.shared.pasteStartTs = Date()
            if matchStyle {
                pasteUsingMatchStyle()
            } else {
                pasteUsingCommandV()
            }
        }
        // Mark paste done immediately after issuing Command+V and emit E2E log
        TimingMetrics.shared.pasteDoneTs = Date()
StructuredLog.shared.log(cat: .transcript, evt: "insert_result", lvl: .info, ["ok": true])
        emitPostReleaseE2ELog()

        // Kick off post-paste edit observation window (MainActor)
        Task { @MainActor in
            EditObserver.shared.startWatchingAfterPaste(pastedText: text, windowSeconds: 60.0)
        }
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + pasteCompletionDelay) {
            if !savedContents.isEmpty {
                pasteboard.clearContents()
                for (type, data) in savedContents {
                    pasteboard.setData(data, forType: type)
                }
            }
        }

        // Kick off post-paste edit observation window (MainActor)
        Task { @MainActor in
            EditObserver.shared.startWatchingAfterPaste(pastedText: text, windowSeconds: 60.0)
        }
    }
    
    private static func makeSignature(for text: String) -> String {
        let prefix = text.prefix(16)
        let suffix = text.suffix(16)
        return "\(text.count)|\(prefix)|\(suffix)"
    }
    
    private static func pasteUsingAppleScript() -> Bool {
        let script = """
        tell application "System Events"
            keystroke "v" using command down
        end tell
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            _ = scriptObject.executeAndReturnError(&error)
            return error == nil
        }
        return false
    }
    
    private static func pasteUsingAppleScriptMatchStyle() -> Bool {
        let script = """
        tell application "System Events"
            keystroke "v" using {command down, option down, shift down}
        end tell
        """
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            _ = scriptObject.executeAndReturnError(&error)
            return error == nil
        }
        return false
    }
    
private static func pasteUsingCommandV() {
        
        let source = CGEventSource(stateID: .hidSystemState)
        
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)
        
        cmdDown?.flags = .maskCommand
        vDown?.flags = .maskCommand
        vUp?.flags = .maskCommand
        
        cmdDown?.post(tap: .cghidEventTap)
        vDown?.post(tap: .cghidEventTap)
        vUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
    }
    
    private static func pasteUsingMatchStyle() {
        let source = CGEventSource(stateID: .hidSystemState)
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        let vDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let vUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)
        // Apply Command+Option+Shift modifiers
        cmdDown?.flags = [.maskCommand, .maskAlternate, .maskShift]
        vDown?.flags = [.maskCommand, .maskAlternate, .maskShift]
        vUp?.flags = [.maskCommand, .maskAlternate, .maskShift]
        cmdUp?.flags = [.maskCommand, .maskAlternate, .maskShift]
        cmdDown?.post(tap: .cghidEventTap)
        vDown?.post(tap: .cghidEventTap)
        vUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
    }
    
    private static func emitPostReleaseE2ELog() {
        let logger = Self.logger
        let tm = TimingMetrics.shared
        guard let keyUp = tm.keyUpTs, let pasteDone = tm.pasteDoneTs else { return }
        let e2eMs = Int(pasteDone.timeIntervalSince(keyUp) * 1000)
        // Prefer client-side finalize marker if present (fast path), else fall back to <fin>
        let finalizeRef = tm.clientFinalizeTs ?? tm.finTs
        let finalizeMs = finalizeRef != nil ? Int((finalizeRef!.timeIntervalSince(keyUp)) * 1000) : -1
        let llmMs = (tm.llmStartTs != nil && tm.llmEndTs != nil) ? Int(tm.llmEndTs!.timeIntervalSince(tm.llmStartTs!) * 1000) : -1
        let pasteMs = tm.pasteStartTs != nil ? Int(pasteDone.timeIntervalSince(tm.pasteStartTs!) * 1000) : -1
        // Check if warm socket was actually reused for this session
        var warmReused = tm.wasWarmSocketReused
        if !warmReused {
            // Fallback: check last-session flag set by streaming service to avoid timing races
            warmReused = UserDefaults.standard.bool(forKey: "LastWarmSocketReused")
        }
        // Clear the fallback flag so it doesn't bleed into the next session
        if warmReused { UserDefaults.standard.set(false, forKey: "LastWarmSocketReused") }
        let warm = warmReused ? "yes" : "no"
        var parts: [String] = []
        if finalizeMs >= 0 { parts.append("finalize=\(finalizeMs)ms") }
        if llmMs >= 0 { parts.append("llm=\(llmMs)ms") }
        if pasteMs >= 0 { parts.append("paste=\(pasteMs)ms") }
        let breakdown = parts.joined(separator: " | ")
        logger.notice("📊 [POST-RELEASE E2E] \(e2eMs)ms (\(breakdown)) | warm_socket=\(warm)")
    }
}
