import Foundation

/// Manages transcription text buffering with intelligent segment completion and text joining
struct TranscriptionBuffer {
    private var currentSegment: String = ""
    private var completedSegments: [String] = []
    
    mutating func addFinalToken(_ text: String) {
        // Filter out <end> tokens at the source to prevent them from entering the buffer
        // IMPORTANT: Do NOT trim spaces here — Soniox tokens include leading spaces for word boundaries
        // Trimming would glue words together (e.g., "Hello" + " world" -> "Helloworld")
        let cleanedText = text.replacingOccurrences(of: "<end>", with: "")
        if !cleanedText.isEmpty {
            currentSegment += cleanedText
        }
    }
    
    mutating func checkAndCompleteSegment() {
        // Clean any remaining <end> tokens that might have slipped through
        currentSegment = currentSegment.replacingOccurrences(of: "<end>", with: "")
        
        // Check if current segment ends with sentence terminator
        let sentenceTerminators = CharacterSet(charactersIn: ".!?。！？")
        let trimmed = currentSegment.trimmingCharacters(in: .whitespaces)
        
        if !trimmed.isEmpty {
            if let lastChar = trimmed.last,
               let scalar = lastChar.unicodeScalars.first,
               sentenceTerminators.contains(scalar) {
                // Complete the segment
                completedSegments.append(currentSegment)
                currentSegment = ""
            }
        }
    }
    
    mutating func forceCompleteCurrentSegment() {
        // Clean any remaining <end> tokens before completing
        currentSegment = currentSegment.replacingOccurrences(of: "<end>", with: "")
        
        // Force complete any pending text (e.g., on stream end)
        // IMPORTANT: Preserve leading spaces (they encode word boundaries from the ASR),
        // but trim trailing spaces to avoid duplicating whitespace when joining.
        var trailingTrimmed = currentSegment
        while let last = trailingTrimmed.last, last.isWhitespace { trailingTrimmed.removeLast() }
        
        // Only append if there is any non-whitespace content
        if !currentSegment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            completedSegments.append(trailingTrimmed)
            currentSegment = ""
        }
    }
    
    mutating func reset() {
        currentSegment = ""
        completedSegments.removeAll()
    }
    
    var finalText: String {
        // Join completed segments and any current segment while avoiding accidental
        // spaces inside words when a segment boundary falls mid-word (e.g., "trans" + "cript").
        var pieces = completedSegments
        if !currentSegment.isEmpty { pieces.append(currentSegment) }

        // Helper: detect first non-whitespace character
        func firstNonWhitespace(in s: String) -> Character? {
            for ch in s { if !ch.isWhitespace { return ch } }
            return nil
        }
        // Helper: detect last non-whitespace character
        func lastNonWhitespace(in s: String) -> Character? {
            for ch in s.reversed() { if !ch.isWhitespace { return ch } }
            return nil
        }
        // Helper: trim only trailing spaces
        func trimTrailingSpaces(_ s: String) -> String {
            var s = s
            while let last = s.last, last.isWhitespace { s.removeLast() }
            return s
        }
        // Helper: drop leading spaces
        func dropLeadingSpaces(_ s: String) -> String {
            String(s.drop { $0.isWhitespace })
        }
        // Helper: CJK detector (Chinese ideographs)
        func isCJK(_ c: Character) -> Bool {
            for scalar in c.unicodeScalars {
                switch scalar.value {
                case 0x4E00...0x9FFF, // CJK Unified Ideographs
                     0x3400...0x4DBF, // Extension A
                     0x20000...0x2A6DF, // Extension B
                     0x2A700...0x2B73F, // Extension C
                     0x2B740...0x2B81F, // Extension D
                     0x2B820...0x2CEAF, // Extension E/F (combined range)
                     0xF900...0xFAFF, // Compatibility Ideographs
                     0x2F800...0x2FA1F: // Compatibility Ideographs Supplement
                    return true
                default:
                    continue
                }
            }
            return false
        }
        // Helper: is closing punctuation where English typically wants a following space
        let closingPunctuation = CharacterSet(charactersIn: ".!?,:;)]}”’\"")

        var result = ""
        for seg in pieces {
            let cleanSeg = seg.replacingOccurrences(of: "<end>", with: "")
            if result.isEmpty {
                result = cleanSeg
                continue
            }

            // Determine boundary characters ignoring surrounding spaces
            let leftChar = lastNonWhitespace(in: result)
            let rightChar = firstNonWhitespace(in: cleanSeg)
            let hasLeadingSpaceOnRight = cleanSeg.first?.isWhitespace == true

            // Decide whether a space is desired at the boundary
            var shouldInsertSpace = false
            if let l = leftChar, let r = rightChar {
                let lIsCJK = isCJK(l)
                let rIsCJK = isCJK(r)
                let leftIsClosingPunct = l.unicodeScalars.first.map { closingPunctuation.contains($0) } ?? false

                if lIsCJK && rIsCJK {
                    // Chinese/CJK-to-CJK: no space
                    shouldInsertSpace = false
                } else if leftIsClosingPunct {
                    // After closing punctuation: space before Latin/digits, none before CJK
                    shouldInsertSpace = !rIsCJK
                } else {
                    // Default: honor ASR-leading-space as word boundary indicator
                    shouldInsertSpace = hasLeadingSpaceOnRight && !(lIsCJK && rIsCJK)
                }
            }

            // Normalize boundary spacing to avoid doubles: ensure either 0 or 1 space
            var left = trimTrailingSpaces(result)
            var right = dropLeadingSpaces(cleanSeg)
            if shouldInsertSpace { left.append(" ") }
            result = left + right
        }

        return result.trimmingCharacters(in: .whitespaces)
    }

    /*
    /// Cleaned version removing filler words/false starts.
    /// Currently unused – retained for potential future toggling.
    var cleanedText: String {
        TextCleaner.clean(finalText)
    }
    */
    
    var hasUncompletedSegment: Bool {
        return !currentSegment.trimmingCharacters(in: .whitespaces).isEmpty
    }
}