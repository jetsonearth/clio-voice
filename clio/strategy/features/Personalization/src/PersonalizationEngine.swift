// PersonalizationEngine.swift
// Core personalization system for improving dictation accuracy per user
// Learns user-specific terms, tone, and style preferences

import Foundation

class PersonalizationEngine: ObservableObject {
    @Published var userProfile: UserPersonalizationProfile?
    
    struct UserPersonalizationProfile {
        var userId: String
        var customTerms: [String: String]    // spoken -> written mappings
        var toneSettings: ToneSettings
        var writingStyle: WritingStyle
        var correctionHistory: [CorrectionEvent]
        
        struct ToneSettings {
            var formalityLevel: Double      // 0.0 = casual, 1.0 = formal
            var personalityTraits: [String] // friendly, professional, direct, etc.
        }
        
        struct WritingStyle {
            var preferredPunctuation: Bool
            var abbreviationStyle: AbbreviationStyle
            var sentenceStructure: SentenceStructure
        }
    }
    
    func learnFromCorrection(_ correction: CorrectionEvent) {
        // Auto-add corrected terms to user dictionary
        // Update personalization model based on user feedback
    }
    
    func generatePersonalizedPrompt(for context: String) -> String {
        // Build LLM prompt with user-specific tone and style preferences
        return ""
    }
    
    func adaptToUserStyle(_ originalText: String, userCorrections: [String]) -> String {
        // Apply learned user preferences to transcription
        return ""
    }
}

struct CorrectionEvent {
    let originalTranscript: String
    let userCorrectedText: String
    let timestamp: Date
    let context: String
}

enum AbbreviationStyle {
    case full, abbreviated, mixed
}

enum SentenceStructure {
    case short, medium, long, varied
}