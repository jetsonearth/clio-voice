import SwiftUI

struct AudioInputSettingsView: View {
    @ObservedObject var audioDeviceManager = AudioDeviceManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                mainContent
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var mainContent: some View {
        VStack(spacing: 40) {
            inputModeSection
            
            if audioDeviceManager.inputMode == .custom {
                customDeviceSection
            } else if audioDeviceManager.inputMode == .prioritized {
                prioritizedDevicesSection
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
    }
    
    private var heroSection: some View {
        VStack(spacing: 24) {
            Image(systemName: "airpod.gen3")
                .font(.system(size: 40))
                .foregroundStyle(Color.accentColor)
                .padding(20)
                .background(Circle()
                    .fill(Color(.windowBackgroundColor).opacity(0.4))
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5))
            
            VStack(spacing: 8) {
                Text(localizationManager.localizedString("audio.input.title"))
                    .font(.system(size: 28, weight: .bold))
                Text(localizationManager.localizedString("audio.input.subtitle"))
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
    
    private var inputModeSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(localizationManager.localizedString("audio.input.mode"))
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                ForEach(AudioInputMode.allCases, id: \.self) { mode in
                    InputModeCard(
                        mode: mode,
                        isSelected: audioDeviceManager.inputMode == mode,
                        action: { audioDeviceManager.selectInputMode(mode) },
                        localizationManager: localizationManager
                    )
                }
            }
        }
    }
    
    private var customDeviceSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(localizationManager.localizedString("audio.devices.available"))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { audioDeviceManager.loadAvailableDevices() }) {
                    Label(localizationManager.localizedString("general.refresh"), systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
            }
            
            VStack(spacing: 12) {
                ForEach(audioDeviceManager.availableDevices, id: \.id) { device in
                    DeviceSelectionCard(
                        name: device.name,
                        isSelected: audioDeviceManager.selectedDeviceID == device.id,
                        isActive: audioDeviceManager.getCurrentDevice() == device.id,
                        activeLabel: localizationManager.localizedString("audio.device.active")
                    ) {
                        audioDeviceManager.selectDevice(id: device.id)
                    }
                }
            }
        }
    }
    
    private var prioritizedDevicesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if audioDeviceManager.availableDevices.isEmpty {
                emptyDevicesState
            } else {
                prioritizedDevicesContent
                Divider().padding(.vertical, 8)
                availableDevicesContent
            }
        }
    }
    
    private var prioritizedDevicesContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(localizationManager.localizedString("audio.devices.prioritized"))
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(localizationManager.localizedString("audio.devices.priority_description"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if audioDeviceManager.prioritizedDevices.isEmpty {
                Text(localizationManager.localizedString("audio.devices.no_priority"))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                prioritizedDevicesList
            }
        }
    }
    
    private var availableDevicesContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localizationManager.localizedString("audio.devices.available"))
                .font(.title2)
                .fontWeight(.semibold)
            
            availableDevicesList
        }
    }
    
    private var emptyDevicesState: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.slash.circle.fill")
                .font(.system(size: 48))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text(localizationManager.localizedString("audio.devices.none.title"))
                    .font(.headline)
                Text(localizationManager.localizedString("audio.devices.none.description"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.windowBackgroundColor).opacity(0.4))
        )
    }
    
    private var prioritizedDevicesList: some View {
        VStack(spacing: 12) {
            ForEach(audioDeviceManager.prioritizedDevices.sorted(by: { $0.priority < $1.priority })) { device in
                devicePriorityCard(for: device)
            }
        }
    }
    
    private func devicePriorityCard(for prioritizedDevice: PrioritizedDevice) -> some View {
        let device = audioDeviceManager.availableDevices.first(where: { $0.uid == prioritizedDevice.id })
        return DevicePriorityCard(
            name: prioritizedDevice.name,
            priority: prioritizedDevice.priority,
            isActive: device.map { audioDeviceManager.getCurrentDevice() == $0.id } ?? false,
            isPrioritized: true,
            isAvailable: device != nil,
            canMoveUp: prioritizedDevice.priority > 0,
            canMoveDown: prioritizedDevice.priority < audioDeviceManager.prioritizedDevices.count - 1,
            activeLabel: localizationManager.localizedString("audio.device.active"),
            unavailableLabel: localizationManager.localizedString("audio.device.unavailable"),
            onTogglePriority: { audioDeviceManager.removePrioritizedDevice(id: prioritizedDevice.id) },
            onMoveUp: { moveDeviceUp(prioritizedDevice) },
            onMoveDown: { moveDeviceDown(prioritizedDevice) }
        )
    }
    
    private var availableDevicesList: some View {
        let unprioritizedDevices = audioDeviceManager.availableDevices.filter { device in
            !audioDeviceManager.prioritizedDevices.contains { $0.id == device.uid }
        }
        
        return Group {
            if unprioritizedDevices.isEmpty {
                Text(localizationManager.localizedString("audio.devices.no_additional"))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(unprioritizedDevices, id: \.id) { device in
                    DevicePriorityCard(
                        name: device.name,
                        priority: nil,
                        isActive: audioDeviceManager.getCurrentDevice() == device.id,
                        isPrioritized: false,
                        isAvailable: true,
                        canMoveUp: false,
                        canMoveDown: false,
                        activeLabel: localizationManager.localizedString("audio.device.active"),
                        unavailableLabel: localizationManager.localizedString("audio.device.unavailable"),
                        onTogglePriority: { audioDeviceManager.addPrioritizedDevice(uid: device.uid, name: device.name) },
                        onMoveUp: {},
                        onMoveDown: {}
                    )
                }
            }
        }
    }
    
    private func moveDeviceUp(_ device: PrioritizedDevice) {
        guard device.priority > 0,
              let currentIndex = audioDeviceManager.prioritizedDevices.firstIndex(where: { $0.id == device.id })
        else { return }
        
        var devices = audioDeviceManager.prioritizedDevices
        devices.swapAt(currentIndex, currentIndex - 1)
        updatePriorities(devices)
    }
    
    private func moveDeviceDown(_ device: PrioritizedDevice) {
        guard device.priority < audioDeviceManager.prioritizedDevices.count - 1,
              let currentIndex = audioDeviceManager.prioritizedDevices.firstIndex(where: { $0.id == device.id })
        else { return }
        
        var devices = audioDeviceManager.prioritizedDevices
        devices.swapAt(currentIndex, currentIndex + 1)
        updatePriorities(devices)
    }
    
    private func updatePriorities(_ devices: [PrioritizedDevice]) {
        let updatedDevices = devices.enumerated().map { index, device in
            PrioritizedDevice(id: device.id, name: device.name, priority: index)
        }
        audioDeviceManager.updatePriorities(devices: updatedDevices)
    }
}

struct InputModeCard: View {
    let mode: AudioInputMode
    let isSelected: Bool
    let action: () -> Void
    let localizationManager: LocalizationManager
    
    private var icon: String {
        switch mode {
        case .systemDefault: return "macbook.and.iphone"
        case .custom: return "mic.circle.fill"
        case .prioritized: return "list.number"
        }
    }
    
    private var description: String {
        switch mode {
        case .systemDefault: return localizationManager.localizedString("audio.mode.system_default")
        case .custom: return localizationManager.localizedString("audio.mode.custom")
        case .prioritized: return localizationManager.localizedString("audio.mode.prioritized")
        }
    }
    
    private func getModeTitle(_ mode: AudioInputMode) -> String {
        switch mode {
        case .systemDefault: return localizationManager.localizedString("audio.mode.system_default.title")
        case .custom: return localizationManager.localizedString("audio.mode.custom.title")
        case .prioritized: return localizationManager.localizedString("audio.mode.prioritized.title")
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(getModeTitle(mode))
                        .font(.headline)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.windowBackgroundColor).opacity(0.4))
                    .shadow(color: isSelected ? Color.accentColor.opacity(0.2) : .clear, radius: 8, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.accentColor.opacity(0.5) : .clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct DeviceSelectionCard: View {
    let name: String
    let isSelected: Bool
    let isActive: Bool
    let activeLabel: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .font(.system(size: 18))
                
                Text(name)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if isActive {
                    Label(activeLabel, systemImage: "wave.3.right")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.green.opacity(0.1))
                        )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.windowBackgroundColor).opacity(0.4))
            )
        }
        .buttonStyle(.plain)
    }
}

struct DevicePriorityCard: View {
    let name: String
    let priority: Int?
    let isActive: Bool
    let isPrioritized: Bool
    let isAvailable: Bool
    let canMoveUp: Bool
    let canMoveDown: Bool
    let activeLabel: String
    let unavailableLabel: String
    let onTogglePriority: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    
    var body: some View {
        HStack {
            // Priority number or dash
            if let priority = priority {
                Text("\(priority + 1)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
            } else {
                Text("-")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
            }
            
            // Device name
            Text(name)
                .foregroundStyle(isAvailable ? .primary : .secondary)
            
            Spacer()
            
            // Status and Controls
            HStack(spacing: 12) {
                // Active status
                if isActive {
                    Label(activeLabel, systemImage: "wave.3.right")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.green.opacity(0.1))
                        )
                } else if !isAvailable && isPrioritized {
                    Label(unavailableLabel, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(.windowBackgroundColor).opacity(0.4))
                        )
                }
                
                // Priority controls (only show if prioritized)
                if isPrioritized {
                    HStack(spacing: 2) {
                        Button(action: onMoveUp) {
                            Image(systemName: "chevron.up")
                                .foregroundStyle(canMoveUp ? Color.accentColor : .secondary.opacity(0.5))
                        }
                        .disabled(!canMoveUp)
                        
                        Button(action: onMoveDown) {
                            Image(systemName: "chevron.down")
                                .foregroundStyle(canMoveDown ? Color.accentColor : .secondary.opacity(0.5))
                        }
                        .disabled(!canMoveDown)
                    }
                }
                
                // Toggle priority button
                Button(action: onTogglePriority) {
                    Image(systemName: isPrioritized ? "minus.circle.fill" : "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(isPrioritized ? .red : Color.accentColor)
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.windowBackgroundColor).opacity(0.4))
                .opacity(isAvailable ? 1 : 0.8)
        )
    }
} 
