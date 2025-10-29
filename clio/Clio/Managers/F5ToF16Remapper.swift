import Foundation
import AppKit

final class F5ToF16Remapper {
    private var runLoopSource: CFRunLoopSource?
    private var eventTap: CFMachPort?
    private var isRunning = false
    private var workerThread: Thread?
    private var workerRunLoop: CFRunLoop?
    private var onF5Down: (() -> Void)?
    private var onF5Up: (() -> Void)?

    // macOS virtual key codes
    private let kVK_F5_Code: CGKeyCode  = 96
    private let kVK_F16_Code: CGKeyCode = 106

    // Common NX key types seen for top-row hardware functions
    private let NX_KEYTYPE_ILLUMINATION_DOWN: Int32 = 0x50
    private let NX_KEYTYPE_DICTATION: Int32 = 0x82

    func start(onF5Down: @escaping () -> Void, onF5Up: (() -> Void)? = nil) {
        guard !isRunning else { return }
        self.onF5Down = onF5Down
        self.onF5Up = onF5Up

        // Only prompt for Accessibility if not already trusted, and avoid doing it synchronously at launch
        if !AXIsProcessTrusted() {
            DispatchQueue.main.async {
                let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
                _ = AXIsProcessTrustedWithOptions(opts)
            }
            // Do not start the tap until permission is granted
            return
        }

        // CGEventType doesn't expose `systemDefined` in all SDKs; bridge from NSEvent
        let systemDefined = CGEventType(rawValue: UInt32(NSEvent.EventType.systemDefined.rawValue))
        let mask: CGEventMask = (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.keyUp.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)
            | (1 << (systemDefined?.rawValue ?? 0))

        let callback: CGEventTapCallBack = { _, type, cgEvent, userInfo in
            guard let userInfo = userInfo else { return Unmanaged.passUnretained(cgEvent) }
            let me = Unmanaged<F5ToF16Remapper>.fromOpaque(userInfo).takeUnretainedValue()

            // Handle tap disabled cases safely
            if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                if let tap = me.eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
                return nil
            }

            // Standard key path
            if type == .keyDown || type == .keyUp {
                let raw = Int(cgEvent.getIntegerValueField(.keyboardEventKeycode))
                var key = raw
                if (176...187).contains(raw) { key = raw - 80 } // normalize 176..187 → 96..107
                if key == Int(me.kVK_F5_Code) {
                    if type == .keyDown {
                        DispatchQueue.main.async { me.onF5Down?() }
                    } else {
                        DispatchQueue.main.async { me.onF5Up?() }
                    }
                    return nil
                }
                return Unmanaged.passUnretained(cgEvent)
            }

            // For all other event types, do not attempt NSEvent conversion on the tap thread.
            // Simply pass the event through unchanged.
            return Unmanaged.passUnretained(cgEvent)
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        ) else { return }

        eventTap = tap
        let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        runLoopSource = src

        let thread = Thread { [weak self] in
            guard let self, let src = self.runLoopSource else { return }
            let rl = CFRunLoopGetCurrent()
            self.workerRunLoop = rl
            CFRunLoopAddSource(rl, src, CFRunLoopMode.commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            print("✅ F5→F16 remapper thread runloop started")
            CFRunLoopRun()
        }
        workerThread = thread
        thread.start()
        isRunning = true
        print("✅ F5→F16 remapper started (event tap)")
    }

    func stop() {
        guard isRunning else { return }
        if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let rl = workerRunLoop {
            CFRunLoopStop(rl)
            CFRunLoopWakeUp(rl)
        }
        eventTap = nil
        runLoopSource = nil
        workerRunLoop = nil
        workerThread = nil
        isRunning = false
        print("✅ F5→F16 remapper stopped")
    }

    // No key synthesis – we call back directly to app logic
}

