import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Handle community deep-links (legacy activation/sign-in URLs now show info alerts)
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            guard url.scheme == "com.cliovoice.clio" else { continue }
            handleCommunityDeepLink(url)
        }
    }
    
    private func handleCommunityDeepLink(_ url: URL) {
        print("🔗 [DEEP-LINK] Received Clio deep-link: \(url.absoluteString)")
        guard let host = url.host else { return }

        switch host {
        case "activate":
            showCommunityEditionNotice(
                title: "Community Edition",
                message: "This open-source build no longer requires license activation. All features are unlocked by default."
            )
        case "signin":
            showCommunityEditionNotice(
                title: "No Account Needed",
                message: "Cloud sign-in has been removed in the open-source build. Manage everything locally from Settings."
            )
        default:
            print("🔗 [DEEP-LINK] Unknown deep-link host: \(host)")
        }
    }
    
    private func showCommunityEditionNotice(title: String, message: String) {
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            WindowManager.shared.ensureAndActivateMainWindow()

            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    private var lastResignActive: Date? = nil
    private weak var recordingEngine: RecordingEngine?
    private var didStartWarmupCadence = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        StructuredLog.shared.log(cat: .sys, evt: "app_launch", lvl: .info, ["ver": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"])
        // One-time migration: ensure all existing users switch to regular activation policy.
        // We do this once, then leave the user's setting alone on future launches.
        let activationPolicyMigrationKey = "ActivationPolicyMigration_2025_08_20"
        if !UserDefaults.standard.bool(forKey: activationPolicyMigrationKey) {
            UserDefaults.standard.set(false, forKey: "IsMenuBarOnly")
            UserDefaults.standard.set(true, forKey: activationPolicyMigrationKey)
        }
        updateActivationPolicy()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidResignActive), name: NSApplication.didResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecordingEngineReady(_:)), name: .recordingEngineReady, object: nil)
        
        // Handle menu bar navigation notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleNavigateToDestination(_:)), name: .navigateToDestination, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowFeedbackModal(_:)), name: .showFeedbackModal, object: nil)

        // Refresh authentication/subscription promptly after wake from sleep
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake(_:)),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        // Also observe system sleep to proactively tear down warm sockets
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep(_:)),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        // Defer warmup/cadence until after activation to avoid any launch-time contention
        // Also schedule an app-launch warmup shortly after launch (non-blocking), unless disabled
        if !RuntimeConfig.disableWarmupOnLaunch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                WarmupCoordinator.shared.ensureReady(.appLaunch)
            }
        }
        
        // Debug overlay shortcut is handled via SwiftUI .commands in Clio.swift
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        print("🧭 [APP] applicationShouldHandleReopen called - hasVisibleWindows: \(flag)")
        updateActivationPolicy()
        
        // CRITICAL FIX: Only activate existing window if it exists, don't try to create new ones
        // This prevents duplicate windows when clicking dock icon
        DispatchQueue.main.async {
            // Always just activate the app and let existing windows come to front
            NSApp.activate(ignoringOtherApps: true)
            
            if let existingWindow = WindowManager.shared.mainWindow {
                print("🪟 [DOCK] Found existing window, activating it")
                // Just activate the existing window
                if existingWindow.isMiniaturized {
                    existingWindow.deminiaturize(nil)
                }
                existingWindow.makeKeyAndOrderFront(nil)
            } else {
                print("🪟 [DOCK] No existing window found - relying on SwiftUI natural behavior")
                // Do NOT try to force window creation - let SwiftUI handle it naturally
            }
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        print("🧭 [APP] applicationDidBecomeActive")
        updateActivationPolicy()
        // Trigger quick audio warmup when regaining focus after being idle for a while
        if let last = lastResignActive {
            let idleSecs = Date().timeIntervalSince(last)
            if idleSecs > 7 * 60 { // 7 minutes threshold
                Task { [weak self] in
                    await self?.recordingEngine?.sonioxStreamingService.quickFocusWarmup()
                }
            }
        }

        // Always refresh auth and recompute subscription state on foreground
        refreshSubscriptionState(reason: "appDidBecomeActive")
        // Register RecordingEngine for warmup plumbing if available
        if let state = recordingEngine {
            WarmupCoordinator.shared.register(recordingEngine: state)
            // Optional: prewarm the notch window to remove first-show latency
            if RuntimeConfig.notchKeepAliveEnabled && RuntimeConfig.notchPrewarmOnActivation {
                Task { @MainActor in await state.prewarmNotchIfEnabled() }
            }
        }

        // Always run a warmup on activation (cheap, coalesced)
        WarmupCoordinator.shared.ensureReady(.appActivation)
        // Start cadence only once per launch
        if !didStartWarmupCadence {
            didStartWarmupCadence = true
            WarmupCoordinator.shared.startCadence()
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Force cleanup of all audio resources when app terminates
        NotificationCenter.default.post(name: .forceCleanupAudioResources, object: nil)
    }
    
    @objc private func appDidResignActive() {
        lastResignActive = Date()
    }
    
    private func updateActivationPolicy() {
        let isMenuBarOnly = UserDefaults.standard.bool(forKey: "IsMenuBarOnly")
        if isMenuBarOnly {
            NSApp.setActivationPolicy(.accessory)
            print("🧭 [APP] ActivationPolicy=.accessory (IsMenuBarOnly=true)")
        } else {
            NSApp.setActivationPolicy(.regular)
            print("🧭 [APP] ActivationPolicy=.regular (IsMenuBarOnly=false)")
        }
    }
    
    private func createMainWindowIfNeeded() {
        print("🧭 [APP] createMainWindowIfNeeded called")
        // Use the new WindowManager method that guarantees window creation and activation
        WindowManager.shared.ensureAndActivateMainWindow()
    }
    
    @objc private func handleNavigateToDestination(_ notification: Notification) {
        print("AppDelegate: Received navigation notification")
        
        // Always ensure we are a regular app before presenting UI, even if users
        // have a legacy/default setting for menu-bar-only mode in production.
        // Some users reported clicks from the status bar not foregrounding the app.
        // For reliability, force regular policy for any explicit user navigation.
        NSApp.setActivationPolicy(.regular)
        NSApp.unhide(nil)
        
        // Force the app to become active - this is critical for menu bar interactions
        // Some users report the app doesn't come to foreground without this
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            
            // Guarantee window exists and activate it atomically
            WindowManager.shared.ensureAndActivateMainWindow()
            
            // Forward navigation after window is guaranteed to be active
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(
                    name: .navigateToDestinationInternal,
                    object: notification.object,
                    userInfo: notification.userInfo
                )
            }
        }
    }
    
    @objc private func handleShowFeedbackModal(_ notification: Notification) {
        print("AppDelegate: Received feedback modal notification")
        
        // Force regular activation policy for explicit UI presentation paths
        NSApp.setActivationPolicy(.regular)
        NSApp.unhide(nil)
        
        // Force the app to become active - this is critical for menu bar interactions
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            
            // Guarantee window exists and activate it atomically
            WindowManager.shared.ensureAndActivateMainWindow()
            
            // Forward feedback modal after window is guaranteed to be active
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(
                    name: .showFeedbackModalInternal,
                    object: notification.object,
                    userInfo: notification.userInfo
                )
            }
        }
    }
    
    // Inject reference to RecordingEngine so we can warm up the audio when needed
    func setRecordingEngine(_ state: RecordingEngine) {
        self.recordingEngine = state
    }

    @objc private func handleRecordingEngineReady(_ note: Notification) {
        if let state = note.object as? RecordingEngine {
            self.recordingEngine = state
        }
    }

    // MARK: - Subscription refresh hooks
    @objc private func systemDidWake(_ note: Notification) {
        // Refresh auth/subscription promptly after wake
        refreshSubscriptionState(reason: "systemDidWake")
        // Proactively refresh streaming network stack to avoid stale sockets post-wake
        Task { @MainActor in
            await self.recordingEngine?.sonioxStreamingService.handleSystemWake()
        }
    }
    
    @objc private func systemWillSleep(_ note: Notification) {
        // Tear down any warm/standby sockets to avoid post-sleep stalls
        Task { @MainActor in
            await self.recordingEngine?.sonioxStreamingService.prepareForSleep()
        }
    }
    
    private func refreshSubscriptionState(reason: String) {
        Task {
            DebugLogger.debug("Refreshing auth/subscription after: \(reason)", category: .subscription)
            await SubscriptionManager.shared.forceRefreshAuthentication()
            await MainActor.run {
                SubscriptionManager.shared.updateSubscriptionState()
            }
        }
    }

    // Removed cadence-based background sync to minimize Supabase calls
}

extension Notification.Name {
    static let recordingEngineReady = Notification.Name("RecordingEngineReadyNotification")
    static let navigateToDestinationInternal = Notification.Name("navigateToDestinationInternal")
    static let showFeedbackModalInternal = Notification.Name("showFeedbackModalInternal")
}
