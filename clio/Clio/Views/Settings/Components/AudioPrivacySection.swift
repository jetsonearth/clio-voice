import SwiftUI
import AVFoundation

struct AudioInputSection: View {
    @StateObject private var deviceManager = AudioDeviceManager.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "waveform")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.localizedString("audio.input.title"))
                        .font(.headline)
                        .foregroundColor(DarkTheme.textPrimary)
                    Text(localizationManager.localizedString("audio.input.subtitle"))
                        .font(.subheadline)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                // Dropdown directly in the header
                StyledDropdown(
                    icon: "mic",
                    options: deviceManager.availableDevices.map { AudioDeviceOption(id: $0.id, uid: $0.uid, name: $0.name) },
                    selectedOption: deviceManager.availableDevices.map { AudioDeviceOption(id: $0.id, uid: $0.uid, name: $0.name) }.first { $0.id == deviceManager.selectedDeviceID },
                    defaultText: localizationManager.localizedString("audio.mode.system_default"),
                    optionDisplayText: { $0.name }
                ) { selectedDevice in
                    if let device = selectedDevice {
                        deviceManager.selectDevice(id: device.id)
                    } else {
                        // Select system default
                        deviceManager.selectInputMode(.systemDefault)
                    }
                }
                .frame(width: 250)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DarkTheme.textPrimary.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
        .onAppear {
            deviceManager.loadAvailableDevices()
        }
    }
}

struct PrivacySection: View {
    @EnvironmentObject private var recordingEngine: RecordingEngine
    @EnvironmentObject private var localizationManager: LocalizationManager
    @AppStorage("UseLocalModel") private var useLocalModel = false
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0.0
    
    private var localModelAvailable: Bool {
        // Check if Clio Flash is downloaded
        recordingEngine.availableModels.contains(where: { $0.name == "ggml-small" })
    }
    
    var body: some View {
        SettingsSection(
            icon: "lock.shield",
            title: localizationManager.localizedString("settings.privacy.title"),
            subtitle: localizationManager.localizedString("settings.privacy.subtitle")
        ) {
            VStack(alignment: .leading, spacing: 16) {
                // Use local model toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(localizationManager.localizedString("settings.privacy.use_local_model"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary)
                        Text(localizationManager.localizedString("settings.privacy.local_model_description"))
                            .font(.system(size: 12))
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $useLocalModel)
                        .toggleStyle(.switch)
                        .disabled(!localModelAvailable && !useLocalModel)
                        .onChange(of: useLocalModel) { oldValue, newValue in
                            updateModelSelection(useLocal: newValue)
                        }
                }
                
                // Show download button if local model not available
                if !localModelAvailable && useLocalModel {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 14))
                            Text(localizationManager.localizedString("settings.privacy.model_not_downloaded"))
                                .font(.system(size: 13))
                                .foregroundColor(DarkTheme.textSecondary)
                        }
                        
                        if isDownloading {
                            HStack {
                                ProgressView(value: downloadProgress)
                                    .progressViewStyle(.linear)
                                Text("\(Int(downloadProgress * 100))%")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(DarkTheme.textSecondary)
                            }
                        } else {
                            Button(action: downloadLocalModel) {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                    Text(localizationManager.localizedString("settings.privacy.download_model"))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(DarkTheme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Status text - more compact
                if localModelAvailable {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 12))
                        Text("Clio Flash (244 MB)")
                            .font(.system(size: 12))
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                }
            }
        }
    }
    
    private func updateModelSelection(useLocal: Bool) {
        Task {
            if useLocal {
                // Switch to local Clio Flash
                if let flashModel = recordingEngine.availableModels.first(where: { $0.name == "ggml-small" }) {
//                    await recordingEngine.setDefaultModel(flashModel)
                }
            } else {
                // Switch to Soniox (cloud)
                let sonioxModel = WhisperModel(
                    name: "soniox-realtime-streaming",
                    url: URL(fileURLWithPath: "/tmp/dummy"),
                    coreMLEncoderURL: nil
                )
//                await recordingEngine.setDefaultModel(sonioxModel)
            }
        }
    }
    
    private func downloadLocalModel() {
        guard let flashModel = recordingEngine.predefinedModels.first(where: { $0.name == "ggml-small" }) else {
            return
        }
        
        isDownloading = true
        
        Task {
            // Subscribe to download progress
            for await progress in recordingEngine.$downloadProgress.values {
                if let modelProgress = progress[flashModel.name] {
                    await MainActor.run {
                        downloadProgress = modelProgress
                    }
                }
            }
        }
        
        Task {
//            await recordingEngine.downloadModel(flashModel)
            await MainActor.run {
                isDownloading = false
                downloadProgress = 0.0
                // Model will auto-select after download if toggle is on
                if useLocalModel && localModelAvailable {
                    updateModelSelection(useLocal: true)
                }
            }
        }
    }
}
