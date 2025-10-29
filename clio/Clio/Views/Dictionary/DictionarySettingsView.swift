import SwiftUI

enum EditModalItem: Identifiable {
    case vocabulary(DictionaryItem)
    case replacement(String, String)
    
    var id: String {
        switch self {
        case .vocabulary(let item):
            return "vocab_\(item.id)"
        case .replacement(let original, _):
            return "replacement_\(original)"
        }
    }
}

struct DictionarySettingsView: View {
    @State private var selectedTab: DictionaryTab = .vocabulary
    @State private var searchText = ""
    @State private var showAddModal = false
    @State private var editingItem: DictionaryItem?
    @State private var editingReplacement: (original: String, replacement: String)?
    @StateObject private var dictionaryManager: DictionaryManager
    @StateObject private var replacementManager = WordReplacementManager()
    @EnvironmentObject private var localizationManager: LocalizationManager
    let whisperPrompt: WhisperPrompt
    @AppStorage("DictionaryInfoCardDismissed") private var infoCardDismissed = false
    
    enum DictionaryTab: String, CaseIterable {
        case vocabulary = "vocabulary"
        case replacements = "replacements"
        
        var icon: String {
            switch self {
            case .vocabulary:
                return "textformat.abc"
            case .replacements:
                return "arrow.2.squarepath"
            }
        }
    }
    
init(whisperPrompt: WhisperPrompt, initialTab: DictionaryTab = .vocabulary) {
        self.whisperPrompt = whisperPrompt
        _dictionaryManager = StateObject(wrappedValue: DictionaryManager(whisperPrompt: whisperPrompt))
        _selectedTab = State(initialValue: initialTab)
    }
    
var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Page Header Section
                pageHeader
                    .padding(.horizontal, 40)
                    .padding(.top, 32)
                    .padding(.bottom, 16)
                
                if !infoCardDismissed {
                    infoCard
                        .padding(.horizontal, 40)
                        .padding(.bottom, 16)
                }
                
                // Main Content
                VStack(spacing: 16) {
                    searchSection
                    contentArea
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .sheet(isPresented: $showAddModal) {
            AddItemModal(
                selectedTab: selectedTab,
                dictionaryManager: dictionaryManager,
                replacementManager: replacementManager
            )
            .environmentObject(localizationManager)
        }
        .sheet(item: Binding<EditModalItem?>(
            get: { 
                if let editingItem = editingItem {
                    return EditModalItem.vocabulary(editingItem)
                } else if let editingReplacement = editingReplacement {
                    return EditModalItem.replacement(editingReplacement.original, editingReplacement.replacement)
                }
                return nil
            },
            set: { newValue in
                if newValue == nil {
                    editingItem = nil
                    editingReplacement = nil
                }
            }
        )) { modalItem in
            Group {
                switch modalItem {
                case .vocabulary(let item):
                    EditVocabularyModal(
                        item: item,
                        dictionaryManager: dictionaryManager
                    )
                case .replacement(let original, let replacement):
                    EditReplacementModal(
                        original: original,
                        replacement: replacement,
                        replacementManager: replacementManager
                    )
                }
            }
            .environmentObject(localizationManager)
        }
        .onAppear {
            // Ensure sample/example terms never persist in the real list
            removeSampleVocabularyIfPresent()
        }
    }
    
    // MARK: - Page Header
private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
Text(selectedTab == .vocabulary ? localizationManager.localizedString("dictionary.title") : localizationManager.localizedString("dictionary.replacements"))
                        .fontScaled(size: 30, weight: .semibold)
                        .foregroundColor(DarkTheme.textPrimary)
                }
                
                Spacer()
                
                AddNewButton(localizationManager.localizedString("dictionary.add_new"), action: {
                    presentAddModal()
                })
            }
        }
        }
    
    // MARK: - Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
VStack(alignment: .leading, spacing: 8) {
Text(localizationManager.localizedString(selectedTab == .vocabulary ? "dictionary.info_card.title.vocab" : "dictionary.info_card.title.voice"))
                        .fontScaled(size: 20, weight: .semibold)
                        .foregroundColor(DarkTheme.textPrimary)
Text(selectedTab == .vocabulary ? localizationManager.localizedString("dictionary.custom_description") : localizationManager.localizedString("dictionary.voice_shortcuts_description"))
                        .fontScaled(size: 14)
                        .foregroundColor(DarkTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
Button(action: { infoCardDismissed = true }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(DarkTheme.textPrimary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(DarkTheme.textPrimary.opacity(0.12))
                                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
                        )
                }
                .buttonStyle(.borderless)
            }

// Example chips
            if selectedTab == .vocabulary {
                WrapTags(tags: vocabExamples)
            } else {
                WrapTags(tags: replacementsExamplesCombined)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.12), lineWidth: 1)
                )
        )
    }

private var vocabExamples: [String] {
        [
            "Sternocleidomastoid",
            "碧玺",
            "Koyeb",
            "Quetzaltenango",
            "君子慎独",
            "心斋坐忘",
            "Chutzpah"
        ]
    }

private var replacementsExamplesCombined: [String] {
        [
            "my number → 123-456-7890",
            "my email → jetson@cliovoice.com",
            "cold dm → Just launched something you might like: cliovoice.com — mind if I share a quick demo?"
        ]
    }

    // MARK: - Search Section
    private var searchSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(DarkTheme.textSecondary)
                .font(.system(size: 14))
            
            TextField(localizationManager.localizedString("dictionary.search_placeholder"), text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(DarkTheme.textSecondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
            .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(DictionaryTab.allCases, id: \.self) { tab in
                    ToggleTabButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        isFirst: tab == DictionaryTab.allCases.first,
                        isLast: tab == DictionaryTab.allCases.last,
                        action: { selectedTab = tab }
                    )
                }
            }
            .background(Color.primary.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
            )
            
            Spacer()
        }
        .padding(.vertical, 12)
    }
    
    private var contentArea: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                switch selectedTab {
                case .vocabulary:
                    vocabularyContent
                case .replacements:
                    replacementsContent
                }
            }
            .padding(.vertical, 4)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.25), lineWidth: 1)
                )
        )
    }
    
    private var vocabularyContent: some View {
        Group {
            if filteredVocabularyItems.isEmpty {
                EmptyVocabularyView()
                    .padding(.vertical, 60)
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredVocabularyItems) { item in
                        VocabularyRow(
                            item: item,
                            onEdit: { editVocabularyItem(item) },
                            onDelete: { dictionaryManager.removeWord(item.word) },
                            onToggle: { dictionaryManager.toggleWordState(id: item.id) }
                        )
                        
                        if item.id != filteredVocabularyItems.last?.id {
                            Rectangle()
                                .fill(DarkTheme.textPrimary.opacity(0.1))
                                .frame(height: 1)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
    
    private var replacementsContent: some View {
        Group {
            if filteredReplacements.isEmpty {
                EmptyReplacementsView()
                    .padding(.vertical, 60)
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredReplacements, id: \.key) { replacement in
                        DictionaryReplacementRow(
                            original: replacement.key,
                            replacement: replacement.value,
                            onEdit: { editReplacement(original: replacement.key, replacement: replacement.value) },
                            onDelete: { replacementManager.removeReplacement(original: replacement.key) }
                        )
                        
                        if replacement.key != filteredReplacements.last?.key {
                            Rectangle()
                                .fill(DarkTheme.textPrimary.opacity(0.1))
                                .frame(height: 1)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
    
    private var filteredVocabularyItems: [DictionaryItem] {
        // Exclude any known sample/example terms from showing in the real list
        let excluded = Set(["Sternocleidomastoid"]) // example-only chip
        let base = dictionaryManager.items.filter { !excluded.contains($0.word) }
        if searchText.isEmpty {
            return base
        } else {
            return base.filter {
                $0.word.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var filteredReplacements: [(key: String, value: String)] {
        let items = replacementManager.replacements.sorted { $0.key < $1.key }
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { 
                $0.key.localizedCaseInsensitiveContains(searchText) || 
                $0.value.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func presentAddModal() {
        showAddModal = true
    }
    
    private func editVocabularyItem(_ item: DictionaryItem) {
        editingReplacement = nil
        editingItem = item
    }
    
    private func editReplacement(original: String, replacement: String) {
        editingItem = nil
        editingReplacement = (original: original, replacement: replacement)
    }
    
    private func removeSampleVocabularyIfPresent() {
        // If the example word was accidentally saved previously, remove it once.
        let sampleWord = "Sternocleidomastoid"
        if dictionaryManager.items.contains(where: { $0.word == sampleWord }) {
            dictionaryManager.removeWord(sampleWord)
        }
    }
}

struct VocabularyRow: View {
    let item: DictionaryItem
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggle: () -> Void
    @State private var isHovered = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        HStack(spacing: 12) {
            Text(item.word)
                .font(.system(size: 12.5, weight: .medium))
                .foregroundColor(item.isEnabled ? DarkTheme.textPrimary : DarkTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            HStack(spacing: 12) {
AddNewButton(localizationManager.localizedString("general.edit"), action: onEdit, systemImage: "")
                    .opacity(isHovered ? 1.0 : 0.7)
                
                /* Removed toggle button as requested */
                /* Button(action: onToggle) {
                    Image(systemName: item.isEnabled ? "checkmark.circle" : "circle")
                        .font(.system(size: 16))
                        .foregroundColor(item.isEnabled ? DarkTheme.textPrimary : DarkTheme.textSecondary)
                }
                .buttonStyle(.borderless)
                .help(item.isEnabled ? localizationManager.localizedString("dictionary.disable_word") : localizationManager.localizedString("dictionary.enable_word")) */
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
                .help(localizationManager.localizedString("dictionary.delete_word"))
                .opacity(isHovered ? 1.0 : 0.6)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.thinMaterial.opacity(isHovered ? 0.8 : 0.4))
        )
        .opacity(item.isEnabled ? 1.0 : 0.6)
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hover
            }
        }
    }
}

struct DictionaryReplacementRow: View {
    let original: String
    let replacement: String
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var isHovered = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Text(original)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundColor(DarkTheme.textSecondary)
                
                Text(replacement)
                    .font(.system(size: 12.5))
                    .foregroundColor(DarkTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                AddNewButton(localizationManager.localizedString("general.edit"), action: onEdit, systemImage: "")
                    .opacity(isHovered ? 1.0 : 0.7)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
                .help(localizationManager.localizedString("dictionary.delete_replacement"))
                .opacity(isHovered ? 1.0 : 0.6)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.thinMaterial.opacity(isHovered ? 0.8 : 0.4))
        )
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hover
            }
        }
    }
}

struct AddItemModal: View {
    let selectedTab: DictionarySettingsView.DictionaryTab
    let dictionaryManager: DictionaryManager
    let replacementManager: WordReplacementManager
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var inputText = ""
    @State private var replacementText = ""
    @State private var isReplacement = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(localizationManager.localizedString("general.cancel")) {
                    dismiss()
                }
                .buttonStyle(.borderless)
                .foregroundColor(.red)
                
                Spacer()
                
                if selectedTab != .replacements {
                    Text(localizationManager.localizedString("dictionary.add_to_vocabulary"))
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Spacer()
                
                AddNewButton(
                    localizationManager.localizedString("dictionary.add_word"),
                    action: addItem,
                    isEnabled: selectedTab == .replacements ? (!inputText.isEmpty && !replacementText.isEmpty) : !inputText.isEmpty
                )
            }
            .padding()
            .background(.regularMaterial)
            
            Rectangle()
                .fill(DarkTheme.textPrimary.opacity(0.1))
                .frame(height: 1)
            
            // Content
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    if selectedTab == .replacements {
                        // Voice Shortcuts: always replacement, hide toggle
                        HStack(spacing: 12) {
                            TextField(localizationManager.localizedString("dictionary.misspelling_placeholder"), text: $inputText)
                                .textFieldStyle(.roundedBorder)
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(DarkTheme.textSecondary)
                            
                            TextField(localizationManager.localizedString("dictionary.correct_spelling_placeholder"), text: $replacementText)
                                .textFieldStyle(.roundedBorder)
                        }
                    } else {
                        // Personal Terms (Vocabulary): simple add-one-field, no replacement toggle
                        TextField(localizationManager.localizedString("dictionary.add_word_placeholder"), text: $inputText)
                            .textFieldStyle(.roundedBorder)
                            .onAppear { isReplacement = false }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(width: 480, height: selectedTab == .replacements ? 160 : 160)
        .background(.thinMaterial)
        .cornerRadius(16)
        .onAppear {
            // Default to replacement when opened from Voice Shortcuts tab
            if selectedTab == .replacements { isReplacement = true }
        }
    }
    
    private func addItem() {
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        if selectedTab == .replacements || isReplacement {
            let trimmedReplacement = replacementText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedReplacement.isEmpty else { return }
            replacementManager.addReplacement(original: trimmedInput, replacement: trimmedReplacement)
        } else {
            dictionaryManager.addWord(trimmedInput)
        }
        
        dismiss()
    }
}

struct EditVocabularyModal: View {
    let item: DictionaryItem
    let dictionaryManager: DictionaryManager
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var editText: String
    
    init(item: DictionaryItem, dictionaryManager: DictionaryManager) {
        self.item = item
        self.dictionaryManager = dictionaryManager
        self._editText = State(initialValue: item.word)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(localizationManager.localizedString("dictionary.edit_word"))
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
            }
            .padding()
            .background(.regularMaterial)
            
            Rectangle()
                .fill(DarkTheme.textPrimary.opacity(0.1))
                .frame(height: 1)
            
            VStack(spacing: 20) {
                TextField(localizationManager.localizedString("dictionary.word_placeholder"), text: $editText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14))
                
                HStack(spacing: 12) {
                    AddNewButton(localizationManager.localizedString("general.cancel"), action: { dismiss() }, backgroundColor: .red, systemImage: "")
                    
                    AddNewButton(localizationManager.localizedString("dictionary.save_changes"), action: saveChanges, isEnabled: !editText.isEmpty)
                }
            }
            .padding()
        }
        .frame(width: 300, height: 150)
        .background(.thinMaterial)
        .cornerRadius(16)
    }
    
    private func saveChanges() {
        let trimmedText = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty && trimmedText != item.word else {
            dismiss()
            return
        }
        
        dictionaryManager.removeWord(item.word)
        dictionaryManager.addWord(trimmedText)
        dismiss()
    }
}

struct EditReplacementModal: View {
    let original: String
    let replacement: String
    let replacementManager: WordReplacementManager
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var editOriginal: String
    @State private var editReplacement: String
    
    init(original: String, replacement: String, replacementManager: WordReplacementManager) {
        self.original = original
        self.replacement = replacement
        self.replacementManager = replacementManager
        self._editOriginal = State(initialValue: original)
        self._editReplacement = State(initialValue: replacement)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(localizationManager.localizedString("dictionary.edit_replacement"))
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
            }
            .padding()
            .background(.regularMaterial)
            
            Rectangle()
                .fill(DarkTheme.textPrimary.opacity(0.1))
                .frame(height: 1)
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    TextField(localizationManager.localizedString("dictionary.original_placeholder"), text: $editOriginal)
                        .textFieldStyle(.roundedBorder)
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(DarkTheme.textSecondary)
                    
                    TextField(localizationManager.localizedString("dictionary.replacement_placeholder"), text: $editReplacement)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack(spacing: 12) {
                    AddNewButton(localizationManager.localizedString("general.cancel"), action: { dismiss() }, backgroundColor: .red, systemImage: "")
                    
                    AddNewButton(localizationManager.localizedString("dictionary.save_changes"), action: saveChanges, isEnabled: !editOriginal.isEmpty && !editReplacement.isEmpty)
                }
            }
            .padding()
        }
        .frame(width: 400, height: 150)
        .background(.thinMaterial)
        .cornerRadius(16)
    }
    
    private func saveChanges() {
        let trimmedOriginal = editOriginal.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedReplacement = editReplacement.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedOriginal.isEmpty && !trimmedReplacement.isEmpty else {
            dismiss()
            return
        }
        
        replacementManager.removeReplacement(original: original)
        replacementManager.addReplacement(original: trimmedOriginal, replacement: trimmedReplacement)
        dismiss()
    }
}

struct EmptyVocabularyView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "textformat.abc")
                .font(.system(size: 40))
                .foregroundColor(DarkTheme.textSecondary.opacity(0.6))
            
            Text(localizationManager.localizedString("dictionary.no_vocabulary_words"))
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DarkTheme.textPrimary)
            
            Text(localizationManager.localizedString("dictionary.vocabulary_help_text"))
                .font(.system(size: 14))
                .foregroundColor(DarkTheme.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        // .background(
        //     RoundedRectangle(cornerRadius: 12)
        //         .fill(DarkTheme.textPrimary.opacity(0.1))
        // )
    }
}

struct EmptyReplacementsView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.2.squarepath")
                .font(.system(size: 40))
                .foregroundColor(DarkTheme.textSecondary.opacity(0.6))
            
            Text(localizationManager.localizedString("dictionary.no_word_replacements"))
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DarkTheme.textPrimary)
            
            Text(localizationManager.localizedString("dictionary.replacements_help_text"))
                .font(.system(size: 14))
                .foregroundColor(DarkTheme.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        // .background(
        //     RoundedRectangle(cornerRadius: 12)
        //         .fill(DarkTheme.textPrimary.opacity(0.1))
        // )
    }
}

struct ToggleTabButton: View {
    let tab: DictionarySettingsView.DictionaryTab
    let isSelected: Bool
    let isFirst: Bool
    let isLast: Bool
    let action: () -> Void
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 13))
                Text(getLocalizedTabName())
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? DarkTheme.textPrimary : DarkTheme.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .background(
                Rectangle()
                    .fill(isSelected ? DarkTheme.textPrimary.opacity(0.15) : Color.clear)
            )
            .overlay(
                Rectangle()
                    .fill(DarkTheme.textPrimary.opacity(0.2))
                    .frame(width: 1)
                    .opacity(isLast ? 0 : 1),
                alignment: .trailing
            )
        }
        .buttonStyle(.plain)
    }
    
    private func getLocalizedTabName() -> String {
        switch tab {
        case .vocabulary:
            return localizationManager.localizedString("dictionary.vocabulary")
        case .replacements:
            return localizationManager.localizedString("dictionary.replacements")
        }
    }
}
