import SwiftUI
import Combine

/// Audio visualizer for the notch with selectable styles. Defaults to elegant bars.
struct RecordingVisualizerView: View {
    @ObservedObject var recorder: Recorder
    @ObservedObject var whisperState: WhisperState
    let isActive: Bool

    // Test new direct audio visualizer
    private let style: VisualStyle = .directAudio

    enum VisualStyle {
        case wave, bars, dynamicWave, directAudio
        #if canImport(Orb)
        case orb
        #endif
    }

    var body: some View {
        // Source 1: meters (recorder + Soniox)
        let meterProvider: () -> AudioMeter = {
            let r = recorder.audioMeter
            let s = whisperState.sonioxStreamingService.sonioxMeter
            return AudioMeter(
                averagePower: max(r.averagePower, s.averagePower),
                peakPower: max(r.peakPower, s.peakPower)
            )
        }
        // Source 2: direct level from streaming service (0..1)
        let streamingLevelProvider: () -> Double = { whisperState.sonioxStreamingService.streamingAudioLevel }

        ZStack(alignment: .trailing) {
            // Show mic-driven visualizer ONLY during active recording.
            // For pre-recording (attempting) and post-recording processing, show loading indicator.
            if whisperState.isRecording {
                switch style {
                case .wave:
                    ElegantAudioWave(audioMeterProvider: meterProvider,
                                      streamingLevelProvider: streamingLevelProvider,
                                      isActive: isActive)
                case .bars:
                    ElegantBarsVisualizer(audioMeterProvider: meterProvider,
                                          streamingLevelProvider: streamingLevelProvider,
                                          isActive: isActive)
                case .dynamicWave:
                    DynamicIslandWave(audioMeterProvider: meterProvider,
                                      streamingLevelProvider: streamingLevelProvider,
                                      isActive: isActive)
                case .directAudio:
                    // Observe unified audio level publisher so it works for both streaming and local modes
                    DirectAudioVisualizer(levelSource: whisperState.audioLevel,
                                          isActive: isActive)
                #if canImport(Orb)
                case .orb:
                    OrbMinimalVisualizer(audioMeterProvider: meterProvider,
                                         streamingLevelProvider: streamingLevelProvider,
                                         isActive: isActive,
                                         preset: .mystic)
                #endif
                }
            } else if (whisperState.isProcessing && !whisperState.isRecording) {
                // Show loading ONLY after recording stops, while transcribing/enhancing
                ThreeBallsTriangleIfAvailable()
            } else {
                // Idle: keep minimal placeholder to avoid dead space
                MinimalIdlePlaceholder()
            }
        }
        .frame(width: 60, height: 14, alignment: .leading)
    }
}

// Minimal inline placeholder to avoid dependency on private view in another file
private struct MinimalIdlePlaceholder: View {
    @State private var phase: Double = 0
    @State private var timer: Timer?
    var body: some View {
        HStack(spacing: 2) {
ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 1.6, height: 1.6)
                    .scaleEffect(scale(for: i))
                    .animation(.easeInOut(duration: 0.5), value: phase)
            }
            Spacer(minLength: 0)
        }
        .onAppear { start() }
        .onDisappear { stop() }
    }
    private func scale(for index: Int) -> CGFloat {
        let t = phase - Double(index) * 0.4
        return 0.9 + 0.2 * CGFloat((sin(t) + 1) * 0.5)
    }
    private func start() {
        stop()
        let interval = RuntimeConfig.reducedUIEffects ? (1.0/10.0) : (1.0/30.0)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            phase = (phase + 0.4).truncatingRemainder(dividingBy: .pi * 2)
        }
        if let t = timer { RunLoop.main.add(t, forMode: .common) }
    }
    private func stop() {
        timer?.invalidate()
        timer = nil
    }
}

/// Jitter-free elegant audio wave with subtle glow, suitable for very small height.
private struct ElegantAudioWave: View {
    let audioMeterProvider: () -> AudioMeter
    let streamingLevelProvider: () -> Double
    let isActive: Bool

    // State
    @State private var level: Double = 0.0 // 0..1 (smoothed)
    @State private var phase: Double = 0.0 // radians
    @State private var timer: Timer?

    // Smoothing tunables
    private let gate: Double = 0.02    // ignore tiny noise
    private let attack: Double = 0.55  // rise speed
    private let release: Double = 0.12 // fall speed

    // Wave tunables
    private let frequency: Double = 1.6   // waves across width
    private let phaseSpeed: Double = 0.18 // radians per tick

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let strokeColor = Color.white

            ZStack {
                // Glow stroke (blurred)
                wavePath(size: size)
                    .stroke(strokeColor.opacity(isActive ? 0.35 : 0.20), lineWidth: 3)
                    .blur(radius: 2)

                // Main crisp stroke
                wavePath(size: size)
                    .stroke(strokeColor.opacity(isActive ? 0.95 : 0.55), lineWidth: 1.5)
            }
            .modifier(ConditionalDrawingGroup(enabled: !RuntimeConfig.reducedUIEffects))
        }
        .onAppear { start() }
        .onDisappear { stop() }
    }

    private func start() {
        stop()
        let interval = RuntimeConfig.reducedUIEffects ? (1.0 / 20.0) : (1.0 / 30.0)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            sampleAndUpdate()
        }
        if let t = timer { RunLoop.main.add(t, forMode: .common) }
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func sampleAndUpdate() {
        // Source A: meter values in [-1,0] -> normalize to [0,1]
        let m = audioMeterProvider()
        let raw = max(m.averagePower, m.peakPower)
        var normA = max(0.0, min(1.0, raw + 1.0))
        // Source B: direct 0..1 level from streaming service
        let normB = max(0.0, min(1.0, streamingLevelProvider()))
        var norm = max(normA, normB)
        if norm < gate { norm = 0.0 }

        let target = isActive ? norm : 0.0
        let coeff = target > level ? attack : release
        let smoothed = level + (target - level) * coeff

        DispatchQueue.main.async {
            self.level = smoothed
            self.phase = (self.phase + self.phaseSpeed).truncatingRemainder(dividingBy: .pi * 2)
        }
    }

    private func wavePath(size: CGSize) -> Path {
        let width = max(size.width, 1)
        let height = max(size.height, 1)
        let midY = height / 2

        let eased = pow(level, 1.4)
        let maxA = max(0, midY - 1)
        let amplitude = min(maxA, maxA * (0.25 + 0.65 * eased))

        func envelope(_ x: CGFloat) -> CGFloat {
            if width <= 1 { return 1 }
            let w = Double(x / width)
            return CGFloat(0.5 * (1 - cos(2 * .pi * w)))
        }

        var path = Path()
        let steps = Int(width.rounded())
        guard steps > 0 else { return path }
        let k = 2 * Double.pi * 1.6 / Double(width)

        func y(_ x: CGFloat) -> CGFloat {
            let xx = Double(x)
            let s = sin(k * xx + phase)
            return midY + CGFloat(s) * amplitude * envelope(x)
        }

        path.move(to: CGPoint(x: 0, y: y(0)))
        var x: CGFloat = 1
        while Int(x) <= steps {
            path.addLine(to: CGPoint(x: x, y: y(x)))
            x += 1
        }
        return path
    }
}

/// Dynamic Island-style audio wave with fluid, organic motion and blob-like characteristics.
private struct DynamicIslandWave: View {
    let audioMeterProvider: () -> AudioMeter
    let streamingLevelProvider: () -> Double
    let isActive: Bool
    
    // State for organic blob motion
    @State private var level: Double = 0.0
    @State private var primaryPhase: Double = 0.0
    @State private var secondaryPhase: Double = 0.0
    @State private var organicPhase: Double = 0.0
    @State private var breathPhase: Double = 0.0
    @State private var timer: Timer?
    @State private var debugCounter: Int = 0
    
    // Smoothing - much more responsive for organic feel
    private let gate: Double = 0.01
    private let attack: Double = 0.85  // very fast attack
    private let release: Double = 0.35 // slower release for flowing feel
    
    // Organic motion parameters - more irregular
    private let primaryFreq: Double = 1.2    // main blob frequency
    private let secondaryFreq: Double = 2.8  // secondary blob frequency
    private let organicFreq: Double = 0.6    // slow organic morphing
    
    // Phase speeds for fluid, non-uniform motion
    private let primarySpeed: Double = 0.15
    private let secondarySpeed: Double = 0.22
    private let organicSpeed: Double = 0.09
    private let breathSpeed: Double = 0.05   // very slow breathing motion
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let strokeColor = Color.white
            
            ZStack {
                // Outer glow layer with more spread
                dynamicWavePath(size: size)
                    .stroke(strokeColor.opacity(isActive ? 0.25 : 0.15), lineWidth: 4)
                    .blur(radius: 3)
                
                // Inner glow layer
                dynamicWavePath(size: size)
                    .stroke(strokeColor.opacity(isActive ? 0.45 : 0.25), lineWidth: 2.5)
                    .blur(radius: 1.5)
                
                // Main crisp stroke
                dynamicWavePath(size: size)
                    .stroke(strokeColor.opacity(isActive ? 1.0 : 0.65), lineWidth: 1.2)
            }
            .modifier(ConditionalDrawingGroup(enabled: !RuntimeConfig.reducedUIEffects))
        }
        .onAppear { start() }
        .onDisappear { stop() }
    }
    
    private func start() {
        stop()
        let fps: Double = RuntimeConfig.reducedUIEffects ? 30.0 : 60.0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / fps, repeats: true) { _ in
            sampleAndUpdate()
        }
        if let t = timer { RunLoop.main.add(t, forMode: .common) }
    }
    
    private func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func sampleAndUpdate() {
        // Audio level processing
        let m = audioMeterProvider()
        let raw = max(m.averagePower, m.peakPower)
        var normA = max(0.0, min(1.0, raw + 1.0))
        let normB = max(0.0, min(1.0, streamingLevelProvider()))
        var norm = max(normA, normB)
        
        // Debug output every 60 frames (1 second at 60fps)
        debugCounter += 1
        if debugCounter % 60 == 0 {
            // print("🌊 DynamicWave Audio Debug - Raw: \(String(format: \"%.3f\", raw)), NormA: \(String(format: \"%.3f\", normA)), NormB: \(String(format: \"%.3f\", normB)), Final: \(String(format: \"%.3f\", norm)), Level: \(String(format: \"%.3f\", level)), Active: \(isActive)")
        }
        
        if norm < gate { norm = 0.0 }
        
        let target = isActive ? norm : 0.0
        let coeff = target > level ? attack : release
        let smoothed = level + (target - level) * coeff
        
        DispatchQueue.main.async {
            self.level = smoothed
            // Update organic phase components with irregular speeds
            self.primaryPhase = (self.primaryPhase + self.primarySpeed).truncatingRemainder(dividingBy: .pi * 2)
            self.secondaryPhase = (self.secondaryPhase + self.secondarySpeed).truncatingRemainder(dividingBy: .pi * 2)
            self.organicPhase = (self.organicPhase + self.organicSpeed).truncatingRemainder(dividingBy: .pi * 2)
            self.breathPhase = (self.breathPhase + self.breathSpeed).truncatingRemainder(dividingBy: .pi * 2)
        }
    }
    
    private func dynamicWavePath(size: CGSize) -> Path {
        let width = max(size.width, 1)
        let height = max(size.height, 1)
        let midY = height / 2
        
        // More aggressive level scaling for dramatic changes
        let eased = pow(level, 1.0) // linear for more responsiveness
        let maxAmplitude = height * 0.45 // use more of the available height
        
        // Breathing motion adds subtle baseline movement
        let breathMotion = (sin(breathPhase) + 1) * 0.5 // 0..1
        let minAmplitude = height * 0.15 * (0.5 + 0.5 * breathMotion)
        let amplitude = minAmplitude + maxAmplitude * eased
        
        // Organic envelope that creates blob-like shapes
        func organicEnvelope(_ x: CGFloat) -> CGFloat {
            if width <= 1 { return 1 }
            let normalized = Double(x / width)
            
            // Create irregular blob-like envelope with multiple bumps
            let primaryBump = pow(sin(.pi * normalized), 1.2)
            let organicVariation = sin(2 * .pi * normalized + organicPhase) * 0.3
            let asymmetry = sin(1.5 * .pi * normalized + organicPhase * 1.3) * 0.2
            
            // Level-dependent envelope complexity
            let complexity = 0.6 + 0.4 * eased
            let envelope = primaryBump + organicVariation * complexity + asymmetry * eased
            
            return CGFloat(max(0.1, envelope))
        }
        
        var path = Path()
        let steps = max(Int(width * 1.5), 6) // more points for smoother curves
        let stepSize = width / CGFloat(steps - 1)
        
        // Organic wave calculation with irregular motion
        func calculateY(_ x: CGFloat) -> CGFloat {
            let normalized = Double(x / width)
            
            // Primary organic wave with irregular frequency
            let primary = sin(2 * .pi * primaryFreq * normalized + primaryPhase)
            
            // Secondary wave creates blob-like bumps
            let secondary = sin(2 * .pi * secondaryFreq * normalized + secondaryPhase) * 0.4
            
            // Add chaotic elements that intensify with level
            let chaos = sin(2 * .pi * 4.2 * normalized + primaryPhase * 1.7) * 0.15 * eased
            let flutter = cos(2 * .pi * 6.8 * normalized + secondaryPhase * 0.8) * 0.1 * pow(eased, 2)
            
            // Combine all components
            let combined = primary + secondary * (0.8 + 0.4 * eased) + chaos + flutter
            let finalAmplitude = amplitude * organicEnvelope(x)
            
            return midY + CGFloat(combined) * finalAmplitude
        }
        
        // Build smooth curved path
        if steps > 0 {
            let startY = calculateY(0)
            path.move(to: CGPoint(x: 0, y: startY))
            
            // Use quadratic curves for smoother, more organic lines
            for i in 1..<steps {
                let x = CGFloat(i) * stepSize
                let y = calculateY(x)
                
                if i == 1 {
                    path.addLine(to: CGPoint(x: x, y: y))
                } else {
                    let prevX = CGFloat(i - 1) * stepSize
                    let prevY = calculateY(prevX)
                    let controlX = (prevX + x) / 2
                    let controlY = (prevY + y) / 2
                    
                    path.addQuadCurve(to: CGPoint(x: x, y: y), 
                                      control: CGPoint(x: controlX, y: controlY))
                }
            }
        }
        
        return path
    }
}

// MARK: - Utilities
private struct ConditionalDrawingGroup: ViewModifier {
    let enabled: Bool
    func body(content: Content) -> some View {
        if enabled {
            content.drawingGroup(opaque: false, colorMode: .linear)
        } else {
            content
        }
    }
}

/// Boring.notch-style 4-bar visualizer with random animation driven by audio level
private struct DirectAudioVisualizer: View {
    @ObservedObject var levelSource: AudioLevelPublisher
    let isActive: Bool
    
    private let barCount = 4  // Four bars for cleaner visualization
    private let barWidth: CGFloat = 2.0
    private let barSpacing: CGFloat = 2.0  // Tiny bit more spacing between bars
    private let minHeight: CGFloat = 2.8  // 0.2 * 14 = 2.8pt (20% of max height)
    private let maxHeight: CGFloat = 14.0
    private let audioThreshold: Double = 0.35  // 35% threshold for audio detection
    
    @State private var barHeights: [CGFloat] = []
    @State private var currentAudioLevel: Double = 0.0
    @State private var animationTimer: Timer?
    
    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: barWidth / 2)  // Fully rounded bars
                    .fill(Color.white.opacity(isActive ? 0.95 : 0.65))
                    .frame(
                        width: barWidth, 
                        height: barHeights.count > index ? barHeights[index] : minHeight
                    )
                    .animation(.easeInOut(duration: 0.3), value: barHeights.count > index ? barHeights[index] : minHeight)
            }
        }
        .onAppear {
            setupInitialHeights()
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
        .onChange(of: levelSource.level) { _, newValue in
            if isActive {
                updateAudioLevel(Float(newValue.averagePower))
            } else {
                // When inactive, force silence
                currentAudioLevel = 0.0
            }
        }
        .onReceive(levelSource.$level) { newValue in
            // Extra safety: ensure updates even if onChange misses any rapid ticks
            if isActive {
                updateAudioLevel(Float(newValue.averagePower))
            }
        }
    }
    
    private func setupInitialHeights() {
        barHeights = Array(repeating: minHeight, count: barCount)
    }
    
    private func startAnimation() {
        animationTimer?.invalidate()
        // Match boring.notch's 0.3s interval for consistent rhythm
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            updateBarHeights()
        }
        if let timer = animationTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        // Reset to baseline when stopped
        barHeights = Array(repeating: minHeight, count: barCount)
    }
    
    private func updateAudioLevel(_ audioLevel: Float) {
        // WhisperState.audioLevel already publishes 0..1 values
        let normalizedLevel = max(0, min(1, Double(audioLevel)))
        
        // Smooth the audio level with some responsiveness
        let smoothingFactor = 0.4
        currentAudioLevel = currentAudioLevel * (1 - smoothingFactor) + normalizedLevel * smoothingFactor
        currentAudioLevel = max(0.0, min(1.0, currentAudioLevel))
    }
    
    private func updateBarHeights() {
        var newHeights: [CGFloat] = []
        
        for index in 0..<barCount {
            // All bars have the same amplitude (no position-based multiplier)
            let targetHeight: CGFloat
            
            if currentAudioLevel < audioThreshold {
                // Below 35% - subtle movement between 0.2 and 0.35 (very little animation)
                let randomScale = CGFloat.random(in: 0.2...0.35)
                targetHeight = maxHeight * randomScale
            } else {
                // Above 35% - random heights between 0.2 and 1.0
                let randomScale = CGFloat.random(in: 0.2...1.0)
                targetHeight = maxHeight * randomScale
            }
            
            newHeights.append(targetHeight)
        }
        
        barHeights = newHeights
    }
}

/// Elegant bar-band visualizer: 5 bars with subtle phase offsets, driven by mic level.
#if canImport(Orb)
import Orb

/// Orb-based visualizer driven by mic level. Sized for 14pt notch. Preset-selectable.
private struct OrbMinimalVisualizer: View {
    enum Preset { case minimal, mystic, nature, sunset, ocean, shadow }

    let audioMeterProvider: () -> AudioMeter
    let streamingLevelProvider: () -> Double
    let isActive: Bool
    var preset: Preset = .mystic

    @State private var level: Double = 0.0
    @State private var breathPhase: Double = 0.0
    @State private var timer: Timer?

    // Smoothing
    private let gate: Double = 0.02
    private let attack: Double = 0.55
    private let release: Double = 0.12

    // Idle breathing motion
    private let breathSpeed: Double = 0.10   // radians per tick (~6s per cycle)
    private let breathInfluence: Double = 0.25

    var body: some View {
        // Blend mic level with subtle idle breath
        let breath = (sin(breathPhase) + 1) * 0.5 // 0..1
        let blended = max(level, breath * breathInfluence)
        let eased = pow(blended, 1.3)
        let scale = 0.88 + 0.30 * eased
        let glow = 0.50 + 0.90 * eased

        // Make internal motion feel more alive by varying speed with level
        let baseSpeed: Double = 45
        let dynamicSpeed: Double = baseSpeed + 40 * eased

        let config: OrbConfiguration = {
            switch preset {
            case .minimal:
                return OrbConfiguration(
                    backgroundColors: [.gray, .white],
                    glowColor: .white,
                    coreGlowIntensity: glow,
                    showBackground: true,
                    showWavyBlobs: false,
                    showParticles: false,
                    showGlowEffects: true,
                    showShadow: false,
                    speed: dynamicSpeed
                )
            case .mystic:
                return OrbConfiguration(
                    backgroundColors: [.purple, .blue, .indigo],
                    glowColor: .purple,
                    coreGlowIntensity: glow,
                    showBackground: true,
                    showWavyBlobs: true,
                    showParticles: false,
                    showGlowEffects: true,
                    showShadow: false,
                    speed: dynamicSpeed
                )
            case .nature:
                return OrbConfiguration(
                    backgroundColors: [.green, .mint, .teal],
                    glowColor: .green,
                    coreGlowIntensity: glow,
                    showBackground: true,
                    showWavyBlobs: true,
                    showParticles: false,
                    showGlowEffects: true,
                    showShadow: false,
                    speed: dynamicSpeed
                )
            case .sunset:
                return OrbConfiguration(
                    backgroundColors: [.orange, .red, .pink],
                    glowColor: .orange,
                    coreGlowIntensity: max(0.6, glow),
                    showBackground: true,
                    showWavyBlobs: true,
                    showParticles: false,
                    showGlowEffects: true,
                    showShadow: false,
                    speed: dynamicSpeed
                )
            case .ocean:
                return OrbConfiguration(
                    backgroundColors: [.blue, .cyan, .teal],
                    glowColor: .cyan,
                    coreGlowIntensity: glow,
                    showBackground: true,
                    showWavyBlobs: true,
                    showParticles: false,
                    showGlowEffects: true,
                    showShadow: false,
                    speed: dynamicSpeed
                )
            case .shadow:
                return OrbConfiguration(
                    backgroundColors: [.black, .gray],
                    glowColor: .gray,
                    coreGlowIntensity: max(0.5, glow * 0.8),
                    showBackground: true,
                    showWavyBlobs: false,
                    showParticles: false,
                    showGlowEffects: true,
                    showShadow: false,
                    speed: dynamicSpeed
                )
            }
        }()

        HStack(spacing: 0) {
            OrbView(configuration: config)
                .frame(width: 12, height: 12)
                .scaleEffect(scale)
                .opacity(isActive ? 1.0 : 0.6)
                .animation(.easeOut(duration: 0.08), value: scale)
            Spacer(minLength: 0)
        }
        .onAppear { start() }
        .onDisappear { stop() }
    }

    private func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            sample()
        }
        if let t = timer { RunLoop.main.add(t, forMode: .common) }
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func sample() {
        let m = audioMeterProvider()
        let raw = max(m.averagePower, m.peakPower)
        var normA = max(0.0, min(1.0, raw + 1.0))
        let normB = max(0.0, min(1.0, streamingLevelProvider()))
        var norm = max(normA, normB)
        if norm < gate { norm = 0.0 }

        let target = isActive ? norm : 0.0
        let coeff = target > level ? attack : release
        let smoothed = level + (target - level) * coeff
        DispatchQueue.main.async {
            self.level = smoothed
            self.breathPhase = (self.breathPhase + self.breathSpeed).truncatingRemainder(dividingBy: .pi * 2)
        }
    }
}
#endif

private struct ElegantBarsVisualizer: View {
    let audioMeterProvider: () -> AudioMeter
    let streamingLevelProvider: () -> Double
    let isActive: Bool

    @State private var level: Double = 0.0
    @State private var phase: Double = 0.0
    @State private var timer: Timer?

    // Tunables
    private let gate: Double = 0.02
    private let attack: Double = 0.6
    private let release: Double = 0.12
    private let barCount: Int = 5
    private let phaseSpeed: Double = 0.20

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let h = size.height
            let w = size.width
            let spacing: CGFloat = 2
            let totalSpacing = spacing * CGFloat(barCount - 1)
            let barWidth = max(1, (w - totalSpacing) / CGFloat(barCount))
            let eased = pow(level, 1.35)

            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { i in
                    // Per-bar dynamic: center taller, slight phase offset for motion
                    let center = Double(barCount - 1) / 2.0
                    let distance = abs(Double(i) - center)
                    let weight = 1.0 - (distance / center) * 0.35 // center heavier
                    let localPhase = phase + Double(i) * 0.6
                    let wave = (sin(localPhase) + 1) * 0.5 // 0..1
                    let amplitude = min(1.0, eased * weight * (0.6 + 0.4 * wave))
                    let minH = max(2.0, h * 0.18)
                    let barH = min(h, minH + CGFloat(amplitude) * (h - minH))

                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(isActive ? 0.95 : 0.55))
                        .frame(width: barWidth, height: barH)
                        .shadow(color: Color.white.opacity(isActive ? 0.25 : 0.12), radius: 1, x: 0, y: 0)
                        .animation(.easeOut(duration: 0.08), value: barH)
                }
            }
        }
        .onAppear { start() }
        .onDisappear { stop() }
    }

    private func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            sampleAndUpdate()
        }
        if let t = timer { RunLoop.main.add(t, forMode: .common) }
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func sampleAndUpdate() {
        // Combine meters and direct streaming level
        let m = audioMeterProvider()
        let raw = max(m.averagePower, m.peakPower)
        var normA = max(0.0, min(1.0, raw + 1.0))
        let normB = max(0.0, min(1.0, streamingLevelProvider()))
        var norm = max(normA, normB)
        if norm < gate { norm = 0.0 }

        let target = isActive ? norm : 0.0
        let coeff = target > level ? attack : release
        let smoothed = level + (target - level) * coeff

        DispatchQueue.main.async {
            self.level = smoothed
            self.phase = (self.phase + self.phaseSpeed).truncatingRemainder(dividingBy: .pi * 2)
        }
    }
}
