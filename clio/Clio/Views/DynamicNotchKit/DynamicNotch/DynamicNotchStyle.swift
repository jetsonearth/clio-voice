//
//  DynamicNotchStyle.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2025-04-18.
//

import SwiftUI

// Drive animation duration from RuntimeConfig for older GPUs or user overrides
private var notchAnimationDuration: Double {
    Double(RuntimeConfig.notchOpenAnimationDurationMs) / 1000.0
}

/// The style of a DynamicNotch.
///
/// The style determines how the notch appears on the screen.
/// It is generally recommended to use the ``auto`` style, which will automatically choose the best style based on the screen size.
/// However, you can also use the ``notch`` or ``floating`` styles to force the notch to appear in a specific way.
///
/// ## Complex Usage
///
/// Custom border radii can easily complement a rounded user interface.
/// Remember this formula instead of eyeballing the corner radius, if you haven't already!
/// ```
/// Outer Radius = Inner Radius + Padding
/// ```
/// In order to set a custom corner radius, use the following cases:
/// - ``notch(topCornerRadius:bottomCornerRadius:)``
/// - ``floating(cornerRadius:)``
///
public enum DynamicNotchStyle: Sendable {
    /// Notch-style, meant to be used on screens with a notch
    ///
    /// Note that `topCornerRadius` and `bottomCornerRadius` are only use when the notch is in the expanded state.
    case notch(
        topCornerRadius: CGFloat,
        bottomCornerRadius: CGFloat
    )

    /// Floating style, to be used on screens without a notch
    case floating(
        cornerRadius: CGFloat
    )

    /// Automatically choose the style based on the screen
    case auto

    /// A preset notch style, made to look good in most cases.
    public static let notch: DynamicNotchStyle = .notch(topCornerRadius: 15, bottomCornerRadius: 20)

    /// A preset floating style, made to look good in most cases.
    public static let floating: DynamicNotchStyle = .floating(cornerRadius: 20)

    var isNotch: Bool {
        if case .notch = self {
            true
        } else {
            false
        }
    }

    var isFloating: Bool {
        if case .floating = self {
            true
        } else {
            false
        }
    }

    var openingAnimation: Animation {
        if #available(macOS 14.0, *) {
            if RuntimeConfig.instantNotchOpenEnabled || RuntimeConfig.notchOpenAnimationDurationMs == 0 {
                .linear(duration: 0)
            } else if isNotch {
                .bouncy(duration: notchAnimationDuration)
            } else {
                .snappy(duration: notchAnimationDuration)
            }
        } else {
            RuntimeConfig.instantNotchOpenEnabled || RuntimeConfig.notchOpenAnimationDurationMs == 0
            ? .linear(duration: 0)
            : .spring(response: notchAnimationDuration, dampingFraction: 0.82, blendDuration: 0.2)
        }
    }

    var closingAnimation: Animation {
        if #available(macOS 14.0, *) {
            RuntimeConfig.instantNotchOpenEnabled || RuntimeConfig.notchOpenAnimationDurationMs == 0
            ? .linear(duration: 0)
            : .smooth(duration: notchAnimationDuration)
        } else {
            RuntimeConfig.instantNotchOpenEnabled || RuntimeConfig.notchOpenAnimationDurationMs == 0
            ? .linear(duration: 0)
            : .easeOut(duration: notchAnimationDuration)
        }
    }

    var conversionAnimation: Animation {
        if #available(macOS 14.0, *) {
            RuntimeConfig.instantNotchOpenEnabled || RuntimeConfig.notchOpenAnimationDurationMs == 0
            ? .linear(duration: 0)
            : .snappy(duration: 0.4)
        } else {
            RuntimeConfig.instantNotchOpenEnabled || RuntimeConfig.notchOpenAnimationDurationMs == 0
            ? .linear(duration: 0)
            : .spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0.15)
        }
    }
}

extension DynamicNotchStyle: Equatable {
    public static func == (lhs: DynamicNotchStyle, rhs: DynamicNotchStyle) -> Bool {
        switch (lhs, rhs) {
        case let (.notch(lhsTop, lhsBottom), .notch(rhsTop, rhsBottom)):
            lhsTop == rhsTop && lhsBottom == rhsBottom
        case let (.floating(lhsRadius), .floating(rhsRadius)):
            lhsRadius == rhsRadius
        case (.auto, .auto):
            true
        default:
            false
        }
    }
}
