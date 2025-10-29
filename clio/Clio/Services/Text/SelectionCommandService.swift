import Foundation
import AppKit
import os
import SwiftData

@MainActor
final class SelectionCommandService {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.cliovoice.clio", category: "SelectionCommand")
    
    struct SelectionResult {
        let text: String
        let restoreClipboard: () -> Void
    }
    
    @discardableResult
    static func run(instruction: String, enhancementService: AIEnhancementService?, modelContext: ModelContext?) -> Task<Void, Never> {
        return Task { @MainActor in
            guard let enhancementService = enhancementService else {
                logger.error("❌ No enhancement service available for command transform")
                return
            }
            // 0) Context + NER prewarm for Command Mode
            // Kick off a fresh screen context capture and prewarm the AI/NER connection
            Task { await enhancementService.captureScreenContext() }
            enhancementService.prewarmConnection()
            
            // 1) Capture selection
            guard let selection = await captureSelectedText() else {
                ToastBanner.shared.show(title: "No selection", subtitle: "Select text, then try again")
                return
            }
            
            if selection.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ToastBanner.shared.show(title: "No selection", subtitle: "Selected text was empty")
                return
            }
            
            do {
                // 2) Transform
                let transformed = try await enhancementService.transformSelectedText(selected: selection.text, instruction: instruction)
                let output = transformed.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !output.isEmpty else {
                    ToastBanner.shared.show(title: "No output", subtitle: "Model returned empty result")
                    return
                }
                // 3) Replace selection
                var usedClipboardPaste = false
                if TextInjector.insertAtCursor(output) {
                    // Direct insertion succeeded — safe to restore clipboard immediately
                    selection.restoreClipboard()
                } else {
                    // Fallback: paste via clipboard but MATCH STYLE so we don't import fonts/formatting
                    usedClipboardPaste = true
                    CursorPaster.pasteAtCursor(output, matchStyle: true)
                    // Restore the user's pre-capture clipboard after CursorPaster's own restore window
                    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.9) {
                        selection.restoreClipboard()
                    }
                }
                
                // 4) Persist a command-mode entry in history (if we have a model context)
                if let modelContext {
                    let entry = Transcription(text: instruction, duration: 0, enhancedText: nil, audioFileURL: nil)
                    entry.isCommand = true
                    entry.commandOutput = output
                    modelContext.insert(entry)
                    try? modelContext.save()
                }
            } catch {
                logger.error("❌ Transform failed: \(error.localizedDescription)")
                ToastBanner.shared.show(title: "Transform failed", subtitle: error.localizedDescription)
            }
        }
    }
    
    private static func captureSelectedText() async -> SelectionResult? {
        // Save clipboard contents
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
        
        func restoreClipboard() {
            if !savedContents.isEmpty {
                pasteboard.clearContents()
                for (type, data) in savedContents { pasteboard.setData(data, forType: type) }
            }
        }
        
        let originalChangeCount = pasteboard.changeCount
        issueCommandC()

        var copied = false
        let maxAttempts = 6
        for attempt in 0..<maxAttempts {
            try? await Task.sleep(nanoseconds: 60_000_000) // 60ms between polls
            if pasteboard.changeCount != originalChangeCount {
                copied = true
                break
            }
            // Re-issue Command+C once if the first attempt didn't move the pasteboard
            if attempt == 1 {
                issueCommandC()
            }
        }

        guard copied else {
            restoreClipboard()
            logger.error("❌ Failed to copy selection – pasteboard unchanged")
            return nil
        }

        let text = pasteboard.string(forType: .string) ?? ""
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            restoreClipboard()
            logger.error("❌ Copied selection is empty after retries")
            return nil
        }

        return SelectionResult(text: text, restoreClipboard: restoreClipboard)
    }
    
    private static func issueCommandC() {
        let source = CGEventSource(stateID: .hidSystemState)
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        let cDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true) // 'c'
        let cUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)
        cmdDown?.flags = .maskCommand
        cDown?.flags = .maskCommand
        cUp?.flags = .maskCommand
        cmdDown?.post(tap: .cghidEventTap)
        cDown?.post(tap: .cghidEventTap)
        cUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
    }
}
