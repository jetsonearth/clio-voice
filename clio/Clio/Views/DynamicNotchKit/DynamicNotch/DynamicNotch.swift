import SwiftUI
import Combine

public final class DynamicNotch<Expanded, CompactLeading, CompactTrailing, CompactBottom>: ObservableObject, DynamicNotchControllable where Expanded: View, CompactLeading: View, CompactTrailing: View, CompactBottom: View {
    /// Public in case user wants to modify the underlying NSPanel
    public var windowController: NSWindowController?

    /// The window appearance, indicating the style of the notch.
    public let style: DynamicNotchStyle

    /// Behavior of window when mouse enters.
    public let hoverBehavior: DynamicNotchHoverBehavior

    /// Namespace for matched geometry effect. It is automatically generated if `nil` when the notch is first presented.
    @Published public internal(set) var namespace: Namespace.ID?

    /// Content
    let expandedContent: Expanded
    let compactLeadingContent: CompactLeading
    let compactTrailingContent: CompactTrailing
    let compactBottomContent: CompactBottom
    @Published var disableCompactLeading: Bool = false
    @Published var disableCompactTrailing: Bool = false
    @Published var disableCompactBottom: Bool = false

    /// Notch Properties
    @Published private(set) var state: DynamicNotchState = .hidden
    @Published private(set) var notchSize: CGSize = .zero
    @Published private(set) var menubarHeight: CGFloat = 0
    @Published private(set) var isHovering: Bool = false
    /// When true, opening animation should expand horizontally only (used on built-in MacBook notch screen).
    @Published private(set) var preferHorizontalOpening: Bool = false
    /// When enabled, `hide()` will not deinitialize the underlying NSPanel; the window persists hidden
    /// and subsequent shows do not pay window creation/layout cost.
    public var keepAlive: Bool = false

    private var closePanelTask: Task<(), Never>? // Used to close the panel after hiding completes
    private var stateChangeWorkItem: DispatchWorkItem?
    private var cancellables = Set<AnyCancellable>()

    /// Creates a new DynamicNotch with custom content and style.
    /// - Parameters:
    ///   - hoverBehavior: defines the hover behavior of the notch, which allows for different interactions such as haptic feedback, increased shadow etc.
    ///   - style: the popover's style. If unspecified, the style will be automatically set according to the screen (notch or floating).
    ///   - expanded: a SwiftUI View to be shown in the expanded state of the notch.
    ///   - compactLeading: a SwiftUI View to be shown in the compact leading state of the notch.
    ///   - compactTrailing: a SwiftUI View to be shown in the compact trailing state of the notch.
    ///   - compactBottom: a SwiftUI View to be shown in the compact bottom state of the notch.
    public init(
        hoverBehavior: DynamicNotchHoverBehavior = .all,
        style: DynamicNotchStyle = .auto,
        @ViewBuilder expanded: @escaping () -> Expanded,
        @ViewBuilder compactLeading: @escaping () -> CompactLeading = { EmptyView() },
        @ViewBuilder compactTrailing: @escaping () -> CompactTrailing = { EmptyView() },
        @ViewBuilder compactBottom: @escaping () -> CompactBottom = { EmptyView() }
    ) {
        self.hoverBehavior = hoverBehavior
        self.style = style

        self.expandedContent = expanded()
        self.compactLeadingContent = compactLeading()
        self.compactTrailingContent = compactTrailing()
        self.compactBottomContent = compactBottom()

        observeScreenParameters()
    }

    /// Creates a new DynamicNotch with custom content and style. Does not support the compact appearance.
    /// - Parameters:
    ///   - hoverBehavior: defines the hover behavior of the notch, which allows for different interactions such as haptic feedback, increased shadow etc.
    ///   - style: the popover's style. If unspecified, the style will be automatically set according to the screen (notch or floating).
    ///   - expanded: a SwiftUI View to be shown in the expanded state of the notch.
    public convenience init(
        hoverBehavior: DynamicNotchHoverBehavior = [.keepVisible],
        style: DynamicNotchStyle = .auto,
        @ViewBuilder expanded: @escaping () -> Expanded
    ) where CompactLeading == EmptyView, CompactTrailing == EmptyView, CompactBottom == EmptyView {
        self.init(
            hoverBehavior: hoverBehavior,
            style: style,
            expanded: expanded,
            compactLeading: { EmptyView() },
            compactTrailing: { EmptyView() },
            compactBottom: { EmptyView() }
        )
        self.disableCompactLeading = true
        self.disableCompactTrailing = true
        self.disableCompactBottom = true
    }

    /// Observes screen parameters changes and re-initializes the window if necessary.
    private func observeScreenParameters() {
        Task {
            let sequence = NotificationCenter.default.notifications(named: NSApplication.didChangeScreenParametersNotification)
            for await _ in sequence.map(\.name) {
                if let screen = NSScreen.screens.first {
                    initializeWindow(screen: screen)
                }
            }
        }
    }

    /// Pre-initialize the NSPanel for the given screen while keeping state hidden.
    /// This is useful to remove first-show cost from the hot path. The window will be created
    /// and ordered, but content remains masked in hidden state.
    public func prewarm(on screen: NSScreen = NSScreen.screens[0]) async {
        initializeWindow(screen: screen)
        await MainActor.run { self.state = .hidden }
    }

    /// Updates the hover state of the DynamicNotch, and processes necessary hover behavior.
    /// - Parameter hovering: a boolean indicating whether the mouse is hovering over the notch.
    func updateHoverState(_ hovering: Bool) {
        // Ensure that we only update when the state changes
        guard state != .hidden, hovering != isHovering else { return }

        isHovering = hovering

        if hoverBehavior.contains(.hapticFeedback) {
            let performer = NSHapticFeedbackManager.defaultPerformer
            performer.perform(.alignment, performanceTime: .default)
        }
    }
}

// MARK: - Debounced State Changes

extension DynamicNotch {
    public func expandDebounced(on screen: NSScreen = NSScreen.screens[0], debounceTime: TimeInterval = 0.05) {
        stateChangeWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            Task {
                await self.expand(on: screen)
            }
        }
        stateChangeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceTime, execute: workItem)
    }
    
    public func compactDebounced(on screen: NSScreen = NSScreen.screens[0], debounceTime: TimeInterval = 0.05) {
        stateChangeWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            Task {
                await self.compact(on: screen)
            }
        }
        stateChangeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceTime, execute: workItem)
    }
    
    public func hideDebounced(debounceTime: TimeInterval = 0.05) {
        stateChangeWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            Task {
                await self.hide()
            }
        }
        stateChangeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceTime, execute: workItem)
    }
}

// MARK: - Public

extension DynamicNotch {
    public func expand(on screen: NSScreen = NSScreen.screens[0]) async {
        await _expand(on: screen, skipHide: false)
    }

    func _expand(on screen: NSScreen = NSScreen.screens[0], skipHide: Bool) async {
        guard state != .expanded else { return }

        closePanelTask?.cancel()
        // Reuse keep-alive/prewarmed window when available. Only (re)initialize
        // if the window doesn't exist yet or the target screen changed.
        let needsInit = (windowController?.window == nil) || (windowController?.window?.screen != screen)
        if needsInit {
            initializeWindow(screen: screen)
        } else {
            // Ensure the existing panel is in front without paying re-init cost
            windowController?.window?.orderFrontRegardless()
        }

        Task { @MainActor in
            if state != .hidden && !skipHide {
                withAnimation(style.conversionAnimation) {
                    self.state = .expanded
                }
            } else {
                withAnimation(style.openingAnimation) {
                    self.state = .expanded
                }
            }
        }
    }

    public func compact(on screen: NSScreen = NSScreen.screens[0]) async {
        await _compact(on: screen, skipHide: false)
    }

    func _compact(on screen: NSScreen = NSScreen.screens[0], skipHide: Bool) async {
        guard state != .compact else { return }

        if effectiveStyle(for: screen).isFloating {
            await hide()
            return
        }

        if disableCompactLeading, disableCompactTrailing, disableCompactBottom {
            await hide()
            return
        }

        closePanelTask?.cancel()
        // Reuse keep-alive/prewarmed window when available. Only (re)initialize
        // if the window doesn't exist yet or the target screen changed.
        let needsInit = (windowController?.window == nil) || (windowController?.window?.screen != screen)
        if needsInit {
            initializeWindow(screen: screen)
        } else {
            // Ensure the existing panel is in front without paying re-init cost
            windowController?.window?.orderFrontRegardless()
        }

        Task { @MainActor in
            if state != .hidden && !skipHide {
                withAnimation(style.conversionAnimation) {
                    self.state = .compact
                }
            } else {
                withAnimation(style.openingAnimation) {
                    self.state = .compact
                }
            }
        }
    }

    public func hide() async {
        await withCheckedContinuation { continuation in
            _hide {
                continuation.resume()
            }
        }
    }

    /// Hides the popup, with a completion handler when the animation is completed.
    func _hide(completion: (() -> ())? = nil) {
        guard state != .hidden else {
            completion?()
            return
        }

        if hoverBehavior.contains(.keepVisible), isHovering {
            Task {
                try? await Task.sleep(for: .seconds(0.1))
                _hide(completion: completion)
            }
            return
        }

        withAnimation(style.closingAnimation) {
            state = .hidden
            isHovering = false
        }

        closePanelTask?.cancel()
        closePanelTask = Task {
            try? await Task.sleep(for: .seconds(0.4)) // Wait for animation to complete
            guard Task.isCancelled != true else { return }
            if !self.keepAlive { deinitializeWindow() }
            completion?()
        }
    }
}

// MARK: - Window Management

private extension DynamicNotch {
    /// Determines the effective style for a selected screen.
    /// - Parameter screen: the screen to check for a notch.
    /// - Returns: the effective style for the screen.
    func effectiveStyle(for screen: NSScreen) -> DynamicNotchStyle {
        if style == .auto {
            return screen.hasNotch ? .notch : .floating
        }
        return style
    }

    /// Initializes the window for the DynamicNotch.
    /// - Parameter screen: the screen to initialize the window on.
    func initializeWindow(screen: NSScreen) {
        // so that we don't have a duplicate window
        deinitializeWindow()

        // Use built-in screen's notch size for consistency, but display on the target screen
        if let builtInScreen = NSScreen.builtInScreen {
            notchSize = builtInScreen.notchFrameWithMenubarAsBackup.size
            menubarHeight = builtInScreen.menubarHeight
            // print("🔍 [DYNAMIC NOTCH SIZE] Using built-in screen notch size: \(notchSize)")
        } else {
            notchSize = screen.notchFrameWithMenubarAsBackup.size
            menubarHeight = screen.menubarHeight
            // print("🔍 [DYNAMIC NOTCH SIZE] No built-in screen, using target screen size: \(notchSize)")
        }

        // Opening behavior: on built-in (physical notch) screens, prefer horizontal-only expansion
        preferHorizontalOpening = screen.isBuiltIn

        let style = effectiveStyle(for: screen)
        let view = NSHostingView(rootView: NotchContentView(dynamicNotch: self, style: style))

        let panel = DynamicNotchPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.contentView = view

        // Minimize the panel size to only what the notch UI needs.
        // Large windows trigger heavy compositing on high‑DPI/ProMotion internal displays.
        // Compute a conservative minimal frame: base notch width plus leading/trailing areas and small margins,
        // and height for notch row plus optional bottom transcript row.
        // Use a generous estimate for the side areas so the leading visualizer and trailing app icon
        // are not flush with the rounded edges. The actual compact leading/trailing include internal
        // padding and safe-area insets (~90–110pt each side at runtime).
        let estimatedSideWidth: CGFloat = 110   // per side
        let horizontalMargins: CGFloat = 48     // extra breathing room beyond content
        let bottomRowHeight: CGFloat = self.disableCompactBottom ? 0 : 25 // include transcript row height when enabled
        let baseWidth = notchSize.width + (estimatedSideWidth * 2) + horizontalMargins
        let baseHeight = notchSize.height + bottomRowHeight

        let width = min(baseWidth, screen.frame.width) // never exceed screen width
        let height = min(baseHeight, screen.frame.height / 3) // cap height to a small fraction of screen

        let origin = NSPoint(
            x: screen.frame.midX - (width / 2),
            y: screen.frame.maxY - height
        )

        panel.setFrame(NSRect(origin: origin, size: NSSize(width: width, height: height)), display: false)

        panel.layoutIfNeeded()
        panel.orderFrontRegardless()

        windowController = .init(window: panel)
    }

    /// Deinitializes the window and removes it from the screen.
    func deinitializeWindow() {
        guard let windowController else { return }
        windowController.close()
        self.windowController = nil
    }
}
