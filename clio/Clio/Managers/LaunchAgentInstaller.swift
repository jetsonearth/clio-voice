import Foundation

final class LaunchAgentInstaller {
    private let agentId = "com.clio.f5remap"
    private var agentPath: String { (NSHomeDirectory() as NSString).appendingPathComponent("Library/LaunchAgents/\(agentId).plist") }
    private var domainTarget: String { "gui/\(getuid())" }

    func installF5ToF16Agent() {
        let plist: [String: Any] = [
            "Label": agentId,
            "ProgramArguments": [
                "/usr/bin/hidutil",
                "property",
                "--set",
                "{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\":0x70000003E,\"HIDKeyboardModifierMappingDst\":0x70000006B},{\"HIDKeyboardModifierMappingSrc\":0xC00000082,\"HIDKeyboardModifierMappingDst\":0x70000006B}]}"
            ],
            "RunAtLoad": true
        ]

        do {
            try FileManager.default.createDirectory(atPath: (agentPath as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
            let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
            try data.write(to: URL(fileURLWithPath: agentPath), options: .atomic)
            _ = run(["bootout", domainTarget, agentPath])
            _ = run(["bootstrap", domainTarget, agentPath])
            _ = run(["enable", domainTarget + "/" + agentId])
            if let out = run(["kickstart", "-k", domainTarget + "/" + agentId]) { print("✅ LaunchAgent kickstart: \(out)") }
        } catch {
            print("❌ LaunchAgent install failed: \(error)")
        }
    }

    func removeAgent() {
        _ = run(["bootout", domainTarget, agentPath])
        try? FileManager.default.removeItem(atPath: agentPath)
    }

    private func run(_ args: [String]) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        task.arguments = args
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        do { try task.run() } catch { return nil }
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
}


