import Foundation
import CoreAudio

/// Render an OSStatus value with numeric, hex, and FourCC (if printable) representations.
/// Example: -10877 (0xFFFFD5B3) kAudioUnitErr_InvalidElement
public func describeOSStatus(_ status: OSStatus) -> String {
    let u = UInt32(bitPattern: status)
    let hex = String(format: "0x%08X", u)

    // Attempt FourCC if all bytes are printable ASCII (32...126)
    let bytes: [UInt8] = [
        UInt8((u >> 24) & 0xFF),
        UInt8((u >> 16) & 0xFF),
        UInt8((u >> 8) & 0xFF),
        UInt8(u & 0xFF)
    ]
    let isPrintable = bytes.allSatisfy { $0 >= 32 && $0 <= 126 }
    let fourCC = isPrintable ? String(bytes: bytes, encoding: .ascii) ?? "" : ""

    let name = osstatusSymbolicName(status)

    if let n = name, !fourCC.isEmpty {
        return "\(status) (\(hex), '\(fourCC)') \(n)"
    } else if let n = name {
        return "\(status) (\(hex)) \(n)"
    } else if !fourCC.isEmpty {
        return "\(status) (\(hex), '\(fourCC)')"
    } else {
        return "\(status) (\(hex))"
    }
}

/// Best-effort mapping for common CoreAudio and AudioUnit statuses we care about.
/// Add more as needed during debugging sessions.
private func osstatusSymbolicName(_ status: OSStatus) -> String? {
    switch status {
    case 0: return "noErr"
    // Classic Mac paramErr often appears from low-level AudioToolbox calls
    case -50: return "paramErr"

    // AudioUnit errors (AudioUnitErrors.h)
    case -10879: return "kAudioUnitErr_InvalidProperty"
    case -10878: return "kAudioUnitErr_InvalidParameter"
    case -10877: return "kAudioUnitErr_InvalidElement"
    case -10876: return "kAudioUnitErr_NoConnection"
    case -10875: return "kAudioUnitErr_FailedInitialization"
    case -10874: return "kAudioUnitErr_TooManyFramesToProcess"
    case -10868: return "kAudioUnitErr_PropertyNotInUse"
    case -10865: return "kAudioUnitErr_PropertyNotWritable"
    case -10863: return "kAudioUnitErr_InvalidScope"
    case -10861: return "kAudioUnitErr_Initialized"
    case -10860: return "kAudioUnitErr_InvalidElement"

    // AudioConverter / AudioCodec common FourCC statuses (positive values often render as FourCC)
    case 0x70726F70: return "kAudioConverterErr_PropertyNotSupported ('prop')"
    case 0x666D743F: return "kAudioFormatUnknown ('fmt?')"
    case 0x6D697A21: return "kAudioConverterErr_FormatNotSupported ('miz!')"

    default:
        return nil
    }
}

