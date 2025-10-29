import SwiftUI
import AVFoundation

struct MicrophoneSelectionView: View {
    @StateObject private var deviceManager = AudioDeviceManager.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        Menu {
            // System Default option
            Button {
                deviceManager.selectInputMode(.systemDefault)
            } label: {
                HStack {
                    Text(localizationManager.localizedString("audio.mode.system_default"))
                    Spacer()
                    if deviceManager.inputMode == .systemDefault {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            if !deviceManager.availableDevices.isEmpty {
                Divider()
                
                // Available devices
                ForEach(deviceManager.availableDevices, id: \.id) { device in
                    Button {
                        deviceManager.selectInputMode(.custom)
                        deviceManager.selectDevice(id: device.id)
                    } label: {
                        HStack {
                            Text(device.name)
                            Spacer()
                            if deviceManager.inputMode == .custom && deviceManager.selectedDeviceID == device.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            Button(localizationManager.localizedString("general.refresh")) {
                deviceManager.loadAvailableDevices()
            }
        } label: {
            Text(localizationManager.localizedString("menu.select_audio_input"))
        }
    }
    
    private var microphoneDisplayText: String {
        switch deviceManager.inputMode {
        case .systemDefault:
            return localizationManager.localizedString("audio.mode.system_default")
        case .custom:
            if let selectedDevice = deviceManager.availableDevices.first(where: { $0.id == deviceManager.selectedDeviceID }) {
                return selectedDevice.name
            }
            return localizationManager.localizedString("audio.mode.custom")
        case .prioritized:
            return localizationManager.localizedString("audio.mode.prioritized")
        }
    }
}