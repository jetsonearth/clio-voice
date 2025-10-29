// WakeWordDetector.swift
// Local wake-word detection for privacy-first assistant activation

import Foundation
import AVFoundation

class WakeWordDetector: ObservableObject {
    @Published var isListening = false
    @Published var isAssistantMode = false
    
    private let wakeWords = ["Clio", "Clio help", "Clio run"]
    
    func startListening() {
        isListening = true
        // Implementation for local keyword spotting
        // Options: Porcupine, Vosk-KWS, CoreML model
    }
    
    func detectWakeWord(in transcript: String) -> Bool {
        // Text-based wake word detection as fallback
        let lowercased = transcript.lowercased()
        return wakeWords.contains { wakeWord in
            lowercased.hasPrefix(wakeWord.lowercased())
        }
    }
    
    func activateAssistantMode() {
        isAssistantMode = true
        // Transition from Enhancement Mode to Assistant Mode
    }
    
    func deactivateAssistantMode() {
        isAssistantMode = false
        // Return to Enhancement Mode
    }
}