import Foundation
import AppKit

// Persistent store for Style Presets so prompts apply immediately without restart
// Stores minimal info needed at runtime and maps to/from the UI model

struct StoredAssociatedApp: Codable, Hashable {
    var name: String
    var bundleId: String?
    var appPath: String?
}

struct StoredStylePreset: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var prompt: String
    var apps: [StoredAssociatedApp]
    var websites: [String]
    var isBuiltIn: Bool
}

@MainActor
final class StylePresetStore: ObservableObject {
    static let shared = StylePresetStore()
    
    @Published private(set) var presets: [StoredStylePreset] = []
    private let storageKey = "style_presets_store_v1"
    
    private init() {
        load()
    }
    
    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([StoredStylePreset].self, from: data) {
            self.presets = decoded
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    // Replace with view-layer presets
    func replace(with viewPresets: [StylePreset]) {
        self.presets = viewPresets.map { view in
            let storedApps: [StoredAssociatedApp] = view.apps.map { a in
                var bundleId: String? = nil
                if let url = a.url, let b = Bundle(url: url)?.bundleIdentifier {
                    bundleId = b
                }
                return StoredAssociatedApp(name: a.name, bundleId: bundleId, appPath: a.url?.path)
            }
            return StoredStylePreset(
                id: view.id,
                name: view.name,
                prompt: view.prompt,
                apps: storedApps,
                websites: view.websites,
                isBuiltIn: view.isBuiltIn
            )
        }
        save()
    }
    
    // Retrieve presets and map to UI model (best-effort URLs for icons)
    func getForView() -> [StylePreset] {
        return presets.map { p in
            let apps: [AssociatedApp] = p.apps.map { a in
                let url = a.appPath != nil ? URL(fileURLWithPath: a.appPath!) : nil
                return AssociatedApp(name: a.name, url: url)
            }
            return StylePreset(
                name: p.name,
                description: "",
                icon: "square.and.pencil",
                prompt: p.prompt,
                apps: apps,
                websites: p.websites,
                isBuiltIn: p.isBuiltIn
            )
        }
    }
    
    // Find an active prompt by bundle ID or website host. Returns nil if none.
    func activePrompt(bundleId: String?, activeHost: String?) -> String? {
        let bid = bundleId?.lowercased()
        let host = activeHost?.lowercased()
        for preset in presets {
            // Skip empty prompts
            let prompt = preset.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            if prompt.isEmpty { continue }
            // App match
            if let bid = bid {
                if preset.apps.contains(where: { ($0.bundleId?.lowercased() == bid) }) {
                    return prompt
                }
            }
            // Website match (host contains rule or exact match)
            if let host = host, !preset.websites.isEmpty {
                if preset.websites.contains(where: { host.contains($0.lowercased()) }) {
                    return prompt
                }
            }
        }
        return nil
    }

    // Find the active preset (object) by bundle ID or website host. Returns nil if none.
    func activePreset(bundleId: String?, activeHost: String?) -> StoredStylePreset? {
        let bid = bundleId?.lowercased()
        let host = activeHost?.lowercased()
        for preset in presets {
            if let bid = bid, preset.apps.contains(where: { $0.bundleId?.lowercased() == bid }) {
                return preset
            }
            if let host = host, !preset.websites.isEmpty,
               preset.websites.contains(where: { host.contains($0.lowercased()) }) {
                return preset
            }
        }
        return nil
    }
}
