import Foundation

struct TextUtils {
    /// Accurately count words in text that may contain Chinese characters
    /// Chinese characters are counted individually as words
    /// English words are counted by space separation
    static func countWords(in text: String) -> Int {
        var wordCount = 0
        var currentEnglishWord = ""
        
        
        for char in text {
            if isChinese(char) {
                // Finish any pending English word
                if !currentEnglishWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    wordCount += 1
                    currentEnglishWord = ""
                }
                // Each Chinese character counts as one word
                wordCount += 1
            } else if char.isLetter || char.isNumber {
                // Building an English word
                currentEnglishWord.append(char)
            } else if char.isWhitespace || char.isPunctuation {
                // End of English word
                if !currentEnglishWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    wordCount += 1
                    currentEnglishWord = ""
                }
            } else {
                // Other characters (symbols, etc.) - treat as word boundaries
                if !currentEnglishWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    wordCount += 1
                    currentEnglishWord = ""
                }
            }
        }
        
        // Don't forget the last word if text doesn't end with whitespace
        if !currentEnglishWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            wordCount += 1
        }
        
        
        return wordCount
    }
    
    /// Check if a character is Chinese (CJK)
    private static func isChinese(_ char: Character) -> Bool {
        guard let scalar = char.unicodeScalars.first else { return false }
        let value = scalar.value
        
        // Chinese character ranges (same as whisper.cpp is_chinese_char function)
        return (value >= 0x04E00 && value <= 0x09FFF) ||  // CJK Unified Ideographs
               (value >= 0x03400 && value <= 0x04DBF) ||  // CJK Extension A
               (value >= 0x20000 && value <= 0x2A6DF) ||  // CJK Extension B
               (value >= 0x2A700 && value <= 0x2B73F) ||  // CJK Extension C
               (value >= 0x2B740 && value <= 0x2B81F) ||  // CJK Extension D
               (value >= 0x2B920 && value <= 0x2CEAF) ||  // CJK Extension E & F
               (value >= 0x0F900 && value <= 0x0FAFF) ||  // CJK Compatibility Ideographs
               (value >= 0x2F800 && value <= 0x2FA1F)     // CJK Compatibility Supplement
    }
    
    /// Get the percentage of Chinese characters in text
    static func chineseCharacterPercentage(in text: String) -> Double {
        guard !text.isEmpty else { return 0.0 }
        
        let chineseCount = text.filter { isChinese($0) }.count
        return Double(chineseCount) / Double(text.count)
    }
    
    /// Check if text is primarily Chinese (>50% Chinese characters)
    static func isPrimarilyChinese(_ text: String) -> Bool {
        return chineseCharacterPercentage(in: text) > 0.5
    }
} 