import Foundation
import AVFoundation
import SwiftUI

// No iOS-specific imports needed for macOS sound management

class SoundManager {
    static let shared = SoundManager()
    // Toggle to enable/disable the Bluetooth backup start tick (safety beep)
    private let enableBackupStartTick: Bool = false
    
    private var startSound: AVAudioPlayer?
    private var stopSound: AVAudioPlayer?
    private var escSound: AVAudioPlayer?
    
    // New SFX
    private var keyDownSound: AVAudioPlayer?
    private var keyUpSound: AVAudioPlayer?
    private var lockSound: AVAudioPlayer?
    
    // Keep strong references to NSSound so playback isn't cut off prematurely
    private var nsStartSound: NSSound?
    private var nsStartMonoSound: NSSound?
    private var nsStopSound: NSSound?
    private var nsEscSound: NSSound?
    private var nsEscMonoSound: NSSound?
    private var nsKeyDownSound: NSSound?
    private var nsKeyUpSound: NSSound?
    private var nsLockSound: NSSound?
    private var startMonoURLRef: URL?
    private var backupTickWorkItem: DispatchWorkItem?
    
    @AppStorage("isSoundFeedbackEnabled") private var isSoundFeedbackEnabled = true
    
    // Cooldowns to prevent double-plays when sounds are triggered from multiple places
    private var lastStartSoundAt: Date?
    private var lastStopSoundAt: Date?
    private var lastEscSoundAt: Date?
    private var lastKeyDownAt: Date?
    private var lastKeyUpAt: Date?
    private var lastLockAt: Date?
    
    private init() {
        configureSoundSession()
        setupSounds()
        warmupPlayers()
    }
    
    private func configureSoundSession() {
        // macOS automatically routes to the default output device (speakers or headphones)
        // but we need to ensure AVAudioPlayer uses the system default
        // print("✅ [SoundManager] macOS audio system ready - will use system default output")
    }
    
    private func setupSounds() {
        // print("🔧 [SoundManager] Attempting to load sound files...")
        
        // Prefer MP3, optionally load SCO-friendly mono variants for Bluetooth routes
        let startSoundURL = (Bundle.main.url(forResource: "start", withExtension: "mp3")
                             ?? Bundle.main.url(forResource: "start", withExtension: "MP3"))
        let startMonoURL = (
            Bundle.main.url(forResource: "start_mono", withExtension: "wav")
            ?? Bundle.main.url(forResource: "start_mono", withExtension: "WAV")
            ?? Bundle.main.url(forResource: "start_mono", withExtension: "mp3")
            ?? Bundle.main.url(forResource: "start_mono", withExtension: "MP3")
        )
        let stopSoundURL = (Bundle.main.url(forResource: "end", withExtension: "mp3")
                            ?? Bundle.main.url(forResource: "end", withExtension: "MP3"))
        let escSoundURL = (Bundle.main.url(forResource: "esc", withExtension: "mp3")
                           ?? Bundle.main.url(forResource: "esc", withExtension: "MP3"))
        let keyDownURL = (Bundle.main.url(forResource: "keydown", withExtension: "mp3")
                          ?? Bundle.main.url(forResource: "keydown", withExtension: "MP3"))
        let keyUpURL = (Bundle.main.url(forResource: "keyup", withExtension: "mp3")
                        ?? Bundle.main.url(forResource: "keyup", withExtension: "MP3"))
        let lockURL = (Bundle.main.url(forResource: "lock", withExtension: "mp3")
                       ?? Bundle.main.url(forResource: "lock", withExtension: "MP3"))
        let escMonoURL = (
            Bundle.main.url(forResource: "esc_mono", withExtension: "wav")
            ?? Bundle.main.url(forResource: "esc_mono", withExtension: "WAV")
            ?? Bundle.main.url(forResource: "esc_mono", withExtension: "mp3")
            ?? Bundle.main.url(forResource: "esc_mono", withExtension: "MP3")
        )
        
        // print("🔧 [SoundManager] Sound file URLs:")
        // print("   Start sound: \(startSoundURL?.absoluteString ?? "nil")")
        // print("   Stop sound: \(stopSoundURL?.absoluteString ?? "nil")")  
        // print("   Esc sound: \(escSoundURL?.absoluteString ?? "nil")")
        
        if let startSoundURL = startSoundURL,
           let stopSoundURL = stopSoundURL,
           let escSoundURL = escSoundURL {
            // print("✅ [SoundManager] Found all sound files in main bundle")
            do {
                try loadSounds(start: startSoundURL, stop: stopSoundURL, esc: escSoundURL)
                if let kd = keyDownURL { nsKeyDownSound = NSSound(contentsOf: kd, byReference: false); keyDownSound = try? AVAudioPlayer(contentsOf: kd) }
                if let ku = keyUpURL { nsKeyUpSound = NSSound(contentsOf: ku, byReference: false); keyUpSound = try? AVAudioPlayer(contentsOf: ku) }
                if let lk = lockURL { nsLockSound = NSSound(contentsOf: lk, byReference: false); lockSound = try? AVAudioPlayer(contentsOf: lk) }
                // print("✅ [SoundManager] All sounds loaded successfully")
            } catch {
                print("❌ [SoundManager] Failed to load sounds: \(error.localizedDescription)")
            }
            // Prepare NSSound variants as primary route-aware players
            nsStartSound = NSSound(contentsOf: startSoundURL, byReference: false)
            if let monoURL = startMonoURL {
                nsStartMonoSound = NSSound(contentsOf: monoURL, byReference: false)
                nsStartMonoSound?.volume = 0.7
                startMonoURLRef = monoURL
            }
            nsStopSound = NSSound(contentsOf: stopSoundURL, byReference: false)
            nsEscSound = NSSound(contentsOf: escSoundURL, byReference: false)
            if let escMonoURL = escMonoURL {
                nsEscMonoSound = NSSound(contentsOf: escMonoURL, byReference: false)
                nsEscMonoSound?.volume = 0.3
            }
            nsStartSound?.volume = 0.7
            nsStopSound?.volume = 0.7
            nsEscSound?.volume = 0.3
            nsKeyDownSound?.volume = 0.7
            nsKeyUpSound?.volume = 0.7
            nsLockSound?.volume = 0.7
            return
        }
        
        print("❌ [SoundManager] Could not find all sound files in the main bundle")
        print("Bundle path: \(Bundle.main.bundlePath)")
        
        // List contents of the bundle for debugging
        if let bundleURL = Bundle.main.resourceURL {
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil)
                print("Contents of bundle resource directory:")
                let soundFiles = contents.filter { $0.pathExtension.lowercased() == "mp3" || $0.pathExtension.lowercased() == "wav" }
                soundFiles.forEach { print("   🎵 \($0.lastPathComponent)") }
                if soundFiles.isEmpty {
                    print("   No sound files found in bundle!")
                }
            } catch {
                print("Error listing bundle contents: \(error)")
            }
        }
    }

    private func warmupPlayers() {
        // Prime decoders/output path to avoid first-play latency (silent warmup)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let targets: [NSSound?] = [self.nsStartMonoSound ?? self.nsStartSound, self.nsEscMonoSound ?? self.nsEscSound]
            for ns in targets.compactMap({ $0 }) {
                let original = ns.volume
                ns.volume = 0.0
                _ = ns.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                    ns.stop()
                    ns.volume = original
                }
            }
        }
    }
    
    private func loadSounds(start startURL: URL, stop stopURL: URL, esc escURL: URL) throws {
        // print("🔧 [SoundManager] Loading sounds from URLs:")
        // print("   Start: \(startURL.lastPathComponent)")
        // print("   Stop: \(stopURL.lastPathComponent)")
        // print("   Esc: \(escURL.lastPathComponent)")
        
        do {
            // Load each sound individually with detailed error reporting
            do {
                startSound = try AVAudioPlayer(contentsOf: startURL)
                // print("✅ [SoundManager] Start sound loaded successfully")
            } catch {
                print("❌ [SoundManager] Failed to load start sound: \(error)")
                throw error
            }
            
            do {
                stopSound = try AVAudioPlayer(contentsOf: stopURL)
                // print("✅ [SoundManager] Stop sound loaded successfully")
            } catch {
                print("❌ [SoundManager] Failed to load stop sound: \(error)")
                throw error
            }
            
            do {
                escSound = try AVAudioPlayer(contentsOf: escURL)
                // print("✅ [SoundManager] Esc sound loaded successfully")
            } catch {
                print("❌ [SoundManager] Failed to load esc sound: \(error)")
                throw error
            }
            
            // Set lower volume for all sounds
            startSound?.volume = 0.7
            stopSound?.volume = 0.7
            escSound?.volume = 0.3
            
            // Prepare sounds for instant playback
            let startReady = startSound?.prepareToPlay() ?? false
            let stopReady = stopSound?.prepareToPlay() ?? false
            let escReady = escSound?.prepareToPlay() ?? false
            
            // print("🔧 [SoundManager] Sound preparation results:")
            // print("   Start sound ready: \(startReady)")
            // print("   Stop sound ready: \(stopReady)")
            // print("   Esc sound ready: \(escReady)")
            
            // print("✅ [SoundManager] All sound files loaded and prepared successfully")
        } catch {
            print("❌ [SoundManager] Critical error loading sounds: \(error.localizedDescription)")
            throw error
        }
    }
    
    func playStartSound() {
        guard isSoundFeedbackEnabled else { return }
        // Prevent duplicate within 400ms window
        let now = Date()
        if let last = lastStartSoundAt, now.timeIntervalSince(last) < 0.4 {
            return
        }
        lastStartSoundAt = now

        // Cancel any pending backup tick from previous sessions
        backupTickWorkItem?.cancel()
        backupTickWorkItem = nil
        
        let timestamp = String(format: "%.3f", Date().timeIntervalSince1970)
        print("🔊 [SoundManager] Attempting to play start sound @ \(timestamp)")
        // If BT output is active, prefer AVAudioPlayer path (prepared) to minimize NSSound routing latency.
        if AudioDeviceManager.shared.isCurrentOutputBluetooth, let player = startSound {
            player.stop()
            player.volume = 0.6
            player.prepareToPlay()
            if player.play() {
                let ts = String(format: "%.3f", Date().timeIntervalSince1970)
                print("⏱️ [TIMING] start_sound_played @ \(ts)")
                return
            }
        }

        // Otherwise prefer NSSound; if BT input is active, choose mono asset to avoid profile glitches
        let useMono = (AudioDeviceManager.shared.isCurrentOutputBluetooth || AudioDeviceManager.shared.isCurrentInputBluetooth)
                       && nsStartMonoSound != nil
        if useMono, let nsSound = nsStartMonoSound {
            nsSound.stop()
            let success = nsSound.play()
            print("🔊 [SoundManager] NSSound start MONO result: \(success)")
            if success {
                let ts = String(format: "%.3f", Date().timeIntervalSince1970)
                print("⏱️ [TIMING] start_sound_played @ \(ts)")
                // Schedule a soft backup tick for Bluetooth routes to cover SCO swallow
                if enableBackupStartTick && AudioDeviceManager.shared.isCurrentOutputBluetooth {
                    let work = DispatchWorkItem { [weak self] in
                        guard let self = self, let monoURL = self.startMonoURLRef else { return }
                        if !self.isEnabled { return }
                        if let backup = NSSound(contentsOf: monoURL, byReference: false) {
                            backup.volume = 0.28
                            _ = backup.play()
                            let ts = String(format: "%.3f", Date().timeIntervalSince1970)
                            print("🔊 [SoundManager] Backup start tick played @ \(ts)")
                        }
                    }
                    self.backupTickWorkItem = work
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: work)
                }
                return
            }
        }
        if let nsSound = nsStartSound {
            nsSound.stop()
            let success = nsSound.play()
            print("🔊 [SoundManager] NSSound start sound result: \(success)")
            if success {
                let ts = String(format: "%.3f", Date().timeIntervalSince1970)
                print("⏱️ [TIMING] start_sound_played @ \(ts)")
                return
            }
        }
        
        // Fallback to AVAudioPlayer
        if let startSound = startSound {
            startSound.stop() // Stop any previous playback
            startSound.prepareToPlay()
            let success = startSound.play()
            print("🔊 [SoundManager] AVAudioPlayer start sound result: \(success)")
            
            if success {
                let ts = String(format: "%.3f", Date().timeIntervalSince1970)
                print("⏱️ [TIMING] start_sound_played @ \(ts)")
            } else {
                print("⚠️ [SoundManager] All methods failed, using system beep")
                NSSound.beep()
            }
        } else {
            print("❌ [SoundManager] Start sound is nil, using system beep")
            NSSound.beep()
        }
    }
    
    func playStopSound() {
        guard isSoundFeedbackEnabled else { return }
        // Prevent duplicate within 300ms window
        let now = Date()
        if let last = lastStopSoundAt, now.timeIntervalSince(last) < 0.3 {
            return
        }
        lastStopSoundAt = now
        
        print("🔊 [SoundManager] Attempting to play stop sound")
        if !AudioDeviceManager.shared.isCurrentOutputBluetooth, let nsSound = nsStopSound {
            nsSound.stop()
            let finalVol = nsSound.volume
            nsSound.volume = 0.0
            let success = nsSound.play()
            fadeVolume(of: nsSound, to: finalVol, duration: 0.08)
            print("🔊 [SoundManager] NSSound stop sound result: \(success)")
            if success { return }
        }
        
        // Fallback to AVAudioPlayer
        if let stopSound = stopSound {
            stopSound.stop() // Stop any previous playback
            stopSound.prepareToPlay()
            let success = stopSound.play()
            print("🔊 [SoundManager] AVAudioPlayer stop sound result: \(success)")
            
            if !success {
                print("⚠️ [SoundManager] All methods failed, using system beep")
                NSSound.beep()
            }
        } else {
            print("❌ [SoundManager] Stop sound is nil, using system beep")
            NSSound.beep()
        }
    }
    
    func playEscSound() {
        guard isSoundFeedbackEnabled else { return }
        // Prevent duplicate within 300ms window
        let now = Date()
        if let last = lastEscSoundAt, now.timeIntervalSince(last) < 0.3 {
            return
        }
        lastEscSoundAt = now

        // Cancel any pending backup tick when exiting
        backupTickWorkItem?.cancel()
        backupTickWorkItem = nil
        
        print("🔊 [SoundManager] Attempting to play esc sound (with fade)")
        if !AudioDeviceManager.shared.isCurrentOutputBluetooth {
            let useMono = (AudioDeviceManager.shared.isCurrentInputBluetooth) && nsEscMonoSound != nil
            if useMono, let nsMono = nsEscMonoSound {
                nsMono.stop()
                let finalVol = nsMono.volume
                nsMono.volume = 0.0
                let _ = nsMono.play()
                fadeVolume(of: nsMono, to: finalVol, duration: 0.08)
                return
            }
            if let nsSound = nsEscSound {
                nsSound.stop()
                let finalVol = nsSound.volume
                nsSound.volume = 0.0
                let _ = nsSound.play()
                fadeVolume(of: nsSound, to: finalVol, duration: 0.08)
                return
            }
        }
        
        // Fallback to AVAudioPlayer
        if let escSound = escSound {
            escSound.stop() // Stop any previous playback
            escSound.prepareToPlay()
            let _ = escSound.play()
            fadeVolume(of: escSound, to: 0.3, duration: 0.08)
            let success = true
            print("🔊 [SoundManager] AVAudioPlayer esc sound result: \(success)")
            
            if !success {
                print("⚠️ [SoundManager] All methods failed, using system beep")
                NSSound.beep()
            }
        } else {
            print("❌ [SoundManager] Esc sound is nil, using system beep")
            NSSound.beep()
        }
    }
    
    var isEnabled: Bool {
        get { isSoundFeedbackEnabled }
        set { isSoundFeedbackEnabled = newValue }
    }
    
    // MARK: - Debug and Testing Methods
    
    /// Test method to manually trigger all sounds for debugging
    func testAllSounds() {
        print("🧪 [SoundManager] Testing all sounds...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("🧪 [SoundManager] Playing start sound...")
            self.playStartSound()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            print("🧪 [SoundManager] Playing stop sound...")
            self.playStopSound()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            print("🧪 [SoundManager] Playing esc sound...")
            self.playEscSound()
        }
    }
    
    // MARK: - macOS Audio Management
    // Note: macOS handles audio routing automatically
    
    /// Plays the start sound, but delays slightly when a Bluetooth input (e.g., AirPods) is active
    /// to allow the system time to switch to the HFP profile so the sound is audible.
    func playStartSoundRouteAware() {
        // Deprecated in favor of keyDown/keyUp mapping; keep for compatibility.
        playKeyDown()
    }
    
    // MARK: - New SFX API
    func playKeyDown() {
        guard isSoundFeedbackEnabled else { return }
        let now = Date()
        if let last = lastKeyDownAt, now.timeIntervalSince(last) < 0.2 { return }
        lastKeyDownAt = now
        if let ns = nsKeyDownSound { ns.stop(); _ = ns.play(); return }
        if let av = keyDownSound { av.stop(); av.prepareToPlay(); _ = av.play(); return }
    }
    
    func playKeyUp() {
        guard isSoundFeedbackEnabled else { return }
        let now = Date()
        if let last = lastKeyUpAt, now.timeIntervalSince(last) < 0.2 { return }
        lastKeyUpAt = now
        if let ns = nsKeyUpSound { ns.stop(); _ = ns.play(); return }
        if let av = keyUpSound { av.stop(); av.prepareToPlay(); _ = av.play(); return }
    }
    
    func playLock() {
        guard isSoundFeedbackEnabled else { return }
        let now = Date()
        if let last = lastLockAt, now.timeIntervalSince(last) < 0.3 { return }
        lastLockAt = now
        if let ns = nsLockSound { ns.stop(); _ = ns.play(); return }
        if let av = lockSound { av.stop(); av.prepareToPlay(); _ = av.play(); return }
    }

    func cancelScheduledBackupTick() {
        backupTickWorkItem?.cancel()
        backupTickWorkItem = nil
    }

    // MARK: - Helpers
    private func fadeVolume(of nsSound: NSSound, to target: Float, duration: TimeInterval) {
        let steps = 6
        let interval = duration / Double(steps)
        var current = nsSound.volume
        let delta = (target - current) / Float(steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                current += delta
                nsSound.volume = current
            }
        }
    }
    
    private func fadeVolume(of player: AVAudioPlayer, to target: Float, duration: TimeInterval) {
        let steps = 6
        let interval = duration / Double(steps)
        var current = player.volume
        let delta = (target - current) / Float(steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                current += delta
                player.volume = current
            }
        }
    }
}
