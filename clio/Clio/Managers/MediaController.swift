import AppKit
import Combine
import Foundation
import SwiftUI
import CoreAudio

/// Controls system audio management during recording
class MediaController: ObservableObject {
    static let shared = MediaController()
    private var didMuteAudio = false
    private var wasAudioMutedBeforeRecording = false
    
    @Published var isSystemMuteEnabled: Bool = UserDefaults.standard.bool(forKey: "isSystemMuteEnabled") {
        didSet {
            UserDefaults.standard.set(isSystemMuteEnabled, forKey: "isSystemMuteEnabled")
        }
    }
    
    private init() {
        // Set default if not already set
        if !UserDefaults.standard.contains(key: "isSystemMuteEnabled") {
            UserDefaults.standard.set(true, forKey: "isSystemMuteEnabled")
        }
    }
    
    /// Checks if the system audio is currently muted using AppleScript
    private func isSystemAudioMuted() -> Bool {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "output muted of (get volume settings)"]
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return output == "true"
            }
        } catch {
            // Silently fail
        }
        
        return false
    }
    
    /// Mutes system audio during recording
    func muteSystemAudio() async -> Bool {
        guard isSystemMuteEnabled else { return false }
        
        // First check if audio is already muted
        wasAudioMutedBeforeRecording = isSystemAudioMuted()
        
        // If already muted, no need to mute it again
        if wasAudioMutedBeforeRecording {
            return true
        }
        
        // Otherwise mute the audio
        let success = executeAppleScript(command: "set volume with output muted")
        didMuteAudio = success
        return success
    }
    
    /// Restores system audio after recording
    func unmuteSystemAudio() async {
        guard isSystemMuteEnabled else { return }
        
        // Only unmute if we actually muted it (and it wasn't already muted)
        if didMuteAudio && !wasAudioMutedBeforeRecording {
            // Fade unmute in two steps to avoid pop on BT routes
            _ = executeAppleScript(command: "set volume without output muted")
        }
        
        didMuteAudio = false
    }
    
    /// Executes an AppleScript command
    private func executeAppleScript(command: String) -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }
}

extension UserDefaults {
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
    
    var isSystemMuteEnabled: Bool {
        get { bool(forKey: "isSystemMuteEnabled") }
        set { set(newValue, forKey: "isSystemMuteEnabled") }
    }
}
