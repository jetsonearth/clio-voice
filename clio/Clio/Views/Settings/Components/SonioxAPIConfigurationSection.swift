import SwiftUI

struct SonioxAPIConfigurationSection: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @ObservedObject private var keyStore = SonioxAPIKeyStore.shared
    @State private var draftKey: String = ""
    @State private var isRevealed = false

    private var hasKeyConfigured: Bool {
        guard let key = keyStore.apiKey else { return false }
        return !key.isEmpty
    }

    var body: some View {
        SettingsSection(
            title: localizationManager.localizedString("ai_models.section.soniox.title"),
            subtitle: localizationManager.localizedString("ai_models.section.soniox.subtitle")
        ) {
            VStack(alignment: .leading, spacing: 16) {
                credentialField

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

                    ConfigurationStatusBadge(
                        status: hasKeyConfigured ? .ready : .required,
                        text: localizationManager.localizedString(hasKeyConfigured ? "ai_models.status.voice_ready" : "ai_models.status.voice_required")
                    )
                }
            }
        }
        .onAppear {
            draftKey = keyStore.apiKey ?? ""
        }
        .onReceive(keyStore.$apiKey) { newValue in
            draftKey = newValue ?? ""
        }
    }
    
    private var credentialField: some View {
        HStack(spacing: 12) {
            Group {
                if isRevealed {
                    TextField("sk-soniox-...", text: $draftKey)
                        .textFieldStyle(.roundedBorder)
                } else {
                    SecureField("sk-soniox-...", text: $draftKey)
                        .textFieldStyle(.roundedBorder)
                }
            }

            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}
