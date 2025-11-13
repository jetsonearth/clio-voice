import Foundation
import os

@MainActor
final class WarmupCoordinator {
        static let shared = WarmupCoordinator()

        private let logger = Logger(subsystem: "com.cliovoice.clio", category: "WarmupCoordinator")
        private var lastRunAt: Date = .distantPast
        private var isRunning: Bool = false
        private var cadenceTimer: Timer?
        private weak var recordingEngine: RecordingEngine?
        private var isCloudWarmupEnabled: Bool = true

        private init() {}

        func register(recordingEngine: RecordingEngine) {
                self.recordingEngine = recordingEngine
        }

        func setCloudWarmupEnabled(_ enabled: Bool) {
                isCloudWarmupEnabled = enabled
                if !enabled {
                        stopCadence()
                } else {
                        startCadence()
                }
        }

        enum Context: String {
                case appLaunch
                case appActivation
                case hotkeyDown
                case recorderUIShown
                case reachabilityChange
        }

        /// Idempotent, non-blocking warmup. Coalesces concurrent calls and rate-limits to avoid churn.
        func ensureReady(_ context: Context) {
                guard isCloudWarmupEnabled else { return }
                let now = Date()
                // Rate limit to once every 30s by default
                if now.timeIntervalSince(lastRunAt) < 30 {
                        logger.debug("🧊 [WARMUP] Skipping (recently run) context=\(context.rawValue)")
                        return
                }
                lastRunAt = now
                if isRunning { return }
                isRunning = true

                Task.detached { [weak self] in
                        guard let self = self else { return }
                        defer { Task { @MainActor in self.isRunning = false } }
                        await self.runWarmup(context)
                }
        }

        private func runWarmup(_ context: Context) async {
                logger.notice("🔥 [WARMUP] ensureReady() invoked context=\(context.rawValue)")
                // Temp key prefetch (Soniox)
                await TempKeyCache.shared.integrateWithSystemWarmup()
                // Soniox DNS/TLS prewarm (WS path)
                await prewarmASRTransport()
                // UnifiedAudioManager warmup (eliminates cold start on first recording)
                await prewarmAudioSystem()
                // 5) LLM warmup via NER prewarm path (triggered elsewhere on OCR completion)
                // Note: AIEnhancementService is not a singleton; its prewarm is invoked by OCR callback in RecordingEngine.
        }

        /// Lightweight warms for Soniox networking (DNS + TCP/TLS) on cadence
        private func prewarmASRTransport() async {
                guard let svc = recordingEngine?.sonioxStreamingService else { return }
                await svc.prewarmASRTransport()
        }
        
        /// Pre-warm UnifiedAudioManager to eliminate cold start on first recording
        private func prewarmAudioSystem() async {
                let audioManager = UnifiedAudioManager.shared
                logger.notice("🎤 [WARMUP] Pre-warming audio system...")
                await audioManager.prewarmAudioSystem()
                logger.notice("✅ [WARMUP] Audio system pre-warmed successfully")
        }

        /// Start a 5-minute cadence warmup while app is active
        func startCadence() {
                guard isCloudWarmupEnabled else { return }
                cadenceTimer?.invalidate()
                cadenceTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
                        guard let self = self else { return }
                        Task { @MainActor in self.ensureReady(.reachabilityChange) }
                }
        }

        func stopCadence() {
                cadenceTimer?.invalidate()
                cadenceTimer = nil
        }
}
