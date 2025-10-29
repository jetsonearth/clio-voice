import Foundation
import AVFoundation
import SwiftUI

class OnboardingAudioManager: ObservableObject {
    static let shared = OnboardingAudioManager()
    
    // Default to unmuted unless user has explicitly chosen mute
    @Published var isMuted: Bool = false {
        didSet {
            updateVolume()
            UserDefaults.standard.set(isMuted, forKey: "onboarding_audio_muted")
            // Keep playback running; volume reflects mute state
            if isMuted {
                // Keep playing at volume 0 to allow instant unmute without starting playback
                audioPlayer?.volume = 0.0
            } else {
                // Ensure playback is active when unmuted
                startMusic()
            }
        }
    }
    
    private var audioPlayer: AVAudioPlayer?
    private let normalVolume: Float = 0.8 // 80% volume as requested
    
    private init() {
        // Load muted state from UserDefaults; if not set, default to false (music on)
        if UserDefaults.standard.object(forKey: "onboarding_audio_muted") != nil {
            isMuted = UserDefaults.standard.bool(forKey: "onboarding_audio_muted")
        } else {
            isMuted = false
            UserDefaults.standard.set(false, forKey: "onboarding_audio_muted")
        }
        setupAudioPlayer()
    }
    
    private func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: "onboarding", withExtension: "mp3") else {
            print("❌ [OnboardingAudio] Could not find onboarding.mp3 file")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = isMuted ? 0.0 : normalVolume
            audioPlayer?.prepareToPlay()
            print("✅ [OnboardingAudio] Audio player setup successfully")
        } catch {
            print("❌ [OnboardingAudio] Failed to setup audio player: \(error)")
        }
    }
    
    func startMusic() {
        guard let player = audioPlayer else {
            print("❌ [OnboardingAudio] No audio player available")
            return
        }
        // Always start playback; volume is controlled by isMuted
        if !player.isPlaying {
            player.play()
            print("🎵 [OnboardingAudio] Started onboarding music")
        }
        // Ensure volume reflects current mute state immediately
        player.volume = isMuted ? 0.0 : normalVolume
    }
    
    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0 // Reset to beginning
        print("⏹️ [OnboardingAudio] Stopped onboarding music")
    }
    
    func toggleMute() {
        isMuted.toggle()
    }
    
    private func updateVolume() {
        audioPlayer?.volume = isMuted ? 0.0 : normalVolume
        print("🔊 [OnboardingAudio] Volume updated - Muted: \(isMuted)")
    }
    
    deinit {
        stopMusic()
    }
}