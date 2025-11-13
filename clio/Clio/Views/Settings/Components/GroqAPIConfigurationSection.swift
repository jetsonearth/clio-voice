import SwiftUI

private struct ProviderModelOption: Identifiable, Hashable {
    let id: String
    let titleKey: String
    let detailKey: String
}

private let groqModelOptions: [ProviderModelOption] = [
    .init(
        id: "qwen/qwen3-32b",
        titleKey: "ai_models.model.qwen32.title",
        detailKey: "ai_models.model.qwen32.detail"
    ),
    .init(
        id: "meta-llama/llama-4-scout-17b-16e-instruct",
        titleKey: "ai_models.model.llama_scout.title",
        detailKey: "ai_models.model.llama_scout.detail"
    ),
    .init(
        id: "meta-llama/llama-4-maverick-17b-128e-instruct",
        titleKey: "ai_models.model.llama_maverick.title",
        detailKey: "ai_models.model.llama_maverick.detail"
    ),
    .init(
        id: "llama-3.3-70b-versatile",
        titleKey: "ai_models.model.llama33.title",
        detailKey: "ai_models.model.llama33.detail"
    ),
    .init(
        id: "llama-3.1-8b-instant",
        titleKey: "ai_models.model.llama31.title",
        detailKey: "ai_models.model.llama31.detail"
    )
]

private let geminiModelOptions: [ProviderModelOption] = [
    .init(
        id: "gemini-2.5-flash-lite",
        titleKey: "ai_models.model.gemini25.title",
        detailKey: "ai_models.model.gemini25.detail"
    ),
    .init(
        id: "gemini-2.0-flash-exp",
        titleKey: "ai_models.model.gemini20exp.title",
        detailKey: "ai_models.model.gemini20exp.detail"
    ),
    .init(
        id: "gemini-1.5-flash",
        titleKey: "ai_models.model.gemini15flash.title",
        detailKey: "ai_models.model.gemini15flash.detail"
    ),
    .init(
        id: "gemini-1.5-pro",
        titleKey: "ai_models.model.gemini15pro.title",
        detailKey: "ai_models.model.gemini15pro.detail"
    )
]

struct GroqAPIConfigurationSection: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @ObservedObject private var keyStore = GroqAPIKeyStore.shared
    @State private var draftKey: String = ""
    @State private var isRevealed = false
    @State private var selectedModelId: String = groqModelOptions.first?.id ?? ""
    
    private var selectedModel: ProviderModelOption? {
        groqModelOptions.first { $0.id == selectedModelId }
    }
    
    private var hasKeyConfigured: Bool {
        guard let key = keyStore.apiKey else { return false }
        return !key.isEmpty
    }
    
    var body: some View {
        SettingsSection(
            title: localizationManager.localizedString("ai_models.section.groq.title"),
            subtitle: localizationManager.localizedString("ai_models.section.groq.subtitle")
        ) {
            VStack(alignment: .leading, spacing: 16) {
                modelPicker
                
                credentialField(placeholder: "gsk_...")
                
                actionRow(
                    statusText: localizationManager.localizedString(hasKeyConfigured ? "ai_models.status.ready" : "ai_models.status.required"),
                    status: hasKeyConfigured ? .ready : .required
                )
            }
        }
        .onAppear {
            draftKey = keyStore.apiKey ?? ""
            syncModelSelection(with: enhancementService.groqModel)
        }
        .onReceive(keyStore.$apiKey) { newValue in
            draftKey = newValue ?? ""
        }
        .onReceive(enhancementService.$groqModel) { newValue in
            syncModelSelection(with: newValue)
        }
    }
    
    private var modelPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(localizationManager.localizedString("ai_models.section.groq.model_label"))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DarkTheme.textPrimary)
            
            StyledDropdown(
                icon: "slider.horizontal.3",
                options: groqModelOptions,
                selectedOption: selectedModel,
                defaultText: "",
                optionDisplayText: { option in
                    localizationManager.localizedString(option.titleKey)
                }
            ) { option in
                guard let option else { return }
                selectedModelId = option.id
                enhancementService.groqModel = option.id
            }
            
            if let detailKey = selectedModel?.detailKey {
                Text(localizationManager.localizedString(detailKey))
                    .font(.caption)
                    .foregroundColor(DarkTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func credentialField(placeholder: String) -> some View {
        HStack(spacing: 12) {
            Group {
                if isRevealed {
                    TextField(placeholder, text: $draftKey)
                } else {
                    SecureField(placeholder, text: $draftKey)
                }
            }
            .textFieldStyle(.roundedBorder)
            
            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func actionRow(statusText: String, status: ConfigurationStatusBadge.Status) -> some View {
        HStack(spacing: 12) {
            Button(localizationManager.localizedString("general.save")) {
                keyStore.update(apiKey: draftKey)
            }
            .buttonStyle(SettingsPillButtonStyle())
            
            Button(localizationManager.localizedString("general.clear")) {
                draftKey = ""
                keyStore.update(apiKey: nil)
            }
            .buttonStyle(SettingsPillButtonStyle(style: .secondary))
            .disabled(!hasKeyConfigured && draftKey.isEmpty)
            
            Spacer()
            
            ConfigurationStatusBadge(status: status, text: statusText)
                .padding(.trailing, 6)
        }
    }
    
    private func syncModelSelection(with newValue: String) {
        if groqModelOptions.contains(where: { $0.id == newValue }) {
            selectedModelId = newValue
        } else if let fallback = groqModelOptions.first?.id {
            selectedModelId = fallback
            enhancementService.groqModel = fallback
        }
    }
}

struct GeminiAPIConfigurationSection: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @ObservedObject private var keyStore = GeminiAPIKeyStore.shared
    @State private var draftKey: String = ""
    @State private var isRevealed = false
    @State private var selectedModelId: String = geminiModelOptions.first?.id ?? ""
    
    private var selectedModel: ProviderModelOption? {
        geminiModelOptions.first { $0.id == selectedModelId }
    }
    
    private var hasKeyConfigured: Bool {
        guard let key = keyStore.apiKey else { return false }
        return !key.isEmpty
    }
    
    var body: some View {
        SettingsSection(
            title: localizationManager.localizedString("ai_models.section.gemini.title"),
            subtitle: localizationManager.localizedString("ai_models.section.gemini.subtitle")
        ) {
            VStack(alignment: .leading, spacing: 16) {
                geminiModelPicker
                
                credentialField(placeholder: "AIza...")
                
                actionRow(
                    statusText: localizationManager.localizedString(hasKeyConfigured ? "ai_models.status.auto_ready" : "ai_models.status.optional"),
                    status: hasKeyConfigured ? .ready : .optional
                )
            }
        }
        .onAppear {
            draftKey = keyStore.apiKey ?? ""
            syncModelSelection(with: enhancementService.geminiModel)
        }
        .onReceive(keyStore.$apiKey) { newValue in
            draftKey = newValue ?? ""
        }
        .onReceive(enhancementService.$geminiModel) { newValue in
            syncModelSelection(with: newValue)
        }
    }
    
    private var geminiModelPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(localizationManager.localizedString("ai_models.section.gemini.model_label"))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DarkTheme.textPrimary)
            
            StyledDropdown(
                icon: "wand.and.rays",
                options: geminiModelOptions,
                selectedOption: selectedModel,
                defaultText: "",
                optionDisplayText: { option in
                    localizationManager.localizedString(option.titleKey)
                }
            ) { option in
                guard let option else { return }
                selectedModelId = option.id
                enhancementService.geminiModel = option.id
            }
            
            if let detailKey = selectedModel?.detailKey {
                Text(localizationManager.localizedString(detailKey))
                    .font(.caption)
                    .foregroundColor(DarkTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func credentialField(placeholder: String) -> some View {
        HStack(spacing: 12) {
            Group {
                if isRevealed {
                    TextField(placeholder, text: $draftKey)
                } else {
                    SecureField(placeholder, text: $draftKey)
                }
            }
            .textFieldStyle(.roundedBorder)
            
            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func actionRow(statusText: String, status: ConfigurationStatusBadge.Status) -> some View {
        HStack(spacing: 12) {
            Button(localizationManager.localizedString("general.save")) {
                keyStore.update(apiKey: draftKey)
            }
            .buttonStyle(SettingsPillButtonStyle())
            
            Button(localizationManager.localizedString("general.clear")) {
                draftKey = ""
                keyStore.update(apiKey: nil)
            }
            .buttonStyle(SettingsPillButtonStyle(style: .secondary))
            .disabled(!hasKeyConfigured && draftKey.isEmpty)
            
            Spacer()
            
            ConfigurationStatusBadge(status: status, text: statusText)
        }
    }
    
    private func syncModelSelection(with newValue: String) {
        if geminiModelOptions.contains(where: { $0.id == newValue }) {
            selectedModelId = newValue
        } else if let fallback = geminiModelOptions.first?.id {
            selectedModelId = fallback
            enhancementService.geminiModel = fallback
        }
    }
}
