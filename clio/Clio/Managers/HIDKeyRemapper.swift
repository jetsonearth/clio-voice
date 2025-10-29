import Foundation

final class HIDKeyRemapper {
    private let hidutilPath = "/usr/bin/hidutil"
    // Keyboard usage page F5 (standard F5)
    private let srcF5Keyboard: UInt64 = 0x70000003E
    // Consumer usage page Dictation (when top-row sends special function)
    // Matches NX_KEYTYPE_DICTATION (0x82) on Consumer page (0x0C → high nibble 0xC)
    private let srcF5DictationConsumer: UInt64 = 0xC00000082
    // Destination: keyboard usage page F16
    private let dstF16: UInt64 = 0x70000006B
    private var didInsertMapping = false

    func applyF5ToF16() {
        guard var mapping = currentUserKeyMapping() else { return }
        var changed = false
        let sources: [UInt64] = [srcF5Keyboard, srcF5DictationConsumer]
        for src in sources {
            if !mapping.contains(where: { ($0["HIDKeyboardModifierMappingSrc"] as? UInt64) == src }) {
                mapping.append([
                    "HIDKeyboardModifierMappingSrc": src,
                    "HIDKeyboardModifierMappingDst": dstF16
                ])
                changed = true
                print("🔧 [hidutil] Adding mapping \(String(format:"0x%08llX", src)) → 0x70000006B (F16)")
            }
        }
        if changed {
            setUserKeyMapping(mapping)
        } else {
            print("🔧 [hidutil] Mapping already present, skipping set")
        }
        didInsertMapping = true
    }

    func revertF5MappingIfInserted() {
        guard didInsertMapping, var mapping = currentUserKeyMapping() else { return }
        let before = mapping.count
        mapping.removeAll { entry in
            if let src = entry["HIDKeyboardModifierMappingSrc"] as? UInt64 {
                return src == srcF5Keyboard || src == srcF5DictationConsumer
            }
            return false
        }
        let removed = before - mapping.count
        print("🔧 [hidutil] Removed \(removed) F5 mappings")
        setUserKeyMapping(mapping)
        didInsertMapping = false
    }

    // MARK: - Helpers
    private func currentUserKeyMapping() -> [[String: Any]]? {
        let out = run(["property", "--get", "UserKeyMapping"])?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let out, !out.isEmpty else { return [] }
        // Output can be like: "UserKeyMapping = (\n    { ... },\n);"
        if out.contains("=") { // crude parse to JSON-ish
            let jsonPart = out.components(separatedBy: "=").dropFirst().joined(separator: "=")
                .replacingOccurrences(of: ";", with: "")
            let jsonString = jsonPart
                .replacingOccurrences(of: "(\n", with: "[")
                .replacingOccurrences(of: "\n)", with: "]")
                .replacingOccurrences(of: "\n", with: "")
            if let data = jsonString.data(using: .utf8),
               let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                return arr
            }
        }
        // Some systems already return pure JSON
        if let data = out.data(using: .utf8),
           let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let arr = obj["UserKeyMapping"] as? [[String: Any]] {
            return arr
        }
        return []
    }

    private func setUserKeyMapping(_ mapping: [[String: Any]]) {
        guard let data = try? JSONSerialization.data(withJSONObject: ["UserKeyMapping": mapping], options: []),
              let json = String(data: data, encoding: .utf8) else { return }
        if let out = run(["property", "--set", json]) {
            print("🔧 [hidutil] set result: \(out.trimmingCharacters(in: .whitespacesAndNewlines))")
        } else {
            print("❌ [hidutil] failed to run hidutil set")
        }
    }

    private func run(_ args: [String]) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: hidutilPath)
        task.arguments = args
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        do { try task.run() } catch { print("❌ [hidutil] run error: \(error)"); return nil }
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
}


