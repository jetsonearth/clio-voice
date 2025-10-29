import Foundation
import os

// MARK: - Models

public struct SmartDictionaryEntry: Codable, Hashable {
    public let canonicalKey: String
    public var displayVariants: [String]
    public var languageCode: String?
    public var domainScope: String?
    public var contextsSeen: [String]
    public var totalCount: Int
    public var recentCount: Int
    public var score: Double
    public var lastSeenAt: Date
}

// MARK: - Store

@MainActor
final class SmartDictionaryStore {
    static let shared = SmartDictionaryStore()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.clio.app", category: "SmartDictionaryStore")
    private let ioQueue = DispatchQueue(label: "com.clio.smartdict.store", qos: .utility)

    private var entries: [String: SmartDictionaryEntry] = [:] // keyed by canonicalKey
    private let maxEntriesPerLanguage = 200

    private init() {
        loadFromDisk()
    }

    private var storeURL: URL {
        let fm = FileManager.default
        let appSupport = try? fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dir = (appSupport ?? fm.temporaryDirectory).appendingPathComponent("Clio", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("smart_dictionary.json")
    }

    private func loadFromDisk() {
        do {
            let data = try Data(contentsOf: storeURL)
            let decoded = try JSONDecoder().decode([String: SmartDictionaryEntry].self, from: data)
            entries = decoded
        } catch {
            entries = [:]
        }
    }

    private func persist() {
        let snapshot = entries
        ioQueue.async { [storeURL, logger] in
            do {
                let data = try JSONEncoder().encode(snapshot)
                try data.write(to: storeURL, options: [.atomic])
            } catch {
                logger.error("❌ [SMARTDICT] Persist failed: \(error.localizedDescription)")
            }
        }
    }

    func upsert(_ entry: SmartDictionaryEntry) {
        entries[entry.canonicalKey] = entry
        pruneIfNeeded(languageCode: entry.languageCode)
        persist()
    }

    func remove(canonicalKey: String) {
        entries.removeValue(forKey: canonicalKey)
        persist()
    }

    func clearAll(languageCode: String?) {
        if let lang = languageCode {
            entries = entries.filter { $0.value.languageCode != lang }
        } else {
            entries.removeAll()
        }
        persist()
    }

    func getTopEntries(languageCode: String?, domainScope: String?, maxCount: Int) -> [SmartDictionaryEntry] {
        var filtered = Array(entries.values)
        if let lang = languageCode {
            filtered = filtered.filter { $0.languageCode == lang || $0.languageCode == nil }
        }
        if let domain = domainScope {
            filtered = filtered.filter { $0.domainScope == domain || $0.domainScope == nil }
        }
        return filtered
            .sorted { $0.score > $1.score }
            .prefix(maxCount)
            .map { $0 }
    }

    func find(canonicalKey: String) -> SmartDictionaryEntry? {
        return entries[canonicalKey]
    }

    private func pruneIfNeeded(languageCode: String?) {
        guard let lang = languageCode else { return }
        let langEntries = entries.values.filter { $0.languageCode == lang }
        if langEntries.count > maxEntriesPerLanguage {
            let sorted = langEntries.sorted { $0.score < $1.score }
            let toRemove = sorted.prefix(langEntries.count - maxEntriesPerLanguage)
            for entry in toRemove {
                entries.removeValue(forKey: entry.canonicalKey)
            }
        }
    }
}

// MARK: - Service

@MainActor
public final class SmartDictionaryService {
    public static let shared = SmartDictionaryService()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.clio.app", category: "SmartDictionaryService")
    private let store = SmartDictionaryStore.shared
    private let scoreDecayFactor = 0.95
    private let minOccurrencesForHotword = 2

    private init() {}

    public func recordCorrection(
        wrong: String,
        right: String,
        languageCode: String?,
        domainScope: String?,
        localContext: [String],
        asrConfidence: Double?,
        editLatencyMs: Int
    ) {
        let canonical = right.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !canonical.isEmpty else { return }

        let now = Date()
        let key = canonical

        var entry = store.find(canonicalKey: key) ?? SmartDictionaryEntry(
            canonicalKey: key,
            displayVariants: [],
            languageCode: languageCode,
            domainScope: domainScope,
            contextsSeen: [],
            totalCount: 0,
            recentCount: 0,
            score: 0.0,
            lastSeenAt: now
        )

        // Update variants
        if !entry.displayVariants.contains(right) {
            entry.displayVariants.append(right)
        }

        // Update context
        for ctx in localContext {
            if !entry.contextsSeen.contains(ctx) {
                entry.contextsSeen.append(ctx)
            }
        }

        // Update counts and scoring
        entry.totalCount += 1
        entry.recentCount += 1
        entry.lastSeenAt = now

        // Compute score (frequency + recency + confidence factors)
        let frequencyScore = Double(entry.totalCount)
        let recencyBonus = max(0, 7.0 - now.timeIntervalSince(entry.lastSeenAt) / 86400) // 7-day decay
        let confidenceBonus = (asrConfidence ?? 0.5) * 2.0 // Low ASR confidence = higher correction value
        let latencyBonus = max(0, 3.0 - Double(editLatencyMs) / 10000) // Quick corrections = higher value

        entry.score = frequencyScore + recencyBonus + confidenceBonus + latencyBonus

        if UserDefaults.standard.bool(forKey: "SmartDictionaryDebugLogging") {
            logger.notice("🧪 [SMARTDICT] Recorded: '\(wrong)' → '\(right)' (score=\(String(format: "%.1f", entry.score)), total=\(entry.totalCount))")
        }

        store.upsert(entry)
        decayScores()
    }

    public func topHotwords(languageCode: String?, domainScope: String?, maxCount: Int) -> [SmartDictionaryEntry] {
        let entries = store.getTopEntries(languageCode: languageCode, domainScope: domainScope, maxCount: maxCount)
        return entries.filter { $0.totalCount >= minOccurrencesForHotword }
    }

    public func clearDictionary(languageCode: String?) {
        store.clearAll(languageCode: languageCode)
    }

    private func decayScores() {
        // Periodically decay scores to emphasize recent corrections
        // This could be called less frequently in a production implementation
        let allEntries = store.getTopEntries(languageCode: nil, domainScope: nil, maxCount: 10000)
        for var entry in allEntries {
            entry.score *= scoreDecayFactor
            entry.recentCount = Int(Double(entry.recentCount) * scoreDecayFactor)
            store.upsert(entry)
        }
    }
}
