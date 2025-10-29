//
//  GlowModifier.swift
//  Clio
//
//  Created by Claude Code on 2025-08-13.
//  Based on glow extension from boring.notch by TheBoredTeam
//  Original source: https://github.com/TheBoredTeam/boring.notch
//  Modified for Clio voice recorder with GPL3 license compliance
//

import SwiftUI

// MARK: - Glow Effect Extension
extension View where Self: Shape {
    func glow(
        fill: some ShapeStyle,
        lineWidth: Double,
        blurRadius: Double = 8.0,
        lineCap: CGLineCap = .round
    ) -> some View {
        self
            .stroke(style: StrokeStyle(lineWidth: lineWidth / 2, lineCap: lineCap))
            .fill(fill)
            .overlay {
                self
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
                    .fill(fill)
                    .blur(radius: blurRadius)
            }
            .overlay {
                self
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
                    .fill(fill)
                    .blur(radius: blurRadius / 2)
            }
    }
}

// MARK: - Recording Glow Modifier
struct RecordingGlowModifier: ViewModifier {
    let isRecording: Bool
    let isProcessing: Bool
    let isAttempting: Bool
    
    var glowColor: Color {
        if isRecording {
            return .red
        } else if isProcessing {
            return .orange
        } else if isAttempting {
            return .blue
        } else {
            return .clear
        }
    }
    
    var glowIntensity: Double {
        if isRecording || isProcessing || isAttempting {
            return 1.0
        } else {
            return 0.0
        }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if glowIntensity > 0 {
                    content
                        .blur(radius: 8)
                        .opacity(0.6)
                        .colorMultiply(glowColor)
                        .animation(.easeInOut(duration: 0.3), value: glowColor)
                }
            }
            .overlay {
                if glowIntensity > 0 {
                    content
                        .blur(radius: 4)
                        .opacity(0.8)
                        .colorMultiply(glowColor)
                        .animation(.easeInOut(duration: 0.3), value: glowColor)
                }
            }
    }
}

// MARK: - Pulsing Glow for Recording State
struct PulsingGlowModifier: ViewModifier {
    let isActive: Bool
    @State private var pulseScale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? pulseScale : 1.0)
            .onAppear {
                if isActive {
                    startPulsing()
                }
            }
            .onChange(of: isActive) { _, active in
                if active {
                    startPulsing()
                } else {
                    stopPulsing()
                }
            }
    }
    
    private func startPulsing() {
        withAnimation(
            .easeInOut(duration: 1.0)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.05
        }
    }
    
    private func stopPulsing() {
        withAnimation(.easeInOut(duration: 0.3)) {
            pulseScale = 1.0
        }
    }
}

// MARK: - Convenience Extensions
extension View {
    func recordingGlow(
        isRecording: Bool,
        isProcessing: Bool,
        isAttempting: Bool = false
    ) -> some View {
        modifier(RecordingGlowModifier(
            isRecording: isRecording,
            isProcessing: isProcessing,
            isAttempting: isAttempting
        ))
    }
    
    func pulsingGlow(isActive: Bool) -> some View {
        modifier(PulsingGlowModifier(isActive: isActive))
    }
}

// MARK: - Expandable Glow Animation
struct ExpandingGlowEffect: View {
    let isActive: Bool
    let color: Color
    @State private var animationProgress: Double = 0.0
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        color.opacity(0.6),
                        color.opacity(0.3),
                        color.opacity(0.1),
                        .clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 50 * animationProgress
                )
            )
            .scaleEffect(animationProgress)
            .opacity(isActive ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.5), value: isActive)
            .onChange(of: isActive) { _, active in
                if active {
                    withAnimation(
                        .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                    ) {
                        animationProgress = 1.0
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        animationProgress = 0.0
                    }
                }
            }
    }
}

#Preview {
    VStack(spacing: 40) {
        // Recording glow example
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black)
            .frame(width: 200, height: 40)
            .recordingGlow(
                isRecording: true,
                isProcessing: false
            )
        
        // Processing glow example
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black)
            .frame(width: 200, height: 40)
            .recordingGlow(
                isRecording: false,
                isProcessing: true
            )
        
        // Expanding glow example
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black)
                .frame(width: 100, height: 30)
            
            ExpandingGlowEffect(
                isActive: true,
                color: .red
            )
        }
        .frame(width: 200, height: 100)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}