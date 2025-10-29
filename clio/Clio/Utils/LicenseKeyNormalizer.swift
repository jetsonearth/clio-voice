import Foundation

extension String {
    /// Normalizes a license key typed or pasted by the user to the canonical form
    /// expected by the backend. This fixes common issues like smart dashes and
    /// invisible characters introduced by copy/paste.
    /// - Returns: Uppercased string containing only A–Z, 0–9 and hyphens (-).
    func normalizedLicenseKey() -> String {
        // Start with uppercase for consistency
        var s = self.uppercased()

        // Replace common dash variants with ASCII hyphen-minus
        let replacements: [String: String] = [
            "\u{2013}": "-", // en dash –
            "\u{2014}": "-", // em dash —
            "\u{2212}": "-", // minus sign −
            "\u{2010}": "-", // hyphen ‐
            "\u{00AD}": ""   // soft hyphen ­ (remove)
        ]
        for (from, to) in replacements { s = s.replacingOccurrences(of: from, with: to) }

        // Trim whitespace/newlines and remove interior spaces
        s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        s = s.replacingOccurrences(of: " ", with: "")

        // Keep only A–Z, 0–9 and '-'
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-")
        s = String(s.unicodeScalars.filter { allowed.contains($0) })

        // Collapse duplicate hyphens
        while s.contains("--") { s = s.replacingOccurrences(of: "--", with: "-") }

        return s
    }
}
