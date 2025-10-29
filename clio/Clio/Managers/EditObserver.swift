import Foundation
import AppKit
import os

/// Paste-only edit observer: after a paste, watch the focused element for changes near the inserted span.
@MainActor
final class EditObserver {
    static let shared = EditObserver()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.clio.app", category: "EditObserver")
    private let debounceInterval: TimeInterval = 1.0 // seconds of inactivity before evaluating
    private let basePollInterval: TimeInterval = 0.3
    private let heavyFieldThresholdChars: Int = 2000
    private let maxCharsForGlobalDiff: Int = 4000
    private let windowRadiusChars: Int = 800
    private var activeWatcher: PasteWatchSession?

    private init() {}

    struct PasteWatchSession {
        let element: AXUIElement
        let pastedText: String
        let startedAt: Date
        let originalSnapshot: String
        var latestValue: String
        var rangeInValue: Range<String.Index>?
        var timer: Timer?
        var endAt: Date
        var lastChangeAt: Date?
        var lastEvaluatedValue: String?
        var recordedPairs: Set<String> = []
    }

    func startWatchingAfterPaste(pastedText: String, windowSeconds: TimeInterval = 60.0) {
        guard AXIsProcessTrusted() else { return }
        // Get focused element
        let systemWide = AXUIElementCreateSystemWide()
        var focusedRef: CFTypeRef?
        let status = AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedRef)
        guard status == .success, let elementRef = focusedRef else { return }
        let element: AXUIElement = unsafeBitCast(elementRef, to: AXUIElement.self)

        // Read initial value
        var valueObj: CFTypeRef?
        _ = AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &valueObj)
        let initial = (valueObj as? String) ?? ""
        if UserDefaults.standard.bool(forKey: "SmartDictionaryDebugLogging") {
            logger.notice("🧪 [SMARTDICT] Watcher start: pastedLen=\(pastedText.count), initialFieldLen=\(initial.count), window=\(Int(windowSeconds))s")
        }

        // Find pasted range (best-effort)
        let range = initial.range(of: pastedText)
        if range == nil, UserDefaults.standard.bool(forKey: "SmartDictionaryDebugLogging") {
            logger.notice("🧪 [SMARTDICT] Seed text not found verbatim in field (may still detect changes via global diff)")
        }

        var session = PasteWatchSession(
            element: element,
            pastedText: pastedText,
            startedAt: Date(),
            originalSnapshot: initial,
            latestValue: initial,
            rangeInValue: range,
            timer: nil,
            endAt: Date().addingTimeInterval(windowSeconds),
            lastChangeAt: nil
        )

        // Polling fallback (adaptive interval)
        let pollInterval = initial.count > self.heavyFieldThresholdChars ? max(0.5, self.basePollInterval * 1.7) : self.basePollInterval
        let t = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let now = Date()
            if now >= session.endAt {
                if UserDefaults.standard.bool(forKey: "SmartDictionaryDebugLogging") {
                    self.logger.notice("🧪 [SMARTDICT] Watcher end: no qualifying edits detected within window")
                }
                timer.invalidate(); self.activeWatcher = nil; return
            }

            let readStart = CFAbsoluteTimeGetCurrent()
            var newValueObj: CFTypeRef?
            _ = AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &newValueObj)
            let current = (newValueObj as? String) ?? ""
            let readMs = (CFAbsoluteTimeGetCurrent() - readStart) * 1000
            if current != session.latestValue {
                if UserDefaults.standard.bool(forKey: "SmartDictionaryDebugLogging") {
                    self.logger.notice("🧪 [SMARTDICT] Detected change: oldLen=\(session.latestValue.count), newLen=\(current.count) (read=\(String(format: "%.1f", readMs))ms)")
                }
                session.latestValue = current
                session.lastChangeAt = now
            }

            // Debounce: wait for inactivity before evaluating
            if let last = session.lastChangeAt, now.timeIntervalSince(last) >= debounceInterval {
                // Evaluate incremental changes since last evaluation, or from original if none
                let beforeEval = session.lastEvaluatedValue ?? session.originalSnapshot
                let afterEval = session.latestValue

                // If texts are huge, compare within a focused window around first difference to avoid O(n*m) blowups
                let (bWin, aWin) = EditObserver.makeFocusedWindows(before: beforeEval, after: afterEval, maxChars: self.maxCharsForGlobalDiff, radius: self.windowRadiusChars)
                let diffStart = CFAbsoluteTimeGetCurrent()
                let pairs = EditObserver.extractTokenSubstitutions(before: bWin, after: aWin)
                if pairs.isEmpty {
                    // If no token-level substitution, try minimal window as fallback
                    let (w, r) = EditObserver.minimalSubstitution(before: bWin, after: aWin)
                    if var wrong = w, var right = r {
                        // If looks like deletion-in-progress (right empty or much shorter), keep waiting instead of recording
                        let deletionOnly = right.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        let bCount = beforeEval.splitOnWords().count
                        let aCount = afterEval.splitOnWords().count
                        if deletionOnly || aCount < bCount {
                            if UserDefaults.standard.bool(forKey: "SmartDictionaryDebugLogging") {
                                self.logger.notice("🧪 [SMARTDICT] Deletion in progress — deferring evaluation")
                            }
                            // Do not advance lastEvaluatedValue so we compare against the same baseline on next evaluation
                            session.lastChangeAt = now
                            return
                        }
                        wrong = wrong.trimmingCharacters(in: .whitespacesAndNewlines)
                        right = right.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !wrong.isEmpty, !right.isEmpty, wrong.caseInsensitiveCompare(right) != .orderedSame {
                            // Expand to word boundaries for nicer pairs (e.g., Francisco → Fernando)
                            let (wExp, rExp) = EditObserver.expandToWordBoundaries(wrong: wrong, right: right, before: beforeEval, after: afterEval)
                            wrong = wExp; right = rExp
                            let key = "\(wrong.lowercased())→\(right.lowercased())"
                            if !session.recordedPairs.contains(key) {
                                if UserDefaults.standard.bool(forKey: "SmartDictionaryDebugLogging") {
                                    let diffMs = (CFAbsoluteTimeGetCurrent() - diffStart) * 1000
                                    self.logger.notice("🧪 [SMARTDICT] Substitution detected: '\(wrong)' → '\(right)' (diff=\(String(format: "%.1f", diffMs))ms)")
                                }
                                if UserDefaults.standard.bool(forKey: "SmartDictionaryEnableLearning") {
                                    SmartDictionaryService.shared.recordCorrection(
                                        wrong: wrong,
                                        right: right,
                                        languageCode: UserDefaults.standard.string(forKey: "SelectedLanguage"),
                                        domainScope: nil,
                                        localContext: [],
                                        asrConfidence: nil,
                                        editLatencyMs: Int(now.timeIntervalSince(session.startedAt) * 1000)
                                    )
                                }
                                session.recordedPairs.insert(key)
                            }
                        }
                    }
                } else {
                    for (wrongRaw, rightRaw) in pairs.prefix(8) { // cap per evaluation
                        var wrong = wrongRaw.trimmingCharacters(in: .whitespacesAndNewlines)
                        var right = rightRaw.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !wrong.isEmpty, !right.isEmpty, wrong.caseInsensitiveCompare(right) != .orderedSame else { continue }
                        let (wExp, rExp) = EditObserver.expandToWordBoundaries(wrong: wrong, right: right, before: beforeEval, after: afterEval)
                        wrong = wExp; right = rExp
                        let key = "\(wrong.lowercased())→\(right.lowercased())"
                        if session.recordedPairs.contains(key) { continue }
                        if UserDefaults.standard.bool(forKey: "SmartDictionaryDebugLogging") {
                            let diffMs = (CFAbsoluteTimeGetCurrent() - diffStart) * 1000
                            self.logger.notice("🧪 [SMARTDICT] Token substitution: '\(wrong)' → '\(right)' (diff=\(String(format: "%.1f", diffMs))ms)")
                        }
                        if UserDefaults.standard.bool(forKey: "SmartDictionaryEnableLearning") {
                            SmartDictionaryService.shared.recordCorrection(
                                wrong: wrong,
                                right: right,
                                languageCode: UserDefaults.standard.string(forKey: "SelectedLanguage"),
                                domainScope: nil,
                                localContext: [],
                                asrConfidence: nil,
                                editLatencyMs: Int(now.timeIntervalSince(session.startedAt) * 1000)
                            )
                        }
                        session.recordedPairs.insert(key)
                    }
                }

                // Update last evaluated baseline and continue watching until the window ends
                session.lastEvaluatedValue = session.latestValue
                session.lastChangeAt = nil
            }
        }

        session.timer = t
        activeWatcher = session
    }

    private static func extractSubstitution(before: String, after: String, seed: String) -> (String?, String?) {
        // Heuristic: look for the seed in `before`, and if changed in `after`, return replacement
        if let rBefore = before.range(of: seed) {
            let old = String(before[rBefore])
            if let rAfter = after.range(of: seed) {
                // Seed still present unchanged; no correction
                if String(after[rAfter]) == old { return (nil, nil) }
            }
            // Find the best matching window in `after` around rBefore.lowerBound via neighborhood search
            // Fallback: compute minimal differing window
            let right = bestLocalReplacement(before: before, after: after, around: rBefore, seed: seed)
            return (old, right)
        }
        // Fallback: compute minimal edit window globally
        let (w, r) = minimalSubstitution(before: before, after: after)
        return (w, r)
    }

    private static func bestLocalReplacement(before: String, after: String, around rBefore: Range<String.Index>, seed: String) -> String {
        // Try to locate a nearby substring in `after` that best aligns with seed using simple heuristics
        // For MVP, return the substring in `after` that overlaps the same indices if lengths match; otherwise expand 16 chars window
        let startOffset = before.distance(from: before.startIndex, to: rBefore.lowerBound)
        let endOffset = before.distance(from: before.startIndex, to: rBefore.upperBound)
        guard startOffset <= endOffset else { return seed }
        let safeStart = max(0, min(startOffset, after.count))
        let safeEnd = max(safeStart, min(endOffset, after.count))
        let aStart = after.index(after.startIndex, offsetBy: safeStart)
        let aEnd = after.index(after.startIndex, offsetBy: safeEnd)
        let candidate = aStart <= aEnd ? String(after[aStart..<aEnd]) : ""
        if !candidate.isEmpty { return candidate }
        // Expand window
        let w = 16
        let s = max(0, startOffset - w)
        let e = min(after.count, endOffset + w)
        if s >= e { return seed }
        let sI = after.index(after.startIndex, offsetBy: s)
        let eI = after.index(after.startIndex, offsetBy: e)
        return String(after[sI..<eI])
    }

    private static func minimalSubstitution(before: String, after: String) -> (String?, String?) {
        // Find first and last differing indices to bound substitution
        let commonPrefix = before.commonPrefix(with: after)
        let bTail = String(before.dropFirst(commonPrefix.count))
        let aTail = String(after.dropFirst(commonPrefix.count))
        let commonSuffix = bTail.commonSuffix(with: aTail)
        let bCore = String(bTail.dropLast(commonSuffix.count))
        let aCore = String(aTail.dropLast(commonSuffix.count))
        guard !bCore.isEmpty || !aCore.isEmpty else { return (nil, nil) }
        return (bCore, aCore)
    }

    /// Token-level extraction using LCS diff to handle insertions/deletions without cascading false subs
    private static func extractTokenSubstitutions(before: String, after: String) -> [(String, String)] {
        let bTokens = tokenizeWords(before)
        let aTokens = tokenizeWords(after)
        if bTokens.isEmpty && aTokens.isEmpty { return [] }

        // LCS DP
        let n = bTokens.count
        let m = aTokens.count
        var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        if n > 0 && m > 0 {
            for i in 1...n {
                for j in 1...m {
                    if bTokens[i - 1] == aTokens[j - 1] {
                        dp[i][j] = dp[i - 1][j - 1] + 1
                    } else {
                        dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                    }
                }
            }
        }

        // Backtrack to build edit ops
        enum Op { case equal(String), del(String), ins(String) }
        var ops: [Op] = []
        var i = n
        var j = m
        while i > 0 || j > 0 {
            if i > 0, j > 0, bTokens[i - 1] == aTokens[j - 1] {
                ops.append(.equal(bTokens[i - 1]))
                i -= 1; j -= 1
            } else if j > 0, (i == 0 || dp[i][j - 1] >= dp[i - 1][j]) {
                ops.append(.ins(aTokens[j - 1]))
                j -= 1
            } else if i > 0 {
                ops.append(.del(bTokens[i - 1]))
                i -= 1
            }
        }
        ops.reverse()

        // Collapse runs of del+ins into substitution pairs; ignore pure insertions/deletions
        var pairs: [(String, String)] = []
        var delBuf: [String] = []
        var insBuf: [String] = []
        var haveAnchor = false // equal token seen around change

        func flushIfSub() {
            guard !delBuf.isEmpty && !insBuf.isEmpty else { delBuf.removeAll(); insBuf.removeAll(); return }
            let wrong = delBuf.joined(separator: " ")
            let right = insBuf.joined(separator: " ")
            // Heuristics: small phrases only, and require an anchor equal nearby
            if (wrong.count <= 40 && right.count <= 40 && (delBuf.count <= 4 && insBuf.count <= 4) && haveAnchor) {
                pairs.append((wrong, right))
            }
            delBuf.removeAll(); insBuf.removeAll(); haveAnchor = false
        }

        for op in ops {
            switch op {
            case .equal(_):
                flushIfSub()
                haveAnchor = true
            case .del(let t):
                delBuf.append(t)
            case .ins(let t):
                insBuf.append(t)
            }
        }
        flushIfSub()
        return pairs
    }

    private static func tokenizeWords(_ text: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        for ch in text {
            if ch.isLetter || ch.isNumber { current.append(ch) }
            else { if !current.isEmpty { tokens.append(current); current = "" } }
        }
        if !current.isEmpty { tokens.append(current) }
        return tokens
    }

    /// Expand small core diffs out to whole-word boundaries for readability and stability
    private static func expandToWordBoundaries(wrong: String, right: String, before: String, after: String) -> (String, String) {
        func expand(_ text: String, in full: String) -> String {
            guard let r = full.range(of: text) else { return text }
            var start = r.lowerBound
            var end = r.upperBound
            while start > full.startIndex {
                let prev = full[full.index(before: start)]
                if prev.isLetter { start = full.index(before: start) } else { break }
            }
            while end < full.endIndex {
                let next = full[end]
                if next.isLetter { end = full.index(after: end) } else { break }
            }
            return String(full[start..<end])
        }
        let wExp = expand(wrong, in: before)
        let rExp = expand(right, in: after)
        return (wExp, rExp)
    }

    private static func makeFocusedWindows(before: String, after: String, maxChars: Int, radius: Int) -> (String, String) {
        if before.count <= maxChars && after.count <= maxChars {
            return (before, after)
        }
        // Find first differing index via common prefix length
        let commonPrefix = before.commonPrefix(with: after)
        let p = commonPrefix.count
        let bStart = max(0, p - radius)
        let aStart = max(0, p - radius)
        let bEnd = min(before.count, p + radius)
        let aEnd = min(after.count, p + radius)
        let bS = before.index(before.startIndex, offsetBy: bStart)
        let bE = before.index(before.startIndex, offsetBy: bEnd)
        let aS = after.index(after.startIndex, offsetBy: aStart)
        let aE = after.index(after.startIndex, offsetBy: aEnd)
        return (String(before[bS..<bE]), String(after[aS..<aE]))
    }
}

private extension String {
    func commonSuffix(with other: String) -> String {
        var i = self.endIndex
        var j = other.endIndex
        var suffix = ""
        while i > startIndex && j > other.startIndex {
            let ci = self[self.index(before: i)]
            let cj = other[other.index(before: j)]
            if ci != cj { break }
            suffix.insert(ci, at: suffix.startIndex)
            i = self.index(before: i)
            j = other.index(before: j)
        }
        return suffix
    }

    func splitOnWords() -> [String] {
        let separators = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        return self.components(separatedBy: separators).filter { !$0.isEmpty }
    }
}
