import SwiftUI

#if CLIO_ENABLE_LOCAL_MODEL
import AppKit

struct ModelCardRowView: View {
    // Placeholder; this view is unused when local models are disabled.
    let model: PredefinedModel
    let isDownloaded: Bool
    let isCurrent: Bool
    let downloadProgress: [String: Double]
    let modelURL: URL?
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    // Actions
    var deleteAction: () -> Void
    var setDefaultAction: () -> Void
    var downloadAction: () -> Void
    
    private var isDownloading: Bool {
        downloadProgress.keys.contains(model.name + "_main") || 
        downloadProgress.keys.contains(model.name + "_coreml")
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Main Content
            VStack(alignment: .leading, spacing: 6) {
                headerSection
                metadataSection
                descriptionSection
                progressSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Action Controls
            actionSection
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isCurrent ? Color.accentColor.opacity(0.5) : Color.gray.opacity(0.18), lineWidth: isCurrent ? 2 : 1)
        )
        .background(isCurrent ? Color.accentColor.opacity(0.08) : Color.clear)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 3)
        .cornerRadius(12)
    }
    
    // MARK: - Components
    
    private var headerSection: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(model.displayName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DarkTheme.textPrimary)
            
            statusBadge
            
            Spacer()
        }
    }
    
    private var statusBadge: some View {
        Group {
            if isCurrent {
                Text(localizationManager.localizedString("models.status.default"))
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.accentColor))
                    .foregroundColor(DarkTheme.textPrimary)
            } else if isDownloaded {
                Text(localizationManager.localizedString("models.status.downloaded"))
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color(.quaternaryLabelColor)))
                    .foregroundColor(DarkTheme.textPrimary)
            }
        }
    }
    
    private var metadataSection: some View {
        HStack(spacing: 16) {
            // Language
            Label(model.language, systemImage: "globe")
                .font(.system(size: 11))
                .foregroundColor(DarkTheme.textSecondary)
            
            // Size
            Label(model.size, systemImage: "internaldrive")
                .font(.system(size: 11))
                .foregroundColor(DarkTheme.textSecondary)
            
            // Speed
            HStack(spacing: 4) {
                Text(localizationManager.localizedString("models.performance.speed"))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DarkTheme.textSecondary)
                progressDotsWithNumber(value: model.speed * 10)
            }
            
            // Accuracy
            HStack(spacing: 4) {
                Text(localizationManager.localizedString("models.performance.accuracy"))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DarkTheme.textSecondary)
                progressDotsWithNumber(value: model.accuracy * 10)
            }
        }
    }
    
    private var descriptionSection: some View {
        Text(model.description)
            .font(.system(size: 11))
            .foregroundColor(DarkTheme.textSecondary)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 4)
    }
    
    private var progressSection: some View {
        Group {
            if isDownloading {
                DownloadProgressView(
                    modelName: model.name,
                    downloadProgress: downloadProgress
                )
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var actionSection: some View {
        HStack(spacing: 8) {
            if isCurrent {
                Text(localizationManager.localizedString("models.status.default_model"))
                    .font(.system(size: 12))
                    .foregroundColor(DarkTheme.textSecondary)
            } else if isDownloaded {
                Button(action: setDefaultAction) {
                    Text(localizationManager.localizedString("models.action.set_default"))
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            } else {
                Button(action: downloadAction) {
                    HStack(spacing: 4) {
                        Text(isDownloading ? localizationManager.localizedString("models.action.downloading") : localizationManager.localizedString("models.action.download"))
                            .font(.system(size: 12, weight: .medium))
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(DarkTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(.controlAccentColor))
                            .shadow(color: Color(.controlAccentColor).opacity(0.2), radius: 2, x: 0, y: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isDownloading)
            }
            
            if isDownloaded {
                Menu {
                    Button(action: deleteAction) {
                        Label(localizationManager.localizedString("models.action.delete"), systemImage: "trash")
                    }
                    
                    if isDownloaded {
                        Button {
                            if let modelURL = modelURL {
                                NSWorkspace.shared.selectFile(modelURL.path, inFileViewerRootedAtPath: "")
                            }
                        } label: {
                            Label(localizationManager.localizedString("models.action.show_in_finder"), systemImage: "folder")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 14))
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .frame(width: 20, height: 20)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var downloadComponents: [(String, Double)] {
        [
            (localizationManager.localizedString("models.component.model"), downloadProgress[model.name + "_main"] ?? 0),
            (localizationManager.localizedString("models.component.coreml"), downloadProgress[model.name + "_coreml"] ?? 0)
        ].filter { $0.1 > 0 }
    }
    
    private func progressDotsWithNumber(value: Double) -> some View {
        HStack(spacing: 4) {
            progressDots(value: value)
            Text(String(format: "%.1f", value))
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(DarkTheme.textSecondary)
        }
    }
    
    private func progressDots(value: Double) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(index < Int(value / 2) ? performanceColor(value: value / 10) : DarkTheme.textPrimary.opacity(0.2))
                    .frame(width: 6, height: 6)
            }
        }
    }
    
    private func performanceColor(value: Double) -> Color {
        switch value {
        case 0.8...1.0: return Color(.systemGreen)
        case 0.6..<0.8: return Color(.systemYellow)
        case 0.4..<0.6: return Color(.systemOrange)
        default: return Color(.systemRed)
        }
    }
} 
#endif
