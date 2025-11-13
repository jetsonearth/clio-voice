import SwiftUI

struct SonioxAPIConfigurationSection: View {
    @ObservedObject private var keyStore = SonioxAPIKeyStore.shared
    @State private var draftKey: String = ""
    @State private var isRevealed = false

    var body: some View {
        SettingsSection(
            icon: "antenna.radiowaves.left.and.right",
            title: "Soniox Cloud Access",
            subtitle: "Store your own API key to enable Soniox streaming"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Keys are saved only on this Mac via the system keychain. Remove the value to fall back to local-only transcription.")
                    .settingsDescription()

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
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 12) {
                    Button("Save") {
                        keyStore.update(apiKey: draftKey)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Clear", role: .destructive) {
                        draftKey = ""
                        keyStore.update(apiKey: nil)
                    }
                    .buttonStyle(.bordered)
                    .disabled(keyStore.apiKey == nil && draftKey.isEmpty)

                    Spacer()

                    if let key = keyStore.apiKey, !key.isEmpty {
                        Label("Configured", systemImage: "checkmark.seal.fill")
                            .font(.footnote)
                            .foregroundColor(.green)
                    } else {
                        Label("API key required for Soniox", systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .onAppear {
            draftKey = keyStore.apiKey ?? ""
        }
    }
}
