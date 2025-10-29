import Foundation
import os.log

class WordReplacementService {
    static let shared = WordReplacementService()
    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "WordReplacementService")
    
    private init() {}
    
    // MARK: - Built-in Developer Vocabulary
    
    /// Critical ASR failures that affect all developers (Tier 1 - Universal Impact)
    /// These corrections provide immediate value with 99%+ failure rates
    private static let universalDeveloperCorrections: [String: String] = [
        // Git commands (99% failure rate, used 15-50 times daily)
        "get add": "git add",
        "get commit": "git commit",
        "get push": "git push",
        "get pull": "git pull", 
        "get clone": "git clone",
        "get checkout": "git checkout",
        "get merge": "git merge",
        "get rebase": "git rebase",
        "get status": "git status",
        "get log": "git log",
        "get diff": "git diff",
        "get branch": "git branch",
        "get fetch": "git fetch",
        "get reset": "git reset",
        "get stash": "git stash",
        
        // Core technical acronyms (85-98% failure rates)
        "jason": "JSON",
        "j son": "JSON",
        "a p i": "API",
        "c l i": "CLI",
        "sequel": "SQL",
        "s q l": "SQL",
        "u r l": "URL",
        "h t m l": "HTML",
        "c s s": "CSS",
        "u i": "UI",
        "u x": "UX"
    ]
    
    /// Framework-specific corrections (Tier 2 - Context-Aware)
    private static let frameworkCorrections: [String: String] = [
        // React/JavaScript
        "use state": "useState",
        "use effect": "useEffect",
        "use context": "useContext",
        "use memo": "useMemo",
        "use callback": "useCallback",
        "use ref": "useRef",
        "java script": "JavaScript",
        "type script": "TypeScript",
        "node j s": "Node.js",
        "react j s": "React.js",
        "view j s": "Vue.js",
        "angular j s": "Angular.js",
        
        // SwiftUI/iOS
        "v stack": "VStack",
        "h stack": "HStack",
        "z stack": "ZStack",
        "lazy v grid": "LazyVGrid",
        "lazy h grid": "LazyHGrid",
        "at state": "@State",
        "at binding": "@Binding",
        "at published": "@Published",
        "at observed object": "@ObservedObject",
        "at state object": "@StateObject",
        "at environment object": "@EnvironmentObject",
        "swift u i": "SwiftUI",
        "u i kit": "UIKit",
        "x code": "Xcode",
        
        // Database terms
        "my sequel": "MySQL",
        "post gres": "PostgreSQL",
        "mongo d b": "MongoDB",
        "redis": "Redis",
        "elastic search": "Elasticsearch",
        
        // Cloud & DevOps
        "docker": "Docker",
        "kubernetes": "Kubernetes",
        "a w s": "AWS",
        "amazon web services": "AWS",
        "google cloud": "Google Cloud",
        "microsoft azure": "Microsoft Azure",
        "azure": "Azure",
        "github": "GitHub",
        "git lab": "GitLab",
        "bit bucket": "Bitbucket"
    ]
    
    /// Programming language corrections
    private static let languageCorrections: [String: String] = [
        "python": "Python",
        "java": "Java",
        "c plus plus": "C++",
        "c sharp": "C#",
        "go lang": "Go",
        "rust": "Rust",
        "kotlin": "Kotlin",
        "swift": "Swift",
        "ruby": "Ruby",
        "p h p": "PHP",
        "scala": "Scala",
        "dart": "Dart",
        "flutter": "Flutter"
    ]
    
    /// Get all built-in developer corrections
    private func getBuiltInDeveloperCorrections() -> [String: String] {
        var corrections: [String: String] = [:]
        corrections.merge(Self.universalDeveloperCorrections) { _, new in new }
        corrections.merge(Self.frameworkCorrections) { _, new in new }
        corrections.merge(Self.languageCorrections) { _, new in new }
        return corrections
    }
    
    func applyReplacements(to text: String) -> String {
        logger.notice("🔄 WordReplacement: Starting replacement process for text: '\(text)'")
        
        let userReplacements = UserDefaults.standard.dictionary(forKey: "wordReplacements") as? [String: String] ?? [:]
        let isDeveloperVocabEnabled = UserDefaults.standard.bool(forKey: "IsDeveloperVocabularyEnabled")
        
        // Combine user replacements with built-in developer corrections if enabled
        var allReplacements: [String: String] = [:]
        
        if isDeveloperVocabEnabled {
            allReplacements.merge(self.getBuiltInDeveloperCorrections()) { _, new in new }
            logger.notice("👨‍💻 WordReplacement: Developer vocabulary enabled, added \(self.getBuiltInDeveloperCorrections().count) built-in corrections")
        }
        
        // User replacements take precedence over built-in corrections
        allReplacements.merge(userReplacements) { _, new in new }
        
        guard !allReplacements.isEmpty else {
            logger.notice("⚠️ WordReplacement: No replacements found")
            return text
        }
        
        logger.notice("📋 WordReplacement: Found \(allReplacements.count) total replacements (\(userReplacements.count) user + \(isDeveloperVocabEnabled ? self.getBuiltInDeveloperCorrections().count : 0) built-in)")
        
        var modifiedText = text
        var replacementCount = 0
        
        // Apply each replacement (case-insensitive, flexible matching)
        for (original, replacement) in allReplacements {
            let beforeReplacement = modifiedText
            
            // Apply the replacement using flexible pattern matching
            modifiedText = applyReplacement(original: original, replacement: replacement, to: modifiedText)
            
            if beforeReplacement != modifiedText {
                replacementCount += 1
                logger.notice("✅ WordReplacement: Successfully replaced '\(original)' with '\(replacement)'")
            }
        }
        
        logger.notice("🎯 WordReplacement: Completed with \(replacementCount) replacements applied")
        return modifiedText
    }
    
    /// Apply a single replacement with flexible pattern matching optimized for developer vocabulary
    private func applyReplacement(original: String, replacement: String, to text: String) -> String {
        let trimmedOriginal = original.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedReplacement = replacement.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedOriginal.isEmpty && !trimmedReplacement.isEmpty else {
            return text
        }
        
        // For developer vocabulary, use more flexible matching patterns
        let patterns = createMatchingPatterns(for: trimmedOriginal)
        
        var modifiedText = text
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(modifiedText.startIndex..., in: modifiedText)
                let newText = regex.stringByReplacingMatches(
                    in: modifiedText,
                    options: [],
                    range: range,
                    withTemplate: trimmedReplacement
                )
                
                if newText != modifiedText {
                    modifiedText = newText
                    break // Stop after first successful replacement to avoid conflicts
                }
            }
        }
        
        return modifiedText
    }
    
    /// Create flexible matching patterns optimized for developer vocabulary
    private func createMatchingPatterns(for original: String) -> [String] {
        let escaped = NSRegularExpression.escapedPattern(for: original)
        var patterns: [String] = []
        
        // We avoid \b word boundaries because they fail when the phrase starts/ends with punctuation
        // Instead, guard with non-word lookarounds which work for both words and phrases with punctuation.
        // (?<!\w) ... (?!\w) ensures we don't match inside larger words, but allows punctuation at edges.
        let startGuard = "(?<!\\w)"
        let endGuard = "(?!\\w)"
        
        // Pattern 1: Exact literal with safe guards
        patterns.append("\(startGuard)\(escaped)\(endGuard)")
        
        // Pattern 2: For multi-word phrases, also tolerate flexible whitespace
        if original.contains(" ") {
            let flexible = escaped.replacingOccurrences(of: "\\ ", with: "\\s+")
            patterns.append("\(startGuard)\(flexible)\(endGuard)")
        }
        
        // Pattern 3: For Git commands, match "get" followed by Git subcommands
        if original.lowercased().hasPrefix("get ") {
            let gitCommand = String(original.dropFirst(4)) // Remove "get "
            let gitEscaped = NSRegularExpression.escapedPattern(for: gitCommand)
            patterns.append("\(startGuard)get\\s+\(gitEscaped)\(endGuard)")
        }
        
        return patterns
    }
}
