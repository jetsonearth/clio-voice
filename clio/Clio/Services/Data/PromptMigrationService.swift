import Foundation

// Minimal, non-derivative migration shim to preserve API without migrating data.
// Since the product does not support user-customizable prompts, this returns
// an empty collection and performs no persistence.

final class PromptMigrationService {
    static func migratePromptsIfNeeded() -> [CustomPrompt] {
        return []
    }
}