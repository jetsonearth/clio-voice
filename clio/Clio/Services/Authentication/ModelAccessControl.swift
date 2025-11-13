import Foundation
import SwiftUI
import Combine

// MARK: - WhisperModel Extensions for UI
extension WhisperModel: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    static func == (lhs: WhisperModel, rhs: WhisperModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

/// Controls access to AI models based on subscription tier
@MainActor
class ModelAccessControl: ObservableObject {
    static let shared = ModelAccessControl()
    
    @Published private(set) var availableAIProviders: Set<AIProvider> = []
    
    private let subscriptionManager = SubscriptionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Free tier model names (smaller models)
    private let freeModelNames = Set([
        "ggml-small"
    ])
    
    private init() {
        updateAvailableModels()
        
        // Listen for subscription changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(subscriptionChanged),
            name: .subscriptionStateChanged,
            object: nil
        )
        
        // Also listen for SubscriptionManager property changes directly
        subscriptionManager.objectWillChange.sink { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateAvailableModels()
            }
        }.store(in: &cancellables)
    }
    
    @objc private func subscriptionChanged() {
        updateAvailableModels()
    }
    
    private func updateAvailableModels() {
        let features = subscriptionManager.features
        
        // Update AI providers
        // Always allow Groq since it's the only provider
        availableAIProviders = [.groq]
    }
    
    // MARK: - Access Checks
    
    func canUseWhisperModel(_ model: WhisperModel) -> Bool {
        // Quick client-side check first (for UI responsiveness)
        if !subscriptionManager.features.canUseLargeModels {
            // Free tier - only allow specifically whitelisted models
            return freeModelNames.contains(model.name)
        }
        
        // Pro tier - allow access but will be validated server-side before actual use
        return true
    }
    
    /// Validates model access with server-side verification (async)
    func validateModelAccess(_ model: WhisperModel) async -> Bool {
        // Always validate with server for security
        return await ModelValidationService.shared.validateModelAccess(model)
    }
    
    func canUseAIProvider(_ provider: AIProvider) -> Bool {
        availableAIProviders.contains(provider)
    }
    
    func canUseAIEnhancement() -> Bool {
        subscriptionManager.features.canUseAIEnhancement
    }
    
    // MARK: - Model Metadata
    
    func isProModel(_ model: WhisperModel) -> Bool {
        return !canUseWhisperModel(model) || 
               !(freeModelNames.contains(model.name) || 
                 model.name.contains("tiny") || 
                 model.name.contains("base"))
    }
    
    func isProProvider(_ provider: AIProvider) -> Bool {
        switch provider {
        case .groq:
            return true
        }
    }
    
    // MARK: - Feature Descriptions
    
    func getModelDescription(_ model: WhisperModel) -> String {
        let modelName = model.name.lowercased()
        
        if modelName.contains("tiny") {
            return NSLocalizedString("models.access.fastest_lowest_accuracy", comment: "Tiny model description")
        } else if modelName.contains("base") {
            return NSLocalizedString("models.access.fast_good_accuracy", comment: "Base model description")
        } else if modelName.contains("small") {
            return NSLocalizedString("models.access.balanced_speed_accuracy_pro", comment: "Small model description")
        } else if modelName.contains("medium") {
            return NSLocalizedString("models.access.high_accuracy_slower_pro", comment: "Medium model description")
        } else if modelName.contains("large") {
            return NSLocalizedString("models.access.highest_accuracy_pro", comment: "Large model description")
        } else if modelName.contains("v3") {
            return NSLocalizedString("models.access.latest_model_best_quality_pro", comment: "V3 model description")
        } else {
            return isProModel(model) ? NSLocalizedString("models.access.pro_model", comment: "Pro model") : NSLocalizedString("models.access.free_model", comment: "Free model")
        }
    }
    
    func getProviderDescription(_ provider: AIProvider) -> String {
        switch provider {
        case .groq:
            return NSLocalizedString("providers.groq.description", comment: "Groq provider description")
        }
    }
    
    // MARK: - Validation
    
    enum ModelAccessError: LocalizedError {
        case modelRequiresPro(String)
        case featureRequiresPro(String)
        case usageLimitExceeded(String)
        
        var errorDescription: String? {
            switch self {
            case .modelRequiresPro(let model):
                return "\(model) requires a Pro subscription"
            case .featureRequiresPro(let feature):
                return "\(feature) requires a Pro subscription"
            case .usageLimitExceeded(let limit):
                return "Monthly usage limit exceeded: \(limit)"
            }
        }
    }
    
    func validateWhisperModelAccess(_ model: WhisperModel) throws {
        if !canUseWhisperModel(model) {
            throw ModelAccessError.modelRequiresPro(model.name)
        }
    }
    
    func validateAIProviderAccess(_ provider: AIProvider) throws {
        if !canUseAIProvider(provider) {
            throw ModelAccessError.modelRequiresPro(provider.rawValue)
        }
    }
    
    func validateFeatureAccess(_ feature: ProFeature) throws {
        if !subscriptionManager.canAccessFeature(feature) {
            throw ModelAccessError.featureRequiresPro(feature.displayName)
        }
    }
    
    func validateUsageLimit(for feature: ProFeature) throws {
        if let usage = subscriptionManager.getRemainingUsage(for: feature),
           usage.isAtLimit {
            throw ModelAccessError.usageLimitExceeded("\(Int(usage.limit)) \(usage.unit)")
        }
    }
}

// MARK: - SwiftUI View Modifier

struct ProGatedModifier: ViewModifier {
    let feature: ProFeature
    let showLockIcon: Bool
    @StateObject private var accessControl = ModelAccessControl.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showUpgradePrompt = false
    
    func body(content: Content) -> some View {
        content
            .disabled(!subscriptionManager.canAccessFeature(feature))
            .overlay(alignment: .topTrailing) {
                if showLockIcon && !subscriptionManager.canAccessFeature(feature) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(4)
                        .background(Circle().fill(Color.black.opacity(0.2)))
                        .padding(4)
                }
            }
            .onTapGesture {
                if !subscriptionManager.canAccessFeature(feature) {
                    showUpgradePrompt = true
                    subscriptionManager.promptUpgrade(from: feature.rawValue)
                }
            }
            .sheet(isPresented: $showUpgradePrompt) {
                UpgradePromptView(feature: feature)
            }
    }
}

extension View {
    func proGated(_ feature: ProFeature, showLockIcon: Bool = true) -> some View {
        modifier(ProGatedModifier(feature: feature, showLockIcon: showLockIcon))
    }
}

// MARK: - Model Picker Helpers

struct WhisperModelPicker: View {
    @Binding var selection: WhisperModel?
    let availableModels: [WhisperModel]
    @StateObject private var accessControl = ModelAccessControl.shared
    
    var body: some View {
        Picker("Model", selection: $selection) {
            ForEach(availableModels, id: \.id) { model in
                HStack {
                    Text(model.name)
                    if accessControl.isProModel(model) && !accessControl.canUseWhisperModel(model) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .tag(model as WhisperModel?)
            }
        }
        .onChange(of: selection) { _, newValue in
            if let model = newValue, !accessControl.canUseWhisperModel(model) {
                // Show upgrade prompt
                SubscriptionManager.shared.promptUpgrade(from: "whisper_model_picker")
            }
        }
    }
}

struct AIProviderPicker: View {
    @Binding var selection: AIProvider
    @StateObject private var accessControl = ModelAccessControl.shared
    
    var body: some View {
        Picker("AI Provider", selection: $selection) {
            ForEach(AIProvider.allCases, id: \.self) { provider in
                HStack {
                    Text(provider.displayName)
                    if accessControl.isProProvider(provider) && !accessControl.canUseAIProvider(provider) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .tag(provider)
            }
        }
        .onChange(of: selection) { _, newValue in
            if !accessControl.canUseAIProvider(newValue) {
                // Revert to available provider
                if let firstAvailable = accessControl.availableAIProviders.first {
                    selection = firstAvailable
                }
                // Show upgrade prompt
                SubscriptionManager.shared.promptUpgrade(from: "ai_provider_picker")
            }
        }
    }
}
