import SwiftUI

class WordReplacementManager: ObservableObject {
    @Published var replacements: [String: String] {
        didSet {
            UserDefaults.standard.set(replacements, forKey: "wordReplacements")
        }
    }
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "IsWordReplacementEnabled")
        }
    }
    
    @Published var isDeveloperVocabEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isDeveloperVocabEnabled, forKey: "IsDeveloperVocabularyEnabled")
        }
    }
    
    init() {
        let userReplacements = UserDefaults.standard.dictionary(forKey: "wordReplacements") as? [String: String] ?? [:]
        
        // No default replacements - users can add their own
        self.replacements = userReplacements
        self.isEnabled = UserDefaults.standard.bool(forKey: "IsWordReplacementEnabled")
        self.isDeveloperVocabEnabled = UserDefaults.standard.object(forKey: "IsDeveloperVocabularyEnabled") as? Bool ?? true // Default enabled for new users
        
        // Migration: if user already has replacements but the old global toggle was never exposed in this UI,
        // automatically enable replacement so the feature works out of the box.
        if !self.isEnabled && !userReplacements.isEmpty {
            self.isEnabled = true
        }
    }
    
    func addReplacement(original: String, replacement: String) {
        replacements[original] = replacement
        // Auto-enable replacements when user adds any mapping from any UI
        if !isEnabled { isEnabled = true }
    }
    
    func removeReplacement(original: String) {
        replacements.removeValue(forKey: original)
    }
}

struct WordReplacementView: View {
    @StateObject private var manager = WordReplacementManager()
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showAddReplacementModal = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeveloperVocabulary = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Info Section with Toggles
            VStack(spacing: 12) {
                GroupBox {
                    HStack {
                        Label {
Text("Define word replacements to automatically replace specific words or phrases")
                                .fontScaled(size: 12)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(alignment: .leading)
                        } icon: {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Toggle("Enable", isOn: $manager.isEnabled)
                            .toggleStyle(.switch)
                            .labelsHidden()
                            .help("Enable automatic word replacement after transcription")
                    }
                }
                
                // Developer Vocabulary Section
                GroupBox {
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
Text("Built-in Developer Vocabulary")
                                    .fontScaled(size: 13, weight: .medium)
                                    .foregroundColor(.primary)
                                
Text("Automatically fixes common ASR failures for Git commands, technical acronyms, and framework terms")
                                    .fontScaled(size: 11)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        } icon: {
                            Image(systemName: "terminal.fill")
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button("View All") {
                                showDeveloperVocabulary = true
                            }
                            .buttonStyle(.borderless)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .help("View all 200+ built-in developer corrections")
                            
                            Toggle("Developer Vocabulary", isOn: $manager.isDeveloperVocabEnabled)
                                .toggleStyle(.switch)
                                .labelsHidden()
                                .help("Enable built-in corrections for developer terminology (Git, APIs, frameworks)")
                        }
                    }
                }
                .opacity(manager.isEnabled ? 1.0 : 0.6)
                .disabled(!manager.isEnabled)
            }
            
            VStack(spacing: 0) {
                // Header with action button
                HStack {
                    Text("Word Replacements")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: { showAddReplacementModal = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderless)
                    .help("Add new replacement")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.controlBackgroundColor))
                
                Divider()
                
                // Content
                if manager.replacements.isEmpty {
                    EmptyStateView(manager: manager, showAddModal: $showAddReplacementModal)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(manager.replacements.keys.sorted()), id: \.self) { original in
                                ReplacementRow(
                                    original: original,
                                    replacement: manager.replacements[original] ?? "",
                                    onDelete: { manager.removeReplacement(original: original) }
                                )
                                
                                if original != manager.replacements.keys.sorted().last {
                                    Divider()
                                        .padding(.leading, 32)
                                }
                            }
                        }
                        .background(Color(.controlBackgroundColor))
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showAddReplacementModal) {
            AddReplacementSheet(manager: manager)
        }
        .sheet(isPresented: $showDeveloperVocabulary) {
            DeveloperVocabularyView()
        }
    }
}

struct EmptyStateView: View {
    @ObservedObject var manager: WordReplacementManager
    @Binding var showAddModal: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.word.spacing")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text("No Replacements")
                .font(.headline)
            
VStack(spacing: 8) {
                Text("Add word replacements to automatically replace text during AI enhancement.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
                
                if manager.isDeveloperVocabEnabled {
                    Text("Developer vocabulary is enabled with 200+ built-in corrections for Git, APIs, and frameworks.")
                        .font(.caption)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 280)
                }
            }
            
            Button("Add Replacement") {
                showAddModal = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AddReplacementSheet: View {
    @ObservedObject var manager: WordReplacementManager
    @Environment(\.dismiss) private var dismiss
    @State private var originalWord = ""
    @State private var replacementWord = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .buttonStyle(.borderless)
                .foregroundColor(.red)
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                Text("Add Word Replacement")
                    .font(.headline)
                
                Spacer()
                
                AddNewButton("Add", action: addReplacement, isEnabled: !originalWord.isEmpty && !replacementWord.isEmpty)
                    .keyboardShortcut(.return, modifiers: [])
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.windowBackgroundColor).opacity(0.4))
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Define a word or phrase to be automatically replaced during AI enhancement.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Note: Built-in developer vocabulary includes 200+ corrections for Git commands, technical acronyms, and framework terms.")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Form Content
                    VStack(spacing: 16) {
                        // Original Text Section
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Original Text")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Required")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            TextField("Enter word or phrase to replace", text: $originalWord)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                        }
                        .padding(.horizontal)
                        
                        // Replacement Text Section
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Replacement Text")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Required")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            TextEditor(text: $replacementWord)
                                .font(.body)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(.textBackgroundColor))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color(.separatorColor), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Example Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Example")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Original:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("my website link")
                                    .font(.callout)
                            }
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Replacement:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("https://tryio.com")
                                    .font(.callout)
                            }
                        }
                        .padding(12)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                        
                        // Developer vocabulary example
                        Text("Built-in Developer Examples:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\"get commit\" → \"git commit\"")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("\"jason\" → \"JSON\"")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("\"use state\" → \"useState\"")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(12)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
        }
        .frame(width: 480, height: 520)
    }
    
    private func addReplacement() {
        let trimmedOriginal = originalWord.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedReplacement = replacementWord.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedOriginal.isEmpty && !trimmedReplacement.isEmpty else { return }
        
        manager.addReplacement(original: trimmedOriginal, replacement: trimmedReplacement)
        dismiss()
    }
}

struct ReplacementRow: View {
    let original: String
    let replacement: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Original Text Container
            HStack {
                Text(original)
                    .font(.body)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(6)
            }
            .frame(maxWidth: .infinity)
            
            // Arrow
            Image(systemName: "arrow.right")
                .foregroundColor(.secondary)
                .font(.system(size: 12))
            
            // Replacement Text Container
            HStack {
                Text(replacement)
                    .font(.body)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(6)
            }
            .frame(maxWidth: .infinity)
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.red)
                    .font(.system(size: 16))
            }
            .buttonStyle(.borderless)
            .help("Remove replacement")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .background(Color(.controlBackgroundColor))
    }
}
