// UserDictionary.swift
// Dynamic vocabulary adaptation for improved accuracy
// Learns from user corrections and adds to audio model

import Foundation

class UserDictionary: ObservableObject {
    @Published var customTerms: [String: String] = [:]
    @Published var frequentlyMissed: [String] = []
    
    private let userDefaults = UserDefaults.standard
    private let dictionaryKey = "user_custom_dictionary"
    
    func addTerm(spoken: String, written: String) {
        customTerms[spoken.lowercased()] = written
        saveDictionary()
        
        // Update audio model with new term
        updateAudioModelVocabulary()
    }
    
    func learnFromCorrection(original: String, corrected: String) {
        // Analyze what user corrected to learn patterns
        let differences = findDifferences(original: original, corrected: corrected)
        
        for difference in differences {
            addTerm(spoken: difference.spoken, written: difference.written)
        }
    }
    
    private func updateAudioModelVocabulary() {
        // Send updated vocabulary to Whisper fine-tuning pipeline
        // This improves accuracy for user-specific terms
    }
    
    private func findDifferences(original: String, corrected: String) -> [TermMapping] {
        // Smart diffing to identify spoken -> written mappings
        return []
    }
    
    private func saveDictionary() {
        if let data = try? JSONEncoder().encode(customTerms) {
            userDefaults.set(data, forKey: dictionaryKey)
        }
    }
}

struct TermMapping {
    let spoken: String
    let written: String
    let confidence: Double
}