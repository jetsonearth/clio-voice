import SwiftUI

private struct ProviderModelOption: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
}

private let groqModelOptions: [ProviderModelOption] = [
    .init(
        id: "qwen/qwen3-32b",
        title: "Qwen 3 32B",
        detail: "Balanced editing quality with Groq’s fastest TTFT — ideal default."
    ),
    .init(
        id: "meta-llama/llama-4-scout-17b-16e-instruct",
        title: "Llama 4 Scout 17B",
        detail: "Ultra-low latency drafts when you value responsiveness over raw power."
    ),
    .init(
        id: "meta-llama/llama-4-maverick-17b-128e-instruct",
        title: "Llama 4 Maverick 17B",
        detail: "Creative rewrites with a warmer tone and stronger summarization."
    ),
    .init(
        id: "llama-3.3-70b-versatile",
        title: "Llama 3.3 70B",
        detail: "Highest quality Groq model for complex rewrites (slightly slower)."
    ),
    .init(
        id: "llama-3.1-8b-instant",
        title: "Llama 3.1 8B Instant",
        detail: "Lightweight option that favors cost and speed over depth."
    )
]

private let geminiModelOptions: [ProviderModelOption] = [
    .init(
        id: "gemini-2.5-flash-lite",
        title: "Gemini 2.5 Flash Lite",
        detail: "Default fallback — lightning-fast and optimized for editing flows."
    ),
    .init(
        id: "gemini-2.0-flash-exp",
        title: "Gemini 2.0 Flash Experimental",
        detail: "Latest reasoning improvements with similar latency."
    ),
    .init(
        id: "gemini-1.5-flash",
        title: "Gemini 1.5 Flash",
        detail: "Battle-tested streaming model for predictable responses."
    ),
    .init(
        id: "gemini-1.5-pro",
        title: "Gemini 1.5 Pro",
        detail: "Highest quality for long-form edits when speed is less critical."
    )
]

struct GroqAPIConfigurationSection: View {
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
            title: "Groq API",
            subtitle: "Groq runs Clio’s main LLM so your dictation cleans up instantly. Provide your key and choose the model that fits your workflow."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                modelPicker
                
                credentialField(placeholder: "gsk_...")
                
                actionRow(
                    statusText: hasKeyConfigured ? "Ready for enhancement" : "API key required",
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
            Text("Preferred LLM")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DarkTheme.textPrimary)
            
            StyledDropdown(
                icon: "slider.horizontal.3",
                options: groqModelOptions,
                selectedOption: selectedModel,
                defaultText: "",
                optionDisplayText: { $0.title }
            ) { option in
                guard let option else { return }
                selectedModelId = option.id
                enhancementService.groqModel = option.id
            }
            
            if let detail = selectedModel?.detail {
                Text(detail)
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
            Button("Save") {
                keyStore.update(apiKey: draftKey)
            }
            .buttonStyle(SettingsPillButtonStyle())
            
            Button("Clear") {
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
        if groqModelOptions.contains(where: { $0.id == newValue }) {
            selectedModelId = newValue
        } else if let fallback = groqModelOptions.first?.id {
            selectedModelId = fallback
            enhancementService.groqModel = fallback
        }
    }
}

struct GeminiAPIConfigurationSection: View {
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
            title: "Gemini Fallback",
            subtitle: "Add a Google AI Studio key so Clio can switch to Gemini instantly, keeping enhancement online without touching our servers."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                geminiModelPicker
                
                credentialField(placeholder: "AIza...")
                
                actionRow(
                    statusText: hasKeyConfigured ? "Auto-fallback ready" : "Optional fallback",
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
            Text("Fallback model")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DarkTheme.textPrimary)
            
            StyledDropdown(
                icon: "wand.and.rays",
                options: geminiModelOptions,
                selectedOption: selectedModel,
                defaultText: "",
                optionDisplayText: { $0.title }
            ) { option in
                guard let option else { return }
                selectedModelId = option.id
                enhancementService.geminiModel = option.id
            }
            
            if let detail = selectedModel?.detail {
                Text(detail)
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
            Button("Save") {
                keyStore.update(apiKey: draftKey)
            }
            .buttonStyle(SettingsPillButtonStyle())
            
            Button("Clear") {
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
