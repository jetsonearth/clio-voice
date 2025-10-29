//import SwiftUI
//import AVFoundation
//
//struct SimpleAudioPlayer: View {
//    let audioURL: URL
//    let onDismiss: () -> Void
//    
//    @State private var player: AVAudioPlayer?
//    @State private var isPlaying = false
//    @State private var currentTime: TimeInterval = 0
//    @State private var duration: TimeInterval = 0
//    @State private var timer: Timer?
//    
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            VStack(spacing: 12) {
//                // Controls
//            HStack(spacing: 16) {
//                // Play/Pause button
//                Button(action: togglePlayback) {
//                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                        .font(.system(size: 24))
//                        .foregroundColor(.accentColor)
//                }
//                .buttonStyle(.plain)
//                
//                // Progress
//                VStack(alignment: .leading, spacing: 4) {
//                    // Time labels
//                    HStack {
//                        Text(formatTime(currentTime))
//                            .font(.system(size: 11, weight: .regular, design: .monospaced))
//                            .foregroundColor(.secondary)
//                        
//                        Spacer()
//                        
//                        Text(formatTime(duration))
//                            .font(.system(size: 11, weight: .regular, design: .monospaced))
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    // Progress bar
//                    ProgressView(value: duration > 0 ? currentTime / duration : 0)
//                        .progressViewStyle(LinearProgressViewStyle())
//                }
//            }
//            .padding(16)
//            
//            // Close button in top-right corner
//            Button(action: onDismiss) {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.secondary)
//                    .background(Circle().fill(.regularMaterial))
//            }
//            .buttonStyle(.plain)
//            .padding(8)
//        }
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(.regularMaterial)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                )
//        )
//        .onAppear {
//            setupPlayer()
//        }
//        .onDisappear {
//            cleanup()
//        }
//    }
//    
//    private func setupPlayer() {
//        do {
//            player = try AVAudioPlayer(contentsOf: audioURL)
//            player?.prepareToPlay()
//            duration = player?.duration ?? 0
//        } catch {
//            print("Failed to setup audio player: \(error)")
//        }
//    }
//    
//    private func togglePlayback() {
//        guard let player = player else { return }
//        
//        if isPlaying {
//            player.pause()
//            stopTimer()
//        } else {
//            player.play()
//            startTimer()
//        }
//        isPlaying.toggle()
//    }
//    
//    private func startTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//            guard let player = player else { return }
//            currentTime = player.currentTime
//            
//            if !player.isPlaying && isPlaying {
//                // Audio finished
//                isPlaying = false
//                currentTime = 0
//                stopTimer()
//            }
//        }
//    }
//    
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    private func cleanup() {
//        player?.stop()
//        stopTimer()
//        player = nil
//    }
//    
//    private func formatTime(_ time: TimeInterval) -> String {
//        let minutes = Int(time) / 60
//        let seconds = Int(time) % 60
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//}
