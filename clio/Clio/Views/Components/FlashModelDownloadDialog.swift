import SwiftUI

struct FlashModelDownloadDialog: View {
    @Binding var isPresented: Bool
    let onDownload: () -> Void
    let onUpgrade: () -> Void
    let onCancel: () -> Void
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var isDownloading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                // Icon
                HStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(DarkTheme.accent)
                        
                        Text(localizationManager.localizedString("trial.expired.title"))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                
                // Description
                VStack(spacing: 12) {
                    Text(localizationManager.localizedString("trial.expired.description"))
                        .font(.system(size: 16))
                        .foregroundColor(DarkTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                    
                    // Model info card
                    HStack(spacing: 12) {
                        Image(systemName: "cpu")
                            .font(.system(size: 16))
                            .foregroundColor(DarkTheme.accent)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Clio Flash")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(DarkTheme.textPrimary)
                            
                            Text(localizationManager.localizedString("trial.expired.flash.description"))
                                .font(.system(size: 12))
                                .foregroundColor(DarkTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text("244 MB")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DarkTheme.textTertiary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(DarkTheme.surfaceBackground)
                            )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DarkTheme.surfaceBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(DarkTheme.border, lineWidth: 1)
                            )
                    )
                }
            }
            .padding(24)
            
            Divider()
                .background(DarkTheme.border)
            
            // Action buttons
            VStack(spacing: 12) {
                // Primary action - Download Flash
                AddNewButton(
                    localizationManager.localizedString("trial.expired.download.flash"),
                    action: handleDownloadFlash,
                    isEnabled: !isDownloading,
                    backgroundColor: DarkTheme.accent,
                    textColor: .white,
                    systemImage: isDownloading ? "" : "arrow.down.circle"
                )
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                
                // Secondary actions
                HStack(spacing: 12) {
                    // Upgrade button
                    AddNewButton(
                        localizationManager.localizedString("trial.expired.upgrade.pro"),
                        action: handleUpgrade,
                        isEnabled: !isDownloading,
                        backgroundColor: DarkTheme.surfaceBackground,
                        textColor: DarkTheme.textPrimary,
                        systemImage: "star.circle"
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    
                    // Cancel button
                    AddNewButton(
                        localizationManager.localizedString("common.cancel"),
                        action: handleCancel,
                        isEnabled: !isDownloading,
                        backgroundColor: Color.clear,
                        textColor: DarkTheme.textSecondary,
                        systemImage: ""
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
            }
            .padding(24)
        }
        .frame(width: 400)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DarkTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DarkTheme.border, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    private func handleDownloadFlash() {
        isDownloading = true
        onDownload()
        
        // Auto-close dialog after initiating download
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPresented = false
        }
    }
    
    private func handleUpgrade() {
        isPresented = false
        onUpgrade()
    }
    
    private func handleCancel() {
        isPresented = false
        onCancel()
    }
}

struct RecordingFailedDialog: View {
    @Binding var isPresented: Bool
    let modelName: String
    let onDownload: () -> Void
    let onUpgrade: () -> Void
    let onCancel: () -> Void
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(DarkTheme.warning)
                        
                        Text(localizationManager.localizedString("recording.failed.title"))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(DarkTheme.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                
                // Description
                VStack(spacing: 12) {
                    Text(String(format: localizationManager.localizedString("recording.failed.description"), modelName))
                        .font(.system(size: 16))
                        .foregroundColor(DarkTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                    
                    // Alternative options
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(DarkTheme.success)
                            
                            Text(localizationManager.localizedString("recording.failed.option1"))
                                .font(.system(size: 13))
                                .foregroundColor(DarkTheme.textSecondary)
                            
                            Spacer()
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(DarkTheme.success)
                            
                            Text(localizationManager.localizedString("recording.failed.option2"))
                                .font(.system(size: 13))
                                .foregroundColor(DarkTheme.textSecondary)
                            
                            Spacer()
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(DarkTheme.surfaceBackground)
                    )
                }
            }
            .padding(24)
            
            Divider()
                .background(DarkTheme.border)
            
            // Action buttons
            VStack(spacing: 12) {
                // Primary action - Upgrade
                AddNewButton(
                    localizationManager.localizedString("recording.failed.upgrade.now"),
                    action: {
                        isPresented = false
                        onUpgrade()
                    },
                    backgroundColor: DarkTheme.accent,
                    textColor: .white,
                    systemImage: "star.circle"
                )
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                
                // Secondary actions
                HStack(spacing: 12) {
                    // Use free model
                    AddNewButton(
                        localizationManager.localizedString("recording.failed.use.free"),
                        action: {
                            isPresented = false
                            onDownload()
                        },
                        backgroundColor: DarkTheme.surfaceBackground,
                        textColor: DarkTheme.textPrimary,
                        systemImage: "arrow.down.circle"
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    
                    // Cancel
                    AddNewButton(
                        localizationManager.localizedString("common.cancel"),
                        action: {
                            isPresented = false
                            onCancel()
                        },
                        backgroundColor: Color.clear,
                        textColor: DarkTheme.textSecondary,
                        systemImage: ""
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
            }
            .padding(24)
        }
        .frame(width: 420)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DarkTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DarkTheme.border, lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    VStack {
        FlashModelDownloadDialog(
            isPresented: .constant(true),
            onDownload: { print("Download Flash") },
            onUpgrade: { print("Upgrade") },
            onCancel: { print("Cancel") }
        )
        
        RecordingFailedDialog(
            isPresented: .constant(true),
            modelName: "Clio Ultra",
            onDownload: { print("Download Flash") },
            onUpgrade: { print("Upgrade") },
            onCancel: { print("Cancel") }
        )
    }
    .environmentObject(LocalizationManager.shared)
    .background(DarkTheme.background)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}