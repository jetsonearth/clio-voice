import Foundation
import SwiftUI
import Combine

/// Executes commands from the RecorderStateMachine and coordinates with existing WhisperState
actor RecorderCommandExecutor {
    private weak var whisperState: WhisperState?
    private weak var stateMachine: RecorderStateMachine?
    
    // Timer management
    private var promotionTask: Task<Void, Never>?
    private var misTouchTask: Task<Void, Never>?
    
    // Recording completion observation
    private var sessionStateObserver: AnyCancellable?
    private var isWaitingForRecordingComplete = false
    
    init(whisperState: WhisperState) {
        self.whisperState = whisperState
    }
    
    func setStateMachine(_ stateMachine: RecorderStateMachine) {
        self.stateMachine = stateMachine
    }
    
    /// Execute a batch of commands from the state machine
    func execute(_ commands: [RecorderCommand]) async {
        for command in commands {
            await execute(command)
        }
    }
    
    /// Execute a single command
    private func execute(_ command: RecorderCommand) async {
        guard let whisperState = whisperState else { return }
        
        switch command {
        case .showLightweightUI:
            await MainActor.run {
                whisperState.isAttemptingToRecord = true
                whisperState.isVisualizerActive = true
            }
            // Start mic preview + pre-roll buffering immediately on key down
            if RuntimeConfig.enablePreviewCapture {
                let isNotch: Bool = await MainActor.run { whisperState.recorderType == "notch" }
                let isMini: Bool = await MainActor.run { whisperState.recorderType == "mini" }
                if (isNotch) || (isMini && RuntimeConfig.previewCaptureForMini) {
                    Task { await whisperState.sonioxStreamingService.startPreviewCapture() }
                }
            }
            await whisperState.showRecorderPanel()
            
        case .startRecording(let mode):
            await MainActor.run {
                whisperState.recorderMode = mode == .ptt ? .ptt : .hf
                whisperState.isAttemptingToRecord = false
                whisperState.isVisualizerActive = true
                if mode == .handsFreeLocked {
                    whisperState.isHandsFreeLocked = true
                }
            }
            // Do NOT stop preview here. startStreaming() will atomically install the main tap
            // and unregister the preview tap without stopping the session, avoiding mic indicator flicker.
            // EXPERIMENT: for PTT only, add a tiny post-promotion delay to avoid
            // overlapping the heaviest startStreaming work with the notch-open tail.
            if mode == .ptt {
                try? await Task.sleep(nanoseconds: 40_000_000) // ~40ms
            }
            await whisperState.toggleRecord()
            
        case .stopRecording:
            // Always stop any preview capture to ensure mic shuts down on PTT release
            await whisperState.sonioxStreamingService.stopPreviewCapture()
            // If this stop was triggered by an immediate cancel, do a fast dismissal
            let isCancelled = await MainActor.run { whisperState.shouldCancelRecording }
            if isCancelled {
                // Do not observe completion or render stopping; dismiss now
                await whisperState.dismissRecorder()
                stopObservingRecordingCompletion()
            } else {
                // Normal stop: observe recordingComplete and let UI render stopping
                await startObservingRecordingCompletion()
                await whisperState.toggleRecord()
            }
            
        case .hideUI:
            // Ensure any lightweight preview capture is stopped when hiding UI (mis‑touch)
            await whisperState.sonioxStreamingService.stopPreviewCapture()
            await MainActor.run {
                // Ensure transition flags do not block UI dismissal on cancel
                whisperState.isAttemptingToRecord = false
                whisperState.isVisualizerActive = false
                whisperState.isHandsFreeLocked = false
                whisperState.isProcessing = false
            }
            // Force hide to bypass "session active or in transition" guard
            await whisperState.hideRecorderPanel(force: true)
            
        case .playSound(let soundType):
            switch soundType {
            case .keyDown:
                SoundManager.shared.playKeyDown()
            case .keyUp:
                SoundManager.shared.playKeyUp()
            case .lock:
                SoundManager.shared.playLock()
            case .cancel:
                SoundManager.shared.playEscSound()
            }
        
        case .playSoundDelayed(let soundType, let delay):
            // Fire-and-forget delayed playback to separate keyDown and immediate keyUp on mis‑touch
            Task.detached {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                switch soundType {
                case .keyDown: SoundManager.shared.playKeyDown()
                case .keyUp:   SoundManager.shared.playKeyUp()
                case .lock:    SoundManager.shared.playLock()
                case .cancel:  SoundManager.shared.playEscSound()
                }
            }
            
        case .updateUI(let viewModel):
            await MainActor.run {
                // Update WhisperState properties to match view model
                whisperState.isAttemptingToRecord = viewModel.isAttemptingToRecord
                whisperState.isVisualizerActive = viewModel.isVisualizerActive
                whisperState.isHandsFreeLocked = viewModel.isHandsFreeLocked
                whisperState.canTranscribe = viewModel.canTranscribe
            }
            
            // PHASE 3: Update all state machine-driven properties in WhisperState
            await whisperState.updateFromStateMachine()
            
        case .schedulePromotion(let delay):
            promotionTask?.cancel()
            promotionTask = Task { [weak self, weak stateMachine] in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                guard !Task.isCancelled, let stateMachine = stateMachine else { return }
                let commands = await stateMachine.send(.promotionTimeout)
                await self?.execute(commands)
            }
            
        case .scheduleMisTouchHide(let delay):
            misTouchTask?.cancel()
            misTouchTask = Task { [weak self, weak stateMachine] in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                guard !Task.isCancelled, let stateMachine = stateMachine else { return }
                let commands = await stateMachine.send(.misTouchTimeout)
                await self?.execute(commands)
            }
            
        case .cancelTimers:
            promotionTask?.cancel()
            promotionTask = nil
            misTouchTask?.cancel()
            misTouchTask = nil
            
        case .clearCooldowns:
            // PHASE 2: This is handled internally by the state machine, nothing to do here
            break

        case .markCancelled:
            await MainActor.run {
                whisperState.shouldCancelRecording = true
            }
        }
    }
    
    // MARK: - Recording Completion Observation
    
    private func startObservingRecordingCompletion() async {
        guard let whisperState = whisperState, !isWaitingForRecordingComplete else { return }
        
        isWaitingForRecordingComplete = true
        
        // Create observation on main actor, but use task to communicate back to actor
        await MainActor.run {
            let observer = whisperState.$sessionState
                .sink { [weak self] sessionState in
                    if case .idle = sessionState {
                        Task {
                            await self?.handleRecordingComplete()
                        }
                    }
                }
            
            // Store observer reference in a task since we can't directly assign to actor-isolated property
            Task { [weak self] in
                await self?.setSessionStateObserver(observer)
            }
        }
    }
    
    private func setSessionStateObserver(_ observer: AnyCancellable) {
        sessionStateObserver = observer
    }
    
    private func handleRecordingComplete() async {
        guard let stateMachine = stateMachine else { return }
        
        // Recording completed - notify state machine
        let commands = await stateMachine.send(.recordingComplete)
        await execute(commands)
        
        // Clean up observation
        stopObservingRecordingCompletion()
    }
    
    private func stopObservingRecordingCompletion() {
        sessionStateObserver?.cancel()
        sessionStateObserver = nil
        isWaitingForRecordingComplete = false
    }
}
