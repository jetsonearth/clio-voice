import Foundation
import SwiftData
import OSLog

/// Manages periodic deletion of old on-disk audio while keeping SwiftData records intact.
/// Public API is kept stable, but internals are a clean-room reimplementation.
final class AudioCleanupManager {
    static let shared = AudioCleanupManager()

    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "AudioCleanup")
    private var cleanupTimer: Timer?

    // MARK: - Preferences
    private enum CleanupPrefs {
        // New, namespaced keys
        static let enabled = "Clio.Audio.Cleanup.Enabled"
        static let retentionDays = "Clio.Audio.RetentionDays"
        // Legacy keys kept for backward-compatibility
        static let legacyEnabled = "IsAudioCleanupEnabled"
        static let legacyRetentionDays = "AudioRetentionPeriod"
    }

    // MARK: - Tunables
    private let defaultRetentionDays: Int = 7
    private let dailyInterval: TimeInterval = 60 * 60 * 24 // once per day

    private init() {
        // if !RuntimeConfig.shouldSilenceAllLogs { logger.info("AudioCleanup ready") }
    }

    // MARK: - Lifecycle
    func startAutomaticCleanup(modelContext: ModelContext) {
        if !RuntimeConfig.shouldSilenceAllLogs { logger.info("Scheduling daily audio cleanup task") }

        cleanupTimer?.invalidate()

        // Kick off an initial run
        Task { [weak self] in
            await self?.performCleanup(modelContext: modelContext)
        }

        // Schedule future runs
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: dailyInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { await self.performCleanup(modelContext: modelContext) }
        }
    }

    func stopAutomaticCleanup() {
        if !RuntimeConfig.shouldSilenceAllLogs { logger.info("Cancelling audio cleanup scheduling") }
        cleanupTimer?.invalidate()
        cleanupTimer = nil
    }

    // MARK: - Public Queries
    func getCleanupInfo(modelContext: ModelContext) async -> (fileCount: Int, totalSize: Int64, transcriptions: [Transcription]) {
        if !RuntimeConfig.shouldSilenceAllLogs { logger.info("Assessing audio that would be removed") }

        let cutoffDate = calculateCutoffDate()
        do {
            // Fetch on main actor because SwiftData contexts are usually main-thread bound
            let candidates: [Transcription] = try await MainActor.run {
                try modelContext.fetch(self.fetchDescriptor(before: cutoffDate))
            }

            var fileCount = 0
            var totalBytes: Int64 = 0
            var eligible: [Transcription] = []

            for item in candidates {
                guard let url = fileURL(for: item) else { continue }
                do {
                    let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
                    if let size = attrs[.size] as? Int64 { totalBytes += size; fileCount += 1; eligible.append(item) }
                } catch {
                    logger.error("stat failed for \(url.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)")
                }
            }

            if !RuntimeConfig.shouldSilenceAllLogs { logger.info("Eligible files: \(fileCount), size: \(self.formatFileSize(totalBytes))") }
            return (fileCount, totalBytes, eligible)
        } catch {
            logger.error("Cleanup info query failed: \(error.localizedDescription, privacy: .public)")
            return (0, 0, [])
        }
    }

    // MARK: - Operations
    private func performCleanup(modelContext: ModelContext) async {
        guard isCleanupEnabled() else {
            if !RuntimeConfig.shouldSilenceAllLogs { logger.info("Cleanup disabled by preference; skipping") }
            return
        }

        let cutoffDate = calculateCutoffDate()
        do {
            try await MainActor.run {
                var removed = 0
                var failed = 0

                let transcriptions = try modelContext.fetch(self.fetchDescriptor(before: cutoffDate))
                for t in transcriptions {
                    guard let url = self.fileURL(for: t) else { continue }
                    do {
                        try FileManager.default.removeItem(at: url)
                        t.audioFileURL = nil
                        removed += 1
                    } catch {
                        failed += 1
                        self.logger.error("delete failed for \(url.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)")
                    }
                }

                if removed > 0 || failed > 0 { try? modelContext.save() }
                if !RuntimeConfig.shouldSilenceAllLogs { self.logger.info("Cleanup run finished — removed: \(removed), failed: \(failed)") }
            }
        } catch {
            logger.error("Cleanup run failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func runManualCleanup(modelContext: ModelContext) async {
        await performCleanup(modelContext: modelContext)
    }

    func runCleanupForTranscriptions(modelContext: ModelContext, transcriptions: [Transcription]) async -> (deletedCount: Int, errorCount: Int) {
        if !RuntimeConfig.shouldSilenceAllLogs { logger.info("Targeted cleanup for \(transcriptions.count) records") }
        do {
            return try await MainActor.run {
                var removed = 0
                var failed = 0
                for t in transcriptions {
                    guard let url = self.fileURL(for: t) else { continue }
                    do {
                        try FileManager.default.removeItem(at: url)
                        t.audioFileURL = nil
                        removed += 1
                    } catch {
                        failed += 1
                        self.logger.error("targeted delete failed for \(url.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)")
                    }
                }
                if removed > 0 || failed > 0 { try? modelContext.save() }
                return (removed, failed)
            }
        } catch {
            logger.error("Targeted cleanup failed: \(error.localizedDescription, privacy: .public)")
            return (0, 0)
        }
    }

    // MARK: - Helpers
    private func isCleanupEnabled() -> Bool {
        let ud = UserDefaults.standard
        if ud.object(forKey: CleanupPrefs.enabled) != nil {
            return ud.bool(forKey: CleanupPrefs.enabled)
        }
        // Legacy fallback
        return ud.object(forKey: CleanupPrefs.legacyEnabled) == nil ? true : ud.bool(forKey: CleanupPrefs.legacyEnabled)
    }

    private func currentRetentionDays() -> Int {
        let ud = UserDefaults.standard
        let days = ud.integer(forKey: CleanupPrefs.retentionDays)
        if days > 0 { return days }
        let legacy = ud.integer(forKey: CleanupPrefs.legacyRetentionDays)
        return legacy > 0 ? legacy : defaultRetentionDays
    }

    private func calculateCutoffDate() -> Date {
        let days = currentRetentionDays()
        return Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date(timeIntervalSince1970: 0)
    }

    private func fetchDescriptor(before date: Date) -> FetchDescriptor<Transcription> {
        FetchDescriptor<Transcription>(
            predicate: #Predicate<Transcription> { t in
                t.timestamp < date && t.audioFileURL != nil
            }
        )
    }

    private func fileURL(for transcription: Transcription) -> URL? {
        guard let urlString = transcription.audioFileURL, let url = URL(string: urlString) else { return nil }
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return url
    }

    func formatFileSize(_ size: Int64) -> String {
        let f = ByteCountFormatter()
        f.allowedUnits = [.useKB, .useMB, .useGB]
        f.countStyle = .file
        return f.string(fromByteCount: size)
    }
}
