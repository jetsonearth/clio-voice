//
//  NotchView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

struct NotchView<Expanded, CompactLeading, CompactTrailing, CompactBottom>: View where Expanded: View, CompactLeading: View, CompactTrailing: View, CompactBottom: View {
    @ObservedObject private var dynamicNotch: DynamicNotch<Expanded, CompactLeading, CompactTrailing, CompactBottom>
    @State private var compactLeadingWidth: CGFloat = 0
    @State private var compactTrailingWidth: CGFloat = 0
    private let safeAreaInset: CGFloat = 15

    init(dynamicNotch: DynamicNotch<Expanded, CompactLeading, CompactTrailing, CompactBottom>) {
        self.dynamicNotch = dynamicNotch
    }

    private var expandedNotchCornerRadii: (top: CGFloat, bottom: CGFloat) {
        if case let .notch(topCornerRadius, bottomCornerRadius) = dynamicNotch.style {
            (top: topCornerRadius, bottom: bottomCornerRadius)
        } else {
            (top: 15, bottom: 20)
        }
    }

    private var compactNotchCornerRadii: (top: CGFloat, bottom: CGFloat) {
        (top: 6, bottom: 14)
    }

    private var minWidth: CGFloat {
        dynamicNotch.notchSize.width + (topCornerRadius * 2)
    }

    private var topCornerRadius: CGFloat {
        dynamicNotch.state == .expanded ? expandedNotchCornerRadii.top : compactNotchCornerRadii.top
    }

    private var bottomCornerRadius: CGFloat {
        dynamicNotch.state == .expanded ? expandedNotchCornerRadii.bottom : compactNotchCornerRadii.bottom
    }

    private var xOffset: CGFloat {
        if dynamicNotch.state != .compact {
            0
        } else {
            compactXOffset
        }
    }

    private var compactXOffset: CGFloat {
        (compactTrailingWidth - compactLeadingWidth) / 2
    }

    var body: some View {
        notchContent()
            .background {
                Rectangle()
                    .foregroundStyle(.black)
                    .padding(-50) // The opening/closing animation can overshoot, so this makes sure that it's still black
            }
            .mask {
                NotchShape(
                    topCornerRadius: topCornerRadius,
                    bottomCornerRadius: bottomCornerRadius
                )
                .padding(.horizontal, 0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .scaleEffect(
                    x: dynamicNotch.state != .hidden ? 1.0 : 0.001,
                    y: dynamicNotch.disableCompactBottom ? 1.0 : (dynamicNotch.state != .hidden ? 1.0 : 0.001),
                    anchor: .top
                )
            }
            .offset(x: xOffset)
    }

    private func notchContent() -> some View {
        VStack(spacing: 0) {
            // Top row - original notch with leading/trailing content
            ZStack {
                compactContent()
                    .fixedSize()
                    .offset(x: dynamicNotch.state == .compact ? 0 : compactXOffset)
                    .frame(
                        width: dynamicNotch.state == .compact ? nil : dynamicNotch.notchSize.width,
                        height: (dynamicNotch.state == .compact && dynamicNotch.isHovering) ? dynamicNotch.menubarHeight : dynamicNotch.notchSize.height
                    )

                expandedContent()
                    .fixedSize()
                    .frame(
                        maxWidth: dynamicNotch.state == .expanded ? nil : 0,
                        maxHeight: dynamicNotch.state == .expanded ? nil : 0
                    )
                    .offset(x: dynamicNotch.state == .compact ? -compactXOffset : 0)
            }
            
            // Bottom row - streaming text (only in compact mode)
            if dynamicNotch.state == .compact, !dynamicNotch.disableCompactBottom {
                let fullAvailableWidth = dynamicNotch.notchSize.width + compactLeadingWidth + compactTrailingWidth
                let visualizerLeftMargin: CGFloat = 16 // 8pt NotchView inset + 8pt CompactContent padding
                
                HStack(spacing: 0) {
                    // Add left margin to align text with audio visualizer position
                    Spacer().frame(width: visualizerLeftMargin)
                    
                    // Text content with proper left alignment
                    dynamicNotch.compactBottomContent
                        .frame(maxWidth: fullAvailableWidth - (visualizerLeftMargin * 2)) // Account for both left and right margins
                        .frame(maxWidth: .infinity, alignment: .leading) // Fill available space, align left
                    
                    // Add right margin to match the left
                    Spacer().frame(width: visualizerLeftMargin)
                }
                .frame(width: fullAvailableWidth, height: 25) // Span full width including leading/trailing areas
                .clipped() // Hard clip any overflow
                .fixedSize() // Absolutely prevent size changes
            }
        }
        .padding(.horizontal, topCornerRadius)
        .fixedSize()
        .frame(
            minWidth: minWidth,
            minHeight: dynamicNotch.notchSize.height + (dynamicNotch.disableCompactBottom ? 0 : 25)
        )
        .onHover(perform: dynamicNotch.updateHoverState)
    }

    func compactContent() -> some View {
        HStack(spacing: 0) {
            if dynamicNotch.state == .compact, !dynamicNotch.disableCompactLeading {
                dynamicNotch.compactLeadingContent
                    .environment(\.notchSection, .compactLeading)
                    .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: 8) }
                    .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: 4) }
                    .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 8) }
                    .onGeometryChange(for: CGFloat.self, of: \.size.width) { compactLeadingWidth = $0 }
                    .transition(.blur(intensity: 10).combined(with: .scale(x: 0, anchor: .trailing)).combined(with: .opacity))
            }

            Spacer()
                .frame(width: dynamicNotch.notchSize.width)

            if dynamicNotch.state == .compact, !dynamicNotch.disableCompactTrailing {
                dynamicNotch.compactTrailingContent
                    .environment(\.notchSection, .compactTrailing)
                    .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: 8) }
                    .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: 4) }
                    .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 8) }
                    .onGeometryChange(for: CGFloat.self, of: \.size.width) { compactTrailingWidth = $0 }
                    .transition(.blur(intensity: 10).combined(with: .scale(x: 0, anchor: .leading)).combined(with: .opacity))
            }
        }
        .frame(height: dynamicNotch.notchSize.height + (dynamicNotch.disableCompactBottom ? 0 : 25), alignment: .top)
        .onChange(of: dynamicNotch.disableCompactLeading) { _ in
            if dynamicNotch.disableCompactLeading {
                compactLeadingWidth = 0
            }
        }
        .onChange(of: dynamicNotch.disableCompactTrailing) { _ in
            if dynamicNotch.disableCompactTrailing {
                compactTrailingWidth = 0
            }
        }
    }

    func expandedContent() -> some View {
        HStack(spacing: 0) {
            if dynamicNotch.state == .expanded {
                dynamicNotch.expandedContent
                    .transition(.blur(intensity: 10).combined(with: .scale(y: 0.6, anchor: .top)).combined(with: .opacity))
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: dynamicNotch.notchSize.height) }
        .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: safeAreaInset) }
        .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: safeAreaInset) }
        .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: safeAreaInset) }
        .frame(minWidth: dynamicNotch.notchSize.width)
    }
}
