import SwiftUI
import Foundation
import Combine

struct AudioVisualizer: View {
    let audioMeter: AudioMeter
    let color: Color
    let isActive: Bool
    
    private let barCount = 12  // Keep original count for better visual appeal
    private let barWidth: CGFloat = 2.5
    private let barSpacing: CGFloat = 2.0
    private let minHeight: CGFloat = 4.0
    private let maxHeight: CGFloat = 20.0
    private let hardThreshold: Double = 0.5
    private let minIdleAmplitude: Double = 0.04 // ensure slight movement when quiet
    
    @State private var barHeights: [CGFloat] = []
    @State private var animationPhase: Double = 0
    @State private var currentAmplitudeMultiplier: Double = 0.1 // Idle amplitude (15% - clearly visible movement)
    @State private var tickerCancellable: AnyCancellable?
    @State private var barScales: [CGFloat] = []
    
    init(audioMeter: AudioMeter, color: Color, isActive: Bool) {
        self.audioMeter = audioMeter
        self.color = color
        self.isActive = isActive
    }
    
    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(color)  // Solid color instead of gradient for performance
                    .frame(width: barWidth, height: barHeights.count > index ? barHeights[index] : minHeight)
                    .scaleEffect(x: 1.0, y: barScales.count > index ? barScales[index] : 0.0)
                    // No shadow for better performance
            }
        }
        .onAppear {
            setupInitialHeights()
            setupInitialScales()
            startAnimation()
            // Removed animateStaggeredReveal() for instant appearance
        }
        .onDisappear {
            AnimationTicker.shared.stopTicking()
            tickerCancellable?.cancel()
            tickerCancellable = nil
        }
        .onChange(of: audioMeter) { _, newValue in
            if isActive {
                updateAmplitudeFromAudio(Float(newValue.averagePower))
            }
        }
        .onChange(of: isActive) { _, newValue in
            print("🔄 AudioVisualizer state changed: isActive = \(newValue)")
            // No hardcoded amplitude changes - let audio levels decide everything!
        }
    }
    
    private func setupInitialHeights() {
        barHeights = (0..<barCount).map { index in
            let normalizedIndex = Double(index) / Double(barCount - 1)
            let centerDistance = abs(normalizedIndex - 0.5) * 2.0
            let height = minHeight + (maxHeight - minHeight) * CGFloat(exp(-centerDistance * centerDistance * 2.0)) * 0.05
            return height
        }
    }
    
    private func setupInitialScales() {
        barScales = Array(repeating: 1.0, count: barCount)  // Start fully visible - no reveal animation
    }
    
    private func animateStaggeredReveal() {
        // Animate bars from center outward
        let centerIndex = barCount / 2
        for i in 0..<barCount {
            let distance = abs(i - centerIndex)
            let delay = Double(distance) * 0.025 // 25ms delay per bar from center
            
            withAnimation(.interpolatingSpring(stiffness: 600, damping: 25).delay(delay)) {
                if barScales.count > i {
                    barScales[i] = 1.0
                }
            }
        }
    }
    
    private func startAnimation() {
        AnimationTicker.shared.startTicking()
        tickerCancellable = AnimationTicker.shared.publisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                updateBarHeights()
            }
    }
    
    private func updateAmplitudeFromAudio(_ audioLevel: Float) {
        // Use the raw audio level directly - it already represents what we want!
        let normalizedLevel = max(0, min(1, Double(audioLevel)))
        
        // Aggressive speech amplification with ambient suppression
        let targetAmplitude: Double
        if normalizedLevel < 0.3 {
            // Ambient/low sounds - keep very flat
            targetAmplitude = normalizedLevel * 0.8
        } else {
            // Speech range - aggressive amplification to hit 85-90%
            let speechLevel = (normalizedLevel - 0.3) / 0.7 // Normalize speech range to 0-1
            targetAmplitude = 0.3 + (pow(speechLevel, 0.2) * 0.7) // 0.3 base + up to 0.7 more
        }
        
        // Apply idle baseline and smooth within [0,1]
        let adjustedTarget = max(minIdleAmplitude, min(1.0, targetAmplitude))
        let smoothingFactor = 0.3
        currentAmplitudeMultiplier = currentAmplitudeMultiplier * (1 - smoothingFactor) + adjustedTarget * smoothingFactor
        currentAmplitudeMultiplier = max(0.0, min(1.0, currentAmplitudeMultiplier))
    }
    
    private func updateBarHeights() {
        let newHeights = (0..<barCount).map { index in
            let normalizedIndex = Double(index) / Double(barCount - 1)
            
            // Create more natural audio wave pattern - inspired by EmptyStateAudioBars
            let wave1 = sin(animationPhase * 2.0 + normalizedIndex * .pi * 4.0)
            let wave2 = sin(animationPhase * 1.5 + normalizedIndex * .pi * 2.0) * 0.5
            let combined = (wave1 + wave2) * 0.5 + 0.5
            
            // Add variation per bar for more natural audio wave look
            let barVariation = sin(Double(index) * 0.8 + animationPhase * 0.3) * 0.3 + 0.7
            
            // Apply current amplitude multiplier with bar-specific variation
            let amplitude = (maxHeight - minHeight) * currentAmplitudeMultiplier
            let height = minHeight + amplitude * CGFloat(combined * barVariation)
            
            return max(minHeight, height)
        }
        
        if RuntimeConfig.disableVisualizerAnimation {
            barHeights = newHeights
        } else {
            withAnimation(.easeInOut(duration: 0.8)) {
                barHeights = newHeights
            }
        }
        
        animationPhase += 0.1  // Slower phase increment for smoother movement
    }
}

struct StaticVisualizer: View {
    private let barCount = 10  // Reduced from 15 for better performance
    private let barWidth: CGFloat = 2.5
    private let barSpacing: CGFloat = 2.0
    private let minHeight: CGFloat = 4.0
    private let maxHeight: CGFloat = 16.0
    let color: Color
    
    @State private var barHeights: [CGFloat] = []
    @State private var animationPhase: Double = 0
    @State private var tickerCancellable: AnyCancellable?
    
    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(color)  // Solid color instead of gradient for performance
                    .frame(width: barWidth, height: barHeights.count > index ? barHeights[index] : minHeight)
                    // No shadow for better performance
            }
        }
        .onAppear {
            setupInitialHeights()
            startAnimation()
        }
        .onDisappear {
            AnimationTicker.shared.stopTicking()
            tickerCancellable?.cancel()
            tickerCancellable = nil
        }
    }
    
    private func setupInitialHeights() {
        barHeights = Array(repeating: minHeight, count: barCount)
    }
    
    private func startAnimation() {
        AnimationTicker.shared.startTicking()
        tickerCancellable = AnimationTicker.shared.publisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                updateBarHeights()
            }
    }
    
    private func updateBarHeights() {
        // Calculate new heights
        let newHeights = (0..<barCount).map { i in
            // Faster, smoother wave pattern
            let phase = animationPhase + Double(i) * 0.25
            let baseWave = sin(phase) * 0.4 + sin(phase * 2.3) * 0.15
            
            // Much smaller amplitude for static state - very subtle movement
            let amplitude = (maxHeight - minHeight) * 0.08 // Much smaller for static state
            let height = minHeight + amplitude + amplitude * CGFloat(baseWave)
            
            return max(minHeight, height)
        }
        
        // Update state
        barHeights = newHeights
        animationPhase += 0.2
    }
}

struct LoadingDots: View {
    let color: Color
    
    @State private var currentDotCount = 1
    @State private var tickerCancellable: AnyCancellable?
    @State private var animationCounter = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: 4, height: 4)
                    .opacity(index < currentDotCount ? 1.0 : 0.3)
            }
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            AnimationTicker.shared.stopTicking()
            tickerCancellable?.cancel()
            tickerCancellable = nil
        }
    }
    
    private func startAnimation() {
        AnimationTicker.shared.startTicking()
        tickerCancellable = AnimationTicker.shared.publisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                animationCounter += 1
                // Update every 30 frames (~0.5 seconds at 60fps)
                if animationCounter % 30 == 0 {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentDotCount = currentDotCount == 3 ? 1 : currentDotCount + 1
                    }
                }
            }
    }
}

struct WaveVisualizer: View {
    private let barCount = 8  // Further reduced for mini recorder
    private let barWidth: CGFloat = 2.0
    private let barSpacing: CGFloat = 1.5
    private let minHeight: CGFloat = 4
    private let maxHeight: CGFloat = 20  // Shortened wave height
    let color: Color
    
    @State private var currentPosition: Double = -5.0  // Start off-screen to the left
    @State private var movingForward = true
    @State private var barHeights: [CGFloat]
    @State private var tickerCancellable: AnyCancellable?
    @State private var pulseScale: CGFloat = 1.0
    
    init(color: Color) {
        self.color = color
        _barHeights = State(initialValue: Array(repeating: 4, count: 8))
    }
    
    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2.0)
                    .fill(color)  // Solid color instead of gradient for performance
                    .frame(width: barWidth, height: barHeights[index])
                    // No background glow or shadow for better performance
                    .animation(nil, value: barHeights[index])
            }
        }
        .scaleEffect(pulseScale)
        .onAppear {
            startWaveAnimation()
            startPulseAnimation()
        }
        .onDisappear {
            AnimationTicker.shared.stopTicking()
            tickerCancellable?.cancel()
            tickerCancellable = nil
        }
    }
    
    private func startWaveAnimation() {
        AnimationTicker.shared.startTicking()
        tickerCancellable = AnimationTicker.shared.publisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                updateWave()
            }
    }
    
    private func updateWave() {
        // Calculate new heights
        let newHeights = (0..<barCount).map { i in
            // Create wave effect around current position with Gaussian-like distribution
            let waveWidth = 6.0  // Wider wave for smoother effect
            let distance = abs(Double(i) - currentPosition)
            
            if distance <= waveWidth {
                // Use a Gaussian-like curve for smoother, more gradual wave
                let normalizedDistance = distance / waveWidth
                let gaussianValue = exp(-1.8 * normalizedDistance * normalizedDistance)
                // Add subtle randomness for organic feel
                let randomFactor = Double.random(in: 0.9...1.1)
                return minHeight + (maxHeight - minHeight) * CGFloat(gaussianValue * randomFactor)
            } else {
                return minHeight
            }
        }
        
        // Update state
        barHeights = newHeights
        
        // Move to next position with bouncing behavior (fractional movement for smoothness)
        let moveSpeed: Double = 0.65  // Adjust this for wave speed
        let waveWidth = 6.0
        
        if movingForward {
            currentPosition += moveSpeed
            if currentPosition >= Double(barCount) + waveWidth {
                currentPosition = Double(barCount) + waveWidth - moveSpeed
                movingForward = false
            }
        } else {
            currentPosition -= moveSpeed
            if currentPosition <= -waveWidth {
                currentPosition = -waveWidth + moveSpeed
                movingForward = true
            }
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseScale = 1.02
        }
    }
}
