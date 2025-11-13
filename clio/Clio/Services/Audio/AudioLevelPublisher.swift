import Foundation
import SwiftUI

/// An extremely lightweight observable that publishes audio-meter updates for the UI that actually needs them (mini-recorder visualiser).
/// Other screens can stay detached from the high-frequency 20 Hz updates coming from RecordingEngine.
@MainActor
final class AudioLevelPublisher: ObservableObject {
    /// Latest RMS/peak information sampled from the recorder or streaming engine.
    /// 0…1 where 1 is full-scale.
    @Published var level: AudioMeter = AudioMeter(averagePower: 0, peakPower: 0)
} 