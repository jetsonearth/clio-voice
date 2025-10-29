import SwiftUI

// MARK: - Onboarding Glassmorphism Background
struct OnboardingGlassmorphismBackground: View {
    var body: some View {
        ZStack {
            // Primary ultra thin material for true transparency
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            // Subtle ambient lighting with floating orbs
            GeometryReader { geometry in
                // Large orb - top right
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DarkTheme.textPrimary.opacity(0.08),
                                DarkTheme.textPrimary.opacity(0.04),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .blur(radius: 60)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.25)
                
                // Medium orb - bottom left
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DarkTheme.textSecondary.opacity(0.1),
                                DarkTheme.textSecondary.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)
                    .blur(radius: 40)
                    .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.75)
                
                // Small accent orb - center
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DarkTheme.textPrimary.opacity(0.06),
                                DarkTheme.textPrimary.opacity(0.03),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 75
                        )
                    )
                    .frame(width: 150, height: 150)
                    .blur(radius: 30)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
            }
        }
    }
}

// MARK: - Glassmorphism Card
struct GlassmorphismCard: View {
    var isSelected: Bool = false
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 24
    var content: () -> AnyView
    
    init(isSelected: Bool = false, cornerRadius: CGFloat = 16, padding: CGFloat = 24, @ViewBuilder content: @escaping () -> any View) {
        self.isSelected = isSelected
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = { AnyView(content()) }
    }
    
    var body: some View {
        content()
            .padding(padding)
            .background(
                ZStack {
                    // Main card background with true glassmorphism
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    
                    // Additional glass layer for depth
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(NSColor.windowBackgroundColor).opacity(0.3), location: 0.0),
                                    .init(color: Color(NSColor.windowBackgroundColor).opacity(0.15), location: 0.7),
                                    .init(color: Color(NSColor.windowBackgroundColor).opacity(0.05), location: 1.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Border with adaptive colors
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    isSelected ? DarkTheme.textPrimary.opacity(0.3) : Color(NSColor.quaternaryLabelColor).opacity(0.3),
                                    isSelected ? DarkTheme.textPrimary.opacity(0.15) : Color(NSColor.quaternaryLabelColor).opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(
                color: Color(NSColor.shadowColor).opacity(isSelected ? 0.2 : 0.1),
                radius: isSelected ? 20 : 15,
                x: 0,
                y: isSelected ? 8 : 5
            )
    }
}

// MARK: - Glassmorphism Button
struct GlassmorphismButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isDisabled ? DarkTheme.textSecondary : DarkTheme.textPrimary)
                
                if !isDisabled {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                ZStack {
                    if isDisabled {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    } else if isDestructive {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.red.opacity(0.8), Color.red.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.thinMaterial)
                    }
                    
                    // Glass overlay
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            DarkTheme.textPrimary.opacity(0.2),
                            lineWidth: 1
                        )
                }
            )
            .shadow(
                color: isDisabled ? Color.clear : DarkTheme.textPrimary.opacity(0.1),
                radius: 8,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

// MARK: - Glassmorphism Breadcrumb
struct GlassmorphismBreadcrumb: View {
    let steps: [String]
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(spacing: 0) {
                    Text(step)
                        .font(.system(size: 14, weight: currentStep >= index ? .semibold : .regular))
                        .foregroundColor(currentStep >= index ? .primary : .secondary)
                    
                    if index < steps.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thinMaterial)
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color(NSColor.quaternaryLabelColor).opacity(0.2),
                        lineWidth: 1
                    )
            }
        )
        .shadow(
            color: Color(NSColor.shadowColor).opacity(0.1),
            radius: 10,
            y: 2
        )
    }
}

// MARK: - Floating Glass Orb (for ambient lighting)
struct FloatingGlassOrb: View {
    let color: Color
    let size: CGFloat
    let blurRadius: CGFloat
    let opacity: Double
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(opacity),
                        color.opacity(opacity * 0.6),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .blur(radius: blurRadius)
    }
}

#Preview {
    OnboardingGlassmorphismBackground()
        .frame(width: 400, height: 600)
}