import Foundation
import SwiftUI
import os
import KeyboardShortcuts
import DynamicNotchKit

// MARK: - UI Management Extension
extension WhisperState {
    
    // MARK: - Intent-driven session control (Phase 1)
    enum Intent {
        case showLightweight
        case startPTT
        case startHF
        case stop
        case cancelImmediate
        case idle
    }

    @MainActor
    func handleIntent(_ intent: Intent) async {
        switch intent {
        case .showLightweight:
            await setSessionStateShowingLightweight()
            // Defer preview slightly to let the notch animation start smoothly
            Task {
                let delayMs = RuntimeConfig.previewCaptureStartDelayMs
                if delayMs > 0 { try? await Task.sleep(nanoseconds: UInt64(delayMs) * 1_000_000) }
                await self.sonioxStreamingService.startPreviewCapture()
            }
        case .startPTT:
            recorderMode = .ptt
            await setSessionStateStarting(mode: .ptt)
            await toggleRecord()
        case .startHF:
            recorderMode = .hf
            isHandsFreeLocked = true
            await setSessionStateStarting(mode: .hf)
            await toggleRecord()
        case .stop:
            await toggleRecord()
        case .cancelImmediate:
            shouldCancelRecording = true
            await dismissRecorder()
        case .idle:
            // If we never promoted to full recording, stop and discard preview pre‑roll
            Task { await self.sonioxStreamingService.stopPreviewCapture() }
            await setSessionStateIdle()
        }
    }

    
    // MARK: - Recorder Panel Management
    
    func showRecorderPanel() {
        if recorderType == "notch" {
            logger.notice("📱 Showing DynamicNotch recorder (MIT licensed)")
            // Ensure mini is hidden when showing notch
            miniWindowManager?.hide()
            if notchWindowManager == nil {
                notchWindowManager = DynamicNotchWindowManager(whisperState: self, recorder: recorder)
            }
            // Call show without forcing callers to hop onto MainActor manually
            Task { @MainActor in await notchWindowManager?.show() }
            return
        }
        logger.notice("📱 Showing mini recorder")
        // Ensure notch is hidden when showing mini
        notchWindowManager?.hide(force: true)
        if miniWindowManager == nil {
            miniWindowManager = MiniWindowManager(whisperState: self, recorder: recorder)
            logger.info("Created new mini window manager")
        }
        miniWindowManager?.show()
    }

    // Ensure notch manager exists before rendering from state (phase 2b)
    @MainActor private func ensureNotchManager() {
        if recorderType == "notch" && notchWindowManager == nil {
            notchWindowManager = DynamicNotchWindowManager(whisperState: self, recorder: recorder)
        }
    }

    // Prewarm hook for app activation
    @MainActor func prewarmNotchIfEnabled() async {
        guard recorderType == "notch" else { return }
        if notchWindowManager == nil {
            notchWindowManager = DynamicNotchWindowManager(whisperState: self, recorder: recorder)
        }
        // Honor flags: only prewarm when keep-alive + prewarm are enabled
        if RuntimeConfig.notchKeepAliveEnabled && RuntimeConfig.notchPrewarmOnActivation {
            await notchWindowManager?.prewarm()
        }
    }
    
    func hideRecorderPanel(force: Bool = false) {
        DebugLogger.debug("perf:ui_close", category: .performance)
        if recorderType == "notch" {
            notchWindowManager?.hide(force: force)
            return
        }
        miniWindowManager?.hide()
    }
    
    // MARK: - Session State Management
    @MainActor func setSessionStateShowingLightweight() async {
        uiGenerationCounter &+= 1
        let gen = uiGenerationCounter
        sessionState = .showingLightweight(gen: gen)
        // Immediate lightweight UI
        isAttemptingToRecord = true
        isVisualizerActive = true
        ensureNotchManager()
        if recorderType == "notch", let manager = notchWindowManager {
            await manager.render(sessionState: sessionState)
        }
    }

    @MainActor func setSessionStateStarting(mode: RecorderMode) async {
        let gen: UInt64
        switch sessionState {
        case .showingLightweight(let g): gen = g
        case .starting(_, let g): gen = g
        case .recording(_, let g): gen = g
        default:
            uiGenerationCounter &+= 1
            gen = uiGenerationCounter
        }
        recorderMode = mode
        sessionState = .starting(mode: mode, gen: gen)
        // Ensure UI is up
        isAttemptingToRecord = true
        isVisualizerActive = true
        ensureNotchManager()
        DebugLogger.debug("perf:ui_open", category: .performance)
        if recorderType == "notch", let manager = notchWindowManager {
            await manager.render(sessionState: sessionState)
        }
    }

    @MainActor func setSessionStateRecording(mode: RecorderMode) async {
        let gen: UInt64
        switch sessionState {
        case .starting(_, let g): gen = g
        case .recording(_, let g): gen = g
        case .showingLightweight(let g): gen = g
        default:
            uiGenerationCounter &+= 1
            gen = uiGenerationCounter
        }
        sessionState = .recording(mode: mode, gen: gen)
        isAttemptingToRecord = false
        isVisualizerActive = true
        // UI already shown
        if recorderType == "notch", let manager = notchWindowManager {
            await manager.render(sessionState: sessionState)
        }
    }

    @MainActor func setSessionStateStopping() async {
        let gen: UInt64
        switch sessionState {
        case .recording(_, let g): gen = g
        case .starting(_, let g): gen = g
        default:
            uiGenerationCounter &+= 1
            gen = uiGenerationCounter
        }
        sessionState = .stopping(gen: gen)
        // Keep UI visible while stopping
        if recorderType == "notch", let manager = notchWindowManager {
            await manager.render(sessionState: sessionState)
        }
    }

    @MainActor func setSessionStateIdle() async {
        sessionState = .idle
        // Centralized hide; force to avoid transient-flag guard
        hideRecorderPanel(force: true)
        if recorderType == "notch", let manager = notchWindowManager {
            await manager.render(sessionState: sessionState)
        }
        isAttemptingToRecord = false
        isVisualizerActive = false
        isHandsFreeLocked = false
    }

    // MARK: - Notch Recorder Management
    
    func toggleNotchRecorder() async {
        if RuntimeConfig.enableVerboseLogging {
            logger.debug("🎤 [UI] toggleNotchRecorder called isRecording=\(self.isRecording)")
        }
        
        if isRecording {
            await toggleRecord()
            return
        }

        if isProcessing {
            if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] Busy finalizing - ignoring start press") }
            NSSound.beep()
            return
        }
        
        // Choose recorder mode based on hands‑free lock state
        let mode: RecorderMode = await MainActor.run { self.isHandsFreeLocked ? .hf : .ptt }

        // Immediate UI flags
        await MainActor.run {
            self.recorderMode = mode
            self.isAttemptingToRecord = true
            self.isVisualizerActive = true
        }

        // Hands‑free specific: show lightweight UI immediately for smoothness
        // (PTT mode shows lightweight during promotion window, so hands-free should match)
        if mode == .hf {
            await setSessionStateShowingLightweight()
            // No artificial delay - let the normal preview capture timing handle the delay
        }

        // Drive UI via state renderer
        await setSessionStateStarting(mode: mode)
        // Optionally delay streaming start to give the notch time to paint first pixels
        let startDelay = RuntimeConfig.startStreamingDelayMs
        if startDelay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(startDelay) * 1_000_000)
        }
        await toggleRecord()
    }
    
    // MARK: - Mini Recorder Management
    
    func toggleMiniRecorder() async {
        // Route to correct recorder based on type
        if recorderType == "notch" {
            await toggleNotchRecorder()
            return
        }
        
        if RuntimeConfig.enableVerboseLogging {
            logger.debug("🎤 [UI] toggleMiniRecorder called isRecording=\(self.isRecording) isMiniVisible=\(self.isMiniRecorderVisible) hasWindow=\(self.miniWindowManager != nil)")
        }
        
        if isRecording {
        if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] Already recording - stopping") }
            // Already recording – stop.
            await toggleRecord()
            return
        }

        // If we're finalizing a previous session, ignore start to avoid showing transcribing bar
        if isProcessing {
            if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] Busy finalizing - ignoring start press") }
            NSSound.beep()
            return
        }
        
        // Signal immediate UI response for start action (instant animation)
        await MainActor.run {
            self.isAttemptingToRecord = true
            self.isMiniRecorderVisible = true // ensure visible immediately
        }

        if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] Requesting start sound") }
        // No special start sound here; handled by key handlers

        // Boost animation ticker immediately for smoother visuals
        await MainActor.run { AnimationTicker.shared.setHighActivity(true) }

        var needsWindowCreation = false
        let windowExists = miniWindowManager?.window != nil
        let windowValid = miniWindowManager?.isVisible == true
        
        if !isMiniRecorderVisible || !windowExists || !windowValid {
            if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] Show mini visible=\(self.isMiniRecorderVisible) exists=\(windowExists) valid=\(windowValid)") }
            if !windowExists {
        if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] Will create mini window") }
                needsWindowCreation = true
            } else {
        if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] Window exists from showAlwaysOn - no delay needed") }
            }
        if RuntimeConfig.enableVerboseLogging { logger.debug("📱 [UI] Showing mini recorder") }
            await MainActor.run { isMiniRecorderVisible = true }
        } else {
        if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] Mini already visible and valid - skip show") }
        }

        if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] Reposition mini recorder") }
        // Reposition mini recorder to the active screen
        miniWindowManager?.updatePosition()

        // If we just created the window, give AppKit a brief moment to lay it out before we start audio (avoids "first-press does nothing" bug).
        if needsWindowCreation {
        if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] Window created - wait 0.4s for layout") }
            try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s
        } else {
        if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] No window creation delay needed") }
        }

        if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] Calling toggleRecord") }
        await toggleRecord()
        if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] toggleRecord completed") }
    }
    
    func dismissRecorder() async {
        logger.notice("📱 Dismissing recorder")
        
        // Stop progress timer and reset progress
        stopProgressTimer()
        transcriptionProgress = 0.0
        
        // Don't overwrite shouldCancelRecording - let caller control fast vs normal cancel
        isAttemptingToRecord = false  // Reset attempt flag on cancel

        // Use shouldCancelRecording flag to determine if we need cleanup
        // (isRecording might already be false for immediate UI updates)
        if shouldCancelRecording {
            // Check if we're using Soniox streaming model and stop appropriately
            let isSonioxModel = currentModel?.name == "soniox-realtime-streaming"
            if isSonioxModel {
                await sonioxStreamingService.stopStreamingFastCancel()
            } else {
                await recorder.stopRecording()
            }
        }

        // Centralized hide via state machine
        await setSessionStateIdle()
        
        // Update states individually
        // Note: When called from cancel confirmation, these may already be set for immediate UI response
        isRecording = false
        isVisualizerActive = false
        isTranscribing = false
        canTranscribe = true
        shouldCancelRecording = false
        showCancelConfirmation = false
        isProcessing = false  // No delay needed - set immediately for responsive UI
        
        // Switch to low-activity animation mode when not recording
        AnimationTicker.shared.setHighActivity(false)
        
        // Hide confirmation window
        cancelConfirmationWindowManager?.hide()
    }
    
    func cancelRecording() async {
        // Fire cancel immediately; stop mic concurrently and play cancel sound shortly after
        shouldCancelRecording = true
        isAttemptingToRecord = false
        Task { await dismissRecorder() }
        try? await Task.sleep(nanoseconds: 120_000_000)
        SoundManager.shared.playEscSound()
    }
    
    func showCancelConfirmation() async {
        await MainActor.run {
            // Only show when recording
            guard isRecording else { return }
            showCancelConfirmation = true

            // Determine anchor window (prefer notch when active)
            if let notchWindow = notchWindowManager?.window {
                let notchFrame = notchWindow.frame
                if !notchFrame.isNull && !notchFrame.isEmpty {
                    cancelConfirmationWindowManager?.show(near: notchFrame)
                    return
                }
            }

            // Fallback to mini recorder anchor
            if let miniWindow = miniWindowManager?.window {
                let miniFrame = miniWindow.frame
                if !miniFrame.isNull && !miniFrame.isEmpty {
                    cancelConfirmationWindowManager?.show(near: miniFrame)
                }
            }
        }
    }
    
    // MARK: - Notification Handling
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleToggleMiniRecorder), name: .toggleMiniRecorder, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLicenseStatusChanged), name: .licenseStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePromptChange), name: .promptDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotchRecorderESC), name: NSNotification.Name("NotchRecorderESCPressed"), object: nil)
        // ESC mapping handled dynamically by HotkeyManager.updateEscapeShortcut()
    }
    
    @objc public func handleToggleMiniRecorder() {
        if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] handleToggleMiniRecorder called") }
        Task {
            await toggleMiniRecorder()
        }
    }
    
    @objc public func handleNotchRecorderESC() {
        if RuntimeConfig.enableVerboseLogging { logger.debug("🎤 [UI] handleNotchRecorderESC called") }
        Task {
            await showCancelConfirmation()
        }
    }
    
    @objc func handleLicenseStatusChanged() {
        // No need to create new instance - using shared singleton
        // License state will update automatically via @Published properties
    }
    
    @objc func handlePromptChange() {
        // Update the whisper context with the new prompt
        Task {
            await updateContextPrompt()
        }
    }
    
    private func updateContextPrompt() async {
        // Always reload the prompt from UserDefaults to ensure we have the latest
        let currentPrompt = UserDefaults.standard.string(forKey: "TranscriptionPrompt") ?? whisperPrompt.transcriptionPrompt
        
        if let context = whisperContext {
            await context.setPrompt(currentPrompt)
        }
    }
}
