import Foundation

struct PredefinedModel: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let displayName: String
    let size: String
    let speed: Double
    let accuracy: Double
    let ramUsage: Double
    let isComingSoon: Bool
    let isCloudModel: Bool
    let isMultilingualModel: Bool
    let language: String
    let supportedLanguages: [String: String]
    let description: String

    private let customDownloadURL: String?
    private let customFilename: String?

    init(
        id: UUID = UUID(),
        name: String,
        displayName: String? = nil,
        size: String,
        speed: Double,
        accuracy: Double,
        ramUsage: Double,
        isComingSoon: Bool = false,
        isCloudModel: Bool = false,
        isMultilingualModel: Bool = true,
        language: String = "Multilingual",
        supportedLanguages: [String: String] = [:],
        description: String = "",
        downloadURL: String? = nil,
        filename: String? = nil
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName ?? name
        self.size = size
        self.speed = speed
        self.accuracy = accuracy
        self.ramUsage = ramUsage
        self.isComingSoon = isComingSoon
        self.isCloudModel = isCloudModel
        self.isMultilingualModel = isMultilingualModel
        self.language = language
        if supportedLanguages.isEmpty {
            self.supportedLanguages = Self.defaultLanguages
        } else {
            self.supportedLanguages = supportedLanguages
        }
        self.description = description
        self.customDownloadURL = downloadURL
        self.customFilename = filename
    }

    var filename: String {
        customFilename ?? "\(name).bin"
    }

    var downloadURL: String {
        if let customDownloadURL {
            return customDownloadURL
        }

        guard !isCloudModel else { return "" }
        return "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/\(filename)"
    }

    private static let defaultLanguages: [String: String] = [
        "en": "English",
        "es": "Spanish",
        "fr": "French",
        "de": "German",
        "it": "Italian",
        "pt": "Portuguese",
        "zh": "Chinese",
        "ja": "Japanese",
        "ko": "Korean"
    ]
}

enum PredefinedModels {
    static let models: [PredefinedModel] = [
        // Cloud streaming option (current default)
        PredefinedModel(
            name: "soniox-realtime-streaming",
            displayName: "Clio Ultra (Cloud)",
            size: "Streaming",
            speed: 1.0,
            accuracy: 0.85,
            ramUsage: 0.0,
            isCloudModel: true,
            language: "Cloud",
            supportedLanguages: [
                "en": "English",
                "es": "Spanish",
                "fr": "French",
                "de": "German",
                "pt": "Portuguese"
            ],
            description: "Real-time streaming transcription with cloud accuracy and low latency.",
            downloadURL: ""
        ),

        // Free offline baseline
        PredefinedModel(
            name: "ggml-small",
            displayName: "Clio Flash (Small)",
            size: "244 MB",
            speed: 0.85,
            accuracy: 0.65,
            ramUsage: 1.6,
            language: "Multilingual",
            description: "Fastest local option for quick notes and lightweight sessions."
        ),

        // Primary offline model (default download)
        PredefinedModel(
            name: "ggml-large-v3-turbo-q5_0",
            displayName: "Whisper Large v3 Turbo Q5_0",
            size: "1.03 GB",
            speed: 0.6,
            accuracy: 0.92,
            ramUsage: 6.0,
            language: "Multilingual",
            description: "Balanced mix of speed and accuracy—recommended default for offline transcription."
        ),

        // Full-precision turbo model (best quality)
        PredefinedModel(
            name: "ggml-large-v3-turbo",
            displayName: "Whisper Large v3 Turbo",
            size: "1.54 GB",
            speed: 0.45,
            accuracy: 0.96,
            ramUsage: 11.0,
            language: "Multilingual",
            description: "Highest fidelity offline model with full precision decoding."
        ),

        // High-precision quantised variant for stronger Macs
        PredefinedModel(
            name: "ggml-large-v3-turbo-q8_0",
            displayName: "Whisper Large v3 Turbo Q8_0",
            size: "874 MB",
            speed: 0.5,
            accuracy: 0.94,
            ramUsage: 8.5,
            language: "Multilingual",
            description: "Improved accuracy over Q5 with moderate performance footprint."
        )
    ]
}
