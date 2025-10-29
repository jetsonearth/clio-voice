import Foundation
import os

enum AIProvider: String, CaseIterable {
    case groq = "GROQ"
    
    var baseURL: String {
        // All requests go through fly.io proxy - no direct API calls
        return APIConfig.llmProxyURL
    }
    
    var defaultModel: String {
        return "qwen/qwen3-32b"
    }
    
    var displayName: String {
        return "Groq"
    }
    
    var availableModels: [String] {
        return [
            "qwen/qwen3-32b"
        ]
    }
    
    var requiresAPIKey: Bool {
        // Proxy handles authentication - no user API keys needed
        return false
    }
    
    /// Returns user-friendly display names for models
    func getDisplayName(for model: String) -> String {
        switch model {
        case "qwen/qwen3-32b":
            return "Qwen 3 32B"
        case "meta-llama/llama-4-scout-17b-16e-instruct":
            return "Llama 4 Scout 17B"
        case "meta-llama/llama-4-maverick-17b-128e-instruct":
            return "Llama 4 Maverick 17B"
        case "llama-3.3-70b-versatile":
            return "Llama 3.3 70B Versatile"
        case "llama-3.1-8b-instant":
            return "Llama 3.1 8B Instant"
        default:
            return model
        }
    }
}

class AIService: ObservableObject {
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "AIService")
    
    @Published var selectedProvider: AIProvider = .groq {
        didSet {
            userDefaults.set(selectedProvider.rawValue, forKey: "selectedAIProvider")
            objectWillChange.send()
        }
    }
    
    @Published private var selectedModels: [AIProvider: String] = [:]
    private let userDefaults = UserDefaults.standard
    
    var currentModel: String {
        if let selectedModel = selectedModels[.groq],
           !selectedModel.isEmpty,
           availableModels.contains(selectedModel) {
            return selectedModel
        }
        return AIProvider.groq.defaultModel
    }
    
    var availableModels: [String] {
        return AIProvider.groq.availableModels
    }
    
    init() {
        // Always use Groq as the only provider (via proxy)
        self.selectedProvider = .groq
        userDefaults.set(AIProvider.groq.rawValue, forKey: "selectedAIProvider")
        
        loadSavedModelSelections()
    }
    
    private func loadSavedModelSelections() {
        let key = "\(AIProvider.groq.rawValue)SelectedModel"
        if let savedModel = userDefaults.string(forKey: key), !savedModel.isEmpty {
            selectedModels[.groq] = savedModel
        }
    }
    
    func selectModel(_ model: String) {
        guard !model.isEmpty else { return }
        
        selectedModels[.groq] = model
        let key = "\(AIProvider.groq.rawValue)SelectedModel"
        userDefaults.set(model, forKey: key)
        
        objectWillChange.send()
    }
    
    // All API authentication handled by proxy - no client-side key management needed
    
}

// API key notifications removed - proxy handles all authentication
