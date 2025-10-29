import Foundation
import AppKit

/// Utilities for opening a prefilled support email to Clio support.
/// Public API preserved: `generateSupportEmailURL()` and `openSupportEmail()`.
struct EmailSupport {
    // MARK: - Public
    static func generateSupportEmailURL() -> URL? {
        let subject = composeSubject()
        let body = composeBody()

        // Use a conservative query allowed set for mailto query parameters
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "+&=?%#")

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
        let recipient = SupportConfig.supportEmail

        return URL(string: "mailto:\(recipient)?subject=\(encodedSubject)&body=\(encodedBody)")
    }

    static func openSupportEmail() {
        guard let emailURL = generateSupportEmailURL() else { return }
        NSWorkspace.shared.open(emailURL)
    }

    // MARK: - Composition
    private static func composeSubject() -> String {
        "Clio Support Request"
    }

    private static func composeBody() -> String {
        let sys = composeSystemInfo()
        return """
        Hi Clio Support,

        Please describe the issue in a few sentences, including the steps to reproduce and what you expected to happen.

        Helpful tip: including a short screen recording often speeds up resolution.
        Support site: https://www.cliovoice.com

        ---
        System Information
        \(sys)
        """
    }

    private static func composeSystemInfo() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let model = readMacModel()
        let cpu = readCPUBrandString()
        let memory = formattedPhysicalMemory()

        return """
        App Version: \(appVersion)
        macOS Version: \(osVersion)
        Device: \(model)
        CPU: \(cpu)
        Memory: \(memory)
        """
    }

    // MARK: - Hardware helpers
    private static func readMacModel() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    private static func readCPUBrandString() -> String {
        var size = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var buffer = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &buffer, &size, nil, 0)
        return String(cString: buffer)
    }

    private static func formattedPhysicalMemory() -> String {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        return ByteCountFormatter.string(fromByteCount: Int64(totalMemory), countStyle: .memory)
    }
}