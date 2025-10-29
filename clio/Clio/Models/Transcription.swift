import Foundation
import SwiftData

@Model
final class Transcription {
    var id: UUID
    var text: String
    var enhancedText: String?
    var timestamp: Date
    var duration: TimeInterval
    var audioFileURL: String?
    var processingLatencyMs: Double? // Time from recording stop to text ready (T0 to T1)
    var llmLatencyMs: Double? // Time for LLM processing (T1 to T2)
    var totalLatencyMs: Double? // Total time from recording stop to enhanced text ready (T0 to T2)
    var aiProvider: String? // Which AI provider was used for enhancement
    
    // Command Mode metadata
    var isCommand: Bool = false
    var commandOutput: String?
    
    init(text: String, duration: TimeInterval, enhancedText: String? = nil, audioFileURL: String? = nil, processingLatencyMs: Double? = nil, llmLatencyMs: Double? = nil, totalLatencyMs: Double? = nil, aiProvider: String? = nil) {
        self.id = UUID()
        self.text = text
        self.enhancedText = enhancedText
        self.timestamp = Date()
        self.duration = duration
        self.audioFileURL = audioFileURL
        self.processingLatencyMs = processingLatencyMs
        self.llmLatencyMs = llmLatencyMs
        self.totalLatencyMs = totalLatencyMs
        self.aiProvider = aiProvider
    }
    
    // Computed property for formatted latency display
    var formattedLatency: String {
        if let totalMs = totalLatencyMs {
            return String(format: "%.0f ms", totalMs)
        } else if let whisperMs = processingLatencyMs {
            return String(format: "%.0f ms", whisperMs)
        } else {
            return "N/A"
        }
    }
    
    // Formatted breakdown of latencies
    var formattedLatencyBreakdown: String {
        var parts: [String] = []
        
        if let whisperMs = processingLatencyMs {
            parts.append("ASR: \(String(format: "%.0f ms", whisperMs))")
        }
        
        if let llmMs = llmLatencyMs {
            parts.append("LLM: \(String(format: "%.0f ms", llmMs))")
        }
        
        if let totalMs = totalLatencyMs {
            parts.append("Total: \(String(format: "%.0f ms", totalMs))")
        }
        
        return parts.isEmpty ? "N/A" : parts.joined(separator: " • ")
    }
    
    // Helper computed properties for metrics calculations
    var isAIEnhanced: Bool {
        return enhancedText != nil && llmLatencyMs != nil
    }
    
    var ASRLatency: Double {
        return processingLatencyMs ?? 0
    }
    
    var LLMLatency: Double {
        return llmLatencyMs ?? 0
    }
    
    var totalLatency: Double {
        return totalLatencyMs ?? processingLatencyMs ?? 0
    }
}
