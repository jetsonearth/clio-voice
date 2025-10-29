import Foundation
import os

class PromptDetectionService {
    private let logger = Logger(
        subsystem: "com.jetsonai.clio",
        category: "promptdetection"
    )
    
    struct PromptDetectionResult {
        let shouldEnableAI: Bool
        let selectedPromptId: UUID?
        let processedText: String
        let detectedTriggerWord: String?
        let originalEnhancementState: Bool
        let originalPromptId: UUID?
    }
    
    func analyzeText(_ text: String, with enhancementService: AIEnhancementService) async -> PromptDetectionResult {
        // Read prompt state on main once
        let prompts = await MainActor.run { enhancementService.allPrompts }
        let originalEnhancementState = await MainActor.run { enhancementService.isEnhancementEnabled }
        let originalPromptId = await MainActor.run { enhancementService.selectedPromptId }

        // Fast exit: no triggers configured
        if prompts.allSatisfy({ $0.triggerWords.isEmpty }) {
            return PromptDetectionResult(
                shouldEnableAI: false,
                selectedPromptId: nil,
                processedText: text,
                detectedTriggerWord: nil,
                originalEnhancementState: originalEnhancementState,
                originalPromptId: originalPromptId
            )
        }

        // Scan off-main
        for prompt in prompts {
            if !prompt.triggerWords.isEmpty {
                if let (detectedWord, processedText) = findMatchingTriggerWord(from: text, triggerWords: prompt.triggerWords) {
                    return PromptDetectionResult(
                        shouldEnableAI: true,
                        selectedPromptId: prompt.id,
                        processedText: processedText,
                        detectedTriggerWord: detectedWord,
                        originalEnhancementState: originalEnhancementState,
                        originalPromptId: originalPromptId
                    )
                }
            }
        }
        return PromptDetectionResult(
            shouldEnableAI: false,
            selectedPromptId: nil,
            processedText: text,
            detectedTriggerWord: nil,
            originalEnhancementState: originalEnhancementState,
            originalPromptId: originalPromptId
        )
    }
    
    func applyDetectionResult(_ result: PromptDetectionResult, to enhancementService: AIEnhancementService) async {
        await MainActor.run {
            if result.shouldEnableAI {
                if !enhancementService.isEnhancementEnabled {
                    enhancementService.isEnhancementEnabled = true
                }
                if let promptId = result.selectedPromptId {
                    enhancementService.selectedPromptId = promptId
                }
            }
        }
        
        // Removed artificial sleep to avoid adding latency on stop-path
    }
    
    func restoreOriginalSettings(_ result: PromptDetectionResult, to enhancementService: AIEnhancementService) async {
        if result.shouldEnableAI {
            await MainActor.run {
                if enhancementService.isEnhancementEnabled != result.originalEnhancementState {
                    enhancementService.isEnhancementEnabled = result.originalEnhancementState
                }
                if let originalId = result.originalPromptId, enhancementService.selectedPromptId != originalId {
                    enhancementService.selectedPromptId = originalId
                }
            }
        }
    }
    
    private func removeTriggerWord(from text: String, triggerWord: String) -> String? {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowerText = trimmedText.lowercased()
        let lowerTrigger = triggerWord.lowercased()
        
        guard lowerText.hasPrefix(lowerTrigger) else { return nil }
        
        let triggerEndIndex = trimmedText.index(trimmedText.startIndex, offsetBy: triggerWord.count)
        
        if triggerEndIndex >= trimmedText.endIndex {
            return ""
        }
        
        var remainingText = String(trimmedText[triggerEndIndex...])
        
        remainingText = remainingText.replacingOccurrences(
            of: "^[,\\.!\\?;:\\s]+",
            with: "",
            options: .regularExpression
        )
        
        remainingText = remainingText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !remainingText.isEmpty {
            remainingText = remainingText.prefix(1).uppercased() + remainingText.dropFirst()
        }
        
        return remainingText
    }
    
    private func findMatchingTriggerWord(from text: String, triggerWords: [String]) -> (String, String)? {
        let trimmedWords = triggerWords.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // Sort by length (longest first) to match the most specific trigger word
        let sortedTriggerWords = trimmedWords.sorted { $0.count > $1.count }
        
        for triggerWord in sortedTriggerWords {
            if let processedText = removeTriggerWord(from: text, triggerWord: triggerWord) {
                return (triggerWord, processedText)
            }
        }
        return nil
    }
}