import SwiftUI
import AppKit
import SwiftData
import KeyboardShortcuts

// ViewType enum with all cases
enum ViewType: String, CaseIterable {
    case home = "Home"
    case aiModels = "AI Models"
    // case metrics = "Dashboard"
    // case record = "Record Audio"
    // COMMENTED OUT: Transcribe Audio sidebar item - replace with your own features
    // case transcribeAudio = "Transcribe Audio"
    // case models = "Models" // Disabled for proxy architecture
    // case enhancement = "Prompts"
//    case powerMode = "AI Enhancement"
    // case permissions = "Permissions"
    // case audioInput = "Audio Input"

    // Personalization subpages
    case personalizationEditingStrength = "Personalization_EditingStrength"
    case personalizationVocabulary = "Personalization_Vocabulary"
    case personalizationReplacements = "Personalization_Replacements"
    case personalizationSnippets = "Personalization_Snippets"

    case settings = "Settings"
    // case profile = "Profile"
    case license = "License"
    
    var localizedName: String {
        switch self {
        case .home: return NSLocalizedString("Home", comment: "")
        case .aiModels: return NSLocalizedString("AI Models", comment: "")
        // case .models: return NSLocalizedString("speech.models.title", comment: "") // Disabled for proxy architecture
//        case .powerMode: return NSLocalizedString("enhance.mode.title", comment: "")
        case .personalizationEditingStrength: return NSLocalizedString("navigation.ai_editing_strength", comment: "")
        case .personalizationVocabulary: return NSLocalizedString("dictionary.vocabulary", comment: "")
        case .personalizationReplacements: return NSLocalizedString("dictionary.replacements", comment: "")
        case .personalizationSnippets: return NSLocalizedString("navigation.snippets", comment: "")
        case .settings: return NSLocalizedString("settings.title", comment: "")
        case .license: return NSLocalizedString("Plan", comment: "")
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "macbook"
        case .aiModels: return "brain"
        // case .metrics: return "gauge.medium"
        // case .record: return "mic.circle.fill"
        // case .transcribeAudio: return "waveform.circle.fill"
        // case .models: return "brain.head.profile.fill" // Disabled for proxy architecture
        // case .enhancement: return "text.quote"
//        case .powerMode: return "circle.lefthalf.striped.horizontal"
        // case .permissions: return "shield.fill"
        // case .audioInput: return "mic.fill"
        case .personalizationEditingStrength: return "wand.and.stars"
        case .personalizationVocabulary: return "textformat.abc"
        case .personalizationReplacements: return "arrow.2.squarepath"
        case .personalizationSnippets: return "text.badge.plus"
        case .settings: return "gearshape"
        // case .profile: return "person.circle.fill"
        case .license: return "envelope"
        }
    }
}

struct AIModelsView: View {
    @State private var selectedCategory: ModelCategory = .llm
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                PageHeaderView(
                    title: "AI Models",
                    subtitle: "Connect Groq, Gemini, and Soniox directly with your own API keys—nothing routes through our proxy."
                )
                .padding(.top, 40)
                
                overviewCard
                providerSwitcherSection
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    private var overviewCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(Color.accentColor.opacity(0.12))
                        )
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Connect once, keep it local")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                        Text("Keys live in the macOS Keychain and never leave your device. Swap providers or rotate credentials whenever you need.")
                            .font(.system(size: 14))
                            .foregroundColor(DarkTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                HStack(spacing: 12) {
                    AddNewButton(
                        "Groq Dashboard",
                        action: { openPortal("https://console.groq.com/keys") },
                        backgroundColor: DarkTheme.surfaceBackground,
                        textColor: DarkTheme.textPrimary,
                        systemImage: "link"
                    )
                    AddNewButton(
                        "Soniox Dashboard",
                        action: { openPortal("https://soniox.com/dashboard/api-keys") },
                        backgroundColor: DarkTheme.surfaceBackground,
                        textColor: DarkTheme.textSecondary,
                        systemImage: "link"
                    )
                    AddNewButton(
                        "Google AI Studio",
                        action: { openPortal("https://aistudio.google.com/app/apikey") },
                        backgroundColor: DarkTheme.surfaceBackground,
                        textColor: DarkTheme.textPrimary,
                        systemImage: "sparkles"
                    )
                    Spacer()
                }
            }
        }
    }
    
    private var providerSwitcherSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Provider Keys")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DarkTheme.textSecondary)
                .textCase(.uppercase)
                .padding(.top, 4)
            
            categoryTabs
            
            VStack(spacing: 16) {
                if selectedCategory == .llm {
                    GroqAPIConfigurationSection()
                    GeminiAPIConfigurationSection()
                } else {
                    SonioxAPIConfigurationSection()
                }
            }
        }
    }
    
    private var categoryTabs: some View {
        HStack(spacing: 12) {
            ForEach(ModelCategory.allCases, id: \.self) { category in
                Button {
                    selectedCategory = category
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.rawValue)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(category == selectedCategory ? DarkTheme.textPrimary : DarkTheme.textSecondary)
                        Text(category.subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(category == selectedCategory ? DarkTheme.surfaceBackground.opacity(0.95) : DarkTheme.surfaceBackground.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(category == selectedCategory ? Color.accentColor.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                    .animation(.easeInOut(duration: 0.2), value: selectedCategory)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func openPortal(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
    
    private enum ModelCategory: String, CaseIterable {
        case llm = "Language Models"
        case voice = "Voice Models"
        
        var subtitle: String {
            switch self {
            case .llm:
                return "Configure Groq + Gemini keys and models."
            case .voice:
                return "Control Soniox streaming for ASR."
            }
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        visualEffectView.isEmphasized = true
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        visualEffectView.isEmphasized = true
    }
}

struct DynamicSidebar: View {
    @Binding var selectedView: ViewType
    @Binding var hoveredView: ViewType?
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @ObservedObject private var licenseViewModel = LicenseViewModel.shared
    @ObservedObject private var userProfile = UserProfileService.shared
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject var updaterViewModel: UpdaterViewModel
    @Namespace private var buttonAnimation

    @State private var isPersonalizationExpanded: Bool = true
    @AppStorage("UseLocalModel") private var storedUseLocalModel: Bool = false
    @AppStorage("streamingTranscriptEnabled") private var streamingTranscriptEnabled: Bool = false
    @State private var offlineToggleState: Bool = false
    @State private var isOfflineActionInFlight = false
    @State private var showOfflineSetup = false

    private let defaultOfflineModelName = "ggml-large-v3-turbo-q5_0"

    var body: some View {
        VStack(spacing: 0) {
            // CLIO Banner
            VStack(spacing: 12) {
                // Banner Image with minimal padding
                Image("clio-banner")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                
                // Status Badge (Pro / Trial / Free)
                HStack {
                    Spacer()
                    statusBadge
                    Spacer()
                }
            }
            .padding(.bottom, 24)
            
// Navigation Items
        VStack(spacing: 4) {
            // Home
            DynamicSidebarButton(
                title: getLocalizedTitle(for: .home),
                systemImage: ViewType.home.icon,
                isSelected: selectedView == .home,
                isHovered: hoveredView == .home,
                namespace: buttonAnimation
            ) {
                selectedView = .home
            }
            .onHover { isHovered in
                hoveredView = isHovered ? .home : nil
            }
            
            DynamicSidebarButton(
                title: getLocalizedTitle(for: .aiModels),
                systemImage: ViewType.aiModels.icon,
                isSelected: selectedView == .aiModels,
                isHovered: hoveredView == .aiModels,
                namespace: buttonAnimation
            ) {
                selectedView = .aiModels
            }
            .onHover { isHovered in
                hoveredView = isHovered ? .aiModels : nil
            }

            // Personalization group header
                Button(action: { withAnimation { isPersonalizationExpanded.toggle() } }) {
                    HStack(spacing: 10) {
                        Image(systemName: "person.fill.viewfinder")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 18, height: 18)
                        Text(localizationManager.localizedString("navigation.personalization"))
                            .fontScaled(size: 12, weight: .medium)
                        Spacer()
                    }
                    .foregroundColor(DarkTheme.textPrimary)
                    .frame(height: 28)
                    .padding(.leading, 6)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)

                if isPersonalizationExpanded {
                    VStack(spacing: 2) {
                DynamicSidebarButton(
                    title: getLocalizedTitle(for: .personalizationEditingStrength),
                    systemImage: "",
                    isSelected: selectedView == .personalizationEditingStrength,
                    isHovered: hoveredView == .personalizationEditingStrength,
                    namespace: buttonAnimation
                ) {
                            selectedView = .personalizationEditingStrength
                        }
                        .onHover { isHovered in
                            hoveredView = isHovered ? .personalizationEditingStrength : nil
                        }
                        .padding(.leading, 12)

                DynamicSidebarButton(
                    title: getLocalizedTitle(for: .personalizationVocabulary),
                    systemImage: "",
                    isSelected: selectedView == .personalizationVocabulary,
                    isHovered: hoveredView == .personalizationVocabulary,
                    namespace: buttonAnimation
                ) {
                            selectedView = .personalizationVocabulary
                        }
                        .onHover { isHovered in
                            hoveredView = isHovered ? .personalizationVocabulary : nil
                        }
                        .padding(.leading, 12)

                        DynamicSidebarButton(
                            title: getLocalizedTitle(for: .personalizationReplacements),
                            systemImage: "",
                            isSelected: selectedView == .personalizationReplacements,
                            isHovered: hoveredView == .personalizationReplacements,
                            namespace: buttonAnimation
                        ) {
                            selectedView = .personalizationReplacements
                        }
                        .onHover { isHovered in
                            hoveredView = isHovered ? .personalizationReplacements : nil
                        }
                        .padding(.leading, 12)

                        DynamicSidebarButton(
                            title: getLocalizedTitle(for: .personalizationSnippets),
                            systemImage: "",
                            isSelected: selectedView == .personalizationSnippets,
                            isHovered: hoveredView == .personalizationSnippets,
                            namespace: buttonAnimation
                        ) {
                            selectedView = .personalizationSnippets
                        }
                        .onHover { isHovered in
                            hoveredView = isHovered ? .personalizationSnippets : nil
                        }
                        .padding(.leading, 12)
                    }
                }

                // Settings
                DynamicSidebarButton(
                    title: getLocalizedTitle(for: .settings),
                    systemImage: ViewType.settings.icon,
                    isSelected: selectedView == .settings,
                    isHovered: hoveredView == .settings,
                    namespace: buttonAnimation
                ) {
                    selectedView = .settings
                }
                .onHover { isHovered in
                    hoveredView = isHovered ? .settings : nil
                }

                // Plan
                DynamicSidebarButton(
                    title: getLocalizedTitle(for: .license),
                    systemImage: ViewType.license.icon,
                    isSelected: selectedView == .license,
                    isHovered: hoveredView == .license,
                    namespace: buttonAnimation
                ) {
                    selectedView = .license
                }
                .onHover { isHovered in
                    hoveredView = isHovered ? .license : nil
                }
            }
            .padding(.horizontal, 4)
            
            Spacer()
            
            // Bottom section: Different for free vs pro users
            VStack(spacing: 12) {
                offlineModeSection

                HStack {
                    Spacer()
                    UpdateStatusBadge(updaterViewModel: updaterViewModel)
                    Spacer()
                }
            }
            .padding(.bottom, 16)
            .onAppear {
                syncOfflineToggleWithPreference()
            }
            .onChange(of: storedUseLocalModel) { _, newValue in
                guard !isOfflineActionInFlight else { return }
                isOfflineActionInFlight = true
                offlineToggleState = newValue
                isOfflineActionInFlight = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var offlineModeSection: some View {
        HStack {
            Spacer(minLength: 0)
            SidebarToggleCard(
                iconName: offlineToggleState ? "internaldrive" : "antenna.radiowaves.left.and.right",
                title: "Offline Mode",
                isProcessing: isOfflineActionInFlight,
                isOn: offlineToggleBinding
            )
            Spacer(minLength: 0)
        }
        .sheet(isPresented: $showOfflineSetup) {
            OfflineModelDownloadSheet(
                defaultModel: defaultOfflinePredefinedModel,
                isPresented: $showOfflineSetup,
                onDownloadConfirmed: { model in
                    Task { await startOfflineDownload(for: model) }
                }
            )
        }
    }

    private func getLocalizedTitle(for viewType: ViewType) -> String {
        switch viewType {
        case .home: return localizationManager.localizedString("navigation.home")
        case .aiModels: return "AI Models"
        case .personalizationEditingStrength: return localizationManager.localizedString("navigation.ai_editing_strength")
        case .personalizationVocabulary: return localizationManager.localizedString("navigation.vocabulary")
        case .personalizationReplacements: return localizationManager.localizedString("dictionary.replacements")
        case .personalizationSnippets: return localizationManager.localizedString("navigation.snippets")
        case .settings: return localizationManager.localizedString("navigation.settings")
        case .license: return localizationManager.localizedString("navigation.license")
        }
    }
    
    
    @ViewBuilder
    private var statusBadge: some View {
        Text("COMMUNITY")
            .font(.system(size: 9, weight: .heavy))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(DarkTheme.accent)
                    .shadow(color: DarkTheme.accent.opacity(0.3), radius: 2, x: 0, y: 1)
            )
    }

    private var offlineToggleBinding: Binding<Bool> {
        Binding(
            get: { offlineToggleState },
            set: { newValue in
                if isOfflineActionInFlight {
                    offlineToggleState = newValue
                    return
                }
                offlineToggleState = newValue
                Task {
                    await handleOfflineToggleChange(newValue)
                }
            }
        )
    }

    private var defaultOfflinePredefinedModel: PredefinedModel? {
        PredefinedModels.models.first(where: { $0.name == defaultOfflineModelName })
    }

    private var availableLocalModels: [WhisperModel] {
        whisperState.availableModels.filter { $0.url.isFileURL }
    }

    private func preferredLocalModel(named preferredName: String? = nil) -> WhisperModel? {
        if let preferredName,
           let explicit = availableLocalModels.first(where: { $0.name == preferredName }) {
            return explicit
        }
        if let preferred = availableLocalModels.first(where: { $0.name == defaultOfflineModelName }) {
            return preferred
        }
        return availableLocalModels.first
    }

    private func syncOfflineToggleWithPreference() {
        isOfflineActionInFlight = true
        if storedUseLocalModel && preferredLocalModel() == nil {
            storedUseLocalModel = false
            offlineToggleState = false
        } else {
            offlineToggleState = storedUseLocalModel
        }
        isOfflineActionInFlight = false
    }

    @MainActor
    private func handleOfflineToggleChange(_ enabled: Bool) async {
        guard !isOfflineActionInFlight else { return }
        isOfflineActionInFlight = true
        defer { isOfflineActionInFlight = false }

        if enabled {
            await enableOfflineMode()
        } else {
            await disableOfflineMode()
        }
    }

    @MainActor
    private func enableOfflineMode(preferredName: String? = nil) async {
        // Refresh available local models from disk in case user deleted files
        whisperState.loadAvailableModels()

        if let model = preferredLocalModel(named: preferredName),
           FileManager.default.fileExists(atPath: model.url.path) {
            storedUseLocalModel = true
            streamingTranscriptEnabled = false
            // Backup current dictation language preferences (cloud) and switch to Auto for offline
            backupCloudLanguagePreferences()
            setDictationLanguageToAuto()
            // Turn off Notch Transcript when going offline (no streaming UI while offline)
            // but remember previous state to restore when returning to cloud.
            let previous = (UserDefaults.standard.object(forKey: "NotchTranscriptEnabled") as? Bool) ?? true
            UserDefaults.standard.set(previous, forKey: "NotchTranscriptEnabled.prev")
            UserDefaults.standard.set(false, forKey: "NotchTranscriptEnabled")
            whisperState.notchWindowManager?.applyBottomTranscriptPreference(false)
            await whisperState.setDefaultModel(model)
            WarmupCoordinator.shared.setCloudWarmupEnabled(false)
            return
        }

        // No local model available – show custom sheet and revert toggle
        storedUseLocalModel = false
        offlineToggleState = false
        showOfflineSetup = true
    }

    @MainActor
    private func disableOfflineMode() async {
        storedUseLocalModel = false
        await whisperState.unloadCurrentModel()
        whisperState.activateStreamingMode()
        streamingTranscriptEnabled = true
        // Restore user's cloud language preferences if a backup exists
        restoreCloudLanguagePreferencesIfAvailable()
        WarmupCoordinator.shared.setCloudWarmupEnabled(true)
        // Restore Notch Transcript preference when coming back online
        let hadPrev = UserDefaults.standard.object(forKey: "NotchTranscriptEnabled.prev") != nil
        let restoreValue = (UserDefaults.standard.object(forKey: "NotchTranscriptEnabled.prev") as? Bool) ?? true
        UserDefaults.standard.removeObject(forKey: "NotchTranscriptEnabled.prev")
        if hadPrev {
            UserDefaults.standard.set(restoreValue, forKey: "NotchTranscriptEnabled")
            whisperState.notchWindowManager?.applyBottomTranscriptPreference(restoreValue)
        } else {
            // If no previous record, default to ON for cloud mode
            UserDefaults.standard.set(true, forKey: "NotchTranscriptEnabled")
            whisperState.notchWindowManager?.applyBottomTranscriptPreference(true)
        }
    }

    @MainActor
    private func startOfflineDownload(for model: PredefinedModel) async {
        await whisperState.downloadModel(model, confirm: false)
        // Refresh toggle state if download succeeded
        if preferredLocalModel(named: model.name) != nil {
            isOfflineActionInFlight = true
            offlineToggleState = true
            await enableOfflineMode(preferredName: model.name)
            isOfflineActionInFlight = false
            showOfflineSetup = false
        }
    }

    // MARK: - Language preference helpers
    private func backupCloudLanguagePreferences() {
        let defaults = UserDefaults.standard
        // Backup single-language key
        if let single = defaults.string(forKey: "SelectedLanguage") {
            defaults.set(single, forKey: "SelectedLanguage.cloudBackup")
        } else {
            defaults.removeObject(forKey: "SelectedLanguage.cloudBackup")
        }
        // Backup multi-language key
        if let multi = defaults.data(forKey: "SelectedLanguages") {
            defaults.set(multi, forKey: "SelectedLanguages.cloudBackup")
        } else {
            defaults.removeObject(forKey: "SelectedLanguages.cloudBackup")
        }
    }

    private func setDictationLanguageToAuto() {
        let defaults = UserDefaults.standard
        // Set both representations to Auto so all codepaths see it
        defaults.set("auto", forKey: "SelectedLanguage")
        if let encoded = try? JSONEncoder().encode(Set(["auto"])) {
            defaults.set(encoded, forKey: "SelectedLanguages")
        }
        // Inform UI/menu observers
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
    }

    private func restoreCloudLanguagePreferencesIfAvailable() {
        let defaults = UserDefaults.standard
        var restored = false
        if let multi = defaults.data(forKey: "SelectedLanguages.cloudBackup") {
            defaults.set(multi, forKey: "SelectedLanguages")
            restored = true
        }
        if let single = defaults.string(forKey: "SelectedLanguage.cloudBackup") {
            defaults.set(single, forKey: "SelectedLanguage")
            restored = true
        }
        // Clear backups once restored
        defaults.removeObject(forKey: "SelectedLanguages.cloudBackup")
        defaults.removeObject(forKey: "SelectedLanguage.cloudBackup")
        if restored {
            NotificationCenter.default.post(name: .languageDidChange, object: nil)
        }
    }
}

private struct SidebarToggleCard: View {
    let iconName: String
    let title: String
    let isProcessing: Bool
    let isOn: Binding<Bool>

    var body: some View {
        let isActive = isOn.wrappedValue
        let tint = isActive ? Color.accentColor : DarkTheme.textSecondary.opacity(0.6)

        return HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 7, weight: .semibold))
                .foregroundColor(tint)
                .padding(3)
                .background(
                    Circle()
                        .fill(tint.opacity(0.12))
                )

            Text(title)
                .font(.system(size: 9.5, weight: .semibold))
                .foregroundColor(DarkTheme.textPrimary)
                
            Spacer(minLength: 6)

            if isProcessing {
                ProgressView()
                    .controlSize(.small)
                    .scaleEffect(0.75)
                    .tint(tint)
            } else {
                Toggle("", isOn: isOn)
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .tint(tint)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(DarkTheme.textPrimary.opacity(0.05))
                .overlay(
                    Capsule()
                        .stroke(DarkTheme.textPrimary.opacity(0.12), lineWidth: 0.6)
                )
        )
        .frame(width: 130)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isActive)
    }
}

private struct OfflineModelDownloadSheet: View {
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var localizationManager: LocalizationManager

    let defaultModel: PredefinedModel?
    @Binding var isPresented: Bool
    let onDownloadConfirmed: (PredefinedModel) -> Void

    @State private var selectedModelName: String
    @State private var isDownloading = false
    @State private var currentProgress: Double = 0.0

    init(defaultModel: PredefinedModel?, isPresented: Binding<Bool>, onDownloadConfirmed: @escaping (PredefinedModel) -> Void) {
        self.defaultModel = defaultModel
        self._isPresented = isPresented
        self.onDownloadConfirmed = onDownloadConfirmed
        _selectedModelName = State(initialValue: defaultModel?.name ?? "")
    }

    var body: some View {
        let percent = Int(currentProgress * 100)
        let model = defaultModel

        return StandardModal(
            title: "Clio Offline Mode",
            width: 500,
            height: nil,
            onClose: { if !isDownloading { isPresented = false } },
            primaryButtonTitle: isDownloading ? localizationManager.localizedString("sidebar.offline_mode.sheet.downloading") : "Install",
            primaryButtonAction: { if let model = model, !isDownloading { startDownload(model: model) } },
            isPrimaryButtonEnabled: !isDownloading && model != nil,
            secondaryButtonTitle: localizationManager.localizedString("general.cancel"),
            secondaryButtonAction: { if !isDownloading { isPresented = false } },
            titleFontSize: 18
        ) {
            VStack(spacing: 10) {
                if let icon = NSApp.applicationIconImage {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 36, height: 36)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                        .padding(.top, 8)
                }

                Text("Install once. Go fully offline.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)

                Text("Clio can transcribe on‑device without internet when Offline Mode is on.")
                    .font(.system(size: 12))
                    .foregroundColor(DarkTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)

                if isDownloading {
                    VStack(spacing: 8) {
                        ProgressView(value: currentProgress)
                            .progressViewStyle(.linear)
                            .frame(maxWidth: .infinity)
                        Text(String(format: localizationManager.localizedString("sidebar.offline_mode.sheet.progress"), percent))
                            .font(.caption.monospacedDigit())
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .onAppear {
            selectedModelName = defaultModel?.name ?? selectedModelName
        }
        .onReceive(whisperState.$downloadProgress) { progress in
            guard isDownloading, let model = defaultModel else { return }
            let mainKey = model.name + "_main"
            let coreKey = model.name + "_coreml"
            let mainProgress = progress[mainKey] ?? 0
            let coreProgress = progress[coreKey] ?? 0
            let combined = max(mainProgress, coreProgress)
            let hasActiveDownload = progress.keys.contains(mainKey) || progress.keys.contains(coreKey)
            if hasActiveDownload {
                currentProgress = combined
            } else if currentProgress > 0 {
                currentProgress = 1.0
            }
        }
        .onChange(of: isPresented) { _, newValue in
            if !newValue {
                isDownloading = false
                currentProgress = 0
            }
        }
    }

    private func startDownload(model: PredefinedModel) {
        isDownloading = true
        currentProgress = 0
        onDownloadConfirmed(model)
    }
}

struct DynamicSidebarButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let isHovered: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
            if !systemImage.isEmpty {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 18, height: 18)
            }
                
                Text(title)
                    .fontScaled(size: 12, weight: .medium)
                    .lineLimit(1)
                Spacer()
            }
            .foregroundColor(isSelected ? DarkTheme.textPrimary : (isHovered ? DarkTheme.textPrimary : DarkTheme.textPrimary))
            .frame(height: 32)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 6)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? DarkTheme.textPrimary.opacity(0.15) : Color.black.opacity(0.1))
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    } else if isHovered {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? DarkTheme.textPrimary.opacity(0.08) : Color.black.opacity(0.05))
                    }
                }
            )
            .padding(.horizontal, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var updaterViewModel: UpdaterViewModel
    // @EnvironmentObject private var userViewModel: UserViewModel
    @State private var selectedView: ViewType = .home
    @State private var hoveredView: ViewType?
    @State private var hasLoadedData = false
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    @ObservedObject private var licenseViewModel = LicenseViewModel.shared
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    
    // Global dialog states for subscription-related dialogs
    @State private var showFlashDownloadDialog = false
    @State private var showRecordingFailedDialog = false
    @State private var recordingFailedModelName = ""
    @State private var showFeedbackModal = false
    
    private var isSetupComplete: Bool {
        hasLoadedData &&
        whisperState.currentModel != nil &&
        KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) != nil &&
        AXIsProcessTrusted() &&
        CGPreflightScreenCaptureAccess()
    }
    
    // Helper function to determine if a language uses RTL layout
    private func isRTLLanguage(_ languageCode: String) -> Bool {
        let rtlLanguages = ["ar", "he", "fa", "ur", "ps", "sd", "ckb", "dv"]
        return rtlLanguages.contains(languageCode)
    }

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            DynamicSidebar(
                selectedView: $selectedView,
                hoveredView: $hoveredView,
                updaterViewModel: updaterViewModel
            )
            .frame(width: 200)
            .navigationSplitViewColumnWidth(200)
            .background(.ultraThinMaterial)
            .environment(\.locale, Locale(identifier: localizationManager.currentLanguage))

        } detail: {
            ZStack {
                // TEMP: toggle to test if vibrancy seam is causing the line
                let useSolidBackground = false // set true to test quickly
                Group {
                    if useSolidBackground {
                        Color(.windowBackgroundColor)
                    } else {
                        VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)
                    }
                }
                .ignoresSafeArea()
                
                detailView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
                    // Ensure any implicit toolbars are hidden to avoid top separators
                    .toolbar(.hidden, for: .automatic)
                    .navigationTitle("")
                    // DEBUG: 1px probe at the top edge of content; compare with gray line position
                    // #if DEBUG
                    // .overlay(alignment: .top) {
                    //     Color.red.opacity(0.7).frame(height: 1).allowsHitTesting(false)
                    // }
                    // #endif
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 1000, minHeight: 550)
        // Hide the window toolbar background to remove baseline while keeping traffic lights
        .toolbarBackground(.hidden, for: .windowToolbar)
        .environment(\.layoutDirection, isRTLLanguage(localizationManager.currentLanguage) ? .rightToLeft : .leftToRight)
        .id(localizationManager.currentLanguage) // Force re-render on language change
        .onAppear {
            hasLoadedData = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToDestinationInternal)) { notification in
            print("ContentView: Received navigation notification")
            if let destination = notification.userInfo?["destination"] as? String {
                print("ContentView: Destination received: \(destination)")
                // Window activation is now handled by AppDelegate
                switch destination {
                case "Settings":
                    print("ContentView: Navigating to Settings")
                    selectedView = .settings
                case "Dictionary":
                    print("ContentView: Navigating to Dictionary")
                    selectedView = .personalizationVocabulary
//                case "AI Models":
//                    print("ContentView: Navigating to AI Models")
//                    selectedView = .models
                case "Clio Pro":
                    print("ContentView: Navigating to Clio Pro")
                    selectedView = .license
                // Removed Home routing from menu; keep case for potential internal calls
                case "Home":
                    print("ContentView: Navigating to Home")
                    selectedView = .home
                // case "Permissions":
                //     print("ContentView: Navigating to Permissions")
                //     selectedView = .permissions
                // case "Enhancement":
                //     print("ContentView: Navigating to Enhancement")
                //     selectedView = .enhancement
                default:
                    print("ContentView: No matching destination found for: \(destination)")
                    break
                }
            } else {
                print("ContentView: No destination in notification")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showRecordingFailedDialog)) { notification in
            if let modelName = notification.userInfo?["modelName"] as? String {
                recordingFailedModelName = modelName
                showRecordingFailedDialog = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showFeedbackModalInternal)) { _ in
            // Window activation is now handled by AppDelegate
            showFeedbackModal = true
        }
        // Global subscription dialog overlays
        .overlay {
            if showFlashDownloadDialog {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showFlashDownloadDialog = false
                    }
            }
        }
        .overlay {
            if showFlashDownloadDialog {
                FlashModelDownloadDialog(
                    isPresented: $showFlashDownloadDialog,
                    onDownload: {
                        downloadFlashModel()
                    },
                    onUpgrade: {
                        subscriptionManager.promptUpgrade(from: "global_flash_download_dialog")
                    },
                    onCancel: {
                        // Do nothing - just close
                    }
                )
                .environmentObject(localizationManager)
            }
        }
        .overlay {
            if showRecordingFailedDialog {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showRecordingFailedDialog = false
                    }
            }
        }
        .overlay {
            if showRecordingFailedDialog {
                RecordingFailedDialog(
                    isPresented: $showRecordingFailedDialog,
                    modelName: recordingFailedModelName,
                    onDownload: {
                        downloadFlashModel()
                    },
                    onUpgrade: {
                        subscriptionManager.promptUpgrade(from: "global_recording_failed_dialog")
                    },
                    onCancel: {
                        // Do nothing - just close
                    }
                )
                .environmentObject(localizationManager)
            }
        }
        // Feedback Modal
        .sheet(isPresented: $showFeedbackModal) {
            FeedbackView()
                .environmentObject(localizationManager)
        }
    }
    
    // Download and switch to Flash model with permission
    private func downloadFlashModel() {
        // Find Clio Flash (ggml-small) model
        if let freeModel = whisperState.predefinedModels.first(where: { $0.name == "ggml-small" }) {
            print("🔄 Auto-switching to free model: \(freeModel.displayName)")
            
            // Check if it's downloaded
            if let downloadedModel = whisperState.availableModels.first(where: { $0.name == "ggml-small" }) {
                Task {
//                    await whisperState.setDefaultModel(downloadedModel)
                    print("✅ Successfully switched to free model: \(freeModel.displayName)")
                }
            } else {
                // Auto-download free model if not available
                print("📥 Free model not downloaded, auto-downloading...")
                Task {
//                    await whisperState.downloadModel(freeModel)
                    
                    // Wait for download to complete and then set as default
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if let downloadedModel = whisperState.availableModels.first(where: { $0.name == "ggml-small" }) {
                            Task {
//                                await whisperState.setDefaultModel(downloadedModel)
                                print("✅ Successfully downloaded and switched to free model: \(freeModel.displayName)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selectedView {
        case .home:
            TranscriptionHistoryView()
        case .aiModels:
            AIModelsView()
        // case .metrics:
        //     MetricsView(skipSetupCheck: true)
        // case .models: // Disabled for proxy architecture
        //     ModelManagementView(whisperState: whisperState)
        // case .enhancement:
        //     EnhancementSettingsView()
        // case .record:
        //     RecordView()
        // case .transcribeAudio:
        //     AudioTranscribeView()
        // case .audioInput:
        //     AudioInputSettingsView()
        case .personalizationEditingStrength:
            AIEditingStrengthView()
                .environmentObject(localizationManager)
        case .personalizationVocabulary:
            DictionarySettingsView(whisperPrompt: whisperState.whisperPrompt, initialTab: .vocabulary)
        case .personalizationReplacements:
            DictionarySettingsView(whisperPrompt: whisperState.whisperPrompt, initialTab: .replacements)
        case .personalizationSnippets:
            SnippetsView()
                .environmentObject(localizationManager)
        // PowerMode removed
        case .settings:
            SettingsView()
                .environmentObject(whisperState)
        // case .profile:
        //     ProfileView()
        case .license:
            LicensePageView()
        // case .permissions:
        //     PermissionsView()
        }
    }
}
