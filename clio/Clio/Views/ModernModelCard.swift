import SwiftUI
import AppKit

#if CLIO_ENABLE_LOCAL_MODEL

struct ModernModelCard: View {
    let model: PredefinedModel
    @EnvironmentObject private var localizationManager: LocalizationManager
    let isDownloaded: Bool
    let isCurrent: Bool
    let downloadProgress: [String: Double]
    let modelURL: URL?
    let isHovered: Bool
    
    // Actions
    var deleteAction: () -> Void
    var setDefaultAction: () -> Void
    var downloadAction: () -> Void
    
    @StateObject private var accessControl = ModelAccessControl.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    private var isDownloading: Bool {
        downloadProgress.keys.contains(model.name + "_main") || 
        downloadProgress.keys.contains(model.name + "_coreml")
    }
    
    private var totalProgress: Double {
        let mainProgress = downloadProgress[model.name + "_main"] ?? 0
        let supportsCoreML = !model.name.contains("q5") && !model.name.contains("q8")
        
        if supportsCoreML {
            let coreMLProgress = downloadProgress[model.name + "_coreml"] ?? 0
            return (mainProgress * 0.5) + (coreMLProgress * 0.5)
        } else {
            return mainProgress
        }
    }
    
    private var isProModel: Bool {
        // Check if this model requires Pro subscription
        let freeModels = ["ggml-small"]
        return !freeModels.contains(model.name)
    }
    
    private var supportsStreaming: Bool {
        // Check if this model supports streaming
        let streamingModels = ["clio_max"]
        return streamingModels.contains(model.name)
    }
    
    private var canUseModel: Bool {
        // Check if user can use this model
        if !isProModel { return true }
        return subscriptionManager.currentTier == .pro || subscriptionManager.isInTrial
    }
    
    private var isCloudModel: Bool {
        // Check if this is a cloud-based model using the new property
        return model.isCloudModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            cardHeader
            
            Divider()
                .opacity(0.3)
            
            cardContent
            
            // Removed downloadProgressSection - progress shown in button instead
            
            cardActions
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isCurrent ? Color(NSColor.controlAccentColor).opacity(0.08) : Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(isHovered ? 0.12 : 0.06), radius: isHovered ? 12 : 8, x: 0, y: isHovered ? 4 : 2)
        )
        .opacity(canUseModel ? 1.0 : 0.6) // Dim locked models
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isCurrent ? Color(NSColor.controlAccentColor).opacity(0.6) : DarkTheme.textPrimary.opacity(0.1),
                    lineWidth: isCurrent ? 2 : 1
                )
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
    }
    
    private var cardHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Text(model.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                    
                    if isProModel {
                        ProBadge(style: .withIcon)
                    }
                    
                    if model.isComingSoon {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                            Text(localizationManager.localizedString("models.coming_soon"))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(.orange)
                        )
                    }
                    
                    if supportsStreaming {
                        StreamingBadge(style: .withIcon)
                    }
                    
                    if isCurrent {
                        statusBadge(text: localizationManager.localizedString("models.status.active"), color: Color(NSColor.controlAccentColor))
                    } else if isDownloaded {
                        statusBadge(text: localizationManager.localizedString("models.status.downloaded"), color: Color.accentColor)
                    }
                    
                    Spacer()
                    
                    if isDownloaded && !isCurrent {
                        menuButton
                    }
                }
                
                Text(getLocalizedDescription())
                    .font(.system(size: 13))
                    .foregroundColor(DarkTheme.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(16)
    }
    
    private var cardContent: some View {
        VStack(spacing: 12) {
            // All info in one compact row
            HStack(spacing: 10) {
                infoChip(icon: "speedometer", text: "\(localizationManager.localizedString("models.performance.speed")) \(String(format: "%.1f", model.speed * 10))")
                infoChip(icon: "chart.line.uptrend.xyaxis", text: "\(localizationManager.localizedString("models.performance.accuracy")) \(String(format: "%.1f", model.accuracy * 10))")
                infoChip(icon: "globe", text: model.language)
                infoChip(icon: "internaldrive", text: model.size)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    
    private var cardActions: some View {
        HStack {
            if isCurrent {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                    Text(localizationManager.localizedString("models.currently_active"))
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(Color(NSColor.controlAccentColor))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            } else if model.isComingSoon {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                    Text(localizationManager.localizedString("models.coming_soon"))
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            } else if isDownloaded || isCloudModel {
                Button(action: setDefaultAction) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 13))
                        Text(localizationManager.localizedString("models.set_as_default"))
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .buttonStyle(AnyButtonStyle(PrimaryButtonStyle()))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            } else {
                Button(action: {
                    if canUseModel {
                        downloadAction()
                    } else {
                        // Show upgrade prompt
                        subscriptionManager.promptUpgrade(from: "model_download_\(model.name)")
                    }
                }) {
                    HStack(spacing: 6) {
                        if isDownloading {
                            ZStack {
                                Circle()
                                    .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 2)
                                    .frame(width: 16, height: 16)
                                
                                Circle()
                                    .trim(from: 0, to: totalProgress)
                                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                    .frame(width: 16, height: 16)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 0.3), value: totalProgress)
                                
                                if totalProgress > 0 {
                                    Text("\(Int(totalProgress * 100))")
                                        .font(.system(size: 7, weight: .bold))
                                        .foregroundColor(DarkTheme.textPrimary)
                                }
                            }
                        } else if !canUseModel {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                        } else {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 14))
                        }
                        Text(isDownloading ? "\(localizationManager.localizedString("models.downloading")) \(Int(totalProgress * 100))%" : 
                             !canUseModel ? localizationManager.localizedString("models.requires_pro") : localizationManager.localizedString("models.download"))
                            .font(.system(size: 13, weight: .medium))
                    }
                }
                .buttonStyle(canUseModel ? AnyButtonStyle(PrimaryButtonStyle()) : AnyButtonStyle(LockedButtonStyle()))
                .disabled(isDownloading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            Spacer()
        }
        .background(DarkTheme.textPrimary.opacity(0.03))
    }
    
    private var menuButton: some View {
        Menu {
            Button(action: deleteAction) {
                Label(localizationManager.localizedString("models.delete"), systemImage: "trash")
            }
            
            if let modelURL = modelURL {
                Button {
                    NSWorkspace.shared.selectFile(modelURL.path, inFileViewerRootedAtPath: "")
                } label: {
                    Label(localizationManager.localizedString("models.show_in_finder"), systemImage: "folder")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 16))
                .foregroundStyle(DarkTheme.textSecondary)
                .frame(width: 28, height: 28)
                .background(Circle().fill(DarkTheme.textPrimary.opacity(0.05)))
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
    }
    
    // MARK: - Helper Components
    
    private func statusBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(DarkTheme.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(color)
            )
    }
    
    private func performanceMetric(icon: String, label: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(label)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(DarkTheme.textSecondary)
            
            HStack(spacing: 8) {
                // Visual bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(DarkTheme.textPrimary.opacity(0.1))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * value, height: 6)
                    }
                }
                .frame(width: 60, height: 6)
                
                Text(String(format: "%.1f", value * 10))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }
        }
    }
    
    private func infoChip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(DarkTheme.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(DarkTheme.textPrimary.opacity(0.06))
        )
    }
    
    
    private func performanceColor(_ value: Double) -> Color {
        switch value {
        case 0.8...1.0: return Color(.systemGreen)
        case 0.6..<0.8: return Color(.systemYellow)
        case 0.4..<0.6: return Color(.systemOrange)
        default: return Color(.systemRed)
        }
    }
    
    private func getLocalizedDescription() -> String {
        return localizationManager.localizedString(model.description)
    }
}
#endif

// MARK: - Button Styles

struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView
    
    init<S: ButtonStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

struct ModernButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(DarkTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DarkTheme.textPrimary.opacity(configuration.isPressed ? 0.15 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(DarkTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(NSColor.controlAccentColor),
                                Color(NSColor.controlAccentColor).opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(NSColor.controlAccentColor).opacity(0.3), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct LockedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(DarkTheme.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(DarkTheme.textPrimary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(DarkTheme.textPrimary.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}