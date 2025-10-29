import Foundation
import AppKit
import Carbon.HIToolbox

final class GlobalHotKey {
    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?
    private var onPress: (() -> Void)?

    deinit {
        unregister()
    }

    @discardableResult
    func register(keyCode: UInt32, modifiers: UInt32 = 0, onPress: @escaping () -> Void) -> OSStatus {
        unregister()
        self.onPress = onPress

        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))

        let statusHandler = InstallEventHandler(GetEventDispatcherTarget(), { _, event, userData in
            guard let userData = userData else { return noErr }
            let manager = Unmanaged<GlobalHotKey>.fromOpaque(userData).takeUnretainedValue()
            var hotKeyID = EventHotKeyID()
            GetEventParameter(event,
                              EventParamName(kEventParamDirectObject),
                              EventParamType(typeEventHotKeyID),
                              nil,
                              MemoryLayout<EventHotKeyID>.size,
                              nil,
                              &hotKeyID)
            if hotKeyID.signature == OSType(UInt32(bigEndian: 0x434C494F)) && hotKeyID.id == 1 {
                manager.onPress?()
            }
            return noErr
        }, 1, &eventSpec, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), &handlerRef)

        guard statusHandler == noErr else { return statusHandler }

        var hotKeyID = EventHotKeyID(signature: OSType(UInt32(bigEndian: 0x434C494F)), id: 1)
        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)
        return status
    }

    func unregister() {
        if let hotKeyRef { UnregisterEventHotKey(hotKeyRef); self.hotKeyRef = nil }
        if let handlerRef { RemoveEventHandler(handlerRef); self.handlerRef = nil }
        onPress = nil
    }
}


