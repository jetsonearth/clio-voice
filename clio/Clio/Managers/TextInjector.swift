import Foundation
import AppKit
import ApplicationServices
import os

// Helper to bridge AXObserver C callback without capturing context
private final class AXSemaphoreBox {
    let sem: DispatchSemaphore
    init(_ sem: DispatchSemaphore) { self.sem = sem }
}

private func TextInjectorAXObserverCallback(_ observer: AXObserver, _ element: AXUIElement, _ notification: CFString, _ refcon: UnsafeMutableRawPointer?) {
    guard let refcon = refcon else { return }
    let box = Unmanaged<AXSemaphoreBox>.fromOpaque(refcon).takeUnretainedValue()
    box.sem.signal()
}

/// Inserts text into the currently focused text field/editor using macOS Accessibility (AX) APIs
/// without modifying the system clipboard. Falls back to caller on failure.
///
/// Returns true if insertion succeeded, false if AX insertion was not possible.
final class TextInjector {
    private static let throttleInterval: TimeInterval = 0.6
    private static var lastInsertionSignature: String?
    private static var lastInsertionTime: Date?
    private static let syncQueue = DispatchQueue(label: Bundle.main.bundleIdentifier.map { "\($0).textinjection.guard" } ?? "com.cliovoice.clio.textinjection.guard")

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.cliovoice.clio", category: "TextInjector")

    @discardableResult
    static func insertAtCursor(_ text: String) -> Bool {
        logger.notice("🔍 [PASTE DEBUG] TextInjector.insertAtCursor() called with text length: \(text.count)")
        let preview = String(text.prefix(12))
StructuredLog.shared.log(cat: .transcript, evt: "insert_attempt", lvl: .info, ["target": "AX", "chars": text.count, "text": text])
        guard AXIsProcessTrusted() else { 
            logger.notice("🔍 [PASTE DEBUG] TextInjector: AXIsProcessTrusted() returned false")
            return false 
        }
        logger.notice("🔍 [PASTE DEBUG] TextInjector: AXIsProcessTrusted() returned true, proceeding")

        // Throttle identical back-to-back insertions to mitigate double inserts
        let throttled = syncQueue.sync { () -> Bool in
            let now = Date()
            let sig = makeSignature(for: text)
            if let lastSig = lastInsertionSignature, let last = lastInsertionTime,
               lastSig == sig, now.timeIntervalSince(last) < throttleInterval {
                return true
            }
            lastInsertionSignature = sig
            lastInsertionTime = now
            return false
        }
        if throttled { return false }

        // Get system-wide focused UI element
        let systemWide = AXUIElementCreateSystemWide()
        var focusedElementRef: CFTypeRef?
        let focusedStatus = AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElementRef
        )

        guard focusedStatus == .success, let elementRef = focusedElementRef else {
            return false
        }

        let focusedElement: AXUIElement = unsafeBitCast(elementRef, to: AXUIElement.self)

        // Discover the true editable target (avoid writing to page-level AXWebArea)
        guard let targetElement = findEditableTarget(start: focusedElement) else {
            logger.debug("No safe editable target found; skipping AX write")
            return false
        }

        // Refuse to write to AXWebArea explicitly
        var tRoleRef: CFTypeRef?
        _ = AXUIElementCopyAttributeValue(targetElement, kAXRoleAttribute as CFString, &tRoleRef)
        let targetRole = tRoleRef as? String
        logger.notice("🔍 [PASTE DEBUG] Target element role: \(targetRole ?? "nil")")
        if let r = targetRole, r == "AXWebArea" {
            logger.notice("🔍 [PASTE DEBUG] Refusing to write to AXWebArea; falling back")
            return false
        }

        // Determine if this target lives under a WebArea BEFORE reading kAXValue
        let webAncestor = findWebAreaAncestor(from: targetElement)
        logger.notice("🔍 [PASTE DEBUG] WebArea ancestor found: \(webAncestor != nil)")

        // WEB PATH: Under WebArea, do NOT read kAXValue - try replacing selected text directly
        if webAncestor != nil {
            logger.notice("🔍 [PASTE DEBUG] Taking WEB PATH - attempting selected text replacement")
            var settableSel = DarwinBoolean(false)
            let settableStatus = AXUIElementIsAttributeSettable(targetElement, kAXSelectedTextAttribute as CFString, &settableSel)
            logger.notice("🔍 [PASTE DEBUG] Selected text settable status: \(String(describing: settableStatus)), settable: \(settableSel.boolValue)")
            if settableStatus == .success, settableSel.boolValue {
                logger.notice("🔍 [PASTE DEBUG] Setting selected text attribute")
                let ok = AXUIElementSetAttributeValue(targetElement, kAXSelectedTextAttribute as CFString, text as CFTypeRef) == .success
                logger.notice("🔍 [PASTE DEBUG] Selected text set result: \(ok)")
                if ok {
                    let changeDetected = waitForValueChange(on: [targetElement, webAncestor!], timeoutSec: 0.30)
                    logger.notice("🔍 [PASTE DEBUG] Value change detected: \(changeDetected)")
                    if changeDetected {
                        logger.notice("🔍 [PASTE DEBUG] WEB PATH succeeded with verified change, returning true")
                        return true
                    } else {
                        logger.notice("🔍 [PASTE DEBUG] WEB PATH failed - no actual change detected, falling back to clipboard")
                        return false
                    }
                }
            }
            // If selected-text is not settable for this element, bail so caller can type/paste
            logger.notice("🔍 [PASTE DEBUG] Under AXWebArea and selected-text not settable; skipping AX write")
            return false
        }

        // NON-WEB PATH: Prefer replacing selected text if the attribute is settable to
        // avoid changing document-wide styling in rich text editors (e.g., Notes).
        var selSettable = DarwinBoolean(false)
        let selSettableStatus = AXUIElementIsAttributeSettable(targetElement, kAXSelectedTextAttribute as CFString, &selSettable)
        if selSettableStatus == .success, selSettable.boolValue {
            logger.notice("🔍 [PASTE DEBUG] NON-WEB PATH: selectedText settable → replacing selection only")
            let ok = AXUIElementSetAttributeValue(targetElement, kAXSelectedTextAttribute as CFString, text as CFTypeRef) == .success
            if ok {
                // Trust the success result; some editors do not emit value-changed reliably.
                // Returning here avoids a second fallback write that could alter page-wide styles.
                logger.notice("🔍 [PASTE DEBUG] NON-WEB PATH: selectedText replacement succeeded (no fallback)")
                return true
            } else {
                logger.notice("🔍 [PASTE DEBUG] NON-WEB PATH: selectedText set failed — continuing to value replacement")
            }
        }

        // Fallback: Safe to read kAXValue and do range-based replacement
        logger.notice("🔍 [PASTE DEBUG] NON-WEB PATH: falling back to value replacement")
        var valueRef: CFTypeRef?
        let valueStatus = AXUIElementCopyAttributeValue(
            targetElement,
            kAXValueAttribute as CFString,
            &valueRef
        )
        guard valueStatus == .success, let rawExisting = valueRef as? String else {
            return false
        }

        // Read current selection range
        var rangeRef: CFTypeRef?
        let rangeStatus = AXUIElementCopyAttributeValue(
            targetElement,
            kAXSelectedTextRangeAttribute as CFString,
            &rangeRef
        )

        // Default insertion point: end of current raw text; will be corrected by actual selection if available
        var selectedRange = CFRange(location: (rawExisting as NSString).length, length: 0)
        if rangeStatus == .success, let anyRef = rangeRef {
            // Verify the CFTypeID matches AXValue before treating it as one to appease the linter
            #if canImport(ApplicationServices)
            if CFGetTypeID(anyRef) == AXValueGetTypeID() {
                let axRange: AXValue = unsafeBitCast(anyRef, to: AXValue.self)
                var tmp = CFRange()
                if AXValueGetType(axRange) == .cfRange, AXValueGetValue(axRange, .cfRange, &tmp) {
                    selectedRange = tmp
                }
            }
            #else
            // Fallback: attempt cast when ApplicationServices type IDs are unavailable
            if let axRange = anyRef as? AXValue {
                var tmp = CFRange()
                if AXValueGetType(axRange) == .cfRange, AXValueGetValue(axRange, .cfRange, &tmp) {
                    selectedRange = tmp
                }
            }
            #endif
        }

        // Determine placeholder value if available on target
        var phRef: CFTypeRef?
        let phStatus = AXUIElementCopyAttributeValue(
            targetElement,
            kAXPlaceholderValueAttribute as CFString,
            &phRef
        )
        let placeholder = (phStatus == .success) ? (phRef as? String) : nil
        let existingText = (placeholder != nil && rawExisting == placeholder) ? "" : rawExisting

        // Build the new value by replacing selection with text (replace-range semantics)
        let nsExisting = existingText as NSString
        let safeLocation = max(0, min(nsExisting.length, selectedRange.location))
        let safeLength = max(0, min(nsExisting.length - safeLocation, selectedRange.length))
        let mutable = NSMutableString(string: existingText)
        mutable.replaceCharacters(in: NSRange(location: safeLocation, length: safeLength), with: text)

        // Attempt to set new value on non-web editable
        let setStatus = AXUIElementSetAttributeValue(
            targetElement,
            kAXValueAttribute as CFString,
            mutable as CFTypeRef
        )
        guard setStatus == .success else {
            logger.debug("AX set value failed: \(String(describing: setStatus.rawValue))")
            return false
        }

        // Verify using AXObserver for value-changed (avoid fixed sleeps)
        _ = waitForValueChange(on: [targetElement], timeoutSec: 0.30)

        // Determine role
        var roleRef: CFTypeRef?
        let roleStatus = AXUIElementCopyAttributeValue(
            targetElement,
            kAXRoleAttribute as CFString,
            &roleRef
        )
        let role = (roleStatus == .success ? (roleRef as? String) : nil) ?? ""

        // Read back value and selection
        var verifyRef: CFTypeRef?
        let verifyStatus = AXUIElementCopyAttributeValue(
            targetElement,
            kAXValueAttribute as CFString,
            &verifyRef
        )
        let newValue = (verifyStatus == .success) ? (verifyRef as? String) : nil

        var newRangeRef: CFTypeRef?
        let newRangeStatus = AXUIElementCopyAttributeValue(
            targetElement,
            kAXSelectedTextRangeAttribute as CFString,
            &newRangeRef
        )

        let insertedCount = (text as NSString).length
        let expectedCaret = safeLocation + insertedCount
        var caretAdvanced = false
        if newRangeStatus == .success, let anyRef = newRangeRef {
            if CFGetTypeID(anyRef) == AXValueGetTypeID() {
                let axVal: AXValue = unsafeBitCast(anyRef, to: AXValue.self)
                var range = CFRange()
                if AXValueGetType(axVal) == .cfRange, AXValueGetValue(axVal, .cfRange, &range) {
                    caretAdvanced = range.location >= max(0, expectedCaret - 1)
                }
            }
        }

        let preLen = nsExisting.length
        let newLen = (newValue as NSString?)?.length ?? preLen
        let expectedLen = preLen - safeLength + insertedCount
        let lenDeltaOkay = newLen >= expectedLen - 1 // allow slack for placeholders
        let presenceOkay = (newValue?.contains(text) ?? false)

        logger.debug("AX verify role=\(role) preLen=\(preLen) newLen=\(newLen) expectedLen=\(expectedLen) presence=\(presenceOkay) caretOK=\(caretAdvanced) lenOK=\(lenDeltaOkay)")

        // Some SDKs don’t expose kAXWebAreaRole; compare string literal
        let heuristicSuccess = presenceOkay || caretAdvanced || lenDeltaOkay
        let success = heuristicSuccess

        // Update caret to end of inserted text (best effort)
        var newCaret = CFRange(location: safeLocation + (text as NSString).length, length: 0)
        if let caretValue = AXValueCreate(.cfRange, &newCaret) {
            _ = AXUIElementSetAttributeValue(
                targetElement,
                kAXSelectedTextRangeAttribute as CFString,
                caretValue
            )
        }

        if success {
StructuredLog.shared.log(cat: .transcript, evt: "insert_result", lvl: .info, ["ok": true])
        } else {
StructuredLog.shared.log(cat: .transcript, evt: "insert_result", lvl: .warn, ["ok": false])
        }
        return success
    }

    // MARK: - Target discovery (capability-driven)
    private static func findEditableTarget(start: AXUIElement, maxDepth: Int = 6) -> AXUIElement? {
        struct QueueItem { let el: AXUIElement; let depth: Int }
        var queue: [QueueItem] = [QueueItem(el: start, depth: 0)]

        func hasAttribute(_ el: AXUIElement, _ attr: CFString) -> Bool {
            var v: CFTypeRef?
            return AXUIElementCopyAttributeValue(el, attr, &v) == .success
        }
        func isSettable(_ el: AXUIElement, _ attr: CFString) -> Bool {
            var b = DarwinBoolean(false)
            if AXUIElementIsAttributeSettable(el, attr, &b) == .success { return b.boolValue }
            return false
        }
        func roleOf(_ el: AXUIElement) -> String {
            var v: CFTypeRef?
            _ = AXUIElementCopyAttributeValue(el, kAXRoleAttribute as CFString, &v)
            return v as? String ?? ""
        }
        func supportsInsertText(_ el: AXUIElement) -> Bool {
            var actionsCF: CFArray?
            guard AXUIElementCopyActionNames(el, &actionsCF) == .success,
                  let actions = actionsCF as? [String] else { return false }
            // Prefer constant-free check; action name is "AXInsertText"
            return actions.contains("AXInsertText")
        }

        while !queue.isEmpty {
            let item = queue.removeFirst()
            if item.depth > maxDepth { continue }

            // Follow focused child first (common in contenteditable trees)
            var focusedRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(item.el, kAXFocusedUIElementAttribute as CFString, &focusedRef) == .success,
               let anyRef = focusedRef {
                let foc: AXUIElement = unsafeBitCast(anyRef, to: AXUIElement.self)
                if (foc as AnyObject) !== (item.el as AnyObject) {
                    queue.insert(QueueItem(el: foc, depth: item.depth + 1), at: 0)
                }
            }

            let hasSel = hasAttribute(item.el, kAXSelectedTextRangeAttribute as CFString)
            let canSet = isSettable(item.el, kAXValueAttribute as CFString)
            let canInsert = supportsInsertText(item.el)
            if hasSel && (canSet || canInsert) {
                // Prefer non-web-area targets
                if roleOf(item.el) != "AXWebArea" { return item.el }
            }

            // Enqueue children
            var kidsRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(item.el, kAXChildrenAttribute as CFString, &kidsRef) == .success,
               let kids = kidsRef as? [AXUIElement] {
                for k in kids { queue.append(QueueItem(el: k, depth: item.depth + 1)) }
            }
        }

        // No safe target found
        return nil
    }

    // Wait for a value change notification (AXObserver) on the target; returns true if received before timeout
    private static func waitForValueChange(on elements: [AXUIElement], timeoutSec: Double) -> Bool {
        var pid: pid_t = 0
        guard let first = elements.first, AXUIElementGetPid(first, &pid) == .success else { return false }
        var observer: AXObserver?
        let sem = DispatchSemaphore(value: 0)
        let box = AXSemaphoreBox(sem)
        let unmanaged = Unmanaged.passUnretained(box)
        
        guard AXObserverCreate(pid, TextInjectorAXObserverCallback, &observer) == .success,
              let obs = observer else { return false }
        
        for el in elements {
            AXObserverAddNotification(obs, el, kAXValueChangedNotification as CFString, unmanaged.toOpaque())
        }
        
        // Use current runloop - simpler and doesn't block main thread
        CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(obs), .defaultMode)
        
        let ok = sem.wait(timeout: .now() + timeoutSec) == .success
        
        // Direct cleanup - no dispatch overhead
        for el in elements {
            AXObserverRemoveNotification(obs, el, kAXValueChangedNotification as CFString)
        }
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(obs), .defaultMode)
        
        return ok
    }

    // Find nearest AXWebArea ancestor from a given element (if any)
    private static func findWebAreaAncestor(from element: AXUIElement) -> AXUIElement? {
        var current: AXUIElement? = element
        while let el = current {
            var roleRef: CFTypeRef?
            _ = AXUIElementCopyAttributeValue(el, kAXRoleAttribute as CFString, &roleRef)
            if let r = roleRef as? String, r == "AXWebArea" { return el }
            var parentRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(el, kAXParentAttribute as CFString, &parentRef) == .success,
               let anyRef = parentRef {
                current = unsafeBitCast(anyRef, to: AXUIElement.self)
            } else {
                current = nil
            }
        }
        return nil
    }

    private static func makeSignature(for text: String) -> String {
        let prefix = text.prefix(16)
        let suffix = text.suffix(16)
        return "\(text.count)|\(prefix)|\(suffix)"
    }
}


