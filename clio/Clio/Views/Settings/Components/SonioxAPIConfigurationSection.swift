import SwiftUI

struct SonioxAPIConfigurationSection: View {
    @ObservedObject private var keyStore = SonioxAPIKeyStore.shared
    @State private var draftKey: String = ""
    @State private var isRevealed = false

    private var hasKeyConfigured: Bool {
        guard let key = keyStore.apiKey else { return false }
        return !key.isEmpty
    }

    var body: some View {
        SettingsSection(
            title: "Soniox Cloud Access",
            subtitle: "Soniox is our fastest cloud ASR—enable it when you want ultra-accurate streaming transcription while recordings stay local."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                credentialField

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

                    ConfigurationStatusBadge(
                        status: hasKeyConfigured ? .ready : .required,
                        text: hasKeyConfigured ? "Streaming unlocked" : "Voice key required"
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
