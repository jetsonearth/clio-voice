import Foundation
import AppKit
import os

/// Best-effort active browser URL detector.
/// Supports Safari and common Chromium-based browsers via AppleScript.
/// Returns the lowercased host if available (e.g., "docs.google.com").
enum ActiveBrowserURL {
    private static let logger = Logger(subsystem: "com.cliovoice.clio", category: "browser")

    /// Attempt to extract the active tab URL for the frontmost browser and return its host.
    static func currentHost(frontBundleId: String?) -> String? {
        guard let bundleId = frontBundleId else { return nil }

        // Map bundle IDs to their AppleScript application names and script snippets
        let appName: String?
        var script: String? = nil

        switch bundleId {
        case "com.apple.Safari":
            appName = "Safari"
            script = "tell application \"Safari\" to if (exists front document) then return URL of front document"

        case "com.google.Chrome", "com.google.Chrome.canary", "org.chromium.Chromium":
            appName = "Google Chrome"
            script = "tell application \"Google Chrome\" to if (exists front window) then return URL of active tab of front window"

        case "com.microsoft.edgemac":
            appName = "Microsoft Edge"
            script = "tell application \"Microsoft Edge\" to if (exists front window) then return URL of active tab of front window"

        case "com.brave.Browser":
            appName = "Brave Browser"
            script = "tell application \"Brave Browser\" to if (exists front window) then return URL of active tab of front window"

        case "com.operasoftware.Opera":
            appName = "Opera"
            script = "tell application \"Opera\" to if (exists front window) then return URL of active tab of front window"

        case "company.thebrowser.Browser":
            // Arc browser (best-effort; AppleScript support can vary by version)
            appName = "Arc"
            script = "tell application \"Arc\" to if (exists front window) then return URL of active tab of front window"

        default:
            appName = nil
        }

        // First try AppleScript for supported browsers
        if let appName, let script {
            if let urlString = runAppleScript(script) ?? runViaSystemEvents(appName: appName) {
                if let host = normalizeHost(from: urlString) {
                    return host
                }
            }
        }

        // Fallback: infer from window title for common web apps opened inside webview shells
        if let title = frontmostWindowTitle() {
            if let inferred = hostFromWindowTitle(title) {
                logger.notice("🌐 [BROWSER-FALLBACK] Using inferred host from title '\\(title)' → \\(inferred)")
                return inferred
            }
        }
        return nil
    }

    private static func normalizeHost(from urlString: String) -> String? {
        guard let url = URL(string: urlString), let rawHost = url.host?.lowercased() else { return nil }
        if rawHost.hasPrefix("www.") { return String(rawHost.dropFirst(4)) }
        return rawHost
    }

    private static func runAppleScript(_ source: String) -> String? {
        let script = NSAppleScript(source: source)
        var error: NSDictionary?
        let result = script?.executeAndReturnError(&error)
        if let error {
            logger.debug("⚠️ [BROWSER] AppleScript error: \(error.description, privacy: .public)")
        }
        return result?.stringValue
    }

    private static func frontmostWindowTitle() -> String? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        let pid = app.processIdentifier
        let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
        // Prefer layer 0 windows with same PID
        if let info = list.first(where: { (info) in
            let ownerPid = info[kCGWindowOwnerPID as String] as? pid_t ?? -1
            let layer = info[kCGWindowLayer as String] as? Int32 ?? 0
            return ownerPid == pid && layer == 0
        }) {
            if let title = info[kCGWindowName as String] as? String, !title.isEmpty { return title }
            return info[kCGWindowOwnerName as String] as? String
        }
        return nil
    }

    private static func hostFromWindowTitle(_ title: String) -> String? {
        let t = title.lowercased()
        if t.contains("google docs") { return "docs.google.com" }
        if t.contains("google sheets") { return "docs.google.com" }
        if t.contains("google slides") { return "docs.google.com" }
        return nil
    }

    /// Generic fallback using System Events UI scripting when a browser lacks a script dictionary.
    /// Returns nil by default to avoid fragile behavior; left as a minimal stub for future expansion.
    private static func runViaSystemEvents(appName: String) -> String? {
        // Intentionally conservative: UI scripting is brittle. Keep disabled unless needed.
        return nil
    }
}
