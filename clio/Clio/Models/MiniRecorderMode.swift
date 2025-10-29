import Foundation

enum MiniRecorderMode: String, CaseIterable {
    case waveVisualizer = "wave"
    case streamingTranscript = "transcript"
    
    var displayName: String {
        switch self {
        case .waveVisualizer:
            return "Wave Visualizer"
        case .streamingTranscript:
            return "Streaming Transcript"
        }
    }
    
    var description: String {
        switch self {
        case .waveVisualizer:
            return "Shows audio wave animation while recording"
        case .streamingTranscript:
            return "Shows real-time transcript text while recording"
        }
    }
}