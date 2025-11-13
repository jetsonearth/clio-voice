import SwiftUI

struct GroqAPIConfigurationSection: View {
    @ObservedObject private var keyStore = GroqAPIKeyStore.shared
    @State private var draftKey: String = ""
    @State private var isRevealed = false
    
    var body: some View {
        SettingsSection(
            icon: "lock.shield",
            title: "Groq API",
            subtitle: "Store your Groq API key to enable cloud enhancement"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Keys stay on this Mac in the system keychain. Generate one at groq.com and paste it here.")
                    .settingsDescription()
                
                HStack(spacing: 12) {
                    Group {
                        if isRevealed {
                            TextField("gsk_...", text: $draftKey)
                        } else {
                            SecureField("gsk_...", text: $draftKey)
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
                    .disabled((keyStore.apiKey ?? "").isEmpty && draftKey.isEmpty)
                    
                    Spacer()
                    
                    if let key = keyStore.apiKey, !key.isEmpty {
                        Label("Configured", systemImage: "checkmark.seal.fill")
                            .font(.footnote)
                            .foregroundColor(.green)
                    } else {
                        Label("API key required", systemImage: "exclamationmark.triangle")
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
