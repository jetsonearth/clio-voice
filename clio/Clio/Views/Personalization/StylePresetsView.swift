import SwiftUI
import AppKit

// MARK: - Models
struct AssociatedApp: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: URL?
}

struct StylePreset: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var description: String
    var icon: String
    var prompt: String = ""
    var apps: [AssociatedApp] = []
    var websites: [String] = []
    var isBuiltIn: Bool = false
}

// MARK: - Main View
struct SnippetsView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    // Reset the info card for development - in production this would be false by default
    @AppStorage("StylePresetsInfoCardDismissed") private var infoCardDismissed = false
    
    // Drawer + modal state
    @State private var selectedPreset: StylePreset? = nil
    @State private var editingPreset: StylePreset? = nil
    @State private var showAppGallery = false
    @State private var showAddPresetModal = false
    
    // Current built-in modes - Default is the system fallback, not shown as a card
    @State private var presets: [StylePreset] = [
        StylePreset(
            name: "Code",
            description: "Perfect for developers and technical writing. Formats code elements, filenames, and technical terms with backticks and proper casing.",
            icon: "chevron.left.forwardslash.chevron.right",
            // Show only the user-configurable portion
            prompt: AIPrompts.getCodeVisiblePresetDefault(),
            apps: [],
            websites: [],
            isBuiltIn: true
        ),
        StylePreset(
            name: "Casual Chat",
            description: "Keep it conversational for everyday chats.",
            icon: "bubble.left.and.bubble.right",
            prompt: "",
            apps: [],
            websites: [],
            isBuiltIn: true
        ),
        StylePreset(
            name: "Email",
            description: "Structure content as a clean email.",
            icon: "envelope",
            prompt: "",
            apps: [],
            websites: [],
            isBuiltIn: true
        )
    ]
    
    // MARK: - Default Context-backed Apps/Websites for Presets
    private struct DefaultAppSpec {
        let displayName: String
        let bundleIDs: [String]
        let searchNames: [String]
    }
    
    // Code preset defaults
    private let defaultCodeApps: [DefaultAppSpec] = [
        DefaultAppSpec(displayName: "VS Code", bundleIDs: ["com.microsoft.VSCode", "com.microsoft.VSCode.Insiders"], searchNames: ["Visual Studio Code", "Code"]),
        DefaultAppSpec(displayName: "Cursor", bundleIDs: ["com.todesktop.230313mzl4w4u92"], searchNames: ["Cursor"]),
        DefaultAppSpec(displayName: "Warp", bundleIDs: ["dev.warp.Warp"], searchNames: ["Warp"]),
        DefaultAppSpec(displayName: "Terminal", bundleIDs: ["com.apple.Terminal"], searchNames: ["Terminal"]),
        DefaultAppSpec(displayName: "Windsurf", bundleIDs: ["com.codeium.windsurf"], searchNames: ["Windsurf"]) // bundle ID best-guess; name scan will catch it
    ]
    
    private let defaultCodeWebsites: [String] = [
        "github.com",
        "lovable.dev",
        "v0.dev",
        "bolt.new",
        "replit.com"
    ]
    
    // Email preset defaults
    private let defaultEmailApps: [DefaultAppSpec] = [
        DefaultAppSpec(displayName: "Mail", bundleIDs: ["com.apple.mail"], searchNames: ["Mail", "Apple Mail"]),
        DefaultAppSpec(displayName: "Outlook", bundleIDs: ["com.microsoft.Outlook"], searchNames: ["Microsoft Outlook", "Outlook"])
    ]
    private let defaultEmailWebsites: [String] = [
        "gmail.com",
        "outlook.com"
    ]
    
    // Casual Chat preset defaults
    private let defaultCasualApps: [DefaultAppSpec] = [
        DefaultAppSpec(displayName: "Discord", bundleIDs: ["com.hnc.Discord", "com.discord"], searchNames: ["Discord"]),
        DefaultAppSpec(displayName: "WeChat", bundleIDs: ["com.tencent.xinWeChat"], searchNames: ["WeChat"]),
        DefaultAppSpec(displayName: "Messages", bundleIDs: ["com.apple.iChat"], searchNames: ["Messages", "iMessage"]),
        DefaultAppSpec(displayName: "WhatsApp", bundleIDs: ["net.whatsapp.WhatsApp", "com.whatsapp.desktop", "com.whatsapp.WhatsApp"], searchNames: ["WhatsApp"]),
        DefaultAppSpec(displayName: "Telegram", bundleIDs: ["ru.keepcoder.Telegram", "org.telegram.desktop"], searchNames: ["Telegram"])
    ]
    private let defaultCasualWebsites: [String] = [
        "x.com",
        "instagram.com"
    ]
    
    private func scanApplicationsIndex() -> [String: URL] {
        let fm = FileManager.default
        let searchPaths: [URL] = [
            URL(fileURLWithPath: "/Applications", isDirectory: true),
            URL(fileURLWithPath: "/System/Applications", isDirectory: true),
            URL(fileURLWithPath: "/Applications/Utilities", isDirectory: true),
            fm.homeDirectoryForCurrentUser.appendingPathComponent("Applications", isDirectory: true)
        ]
        var index: [String: URL] = [:]
        for dir in searchPaths {
            guard let enumerator = fm.enumerator(at: dir, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else { continue }
            for case let url as URL in enumerator where url.pathExtension.lowercased() == "app" {
                let name = url.deletingPathExtension().lastPathComponent
                if index[name] == nil { index[name] = url }
            }
        }
        return index
    }
    
    private func resolveInstalledApps(from specs: [DefaultAppSpec]) -> [AssociatedApp] {
        let workspace = NSWorkspace.shared
        let appIndex = scanApplicationsIndex()
        var resolved: [AssociatedApp] = []
        for spec in specs {
            var foundURL: URL?
            // Try known bundle IDs first
            for bundleID in spec.bundleIDs {
                if let url = workspace.urlForApplication(withBundleIdentifier: bundleID) {
                    foundURL = url
                    break
                }
            }
            // Fallback to name scan
            if foundURL == nil {
                for name in spec.searchNames {
                    if let url = appIndex[name] {
                        foundURL = url
                        break
                    }
                }
            }
            if let url = foundURL {
                resolved.append(AssociatedApp(name: spec.displayName, url: url))
            }
        }
        // Deduplicate by name
        var seen = Set<String>()
        let unique = resolved.filter { seen.insert($0.name).inserted }
        return unique
    }
    
    private func resolveInstalledDefaultCodeApps() -> [AssociatedApp] {
        return resolveInstalledApps(from: defaultCodeApps)
    }
    
    private func resolveInstalledDefaultEmailApps() -> [AssociatedApp] {
        return resolveInstalledApps(from: defaultEmailApps)
    }
    
    private func resolveInstalledDefaultCasualApps() -> [AssociatedApp] {
        return resolveInstalledApps(from: defaultCasualApps)
    }
    
    private func populateCodeModeDefaultsIfNeeded() {
        // After renaming the built-in preset to "Code", make sure we target the right one
        guard let idx = presets.firstIndex(where: { $0.name == "Code" && $0.isBuiltIn }) else { return }
        var preset = presets[idx]
        // Only populate when empty or merge without duplicates
        if preset.apps.isEmpty {
            preset.apps = resolveInstalledDefaultCodeApps()
        } else {
            let resolved = resolveInstalledDefaultCodeApps()
            for app in resolved where !preset.apps.contains(where: { $0.name == app.name }) {
                preset.apps.append(app)
            }
        }
        if preset.websites.isEmpty {
            preset.websites = defaultCodeWebsites
        } else {
            for site in defaultCodeWebsites where !preset.websites.contains(site) {
                preset.websites.append(site)
            }
        }
        presets[idx] = preset
    }
    
    private func populateEmailModeDefaultsIfNeeded() {
        guard let idx = presets.firstIndex(where: { $0.name == "Email" && $0.isBuiltIn }) else { return }
        var preset = presets[idx]
        if preset.apps.isEmpty {
            preset.apps = resolveInstalledDefaultEmailApps()
        } else {
            let resolved = resolveInstalledDefaultEmailApps()
            for app in resolved where !preset.apps.contains(where: { $0.name == app.name }) {
                preset.apps.append(app)
            }
        }
        if preset.websites.isEmpty {
            preset.websites = defaultEmailWebsites
        } else {
            for site in defaultEmailWebsites where !preset.websites.contains(site) {
                preset.websites.append(site)
            }
        }
        presets[idx] = preset
    }
    
    private func populateCasualModeDefaultsIfNeeded() {
        guard let idx = presets.firstIndex(where: { $0.name == "Casual Chat" && $0.isBuiltIn }) else { return }
        var preset = presets[idx]
        if preset.apps.isEmpty {
            preset.apps = resolveInstalledDefaultCasualApps()
        } else {
            let resolved = resolveInstalledDefaultCasualApps()
            for app in resolved where !preset.apps.contains(where: { $0.name == app.name }) {
                preset.apps.append(app)
            }
        }
        if preset.websites.isEmpty {
            preset.websites = defaultCasualWebsites
        } else {
            for site in defaultCasualWebsites where !preset.websites.contains(site) {
                preset.websites.append(site)
            }
        }
        presets[idx] = preset
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                // Base content
                ScrollView {
                    VStack(spacing: 0) {
                        // Header (left-aligned title with trailing action button)
                        HStack {
                            VStack(alignment: .leading, spacing: 16) {
Text(localizationManager.localizedString("navigation.snippets"))
                                    .fontScaled(size: 30, weight: .semibold)
                                    .foregroundColor(DarkTheme.textPrimary)
                            }
                            Spacer()
                            AddNewButton(localizationManager.localizedString("style_presets.add_new"), action: {
                                // Open drawer with a fresh, empty preset
                                let newPreset = StylePreset(
                                    name: "",
                                    description: "",
                                    icon: "square.and.pencil",
                                    prompt: "",
                                    apps: [],
                                    websites: [],
                                    isBuiltIn: false
                                )
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)) {
                                    editingPreset = newPreset
                                    selectedPreset = newPreset
                                }
                            })
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 32)
                        .padding(.bottom, 16)
                        
                        // Closeable info card - reset to show for development
                        if !infoCardDismissed {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 8) {
Text(localizationManager.localizedString("style_presets.info_card.title"))
                                            .fontScaled(size: 20, weight: .semibold)
                                            .foregroundColor(DarkTheme.textPrimary)
Text(localizationManager.localizedString("style_presets.description"))
                                            .fontScaled(size: 14)
                                            .foregroundColor(DarkTheme.textSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                    Button(action: { infoCardDismissed = true }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(DarkTheme.textPrimary)
                                            .padding(8)
                                            .background(
                                                Circle()
                                                    .fill(DarkTheme.textPrimary.opacity(0.12))
                                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
                                            )
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DarkTheme.textPrimary.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(DarkTheme.textPrimary.opacity(0.12), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 40)
                            .padding(.bottom, 24)
                        }
                        
                        // Style Presets Cards
                        LazyVStack(spacing: 12) {
                            ForEach(presets) { preset in
                                StylePresetSimpleCard(preset: preset) {
                            // Open drawer to edit with animation
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)) {
                                editingPreset = preset
                                selectedPreset = preset
                            }
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    }
                }
                .background(Color.clear)
.onAppear {
                    // Load previously saved presets (if any) and merge once
                    let saved = StylePresetStore.shared.getForView()
                    if !saved.isEmpty {
                        // Merge by name to avoid duplicate built-ins
                        for sp in saved {
                            if let idx = presets.firstIndex(where: { $0.name == sp.name && $0.isBuiltIn == sp.isBuiltIn }) {
                                presets[idx] = sp
                            } else {
                                presets.append(sp)
                            }
                        }
                    }
                    // Reset info card for development purposes
                    infoCardDismissed = false
                    // Populate built-in presets from curated defaults
                    populateCodeModeDefaultsIfNeeded()
                    populateEmailModeDefaultsIfNeeded()
                    populateCasualModeDefaultsIfNeeded()
                }
                
            // Dimmed overlay + Drawer
            if selectedPreset != nil, let editing = editingPreset {
                // Dimming layer
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { closeDrawer() }
                HStack {
                    Spacer()
                    
                    // Responsive drawer (roughly half of available width, clamped)
                    let drawerWidth = max(560, min(proxy.size.width * 0.5, 780))
                    
                    PresetDrawer(
                        preset: editing,
                        onClose: { closeDrawer() },
                        onSave: { updated in
                            // Save back into list. If this is a new preset (not yet in array), append it.
                            if let idx = presets.firstIndex(where: { $0.id == updated.id }) {
                                presets[idx] = updated
                            } else {
                                presets.append(updated)
                            }
                            // Persist all presets so runtime respects immediately
                            persistPresets()
                            closeDrawer()
                        },
                        onDelete: { toDelete in
                            presets.removeAll { $0.id == toDelete.id }
                            closeDrawer()
                        }
                    )
                    .frame(width: drawerWidth)
                    .frame(maxHeight: .infinity)
                    .transition(.asymmetric(
                        insertion: AnyTransition.move(edge: .trailing).combined(with: .opacity),
                        removal: AnyTransition.move(edge: .trailing).combined(with: .opacity)
                    ))
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0), value: selectedPreset != nil)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0), value: selectedPreset)
        } // Closing brace for GeometryReader
    }
    
    private func closeDrawer() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)) {
            selectedPreset = nil
            editingPreset = nil
            showAppGallery = false
        }
    }
    
    private func persistPresets() {
        Task { @MainActor in
            StylePresetStore.shared.replace(with: presets)
        }
    }
}

// MARK: - Simple Card (accent-only)
struct StylePresetSimpleCard: View {
    let preset: StylePreset
    var onTap: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Name (no leading icon)
Text(preset.name)
                .fontScaled(size: 15, weight: .semibold)
                .foregroundColor(DarkTheme.textPrimary)
            
            Spacer()
            
            // Right: up to 4 app icons/badges (neutral)
            HStack(spacing: 4) {
                ForEach(preset.apps.prefix(4)) { app in
                    AppIconBadge(app: app)
                }
            }
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DarkTheme.textPrimary.opacity(isHovered ? 0.35 : 0.25), lineWidth: isHovered ? 1.25 : 1)
                )
        )
        .onTapGesture(perform: onTap)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) { isHovered = hovering }
        }
    }
}

// App icon badge. Uses the app's actual icon when URL is available, otherwise falls back to initials.
struct AppIconBadge: View {
        let app: AssociatedApp
        
        private func appInitials(from name: String) -> String {
            name.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined()
        }
        
        private func appIcon(for url: URL?) -> NSImage? {
            guard let path = url?.path else { return nil }
            let icon = NSWorkspace.shared.icon(forFile: path)
            icon.size = NSSize(width: 16, height: 16)
            return icon
        }
        
        var body: some View {
            let initials = appInitials(from: app.name)
            let nsImage = appIcon(for: app.url)
            
            Group {
                if let nsImage {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                } else {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(DarkTheme.textPrimary.opacity(0.10))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Text(initials.isEmpty ? "•" : initials)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(DarkTheme.textPrimary)
                        )
                }
            }
        }
    }

// MARK: - Drawer
struct PresetDrawer: View {
        @EnvironmentObject private var localizationManager: LocalizationManager
        @State var preset: StylePreset
        var onClose: () -> Void
        var onSave: (StylePreset) -> Void
        var onDelete: (StylePreset) -> Void
        
        @State private var websiteInput: String = ""
        @State private var showAppPicker = false
        
        var body: some View {
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Button(action: onClose) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(DarkTheme.surfaceBackground))
                    }
                    .buttonStyle(.plain)
                    
Text(localizationManager.localizedString("style_presets.drawer.title"))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                    
                    Spacer()
                    
                    // Delete button (moved to header, left of Save)
                    Button(action: { onDelete(preset) }) {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                            Text(localizationManager.localizedString("style_presets.drawer.delete"))
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red.opacity(0.7), lineWidth: 1)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.06)))
                        )
                    }
                    .buttonStyle(.plain)
                    
Button(action: { onSave(preset) }) {
                        Text(localizationManager.localizedString("general.save"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .overlay(Divider(), alignment: .bottom)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Mode name
                        SectionCard(title: localizationManager.localizedString("style_presets.drawer.mode_name")) {
                            TextField(localizationManager.localizedString("style_presets.drawer.mode_placeholder"), text: $preset.name)
                                .textFieldStyle(.roundedBorder)
                                .frame(height: 28)
                        }
                        // Activate section card
                        SectionCard(title: localizationManager.localizedString("style_presets.drawer.activate")) {
                            VStack(alignment: .leading, spacing: 12) {
// Apps grid
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 64, maximum: 88), spacing: 10)], spacing: 10) {
                                    // Add App button
                                    Button(action: { showAppPicker = true }) {
                                        VStack(spacing: 6) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 9)
                                                    .fill(DarkTheme.textPrimary.opacity(0.08))
                                                    .frame(width: 44, height: 44)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 9)
                                                            .stroke(DarkTheme.textPrimary.opacity(0.20), lineWidth: 1)
                                                    )
                                                Image(systemName: "plus")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(DarkTheme.textPrimary)
                                            }
                                            Text(localizationManager.localizedString("style_presets.drawer.add_app"))
                                                .font(.system(size: 10))
                                                .foregroundColor(DarkTheme.textPrimary)
                                                .lineLimit(1)
                                        }
                                        .frame(width: 64)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    // Selected apps
                                    ForEach(preset.apps) { app in
                                        SelectedAppTile(app: app) {
                                            // Remove app
                                            preset.apps.removeAll { $0.id == app.id }
                                        }
                                    }
                                }
                                
                                // Website field
HStack(spacing: 8) {
                                    TextField(localizationManager.localizedString("style_presets.drawer.website_placeholder"), text: $websiteInput)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(height: 28)
Button(localizationManager.localizedString("style_presets.drawer.add_website")) {
                                        let trimmed = websiteInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                        guard !trimmed.isEmpty else { return }
                                        if !preset.websites.contains(trimmed) { preset.websites.append(trimmed) }
                                        websiteInput = ""
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .stroke(DarkTheme.textPrimary.opacity(0.6), lineWidth: 1)
                                    )
                                    .foregroundColor(DarkTheme.textPrimary)
                                }
                                
                                // Website chips
                                WrapWebsites(websites: preset.websites) { toRemove in
                                    preset.websites.removeAll { $0 == toRemove }
                                }
                            }
                        }
                        
                        // Prompt editor card
SectionCard(title: localizationManager.localizedString("style_presets.drawer.prompt")) {
                            TextEditor(text: $preset.prompt)
                                .font(.system(.caption, design: .monospaced))
                                .padding(8)
                                .frame(minHeight: 180)
                                .background(RoundedRectangle(cornerRadius: 8).fill(DarkTheme.surfaceBackground))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(DarkTheme.border, lineWidth: 1))
                        }
                        
                    }
                    .padding(16)
                }
            }
            .background(
                // Attached to right edge; round only leading corners for a panel feel
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 14,
                            bottomLeadingRadius: 14,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        )
                    )
                    .shadow(color: .black.opacity(0.28), radius: 24, x: -4, y: 0)
            )
            // App search modal sheet (search dropdown style)
            .sheet(isPresented: $showAppPicker) {
                AppSearchPicker { found in
                    // Avoid duplicates by name or url
                    if !preset.apps.contains(where: { $0.name == found.name || $0.url == found.url }) {
                        preset.apps.append(AssociatedApp(name: found.name, url: found.url))
                    }
                    // Auto close sheet after selection
#if os(macOS)
                    NSApp.keyWindow?.makeFirstResponder(nil)
#endif
                    // Keep sheet open to allow multiple adds; comment next line to keep open
                    // showAppPicker = false
                }
            }
        }
    }

// Selected app tile with hover-to-delete
struct SelectedAppTile: View {
        let app: AssociatedApp
        let onDelete: () -> Void
        @State private var isHovered = false
        
        private func appIcon(for url: URL?) -> NSImage? {
            guard let path = url?.path else { return nil }
            let icon = NSWorkspace.shared.icon(forFile: path)
            icon.size = NSSize(width: 40, height: 40)
            return icon
        }
        
        var body: some View {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    // App icon
                    Group {
                        if let nsImage = appIcon(for: app.url) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                        } else {
                            // Fallback for apps without URL
                            RoundedRectangle(cornerRadius: 9)
                                .fill(DarkTheme.textPrimary.opacity(0.10))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(app.name.prefix(2))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(DarkTheme.textPrimary)
                                )
                        }
                    }
                    .cornerRadius(10)
                    
                    // Delete button on hover
                    if isHovered {
                        Button(action: onDelete) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                                .background(Circle().fill(.white))
                        }
                        .buttonStyle(.plain)
                        .offset(x: 4, y: -4)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                
                Text(app.name)
                    .font(.system(size: 10))
                    .foregroundColor(DarkTheme.textPrimary)
                    .lineLimit(1)
                    .frame(width: 64)
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
        }
    }

// Section card wrapper with accent-neutral style
struct SectionCard<Content: View>: View {
        let title: String
        @ViewBuilder var content: () -> Content
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                content()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thinMaterial)
            )
        }
    }

// MARK: - App Search Picker (modal)  
struct AppSearchPicker: View {
            struct FoundApp: Identifiable, Hashable {
                let id = UUID()
                let name: String
                let url: URL
            }
            
            var onSelect: (FoundApp) -> Void
            @Environment(\.dismiss) private var dismiss
            
            @State private var allApps: [FoundApp] = []
            @State private var query: String = ""
            @State private var isScanning: Bool = true
            
            private func scanApplications() {
                isScanning = true
                DispatchQueue.global(qos: .userInitiated).async {
                    let fm = FileManager.default
                    let searchPaths: [URL] = [
                        URL(fileURLWithPath: "/Applications", isDirectory: true),
                        URL(fileURLWithPath: "/System/Applications", isDirectory: true),
                        URL(fileURLWithPath: "/Applications/Utilities", isDirectory: true),
                        (fm.homeDirectoryForCurrentUser.appendingPathComponent("Applications", isDirectory: true))
                    ]
                    var results: [FoundApp] = []
                    for dir in searchPaths {
                        guard let enumerator = fm.enumerator(at: dir, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else { continue }
                        for case let fileURL as URL in enumerator {
                            if fileURL.pathExtension.lowercased() == "app" {
                                let name = fileURL.deletingPathExtension().lastPathComponent
                                results.append(FoundApp(name: name, url: fileURL))
                            }
                        }
                    }
                    // Deduplicate by name, prefer /Applications over others
                    let deduped = Dictionary(grouping: results, by: { $0.name }).compactMap { (_, group) -> FoundApp? in
                        return group.sorted { a, b in
                            if a.url.path.hasPrefix("/Applications") && !b.url.path.hasPrefix("/Applications") { return true }
                            if b.url.path.hasPrefix("/Applications") && !a.url.path.hasPrefix("/Applications") { return false }
                            return a.url.path < b.url.path
                        }.first
                    }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                    
                    DispatchQueue.main.async {
                        self.allApps = deduped
                        self.isScanning = false
                    }
                }
            }
            
            private var filteredApps: [FoundApp] {
                let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
                if q.isEmpty { return allApps.prefix(50).map { $0 } }
                return allApps.filter { $0.name.localizedCaseInsensitiveContains(q) }
            }
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(DarkTheme.textSecondary)
                        TextField(NSLocalizedString("power_mode.modal.search_apps", comment: "Search applications"), text: $query)
                            .textFieldStyle(.plain)
                            .disableAutocorrection(true)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).fill(DarkTheme.surfaceBackground))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(DarkTheme.border, lineWidth: 1))
                    
                    if isScanning {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text(NSLocalizedString("power_mode.modal.loading_apps", comment: "Loading applications..."))
                                .foregroundColor(DarkTheme.textSecondary)
                                .font(.system(size: 12))
                        }
                        .padding(.vertical, 8)
                    } else if filteredApps.isEmpty {
Text(NSLocalizedString("style_presets.drawer.no_apps_found", comment: "No apps found"))
                            .foregroundColor(DarkTheme.textSecondary)
                            .font(.system(size: 12))
                            .padding(.vertical, 8)
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 6) {
                                ForEach(filteredApps) { app in
                                    Button(action: { onSelect(app) }) {
                                        HStack(spacing: 12) {
                                            // Simple app icon without extra outlines
                                            Image(nsImage: NSWorkspace.shared.icon(forFile: app.url.path))
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 32, height: 32)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(app.name)
                                                    .font(.system(size: 13))
                                                    .foregroundColor(DarkTheme.textPrimary)
                                                Text(app.url.deletingLastPathComponent().lastPathComponent)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(DarkTheme.textSecondary)
                                            }
                                            Spacer()
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .contentShape(Rectangle())
                                        .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(maxHeight: 280)
                    }
                    
                    HStack {
                        Spacer()
                        Button(NSLocalizedString("general.done", comment: "Done")) {
                            dismiss()
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor))
                    }
                }
                .padding(16)
                .frame(width: 420)
                .onAppear(perform: scanApplications)
            }
        }


// Websites wrap view
struct WrapWebsites: View {
            let websites: [String]
            var onRemove: (String) -> Void
            
            var body: some View {
                var rows: [[String]] = []
                var currentRow: [String] = []
                var currentWidth: CGFloat = 0
                let maxWidth: CGFloat = 560 // allow up to ~5 chips per row on typical drawer width
                let spacing: CGFloat = 6
                
                for site in websites {
                    let width = CGFloat(9 * max(4, site.count)) // tighter estimate to fit more chips
                    if currentWidth + width + spacing > maxWidth {
                        rows.append(currentRow)
                        currentRow = [site]
                        currentWidth = width + spacing
                    } else {
                        currentRow.append(site)
                        currentWidth += width + spacing
                    }
                }
                if !currentRow.isEmpty { rows.append(currentRow) }
                
                return VStack(alignment: .leading, spacing: 6) {
                    ForEach(0..<rows.count, id: \.self) { i in
                        HStack(spacing: spacing) {
                            ForEach(rows[i], id: \.self) { site in
                                HStack(spacing: 4) {
                                    Text(site)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(DarkTheme.textPrimary)
                                    Button(action: { onRemove(site) }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 9, weight: .bold))
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundColor(DarkTheme.textPrimary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(DarkTheme.textPrimary.opacity(0.08)))
                                .overlay(Capsule().stroke(DarkTheme.textPrimary.opacity(0.25), lineWidth: 1))
                            }
                        }
                    }
                }
            }
        }
    
