struct SonioxConfig: Codable {
    let api_key: String
    let model: String
    let audio_format: String
    let sample_rate: Int?
    let num_channels: Int?
    let language_hints: [String]?
    let enable_non_final_tokens: Bool
    let enable_endpoint_detection: Bool
    // let max_non_final_tokens_duration_ms: Int? // Deprecated by Soniox as of Sept 1st 2024
    let context: SonioxContext?
}

struct SonioxContext: Codable {
    let general: [SonioxContextGeneral]?
    let text: String?
    let terms: [String]?
    let translationTerms: [SonioxTranslationTerm]?
    
    enum CodingKeys: String, CodingKey {
        case general
        case text
        case terms
        case translationTerms = "translation_terms"
    }
}

struct SonioxContextGeneral: Codable {
    let key: String
    let value: String
}

struct SonioxTranslationTerm: Codable {
    let source: String
    let target: String
}

struct SonioxResponse: Codable {
    let tokens: [SonioxToken]
}

struct SonioxToken: Codable {
    let text: String
    let is_final: Bool
    let confidence: Double?
    let start_time: Double?
    let end_time: Double?
}
