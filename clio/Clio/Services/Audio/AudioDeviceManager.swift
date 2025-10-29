import Foundation
import CoreAudio
import AVFoundation
import os

fileprivate func _dm(_ status: OSStatus) -> String {
    let u = UInt32(bitPattern: status)
    let hex = String(format: "0x%08X", u)
    let bytes: [UInt8] = [UInt8((u>>24)&0xFF), UInt8((u>>16)&0xFF), UInt8((u>>8)&0xFF), UInt8(u&0xFF)]
    let isPrintable = bytes.allSatisfy { $0 >= 32 && $0 <= 126 }
    let fourCC = isPrintable ? String(bytes: bytes, encoding: .ascii) ?? "" : ""
    let name: String? = (status == -10877 ? "kAudioUnitErr_InvalidElement" : (status == 0 ? "noErr" : nil))
    if let n = name, !fourCC.isEmpty { return "\(status) (\(hex), '\(fourCC)') \(n)" }
    if let n = name { return "\(status) (\(hex)) \(n)" }
    if !fourCC.isEmpty { return "\(status) (\(hex), '\(fourCC)')" }
    return "\(status) (\(hex))"
}

struct PrioritizedDevice: Codable, Identifiable {
    let id: String // Device UID
    let name: String
    let priority: Int
}

enum AudioInputMode: String, CaseIterable {
    case systemDefault = "System Default"
    case custom = "Custom Device"
    case prioritized = "Prioritized"
}

final class AudioDeviceManager: ObservableObject {
    private let logger = Logger(subsystem: "com.cliovoice.clio", category: "AudioDeviceManager")
    @Published var availableDevices: [(id: AudioDeviceID, uid: String, name: String)] = []
    @Published var selectedDeviceID: AudioDeviceID?
    @Published var inputMode: AudioInputMode = .custom
    @Published var prioritizedDevices: [PrioritizedDevice] = []
     var fallbackDeviceID: AudioDeviceID?
    
    var isRecordingActive: Bool = false
    private var lastPinnedRestoreAt: Date? = nil
    
    static let shared = AudioDeviceManager()
    
    private init() {
        setupFallbackDevice()
        loadPrioritizedDevices()
        loadAvailableDevices { [weak self] in
            self?.initializeSelectedDevice()
            // Sanitize selection on first load: avoid unstable/virtual devices
            if let self = self, let sel = self.selectedDeviceID, self.isLikelyUnstable(deviceID: sel) {
                self.logger.warning("Detected unstable input device at startup – switching to built-in mic for reliability")
                _ = self.forceSwitchToBuiltIn()
            }
        }
        
        // Load saved input mode
        if let savedMode = UserDefaults.standard.string(forKey: "audioInputMode"),
           let mode = AudioInputMode(rawValue: savedMode) {
            inputMode = mode
        }
        
        // Setup device change notifications
        setupDeviceChangeNotifications()
    }

    // MARK: - Reliability Heuristics

    /// Best-effort detection of virtual/aggregate or otherwise unstable inputs by name
    private func isVirtualOrAggregate(name: String) -> Bool {
        let lower = name.lowercased()
        let patterns: [String] = [
            "mixed", "aggregate", "loopback", "blackhole", "soundflower", "vb", "virtual", "rogue amoeba"
        ]
        return patterns.contains { lower.contains($0) }
    }

    /// Continuity/iOS routed devices that must never be used for capture
    private func isContinuityOrIOS(name: String) -> Bool {
        let lower = name.lowercased()
        return lower.contains("iphone") || lower.contains("ipad") || lower.contains("continuity") || lower.contains("sidecar") || lower.contains("camera") || lower.contains("ios")
    }

    /// Returns summed input channel count for the device, if determinable
    func getInputChannelCount(deviceID: AudioDeviceID) -> UInt32? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        var propertySize: UInt32 = 0
        let sizeStatus = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &propertySize)
        if sizeStatus != noErr { return nil }
        let rawPtr = UnsafeMutableRawPointer.allocate(byteCount: Int(propertySize), alignment: MemoryLayout<AudioBufferList>.alignment)
        defer { rawPtr.deallocate() }
        let listPtr = rawPtr.bindMemory(to: AudioBufferList.self, capacity: 1)
        let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &propertySize, listPtr)
        if status != noErr { return nil }
        let list = UnsafeMutableAudioBufferListPointer(listPtr)
        var channels: UInt32 = 0
        for buf in list { channels += buf.mNumberChannels }
        return channels
    }

    /// Quick sample-rate sanity for input devices
    private func isSampleRateSane(_ rate: Double) -> Bool {
        let allowed: Set<Double> = [16000, 24000, 44100, 48000, 96000]
        return allowed.contains(rate)
    }

    /// Heuristic: treat virtual/aggregate names, Continuity/iOS routes, or odd sample rates as unstable.
    /// IMPORTANT: Do NOT penalize legitimate 2-channel (stereo) inputs; many Macs expose built‑in mics as 2ch.
    func isLikelyUnstable(deviceID: AudioDeviceID) -> Bool {
        guard deviceID != 0 else { return true }
        let name = getDeviceName(deviceID: deviceID) ?? "unknown"
        let ch = getInputChannelCount(deviceID: deviceID) ?? 0
        var rate: Double = 0
        if let fmt: AudioStreamBasicDescription = getDeviceProperty(deviceID: deviceID, selector: kAudioDevicePropertyStreamFormat, scope: kAudioDevicePropertyScopeInput) {
            rate = fmt.mSampleRate
        }
        // Unstable if: clearly virtual/aggregate, or Continuity/iOS, or weird/unsupported sample rate, or absurd channel count (> 2)
        if isContinuityOrIOS(name: name) { return true }
        if isVirtualOrAggregate(name: name) { return true }
        if rate > 0 && !isSampleRateSane(rate) { return true }
        if ch > 2 { return true }
        return false
    }

    /// Find a built-in/internal microphone if present (strict, never returns Continuity/iOS devices)
    func getBuiltInMic() -> AudioDeviceID? {
        // Strict candidates (exclude generic "microphone" to avoid matching "iPhone Microphone")
        let nameCandidates = ["built-in", "internal", "macbook"]
        // First pass: strict name match + channel count == 1 + not virtual + not continuity
        if let best = availableDevices.first(where: { dev in
            let lower = dev.name.lowercased()
            guard nameCandidates.contains(where: { lower.contains($0) }) else { return false }
            if isContinuityOrIOS(name: dev.name) { return false }
            if isVirtualOrAggregate(name: dev.name) { return false }
            let ch = getInputChannelCount(deviceID: dev.id) ?? 0
            // Accept mono or stereo built-in mics
            return ch == 1 || ch == 2
        }) { return best.id }

        // Second pass: any non-virtual, non-continuity mono or stereo physical input
        if let monoPhysical = availableDevices.first(where: { dev in
            if isContinuityOrIOS(name: dev.name) { return false }
            if isVirtualOrAggregate(name: dev.name) { return false }
            let ch = getInputChannelCount(deviceID: dev.id) ?? 0
            return ch == 1 || ch == 2
        }) { return monoPhysical.id }

        // Fallback: if system default is safe and not continuity, use it
        if let sys = getSystemDefaultInputDeviceID(), let name = getDeviceName(deviceID: sys), !isContinuityOrIOS(name: name), !isVirtualOrAggregate(name: name) {
            return sys
        }
        return nil
    }

    /// Force switch to built-in mic and PIN selection to a stable device (custom mode).
    /// Returns true if switched.
    @discardableResult
    func forceSwitchToBuiltIn() -> Bool {
        guard let target = getBuiltInMic() else {
            logger.error("Failed to resolve a safe built-in microphone (no suitable device found)")
            ToastBanner.shared.show(title: "Microphone blocked", subtitle: "Disable Continuity Microphone in macOS Settings and retry")
            return false
        }
        if let name = getDeviceName(deviceID: target), isContinuityOrIOS(name: name) || isLikelyUnstable(deviceID: target) {
            logger.error("Resolved built-in mic is forbidden or unstable (\(name)) — aborting switch")
            ToastBanner.shared.show(title: "Unstable input rejected (\(name))", subtitle: "Using Continuity/iPhone mic is blocked. Please select Mac's internal mic.")
            return false
        }
        logger.warning("Switching input to built-in microphone (ID: \(target)) for reliability")
        DispatchQueue.main.async {
            // Pin to a stable, explicit device to avoid system flipping to iPhone/aggregate
            self.inputMode = .custom
            self.selectedDeviceID = target
            UserDefaults.standard.set(target, forKey: "selectedAudioDeviceID")
            do {
                try AudioDeviceConfiguration.setDefaultInputDevice(target)
            } catch {
                self.logger.error("Failed to set built-in microphone: \(error.localizedDescription)")
            }
            self.notifyDeviceChange()
        }
        return true
    }
    
    /// Heuristic flag whether current default input device is Bluetooth (e.g., AirPods)
    var isCurrentInputBluetooth: Bool {
        let deviceID: AudioDeviceID = getCurrentDevice()
        guard deviceID != 0 else { return false }
        if let name = getDeviceName(deviceID: deviceID)?.lowercased() {
            return name.contains("airpods") || name.contains("bluetooth") || name.contains("beats")
        }
        return false
    }

    /// Heuristic flag whether current default output device is Bluetooth (e.g., AirPods)
    var isCurrentOutputBluetooth: Bool {
        // Read default output device via CoreAudio
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var outputDeviceID = AudioDeviceID(0)
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &propertySize,
            &outputDeviceID
        )
        if status != noErr || outputDeviceID == 0 { return false }
        if let name = getDeviceName(deviceID: outputDeviceID)?.lowercased() {
            return name.contains("airpods") || name.contains("bluetooth") || name.contains("beats")
        }
        return false
    }
    
     func setupFallbackDevice() {
        // Prefer the robust helper that reads the live system default via CoreAudio
        if let deviceID = getSystemDefaultInputDeviceID() {
            fallbackDeviceID = deviceID
            if let name = getDeviceName(deviceID: deviceID) {
                logger.info("Fallback device set to: \(name) (ID: \(deviceID))")
            }
        } else {
            logger.error("Failed to get fallback device")
        }
    }
    
    private func initializeSelectedDevice() {
        if inputMode == .prioritized {
            selectHighestPriorityAvailableDevice()
            return
        }
        
        // Try to load saved device
        if let savedID = UserDefaults.standard.object(forKey: "selectedAudioDeviceID") as? AudioDeviceID {
            // Verify the saved device still exists and is valid
            if isDeviceAvailable(savedID) {
                if let name = getDeviceName(deviceID: savedID), isContinuityOrIOS(name: name) || isLikelyUnstable(deviceID: savedID) {
                    logger.warning("Saved device is forbidden/unstable — selecting preferred safe device")
                    selectPreferredDevice()
                } else {
                    selectedDeviceID = savedID
                    logger.info("Loaded saved device ID: \(savedID)")
                    if let name = getDeviceName(deviceID: savedID) { logger.info("Using saved device: \(name)") }
                }
            } else {
                logger.warning("Saved device ID \(savedID) is no longer available")
                selectPreferredDevice()
            }
        } else if inputMode == .systemDefault {
            // If system default is unstable (e.g. iPhone/aggregate), pin to built‑in immediately
            if let sys = getSystemDefaultInputDeviceID() {
                let name = getDeviceName(deviceID: sys) ?? "unknown"
                if isContinuityOrIOS(name: name) || isLikelyUnstable(deviceID: sys) {
                    logger.warning("System default input (\(name)) appears unstable – forcing built‑in mic")
                    _ = forceSwitchToBuiltIn()
                } else {
                    selectedDeviceID = nil
                    logger.info("Trusting system default input: \(name)")
                }
            } else {
                selectPreferredDevice()
            }
        } else {
            selectPreferredDevice()
        }
    }
    
    private func selectPreferredDevice() {
        // Prefer built-in/physical mic; avoid virtual/aggregate devices
        if let builtIn = getBuiltInMic() {
            logger.info("Using preferred built-in microphone as default")
            selectDevice(id: builtIn)
            return
        }
        // Fall back to system default mode
        fallbackToDefaultDevice()
    }
    
    private func isDeviceAvailable(_ deviceID: AudioDeviceID) -> Bool {
        return availableDevices.contains { $0.id == deviceID }
    }
    
    private func fallbackToDefaultDevice() {
        // Instead of just setting a fallback device ID, explicitly switch to system default mode.
        // selectInputMode(.systemDefault) will handle setting inputMode,
        // clearing selectedDeviceID, and updating UserDefaults.
        selectInputMode(.systemDefault)
        logger.info("Switched to system default audio input mode due to fallback.")
    }
    
    func loadAvailableDevices(completion: (() -> Void)? = nil) {
        // logger.info("Loading available audio devices...")  // Reduced logging verbosity
// StructuredLog.shared.log(cat: .audio, evt: "devices_scan", lvl: .info, [String: Any]())
        var propertySize: UInt32 = 0
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var result = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &propertySize
        )
        
        let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
        // logger.info("Found \(deviceCount) total audio devices")  // Reduced logging verbosity
        
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        
        result = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &propertySize,
            &deviceIDs
        )
        
        if result != noErr {
logger.error("Error getting audio devices: \(_dm(result))")
            return
        }
        
        let devices = deviceIDs.compactMap { deviceID -> (id: AudioDeviceID, uid: String, name: String)? in
            guard let name = getDeviceName(deviceID: deviceID),
                  let uid = getDeviceUID(deviceID: deviceID),
                  isInputDevice(deviceID: deviceID) else {
                return nil
            }
            return (id: deviceID, uid: uid, name: name)
        }
        
        // Structured per-device logs (name, uid_hash, ch)
// StructuredLog.shared.log(cat: .audio, evt: "devices", lvl: .info, ["count": devices.count])
        for d in devices {
            let ch = getInputChannelCount(deviceID: d.id) ?? 0
// StructuredLog.shared.log(cat: .audio, evt: "device", lvl: .info, [
            //     "uid_hash": String(d.uid.hashValue),
            //     "name": d.name,
            //     "ch": Int(ch)
            // ])
        }
        
        // logger.info("Found \(devices.count) input devices")  // Reduced logging verbosity
        // devices.forEach { device in
        //     logger.info("Available device: \(device.name) (ID: \(device.id))")
        // }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.availableDevices = devices.map { ($0.id, $0.uid, $0.name) }
            // Verify current selection is still valid
            if let currentID = self.selectedDeviceID, !devices.contains(where: { $0.id == currentID }) {
                self.logger.warning("Currently selected device is no longer available")
                self.fallbackToDefaultDevice()
            }
            completion?()
        }
    }
    
    func getDeviceName(deviceID: AudioDeviceID) -> String? {
        let name: CFString? = getDeviceProperty(deviceID: deviceID,
                                              selector: kAudioDevicePropertyDeviceNameCFString)
        return name as String?
    }
    
    private func isInputDevice(deviceID: AudioDeviceID) -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var propertySize: UInt32 = 0
        var result = AudioObjectGetPropertyDataSize(
            deviceID,
            &address,
            0,
            nil,
            &propertySize
        )
        
if result != noErr {
logger.error("Error checking input capability for device \(deviceID): \(_dm(result))")
            return false
        }
        
        // Allocate a raw buffer with the exact byte size reported by CoreAudio.
        let rawPtr = UnsafeMutableRawPointer.allocate(
            byteCount: Int(propertySize),
            alignment: MemoryLayout<AudioBufferList>.alignment
        )
        defer { rawPtr.deallocate() }
        let bufferListPtr = rawPtr.bindMemory(to: AudioBufferList.self, capacity: 1)

result = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &propertySize,
            bufferListPtr
        )
        
        if result != noErr {
logger.error("Error getting stream configuration for device \(deviceID): \(_dm(result))")
            return false
        }
        
        let list = UnsafeMutableAudioBufferListPointer(bufferListPtr)
        return list.count > 0
    }
    
    func selectDevice(id: AudioDeviceID) {
        logger.info("Selecting device with ID: \(id)")
        if let uid = getDeviceUID(deviceID: id), let name = getDeviceName(deviceID: id) {
StructuredLog.shared.log(cat: .audio, evt: "select_device", lvl: .info, [
                "uid_hash": String(uid.hashValue),
                "name": name
            ])
        }
        if let name = getDeviceName(deviceID: id) {
            logger.info("Selected device name: \(name)")
        }
        
        if isDeviceAvailable(id) {
            DispatchQueue.main.async {
                // Do not persist likely unstable devices; switch to system default instead
                if self.isLikelyUnstable(deviceID: id) {
                    self.logger.warning("Refusing to persist likely-unstable input; switching to system default")
                    self.selectInputMode(.systemDefault)
                } else {
                    self.selectedDeviceID = id
                    UserDefaults.standard.set(id, forKey: "selectedAudioDeviceID")
                    self.logger.info("Device selection saved")
                }
                // Apply the selection to the system so the input actually switches now (off-main)
                Task.detached(priority: .userInitiated) { [id] in
                    do {
                        try AudioDeviceConfiguration.setDefaultInputDevice(id)
                    } catch {
                        self.logger.error("Failed to apply selected input device: \(error.localizedDescription)")
                    }
                }
                self.notifyDeviceChange()
            }
        } else {
            logger.error("Attempted to select unavailable device: \(id)")
            fallbackToDefaultDevice()
        }
    }
    
    func selectInputMode(_ mode: AudioInputMode) {
        inputMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "audioInputMode")
        
        if mode == .systemDefault {
            selectedDeviceID = nil
            UserDefaults.standard.removeObject(forKey: "selectedAudioDeviceID")
        } else if selectedDeviceID == nil {
            if let firstDevice = availableDevices.first {
                selectDevice(id: firstDevice.id)
            }
        }
        
        notifyDeviceChange()
    }
    
    func getCurrentDevice() -> AudioDeviceID {
        switch inputMode {
        case .systemDefault:
            // Always read the live system default rather than a cached fallback
            return getSystemDefaultInputDeviceID() ?? fallbackDeviceID ?? 0
        case .custom:
            return selectedDeviceID ?? fallbackDeviceID ?? 0
        case .prioritized:
            let sortedDevices = prioritizedDevices.sorted { $0.priority < $1.priority }
            for device in sortedDevices {
                if let available = availableDevices.first(where: { $0.uid == device.id }) {
                    return available.id
                }
            }
            return fallbackDeviceID ?? 0
        }
    }

    /// Returns the current system default input device ID, if available
    private func getSystemDefaultInputDeviceID() -> AudioDeviceID? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID = AudioDeviceID(0)
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &propertySize,
            &deviceID
        )
if status != noErr {
logger.error("Failed to read system default input device: \(_dm(status))")
            return nil
        }
        return deviceID == 0 ? nil : deviceID
    }
    
    private func loadPrioritizedDevices() {
        if let data = UserDefaults.standard.data(forKey: "prioritizedDevices"),
           let devices = try? JSONDecoder().decode([PrioritizedDevice].self, from: data) {
            prioritizedDevices = devices
            logger.info("Loaded \(devices.count) prioritized devices")
        }
    }
    
    func savePrioritizedDevices() {
        if let data = try? JSONEncoder().encode(prioritizedDevices) {
            UserDefaults.standard.set(data, forKey: "prioritizedDevices")
            logger.info("Saved \(self.prioritizedDevices.count) prioritized devices")
        }
    }
    
    func addPrioritizedDevice(uid: String, name: String) {
        guard !prioritizedDevices.contains(where: { $0.id == uid }) else { return }
        let nextPriority = (prioritizedDevices.map { $0.priority }.max() ?? -1) + 1
        let device = PrioritizedDevice(id: uid, name: name, priority: nextPriority)
        prioritizedDevices.append(device)
        savePrioritizedDevices()
    }
    
    func removePrioritizedDevice(id: String) {
        let wasSelected = selectedDeviceID == availableDevices.first(where: { $0.uid == id })?.id
        prioritizedDevices.removeAll { $0.id == id }
        
        // Reindex remaining devices to ensure continuous priority numbers
        let updatedDevices = prioritizedDevices.enumerated().map { index, device in
            PrioritizedDevice(id: device.id, name: device.name, priority: index)
        }
        
        prioritizedDevices = updatedDevices
        savePrioritizedDevices()
        
        // If we removed the currently selected device, select the next best option
        if wasSelected && inputMode == .prioritized {
            selectHighestPriorityAvailableDevice()
        }
    }
    
    func updatePriorities(devices: [PrioritizedDevice]) {
        prioritizedDevices = devices
        savePrioritizedDevices()
        
        if inputMode == .prioritized {
            selectHighestPriorityAvailableDevice()
        }
        
        notifyDeviceChange()
    }
    
    private func selectHighestPriorityAvailableDevice() {
        // Sort by priority (lowest number = highest priority)
        let sortedDevices = prioritizedDevices.sorted { $0.priority < $1.priority }
        
        // Try each device in priority order
        for device in sortedDevices {
            if let availableDevice = availableDevices.first(where: { $0.uid == device.id }) {
                selectedDeviceID = availableDevice.id
                logger.info("Selected prioritized device: \(device.name) (Priority: \(device.priority))")
                
                // Actually set the device as the current input device (off-main)
                Task.detached(priority: .userInitiated) {
                    do {
                        try AudioDeviceConfiguration.setDefaultInputDevice(availableDevice.id)
                    } catch {
                        self.logger.error("Failed to set prioritized device: \(error.localizedDescription)")
                    }
                }
                UserDefaults.standard.set(availableDevice.id, forKey: "selectedAudioDeviceID")
                return
            }
        }
        
        // If no prioritized device is available, fall back to default
        fallbackToDefaultDevice()
    }
    
    private func setupDeviceChangeNotifications() {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let systemObjectID = AudioObjectID(kAudioObjectSystemObject)
        
        // Add listener for device changes
        let status = AudioObjectAddPropertyListener(
            systemObjectID,
            &address,
            { (_, _, _, userData) -> OSStatus in
                let manager = Unmanaged<AudioDeviceManager>.fromOpaque(userData!).takeUnretainedValue()
                DispatchQueue.main.async {
                    manager.handleDeviceListChange()
                }
                return noErr
            },
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )
        
        if status != noErr {
            logger.error("Failed to add device change listener: \(status)")
        } else {
            logger.info("Successfully added device change listener")
        }

        // Also listen for default input device changes so we can react immediately
        var defaultInputAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        let defaultStatus = AudioObjectAddPropertyListener(
            systemObjectID,
            &defaultInputAddress,
            { (_, _, _, userData) -> OSStatus in
                let manager = Unmanaged<AudioDeviceManager>.fromOpaque(userData!).takeUnretainedValue()
                DispatchQueue.main.async {
                    manager.handleDefaultInputChange()
                }
                return noErr
            },
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )
        if defaultStatus != noErr {
            logger.error("Failed to add default input change listener: \(defaultStatus)")
        } else {
            logger.info("Successfully added default input change listener")
        }
    }
    
    private func handleDeviceListChange() {
        logger.info("Device list change detected")
// StructuredLog.shared.log(cat: .audio, evt: "route_change", lvl: .info, ["reason": "devices_changed"])
        loadAvailableDevices { [weak self] in
            guard let self = self else { return }
            
            // If in prioritized mode, recheck the device selection
            if self.inputMode == .prioritized {
                self.selectHighestPriorityAvailableDevice()
            }
            // If in custom mode and selected device is no longer available, fallback
            else if self.inputMode == .custom,
                    let currentID = self.selectedDeviceID,
                    !self.isDeviceAvailable(currentID) {
                self.fallbackToDefaultDevice()
            }
            
            // Notify listeners of changes (even while recording, so recorder can reconfigure)
            NotificationCenter.default.post(name: NSNotification.Name("AudioDeviceChanged"), object: nil)
        }
    }

    private func handleDefaultInputChange() {
        logger.info("Default input device changed by system")
StructuredLog.shared.log(cat: .audio, evt: "route_change", lvl: .info, ["reason": "default_input_change"])
        if let liveDefault = getSystemDefaultInputDeviceID() {
            fallbackDeviceID = liveDefault
            let name = getDeviceName(deviceID: liveDefault) ?? "unknown"
            // If we have a pinned custom device, override flips back to it
            if let pinned = selectedDeviceID {
                if liveDefault != pinned {
                    let now = Date()
                    if let last = lastPinnedRestoreAt, now.timeIntervalSince(last) < 0.75 {
                        // Suppress thrash: ignore repeated re-apply within debounce window
                        logger.debug("Suppressing rapid re-apply of pinned input (debounce)")
                    } else {
                        lastPinnedRestoreAt = now
                        logger.warning("OS switched default to \(name) while pinned to custom – restoring pinned device")
                        Task.detached(priority: .userInitiated) {
                            do {
                                try AudioDeviceConfiguration.setDefaultInputDevice(pinned)
                            } catch {
                                self.logger.error("Failed to restore pinned input device: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            } else if inputMode == .systemDefault {
                // If trusting system default but it becomes unstable, force built-in
                if isContinuityOrIOS(name: name) || isLikelyUnstable(deviceID: liveDefault) {
                    logger.warning("System default changed to unstable (\(name)) – forcing built‑in mic")
                    _ = forceSwitchToBuiltIn()
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name("AudioDeviceChanged"), object: nil)
    }
    
    func getDeviceUID(deviceID: AudioDeviceID) -> String? {
        let uid: CFString? = getDeviceProperty(deviceID: deviceID,
                                             selector: kAudioDevicePropertyDeviceUID)
        return uid as String?
    }
    
    deinit {
        // Remove the listener when the manager is deallocated
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectRemovePropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            { (_, _, _, userData) -> OSStatus in
                return noErr
            },
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )
    }
    
    // MARK: - Helper Methods
    private func createPropertyAddress(selector: AudioObjectPropertySelector,
                                    scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
                                    element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain) -> AudioObjectPropertyAddress {
        return AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: scope,
            mElement: element
        )
    }
    
    private func getDeviceProperty<T>(deviceID: AudioDeviceID,
                                    selector: AudioObjectPropertySelector,
                                    scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> T? {
        // Skip invalid device IDs
        guard deviceID != 0 else { return nil }

        var address = createPropertyAddress(selector: selector, scope: scope)

        // Ask CoreAudio for the exact size we need for this property
        var propertySize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &propertySize)
        if status != noErr || propertySize == 0 {
            logger.error("Failed to query size for property \(selector) on device \(deviceID): \(_dm(status))")
            return nil
        }

        // Allocate a raw buffer of the requested size and read the property into it
        let rawPtr = UnsafeMutableRawPointer.allocate(byteCount: Int(propertySize), alignment: MemoryLayout<UInt8>.alignment)
        defer { rawPtr.deallocate() }

        status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &propertySize, rawPtr)
        if status != noErr {
            logger.error("Failed to get device property \(selector) for device \(deviceID): \(_dm(status))")
            return nil
        }

        // Bind the memory to the requested type and return the value
        return rawPtr.assumingMemoryBound(to: T.self).pointee
    }
    
    private func notifyDeviceChange() {
        NotificationCenter.default.post(name: NSNotification.Name("AudioDeviceChanged"), object: nil)
    }
}
