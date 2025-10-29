import AppKit

/// Lightweight clipboard utility with a minimal API.
/// Rewritten to avoid prior implementation details.
struct ClipboardManager {
    /// Copies the given string to the general pasteboard.
    /// Returns true if the pasteboard accepted the content.
    static func copyToClipboard(_ text: String) -> Bool {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        return pasteboard.setString(text, forType: .string)
    }

    /// Retrieves a string from the general pasteboard, if present.
    static func getClipboardContent() -> String? {
        NSPasteboard.general.string(forType: .string)
    }
}
