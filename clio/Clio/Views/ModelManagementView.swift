import SwiftUI
import SwiftData

#if CLIO_ENABLE_LOCAL_MODEL

struct ModelManagementView: View {
    @ObservedObject var whisperState: WhisperState
    @State private var modelToDelete: WhisperModel?
    @StateObject private var aiService = AIService()
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var whisperPrompt = WhisperPrompt()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var hoveredModelId: UUID? = nil
    @State private var showLanguageSettings = false
    @Namespace private var namespace
    @AppStorage("SelectedLanguage") private var selectedLanguage: String = "en"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with description
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(localizationManager.localizedString("models.library_title"))
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        Spacer()
                    }
                    
                    Text(String(format: localizationManager.localizedString("models.library_subtitle"), whisperState.predefinedModels.count))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 32) {
                    if showLanguageSettings {
                        languageSection
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    }
                    
                    modelsGridSection
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onReceive(subscriptionManager.$currentTier) { tier in
            handleSubscriptionChange(tier: tier)
        }
        .onReceive(subscriptionManager.$isInTrial) { isInTrial in
            handleTrialStatusChange(isInTrial: isInTrial)
        }
        .frame(minWidth: 700, minHeight: 600)
        .alert(item: $modelToDelete) { model in
            Alert(
                title: Text(localizationManager.localizedString("models.delete.title")),
                message: Text(String(format: localizationManager.localizedString("models.delete.confirmation"), model.name)),
                primaryButton: .destructive(Text(localizationManager.localizedString("general.delete"))) {
                    Task {
                        await whisperState.deleteModel(model)
                    }
                },
                secondaryButton: .cancel(Text(localizationManager.localizedString("general.cancel")))
            )
        }
        .alert(item: $whisperState.currentError) { error in
            Alert(
                title: Text("Download Failed"),
                message: Text(error.errorDescription ?? "An error occurred"),
                dismissButton: .default(Text("OK")) {
                    whisperState.currentError = nil
                }
            )
        }
    }
    
    private var heroSection: some View {
        // Main content in single glass card
        compactHeroCard
            .padding(.horizontal, 40)
            .padding(.vertical, 40)
            .frame(maxWidth: .infinity)
    }
    
    private var glassMorphismBackground: some View {
        ZStack {
            // Base subtle gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.02),
                    DarkTheme.textPrimary.opacity(0.08),
                    Color.black.opacity(0.01)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Noise texture effect
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        }
    }
    
    private var compactHeroCard: some View {
        HStack(alignment: .top, spacing: 32) {
            // Model info (left side)
            VStack(alignment: .leading, spacing: 16) {
                // Header with status indicator
                HStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 8, height: 8)
                        .shadow(color: .green.opacity(0.3), radius: 4)
                    
                    Text(localizationManager.localizedString("models.active_model"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DarkTheme.textSecondary)
                    
                }
                
                // Model details
                if let currentModel = whisperState.currentModel,
                   let predefinedModel = PredefinedModels.models.first(where: { $0.name == currentModel.name }) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(predefinedModel.displayName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        HStack(spacing: 16) {
                            glassInfoBadge(icon: "cpu", text: predefinedModel.size)
                            glassInfoBadge(icon: "globe", text: predefinedModel.language)
                        }
                        
                        HStack(spacing: 20) {
                            performanceIndicator(speed: predefinedModel.speed, accuracy: predefinedModel.accuracy)
                        }
                        
                        // VAD Status
                        // HStack(spacing: 8) {
                        //     Image(systemName: whisperState.vadContext != nil ? "waveform.circle.fill" : "waveform.circle")
                        //         .font(.system(size: 14))
                        //         .foregroundColor(whisperState.vadContext != nil ? .green : DarkTheme.textSecondary)
                            
                        //     Text("VAD: \(whisperState.vadContext != nil ? "Active" : "Loading...")")
                        //         .font(.system(size: 12, weight: .medium))
                        //         .foregroundColor(DarkTheme.textSecondary)
                            
                        //     if whisperState.vadContext != nil {
                        //         Text("(Silence removal enabled)")
                        //             .font(.system(size: 11))
                        //             .foregroundColor(DarkTheme.textSecondary.opacity(0.8))
                        //     }
                        // }
                    }
                } else {
                    Text(localizationManager.localizedString("models.no_model_selected"))
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(DarkTheme.textSecondary)
                }
            }
            
            Spacer()
            
            // Language controls (right side)
            compactLanguageCard
        }
        .padding(24)
        .background(
            ZStack {
                // Glass background
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Subtle border
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [DarkTheme.textPrimary.opacity(0.3), .black.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
    }
    
    private var compactLanguageCard: some View {
        VStack(alignment: .trailing, spacing: 12) {
            // Language info
            VStack(alignment: .trailing, spacing: 4) {
                Text(localizationManager.localizedString("general.language"))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DarkTheme.textSecondary)
                
                Text(getCurrentLanguageDisplayName())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
            }
            
            // Interactive button
            Button(action: toggleLanguageSettings) {
                VStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(isCurrentModelMultilingual() ? localizationManager.localizedString("models.change_language") : localizationManager.localizedString("models.language_locked"))
                        .font(.system(size: 9, weight: .medium))
                }
                .foregroundColor(isCurrentModelMultilingual() ? DarkTheme.textPrimary : DarkTheme.textSecondary)
                .frame(width: 46, height: 46)
                .background(
                    ZStack {
                        Circle()
                            .fill(.regularMaterial)
                        
                        Circle()
                            .stroke(
                                isCurrentModelMultilingual() ? 
                                LinearGradient(
                                    colors: [DarkTheme.textPrimary.opacity(0.4), .black.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) : 
                                LinearGradient(
                                    colors: [.clear, .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .scaleEffect(isCurrentModelMultilingual() ? 1.0 : 0.95)
                .opacity(isCurrentModelMultilingual() ? 1.0 : 0.7)
            }
            .buttonStyle(.plain)
            .disabled(!isCurrentModelMultilingual())
            
            // Compact status hint
            HStack(spacing: 4) {
                Image(systemName: isCurrentModelMultilingual() ? "info.circle" : "lock.circle")
                    .font(.system(size: 8))
                Text(isCurrentModelMultilingual() ? localizationManager.localizedString("models.tap_to_change") : localizationManager.localizedString("models.english_only"))
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundColor(DarkTheme.textSecondary.opacity(0.8))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(.regularMaterial)
                    .opacity(0.7)
            )
        }
    }
    
    // MARK: - Language Helpers
    
    private func toggleLanguageSettings() {
        withAnimation(.spring()) {
            showLanguageSettings.toggle()
        }
    }
    
    private func isCurrentModelMultilingual() -> Bool {
        guard let currentModel = whisperState.currentModel,
               let predefinedModel = PredefinedModels.models.first(where: { $0.name == currentModel.name }) else {
            return false
        }
        return predefinedModel.isMultilingualModel
    }
    
    private func getCurrentLanguageDisplayName() -> String {
        guard let currentModel = whisperState.currentModel,
              let predefinedModel = PredefinedModels.models.first(where: { $0.name == currentModel.name }) else {
            return "English"
        }
        return predefinedModel.supportedLanguages[selectedLanguage] ?? "Unknown"
    }
    
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(localizationManager.localizedString("models.language_prompts"), systemImage: "text.bubble")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Button(action: { withAnimation { showLanguageSettings = false } }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            LanguageSelectionView(whisperState: whisperState, displayMode: .full, whisperPrompt: whisperPrompt)
        }
        // .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var modelsGridSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            modelsGrid
        }
    }
    
    private var modelsGrid: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Local Models Section
            if !localModels.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    sectionHeader(title: localizationManager.localizedString("models.section.local_models"))
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(localModels) { model in
                            modelCard(for: model)
                        }
                    }
                }
            }
            
            // Premium Cloud Models Section  
            if !premiumCloudModels.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    sectionHeader(title: localizationManager.localizedString("models.section.premium_cloud_models"))
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(premiumCloudModels) { model in
                            modelCard(for: model)
                        }
                    }
                }
            }
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(DarkTheme.textPrimary)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
    
    private var localModels: [PredefinedModel] {
        whisperState.predefinedModels.filter { model in
            !model.isComingSoon && !model.isCloudModel
        }
    }
    
    private var premiumCloudModels: [PredefinedModel] {
        whisperState.predefinedModels.filter { model in
            model.isCloudModel || model.isComingSoon
        }
    }
    
    @ViewBuilder
    private func modelCard(for model: PredefinedModel) -> some View {
        let isDownloaded: Bool = whisperState.availableModels.contains { $0.name == model.name }
        let isCurrent: Bool = whisperState.currentModel?.name == model.name
        let modelURL: URL? = whisperState.availableModels.first { $0.name == model.name }?.url
        let isHovered: Bool = hoveredModelId == model.id
        
        ModernModelCard(
            model: model,
            isDownloaded: isDownloaded,
            isCurrent: isCurrent,
            downloadProgress: whisperState.downloadProgress,
            modelURL: modelURL,
            isHovered: isHovered,
            deleteAction: { self.handleDeleteAction(for: model) },
            setDefaultAction: { self.handleSetDefaultAction(for: model) },
            downloadAction: { self.handleDownloadAction(for: model) }
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                self.hoveredModelId = hovering ? model.id : nil
            }
        }
        .matchedGeometryEffect(id: model.id, in: namespace)
    }
    
    private func handleDeleteAction(for model: PredefinedModel) {
        if let downloadedModel = whisperState.availableModels.first(where: { $0.name == model.name }) {
            modelToDelete = downloadedModel
        }
    }
    
    private func handleSetDefaultAction(for model: PredefinedModel) {
        print("🎯 handleSetDefaultAction called for model: \(model.displayName) (\(model.name))")
        
        // Check subscription access for Pro models
        if isProModel(model) && !canUseProModel() {
            print("🚫 User tried to select Pro model without subscription: \(model.displayName)")
            showAutoFallbackDialog(requestedModel: model)
            return
        }
        
        // Check if it's a cloud model
        let isCloudModel = model.isCloudModel
        print("🌐 Is cloud model: \(isCloudModel)")
        
        if isCloudModel {
            // Handle cloud models by creating a WhisperModel instance
            print("☁️ Setting cloud model as default: \(model.displayName)")
            let cloudModel = WhisperModel(
                name: model.name,
                url: URL(fileURLWithPath: "/tmp/dummy"), // Dummy URL for cloud models
                coreMLEncoderURL: nil
            )
            
            Task {
                await whisperState.setDefaultModel(cloudModel)
                print("✅ Cloud model set as default successfully: \(model.displayName)")
            }
        } else {
            // Handle local models (existing logic)
            if let downloadedModel = whisperState.availableModels.first(where: { $0.name == model.name }) {
                print("💾 Setting local model as default: \(downloadedModel.name)")
                Task {
                    await whisperState.setDefaultModel(downloadedModel)
                    print("✅ Local model set as default successfully: \(downloadedModel.name)")
                }
            } else {
                print("❌ Local model not found in availableModels: \(model.name)")
            }
        }
    }
    
    // Helper methods for subscription checking
    private func isProModel(_ model: PredefinedModel) -> Bool {
        let freeModels = ["ggml-small"]
        return !freeModels.contains(model.name)
    }
    
    private func canUseProModel() -> Bool {
        return subscriptionManager.currentTier == .pro || subscriptionManager.isInTrial
    }
    
    // Smart auto-fallback dialog - trigger global recording failed dialog
    private func showAutoFallbackDialog(requestedModel: PredefinedModel) {
        // Trigger global recording failed dialog via notification
        NotificationCenter.default.post(
            name: .showRecordingFailedDialog,
            object: nil,
            userInfo: ["modelName": requestedModel.displayName]
        )
    }
    
    private func autoSwitchToFreeModel() {
        downloadFlashModel()
    }
    
    // Download and switch to Flash model with permission
    private func downloadFlashModel() {
        // Find Clio Flash (ggml-small) model
        if let freeModel = whisperState.predefinedModels.first(where: { $0.name == "ggml-small" }) {
            print("🔄 Auto-switching to free model: \(freeModel.displayName)")
            
            // Check if it's downloaded
            if let downloadedModel = whisperState.availableModels.first(where: { $0.name == "ggml-small" }) {
                Task {
                    await whisperState.setDefaultModel(downloadedModel)
                    print("✅ Successfully switched to free model: \(freeModel.displayName)")
                    
                    // Show confirmation notification
                    showFallbackNotification(freeModel: freeModel)
                }
            } else {
                // Auto-download free model if not available
                print("📥 Free model not downloaded, auto-downloading...")
                Task {
                    await whisperState.downloadModel(freeModel)
                    
                    // Wait for download to complete and then set as default
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if let downloadedModel = whisperState.availableModels.first(where: { $0.name == "ggml-small" }) {
                            Task {
                                await whisperState.setDefaultModel(downloadedModel)
                                print("✅ Successfully downloaded and switched to free model: \(freeModel.displayName)")
                                showFallbackNotification(freeModel: freeModel)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func showFallbackNotification(freeModel: PredefinedModel) {
        // Use toast notification or in-app notification instead of alert
        print("✅ Successfully switched to \(freeModel.displayName)")
        // TODO: Implement toast notification system
    }
    
    // MARK: - Subscription Change Handlers
    
    private func handleSubscriptionChange(tier: SubscriptionTier) {
        print("🔔 Subscription tier changed to: \(tier)")
        
        // If user becomes free, check if current model is Pro and trigger auto-switch
        if tier == .free && !subscriptionManager.isInTrial {
            checkAndAutoSwitchModel()
        }
    }
    
    private func handleTrialStatusChange(isInTrial: Bool) {
        print("🔔 Trial status changed to: \(isInTrial)")
        
        // If trial expires and user is still free, check if current model is Pro
        if !isInTrial && subscriptionManager.currentTier == .free {
            checkAndAutoSwitchModel()
        }
    }
    
    private func checkAndAutoSwitchModel() {
        // Check if current model is a Pro model
        guard let currentModel = whisperState.currentModel,
              let predefinedModel = PredefinedModels.models.first(where: { $0.name == currentModel.name }),
              isProModel(predefinedModel) else {
            return // Current model is free, no need to switch
        }
        
        print("🚨 Current model \(predefinedModel.displayName) requires Pro subscription, auto-switching...")
        // Trigger global flash download dialog via notification
        NotificationCenter.default.post(
            name: .showRecordingFailedDialog,
            object: nil,
            userInfo: ["modelName": predefinedModel.displayName]
        )
    }
    
    private func handleDownloadAction(for model: PredefinedModel) {
        Task {
            await whisperState.downloadModel(model)
        }
    }
    
    private var modelFilterTabs: some View {
        HStack(spacing: 12) {
            filterPill(localizationManager.localizedString("models.filter.all"), count: whisperState.predefinedModels.count, isSelected: true)
            filterPill(localizationManager.localizedString("models.filter.downloaded"), count: whisperState.availableModels.count, isSelected: false)
        }
    }
    
    private func filterPill(_ title: String, count: Int, isSelected: Bool) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
            Text("\(count)")
                .font(.system(size: 11, weight: .semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(isSelected ? DarkTheme.textPrimary.opacity(0.2) : DarkTheme.textPrimary.opacity(0.1)))
        }
        .foregroundColor(isSelected ? .white : DarkTheme.textSecondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isSelected ? Color(NSColor.controlAccentColor) : Color.clear)
                .overlay(
                    Capsule()
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                        .opacity(isSelected ? 0 : 1)
                )
        )
    }
    
    private func modelInfoBadge(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundColor(DarkTheme.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(NSColor.quaternaryLabelColor).opacity(0.3))
        )
    }
    
    private func glassInfoBadge(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(DarkTheme.textSecondary)
            
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DarkTheme.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            ZStack {
                Capsule()
                    .fill(.regularMaterial)
                
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [DarkTheme.textPrimary.opacity(0.2), .black.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    private func performanceIndicator(speed: Double, accuracy: Double) -> some View {
        HStack(spacing: 16) {
            metricView(label: localizationManager.localizedString("models.performance.speed"), value: speed)
            metricView(label: localizationManager.localizedString("models.performance.accuracy"), value: accuracy)
        }
    }
    
    private func metricView(label: String, value: Double) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DarkTheme.textSecondary)
            
            ZStack {
                Circle()
                    .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 3)
                    .frame(width: 44, height: 44)
                
                Circle()
                    .trim(from: 0, to: value)
                    .stroke(performanceColor(value), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                
                Text(String(format: "%.1f", value * 10))
                    .font(.system(size: 14, weight: .bold))
            }
        }
    }
    
    private func performanceColor(_ value: Double) -> Color {
        return Color.accentColor
    }
}

#endif
