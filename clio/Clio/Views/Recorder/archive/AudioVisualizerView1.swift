// import SwiftUI

// struct AudioVisualizer: View {
//     let audioMeter: AudioMeter
//     let color: Color
//     let isActive: Bool
    
//     private let barCount = 16
//     private let minHeight: CGFloat = 2.5
//     private let maxHeight: CGFloat = 20
//     private let barWidth: CGFloat = 2.0
//     private let barSpacing: CGFloat = 3
//     private let hardThreshold: Double = 0.1
    
//     private let sensitivityMultipliers: [Double]
    
//     @State private var barHeights: [CGFloat]
//     @State private var targetHeights: [CGFloat]
    
//     init(audioMeter: AudioMeter, color: Color, isActive: Bool) {
//         self.audioMeter = audioMeter
//         self.color = color
//         self.isActive = isActive
        
//         // Generate random sensitivity multipliers for each bar
//         self.sensitivityMultipliers = (0..<16).map { _ in
//             Double.random(in: 0.2...1.9)
//         }
        
//         _barHeights = State(initialValue: Array(repeating: 4, count: 16))
//         _targetHeights = State(initialValue: Array(repeating: 4, count: 16))
//     }
    
//     var body: some View {
//         HStack(spacing: barSpacing) {
//             ForEach(0..<barCount, id: \.self) { index in
//                 // Simple, clean bars like in the reference images
//                 RoundedRectangle(cornerRadius: 1.0)
//                     .fill(color)
//                     .frame(width: barWidth, height: barHeights[index])
//             }
//         }
//         .onChange(of: audioMeter) { _, newValue in
//             if isActive {
//                 updateBars(with: Float(newValue.averagePower))
//             } else {
//                 resetBars()
//             }
//         }
//         .onChange(of: isActive) { _, newValue in
//             if !newValue {
//                 resetBars()
//             } 
//         }
//     }
    
//     private func updateBars(with audioLevel: Float) {
//         let normalizedLevel = max(0, min(1, Double(audioLevel)))
//         let adjustedLevel = normalizedLevel > hardThreshold ? 
//             (normalizedLevel - hardThreshold) / (1.0 - hardThreshold) : 0
        
//         let range = maxHeight - minHeight
        
//         for i in 0..<barCount {
//             let sensitivity = sensitivityMultipliers[i]
//             let targetHeight = minHeight + CGFloat(adjustedLevel * sensitivity) * range
            
//             let smoothingFactor: CGFloat = 0.3
//             targetHeights[i] = targetHeights[i] * (1 - smoothingFactor) + targetHeight * smoothingFactor
            
//             withAnimation(.easeInOut(duration: 0.1)) {
//                 barHeights[i] = targetHeights[i]
//             }
//         }
//     }
    
//     private func resetBars() {
//         withAnimation(.easeOut(duration: 0.2)) {
//             barHeights = Array(repeating: minHeight, count: barCount)
//             targetHeights = Array(repeating: minHeight, count: barCount)
//         }
//     }
// }

// struct StaticVisualizer: View {
//     private let barCount = 24
//     private let barWidth: CGFloat = 2.5
//     private let staticHeight: CGFloat = 6.0 
//     private let barSpacing: CGFloat = 1.5
//     let color: Color
    
//     var body: some View {
//         HStack(spacing: barSpacing) {
//             ForEach(0..<barCount, id: \.self) { index in
//                 RoundedRectangle(cornerRadius: 2.0)
//                     .fill(
//                         LinearGradient(
//                             gradient: Gradient(colors: [
//                                 color,
//                                 color.opacity(0.6)
//                             ]),
//                             startPoint: .top,
//                             endPoint: .bottom
//                         )
//                     )
//                     .frame(width: barWidth, height: staticHeight)
//                     .shadow(color: color.opacity(0.2), radius: 0.5, x: 0, y: 0.5)
//             }
//         }
//     }
// }

// struct WaveVisualizer: View {
//     private let barCount = 16
//     private let barWidth: CGFloat = 2.0
//     private let barSpacing: CGFloat = 1.5
//     private let minHeight: CGFloat = 4
//     private let maxHeight: CGFloat = 20  // Shortened wave height
//     let color: Color
    
//     @State private var currentIndex: Int = 0
//     @State private var movingForward = true
//     @State private var barHeights: [CGFloat]
//     @State private var timer: Timer?
//     @State private var pulseScale: CGFloat = 1.0
    
//     init(color: Color) {
//         self.color = color
//         _barHeights = State(initialValue: Array(repeating: 4, count: 16))
//     }
    
//     var body: some View {
//         HStack(spacing: barSpacing) {
//             ForEach(0..<barCount, id: \.self) { index in
//                 ZStack {
//                     // Subtle background glow
//                     RoundedRectangle(cornerRadius: 2.5)
//                         .fill(color.opacity(0.15))
//                         .frame(width: barWidth + 1, height: barHeights[index] + 2)
//                         .blur(radius: 1)
                    
//                     // Main bar with gradient
//                     RoundedRectangle(cornerRadius: 2.0)
//                         .fill(
//                             LinearGradient(
//                                 gradient: Gradient(colors: [
//                                     color,
//                                     color.opacity(0.7)
//                                 ]),
//                                 startPoint: .top,
//                                 endPoint: .bottom
//                             )
//                         )
//                         .frame(width: barWidth, height: barHeights[index])
//                         .shadow(color: color.opacity(0.4), radius: 1.5, x: 0, y: 1)
//                 }
//                 .animation(.spring(response: 0.2, dampingFraction: 0.9), value: barHeights[index])
//             }
//         }
//         .scaleEffect(pulseScale)
//         .onAppear {
//             startWaveAnimation()
//             startPulseAnimation()
//         }
//         .onDisappear {
//             timer?.invalidate()
//             timer = nil
//         }
//     }
    
//     private func startWaveAnimation() {
//         timer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { _ in
//             updateWave()
//         }
//     }
    
//     private func updateWave() {
//         // Create wave effect around current position with Gaussian-like distribution
//         let waveWidth = 6  // Adjusted for 16 bars
        
//         for i in 0..<barCount {
//             let distance = abs(i - currentIndex)
//             if distance <= waveWidth {
//                 // Use a Gaussian-like curve for smoother, more gradual wave
//                 let normalizedDistance = Double(distance) / Double(waveWidth)
//                 let gaussianValue = exp(-2.0 * normalizedDistance * normalizedDistance)
//                 let height = minHeight + (maxHeight - minHeight) * CGFloat(gaussianValue)
//                 barHeights[i] = height
//             } else {
//                 // Gradually decay bars outside the wave to minimum height
//                 barHeights[i] = minHeight
//             }
//         }
        
//         // Move to next position
//         if movingForward {
//             currentIndex += 1
//             if currentIndex >= barCount - 1 {
//                 currentIndex = barCount - 1
//                 movingForward = false
//             }
//         } else {
//             currentIndex -= 1
//             if currentIndex <= 0 {
//                 currentIndex = 0
//                 movingForward = true
//             }
//         }
//     }
    
//     private func startPulseAnimation() {
//         withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
//             pulseScale = 1.02
//         }
//     }
// }
