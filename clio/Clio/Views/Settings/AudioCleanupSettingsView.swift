import SwiftUI
import SwiftData

/// A view component for configuring audio cleanup settings
struct AudioCleanupSettingsView: View {
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    // Audio cleanup settings (simplified - default to 14 days)
    @AppStorage("IsAudioCleanupEnabled") private var isAudioCleanupEnabled = true
    private let audioRetentionPeriod = 14 // Fixed at 14 days for simplicity
    @State private var isPerformingCleanup = false
    @State private var isShowingConfirmation = false
    @State private var cleanupInfo: (fileCount: Int, totalSize: Int64, transcriptions: [Transcription]) = (0, 0, [])
    @State private var showResultAlert = false
    @State private var cleanupResult: (deletedCount: Int, errorCount: Int) = (0, 0)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(localizationManager.localizedString("audio.cleanup.enable"), isOn: $isAudioCleanupEnabled)
                .toggleStyle(.switch)
                .padding(.vertical, 4)
            
            if isAudioCleanupEnabled {
                Text("Audio files are automatically deleted after 14 days to save storage space. Transcriptions are always preserved.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
        }
    }
}

// MARK: - Configuration View Component
struct AudioCleanupConfigurationView: View {
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    // Audio cleanup settings
    @AppStorage("AudioRetentionPeriod") private var audioRetentionPeriod = 7
    @State private var isPerformingCleanup = false
    @State private var isShowingConfirmation = false
    @State private var cleanupInfo: (fileCount: Int, totalSize: Int64, transcriptions: [Transcription]) = (0, 0, [])
    @State private var showResultAlert = false
    @State private var cleanupResult: (deletedCount: Int, errorCount: Int) = (0, 0)
    
    // Retention period options
    private var retentionOptions: [(days: Int, label: String)] {
        [
            (days: 1, label: localizationManager.localizedString("audio.cleanup.1_day")),
            (days: 3, label: localizationManager.localizedString("audio.cleanup.3_days")),
            (days: 7, label: localizationManager.localizedString("audio.cleanup.7_days")),
            (days: 14, label: localizationManager.localizedString("audio.cleanup.14_days")),
            (days: 30, label: localizationManager.localizedString("audio.cleanup.30_days"))
        ]
    }
    
    var body: some View {
        // Combined compact card
        VStack {
            HStack(spacing: 24) {
                // Left column: Retention Period
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 20))
                        .foregroundColor(DarkTheme.accent)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DarkTheme.accent.opacity(0.15))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localizationManager.localizedString("audio.cleanup.retention_period"))
                            .font(.headline)
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        Text(localizationManager.localizedString("audio.cleanup.how_long_keep"))
                            .font(.subheadline)
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                    
                    StyledDropdown(
                        icon: "clock.fill",
                        options: retentionOptions.map { $0.days },
                        selectedOption: audioRetentionPeriod,
                        defaultText: localizationManager.localizedString("audio.cleanup.select_period"),
                        optionDisplayText: { days in
                            retentionOptions.first { $0.days == days }?.label ?? "\(days) days"
                        }
                    ) { selectedDays in
                        if let days = selectedDays {
                            audioRetentionPeriod = days
                        }
                    }
                }
                
                Spacer()
                
                // Right column: Manual Cleanup Button Only
                AddNewButton(
                    isPerformingCleanup ? localizationManager.localizedString("audio.cleanup.analyzing") : localizationManager.localizedString("audio.cleanup.run_now"),
                    action: {
                        runCleanupAnalysis()
                    },
                    isEnabled: !isPerformingCleanup,
                    backgroundColor: .accentColor,
                    textColor: .white,
                    systemImage: isPerformingCleanup ? "" : "arrow.clockwise"
                )
            }
        }
        .alert(localizationManager.localizedString("audio.cleanup.analysis_title"), isPresented: $isShowingConfirmation) {
            Button(localizationManager.localizedString("general.cancel"), role: .cancel) { }
            
            if cleanupInfo.fileCount > 0 {
                Button(localizationManager.localizedString("audio.cleanup.delete_files").replacingOccurrences(of: "%d", with: "\(cleanupInfo.fileCount)"), role: .destructive) {
                    performCleanup()
                }
            }
        } message: {
            VStack(alignment: .leading, spacing: 8) {
                if cleanupInfo.fileCount > 0 {
                    Text(localizationManager.localizedString("audio.cleanup.found_files").replacingOccurrences(of: "%d", with: "\(cleanupInfo.fileCount)").replacingOccurrences(of: "%@", with: "\(audioRetentionPeriod)"))
                    Text(localizationManager.localizedString("audio.cleanup.storage_freed").replacingOccurrences(of: "%@", with: AudioCleanupManager.shared.formatFileSize(cleanupInfo.totalSize)))
                    Text(localizationManager.localizedString("audio.cleanup.transcripts_preserved"))
                } else {
                    Text(localizationManager.localizedString("audio.cleanup.no_files").replacingOccurrences(of: "%@", with: "\(audioRetentionPeriod)"))
                    Text(localizationManager.localizedString("audio.cleanup.already_optimized"))
                }
            }
        }
        .alert(localizationManager.localizedString("audio.cleanup.complete_title"), isPresented: $showResultAlert) {
            Button(localizationManager.localizedString("general.ok"), role: .cancel) { }
        } message: {
            if cleanupResult.errorCount > 0 {
                Text(localizationManager.localizedString("audio.cleanup.result_with_errors").replacingOccurrences(of: "%d", with: "\(cleanupResult.deletedCount)").replacingOccurrences(of: "%@", with: "\(cleanupResult.errorCount)"))
            } else {
                Text(localizationManager.localizedString("audio.cleanup.result_success_with_space").replacingOccurrences(of: "%d", with: "\(cleanupResult.deletedCount)"))
            }
        }
    }
    
    // MARK: - Old Card Implementations (commented out)
    /*
    // MARK: - Retention Period Card
    private var retentionPeriodCard: some View {
        DarkSettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 20))
                        .foregroundColor(DarkTheme.accent)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DarkTheme.accent.opacity(0.15))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localizationManager.localizedString("audio.cleanup.retention_period"))
                            .font(.headline)
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        Text(localizationManager.localizedString("audio.cleanup.how_long_keep"))
                            .font(.subheadline)
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                    
                    Spacer()
                }
                
                StyledDropdown(
                    icon: "clock.fill",
                    options: retentionOptions.map { $0.days },
                    selectedOption: audioRetentionPeriod,
                    defaultText: localizationManager.localizedString("audio.cleanup.select_period"),
                    optionDisplayText: { days in
                        retentionOptions.first { $0.days == days }?.label ?? "\(days) days"
                    }
                ) { selectedDays in
                    if let days = selectedDays {
                        audioRetentionPeriod = days
                    }
                }
                
                // Info Box
                // HStack(spacing: 12) {
                //     Image(systemName: "info.circle.fill")
                //         .font(.system(size: 16))
                //         .foregroundColor(DarkTheme.accent)
                    
                //     VStack(alignment: .leading, spacing: 4) {
                //         Text(localizationManager.localizedString("audio.cleanup.auto_delete_info").replacingOccurrences(of: "%@", with: "\(audioRetentionPeriod)"))
                //             .font(.system(size: 13, weight: .medium))
                //             .foregroundColor(DarkTheme.textPrimary)
                        
                //         Text(localizationManager.localizedString("audio.cleanup.transcripts_always_preserved"))
                //             .font(.system(size: 12))
                //             .foregroundColor(DarkTheme.textSecondary)
                //     }
                    
                //     Spacer()
                // }
                // .padding(12)
                // .background(
                //     RoundedRectangle(cornerRadius: 8)
                //         .fill(DarkTheme.accent.opacity(0.1))
                //         .overlay(
                //             RoundedRectangle(cornerRadius: 8)
                //                 .stroke(DarkTheme.accent.opacity(0.3), lineWidth: 1)
                //         )
                // )
            }
        }
    }
    
    // MARK: - Action Button Card
    private var actionButtonCard: some View {
        DarkSettingsCard {
            HStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.15))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.localizedString("audio.cleanup.manual_cleanup"))
                        .font(.headline)
                        .foregroundColor(DarkTheme.textPrimary)
                    
                    Text(localizationManager.localizedString("audio.cleanup.run_immediately"))
                        .font(.subheadline)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                AddNewButton(
                    isPerformingCleanup ? localizationManager.localizedString("audio.cleanup.analyzing") : localizationManager.localizedString("audio.cleanup.run_now"),
                    action: {
                        runCleanupAnalysis()
                    },
                    isEnabled: !isPerformingCleanup,
                    backgroundColor: .accentColor,
                    textColor: .white,
                    systemImage: isPerformingCleanup ? "" : "arrow.clockwise"
                )
            }
        }
        .alert(localizationManager.localizedString("audio.cleanup.analysis_title"), isPresented: $isShowingConfirmation) {
            Button(localizationManager.localizedString("general.cancel"), role: .cancel) { }
            
            if cleanupInfo.fileCount > 0 {
                Button(localizationManager.localizedString("audio.cleanup.delete_files").replacingOccurrences(of: "%d", with: "\(cleanupInfo.fileCount)"), role: .destructive) {
                    performCleanup()
                }
            }
        } message: {
            VStack(alignment: .leading, spacing: 8) {
                if cleanupInfo.fileCount > 0 {
                    Text(localizationManager.localizedString("audio.cleanup.found_files").replacingOccurrences(of: "%d", with: "\(cleanupInfo.fileCount)").replacingOccurrences(of: "%@", with: "\(audioRetentionPeriod)"))
                    Text(localizationManager.localizedString("audio.cleanup.storage_freed").replacingOccurrences(of: "%@", with: AudioCleanupManager.shared.formatFileSize(cleanupInfo.totalSize)))
                    Text(localizationManager.localizedString("audio.cleanup.transcripts_preserved"))
                } else {
                    Text(localizationManager.localizedString("audio.cleanup.no_files").replacingOccurrences(of: "%@", with: "\(audioRetentionPeriod)"))
                    Text(localizationManager.localizedString("audio.cleanup.already_optimized"))
                }
            }
        }
        .alert(localizationManager.localizedString("audio.cleanup.complete_title"), isPresented: $showResultAlert) {
            Button(localizationManager.localizedString("general.ok"), role: .cancel) { }
        } message: {
            if cleanupResult.errorCount > 0 {
                Text(localizationManager.localizedString("audio.cleanup.result_with_errors").replacingOccurrences(of: "%d", with: "\(cleanupResult.deletedCount)").replacingOccurrences(of: "%@", with: "\(cleanupResult.errorCount)"))
            } else {
                Text(localizationManager.localizedString("audio.cleanup.result_success_with_space").replacingOccurrences(of: "%d", with: "\(cleanupResult.deletedCount)"))
            }
        }
    }
    */
    
    // MARK: - Actions
    private func runCleanupAnalysis() {
        Task {
            await MainActor.run {
                isPerformingCleanup = true
            }
            
            let info = await AudioCleanupManager.shared.getCleanupInfo(modelContext: whisperState.modelContext)
            
            await MainActor.run {
                cleanupInfo = info
                isPerformingCleanup = false
                isShowingConfirmation = true
            }
        }
    }
    
    private func performCleanup() {
        Task {
            await MainActor.run {
                isPerformingCleanup = true
            }
            
            let result = await AudioCleanupManager.shared.runCleanupForTranscriptions(
                modelContext: whisperState.modelContext,
                transcriptions: cleanupInfo.transcriptions
            )
            
            await MainActor.run {
                cleanupResult = result
                isPerformingCleanup = false
                showResultAlert = true
            }
        }
    }
}