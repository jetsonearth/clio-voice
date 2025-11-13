import SwiftUI
import SwiftData
import Sparkle
import AppKit
import OSLog

@main
struct ClioApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let container: ModelContainer
    
    @StateObject private var recordingEngine: RecordingEngine
    @StateObject private var hotkeyManager: HotkeyManager
    @StateObject private var updaterViewModel: UpdaterViewModel
    // MenuBarManager removed
    @StateObject private var aiService: AIService
    @StateObject private var contextService: ContextService
    @StateObject private var enhancementService: AIEnhancementService
    // ActiveWindowService deprecated – ContextService is the source of truth
    @StateObject private var userViewModel: UserViewModel
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject private var modelAccessControl = ModelAccessControl.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var supabaseService = SupabaseServiceSDK.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("ui.compactMode") private var compactMode: Bool = true
    
    // Audio cleanup manager for automatic deletion of old audio files
    private let audioCleanupManager = AudioCleanupManager.shared
    
    init() {
        // Apply global log silencing ASAP
        // - Debug: respect runtime flag (developer control)
        // - Release: always silence for consistent performance for all users
        #if DEBUG
        if RuntimeConfig.shouldSilenceAllLogs { LogSilencer.activate() }
        #else
        LogSilencer.activate()
        #endif
        do {
            let schema = Schema([
                Transcription.self
            ])
            
            // Create app-specific Application Support directory URL
            let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("com.cliovoice.clio", isDirectory: true)
            
            // Create the directory if it doesn't exist
            try? FileManager.default.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
            
            // Migrate data from old VoiceInk location if needed
            Self.migrateDataFromOldLocation(to: appSupportURL)
            
            // Configure SwiftData to use the conventional location
            let storeURL = appSupportURL.appendingPathComponent("default.store")
            let modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
            
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Print SwiftData storage location
            if let url = container.mainContext.container.configurations.first?.url {
                // print("💾 SwiftData storage location: \(url.path)")
            }
            
        } catch {
            fatalError("Failed to create ModelContainer for Transcription: \(error.localizedDescription)")
        }
        
        // Initialize services with proper sharing of instances
        let aiService = AIService()
        _aiService = StateObject(wrappedValue: aiService)
        
         // Register first-run defaults for new users (does not override existing users)
         // Set direct insertion OFF by default for production stability (uses paste path)
             UserDefaults.standard.register(defaults: [
             "useScreenCaptureContext": true,
             "UseDirectTextInsertion": false,
             // Ensure dedicated modifier PTT is OFF by default; user must explicitly set a key
             "isPushToTalkEnabled": false,
             // Smart Dictionary disabled by default (Phase 1 - not ready for users yet)
             "SmartDictionaryDebugLogging": false,
             "SmartDictionaryEnableLearning": false,
             // Enable compact mode by default (one step smaller UI)
             "ui.compactMode": true,
             // Default onboarding music to unmuted unless user opts out
             "onboarding_audio_muted": false,
             // Default AI editing strength → Deep Clean recommended for clarity
             "ai.editingStrength": "full"
         ])
         // Force-migrate all users to legacy paste path once (no AX)
         let migrationKey = "DirectInsertionForcedOff_2025_08_10"
         if !UserDefaults.standard.bool(forKey: migrationKey) {
             UserDefaults.standard.set(false, forKey: "UseDirectTextInsertion")
             UserDefaults.standard.set(true, forKey: migrationKey)
         }
         
         let contextService = ContextService()
        _contextService = StateObject(wrappedValue: contextService)
        
        // Ensure Compact Mode is enabled once for all users after this update
        let compactMigrationKey = "CompactModeEnabledByDefault_2025_09_06"
        if !UserDefaults.standard.bool(forKey: compactMigrationKey) {
            UserDefaults.standard.set(true, forKey: "ui.compactMode")
            UserDefaults.standard.set(true, forKey: compactMigrationKey)
        }
        
        let updaterViewModel = UpdaterViewModel()
        _updaterViewModel = StateObject(wrappedValue: updaterViewModel)
        
        let enhancementService = AIEnhancementService(contextService: contextService, modelContext: container.mainContext)
        _enhancementService = StateObject(wrappedValue: enhancementService)
        
        // Set up cross-references between services for NER entity sharing
        contextService.aiEnhancementService = enhancementService

        // Ensure all proxy calls share a single session with metrics collection
        ProxySessionManager.shared.setDelegate(enhancementService)
        
        let recordingEngine = RecordingEngine(modelContext: container.mainContext, enhancementService: enhancementService, contextService: contextService)
        _recordingEngine = StateObject(wrappedValue: recordingEngine)
        
        // TEMPORARILY COMMENT OUT: Testing if HotkeyManager initialization causes hang
        // Re-enable HotkeyManager in safe minimal mode (defers setup until app is active)
        let hotkeyManager = HotkeyManager(
            recordingEngine: recordingEngine,
            disabled: false,
            minimalMode: true,
            enablePushToTalk: true,
            enableCustomShortcut: true,
            enableDebugMonitors: false,
            enableDelayedReregistration: false
        )
        _hotkeyManager = StateObject(wrappedValue: hotkeyManager)
        
        // Initialize user authentication system
        let userViewModel = UserViewModel()
        _userViewModel = StateObject(wrappedValue: userViewModel)
        
        // MenuBarManager removed
        
        // ActiveWindowService removed
        
        // Set the shared model context for UserStatsService
        UserStatsService.sharedModelContext = container.mainContext
        
        // Initialize SoundManager early to avoid delays on first recording
        _ = SoundManager.shared
        
        // Initialize SupabaseService early to load stored sessions
        _ = SupabaseServiceSDK.shared
        
        // Initialize SubscriptionManager early to ensure it receives SupabaseService notifications
        _ = SubscriptionManager.shared

        // Diagnostics boot: if enabled via defaults, start the stall monitor and show the debug overlay.
        if UserDefaults.standard.bool(forKey: "DiagnosticsEnabled") {
            // Ensure the on-screen log overlay can render
            UserDefaults.standard.set(true, forKey: "DebugConsoleEnabled")
            MainThreadStallMonitor.shared.start()
            // Emit an initial snapshot shortly after launch
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NotificationCenter.default.post(name: .diagnosticsSnapshot, object: nil)
            }
        }
    }
    
    // MARK: - Update Showcase gating
    // Use @AppStorage for the developer override so toggling `defaults write ... ForceShowUpdates` takes effect without relaunch.
    @AppStorage("ForceShowUpdates") private var forceShowUpdates: Bool = false
    @AppStorage("lastSeenUpdateShowcaseVersion") private var lastSeenUpdateShowcaseVersion: String = ""
    @State private var updateShowcaseFinished: Bool = false

    private var currentAppVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "\(v) (\(b))"
    }
    private var shouldShowUpdateShowcase: Bool {
        // Disable the update showcase in Release builds to avoid
        // re-showing the tour after every app update.
        // Developers can still force it in DEBUG via `ForceShowUpdates`.
        #if DEBUG
        if forceShowUpdates { return true }
        // Only show for users who already completed onboarding and have not seen this version’s tour
        guard hasCompletedOnboarding else { return false }
        return lastSeenUpdateShowcaseVersion != currentAppVersion
        #else
        return false
        #endif
    }
    private func markUpdateShowcaseSeen() {
        lastSeenUpdateShowcaseVersion = currentAppVersion
    }

    var body: some Scene {
        Window("Clio", id: "main") {
            // CRITICAL FIX: Use Window instead of WindowGroup to prevent multiple windows
            // Window is designed for single-window apps, WindowGroup allows multiples
            ZStack {
                // Always render a base content layer to maintain window consistency
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Conditional content rendered on top without affecting window creation
                Group {
                    if !hotkeyManager.isHotkeyReady {
                        LoadingView()
                            .preferredColorScheme(.dark)
                            .onAppear {
                                hotkeyManager.beginHotkeyLoading()
                            }
                    } else if RuntimeConfig.forceShowOnboarding {
                        // Developer override: force show onboarding (enabled via UserDefaults)
                        ProfessionalOnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                            .environmentObject(hotkeyManager)
                            .environmentObject(recordingEngine)
                            .environmentObject(aiService)
                            .environmentObject(contextService)
                            .environmentObject(enhancementService)
                            .environmentObject(userViewModel)
                            .environmentObject(subscriptionManager)
                            .environmentObject(modelAccessControl)
                            .environmentObject(localizationManager)
                            .environmentObject(supabaseService)
                            .localized()
                            .preferredColorScheme(.dark)
                    } else if shouldShowUpdateShowcase {
                        UpdateShowcaseView(didFinish: $updateShowcaseFinished)
                            .environmentObject(hotkeyManager)
                            .environmentObject(recordingEngine)
                            .environmentObject(aiService)
                            .environmentObject(contextService)
                            .environmentObject(enhancementService)
                            .environmentObject(userViewModel)
                            .environmentObject(subscriptionManager)
                            .environmentObject(modelAccessControl)
                            .environmentObject(localizationManager)
                            .environmentObject(supabaseService)
                            .localized()
                            .preferredColorScheme(.dark)
                            .onChange(of: updateShowcaseFinished) { done in
                                guard done else { return }
                                markUpdateShowcaseSeen()
                                WindowManager.shared.resetDefaultSizeForNextTransition()
                                if UserDefaults.standard.bool(forKey: "ForceShowUpdates") {
                                    UserDefaults.standard.set(false, forKey: "ForceShowUpdates")
                                    print("🧪 [UPDATES] ForceShowUpdates override cleared after completion")
                                }
                            }
                    } else if !hasCompletedOnboarding {
                        // First-time users: full onboarding (includes auth, permissions, setup)
                        ProfessionalOnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                            .environmentObject(hotkeyManager)
                            .environmentObject(recordingEngine)
                            .environmentObject(aiService)
                            .environmentObject(contextService)
                            .environmentObject(enhancementService)
                            .environmentObject(userViewModel)
                            .environmentObject(subscriptionManager)
                            .environmentObject(modelAccessControl)
                            .environmentObject(localizationManager)
                            .environmentObject(supabaseService)
                            .localized()
                            .preferredColorScheme(.dark)
                            .onChange(of: hasCompletedOnboarding) { completed in
                                if completed {
                                    markUpdateShowcaseSeen()
                                    WindowManager.shared.resetDefaultSizeForNextTransition()
                                }
                            }
                    } else {
                        // Authenticated or not required: show main app
                        ZStack(alignment: .bottomLeading) {
                            ContentView()
                            if StructuredLog.shared.isOverlayVisible {
                                LogOverlayView()
                                    .frame(maxWidth: .infinity)
                                    .transition(.move(edge: .bottom))
                                    .zIndex(1000)
                            }
                        }
                            .environmentObject(recordingEngine)
                            .environmentObject(hotkeyManager)
                            .environmentObject(updaterViewModel)
                            // MenuBarManager removed
                            .environmentObject(aiService)
                            .environmentObject(contextService)
                            .environmentObject(enhancementService)
                            .environmentObject(userViewModel)
                            .environmentObject(subscriptionManager)
                            .environmentObject(modelAccessControl)
                            .environmentObject(localizationManager)
                            .environmentObject(supabaseService)
                            .compactMode(compactMode)
                            .localized()
                            .preferredColorScheme(.dark)
                            .modelContainer(container)
                            .onAppear {
                                // Re-enable Sparkle check now that activation is stable
                                updaterViewModel.silentlyCheckForUpdates()
                                
                                // Log window size at appear
                                if let w = WindowManager.shared.mainWindow {
                                    let fr = w.frame
                                    let cs = w.contentRect(forFrameRect: fr).size
                                    print("📐 [WINDOW onAppear] pre-apply frame=\(Int(fr.width))x\(Int(fr.height)) content=\(Int(cs.width))x\(Int(cs.height))")
                                }
                                
                                // Apply a smaller default window once per launch (respects user resizes)
                                WindowManager.shared.applyDefaultMainWindowSizeIfNeeded(width: 1000, height: 700)
                                
                                // Log again after applying default size
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    if let w = WindowManager.shared.mainWindow {
                                        let fr = w.frame
                                        let cs = w.contentRect(forFrameRect: fr).size
                                        print("📐 [WINDOW onAppear] post-apply frame=\(Int(fr.width))x\(Int(fr.height)) content=\(Int(cs.width))x\(Int(cs.height))")
                                    }
                                }
                                
                                // Start the automatic audio cleanup process
                                audioCleanupManager.startAutomaticCleanup(modelContext: container.mainContext)
                            }
                            .onDisappear {
                                // Local model path disabled
                                audioCleanupManager.stopAutomaticCleanup()
                            }
                    }
                }
            }
            .frame(idealWidth: 1000, idealHeight: 700)
            .background(WindowAccessor { window in
                WindowManager.shared.configureWindow(window)
            })
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1000, height: 700)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updaterViewModel: updaterViewModel)
                Toggle("Compact mode (smaller UI)", isOn: $compactMode)
                Button("Show Debug Console") {
                    StructuredLog.shared.toggleOverlay()
                }.keyboardShortcut("l", modifiers: [.command, .shift])
            }
        }
        
        MenuBarExtra {
            MenuBarView()
                .environmentObject(recordingEngine)
                .environmentObject(hotkeyManager)
                // MenuBarManager removed
                .environmentObject(updaterViewModel)
                .environmentObject(aiService)
                .environmentObject(contextService)
                .environmentObject(enhancementService)
                .environmentObject(userViewModel)
                .environmentObject(localizationManager)
        } label: {
            let image: NSImage = {
                if let named = NSImage(named: "menuBarIcon") {
                    let ratio = named.size.height / named.size.width
                    named.size.height = 22
                    named.size.width = 22 / ratio
                    return named
                }
                // Fallback: empty image placeholder to avoid crash if asset missing
                return NSImage(size: NSSize(width: 22, height: 22))
            }()
            Image(nsImage: image)
        }
        .menuBarExtraStyle(.menu)
        
        // Debug window for MenuBarManager removed
    }
    
    // MARK: - Data Migration
    
    /// Migrates data from legacy application data folder to the new Clio folder
    private static func migrateDataFromOldLocation(to newLocation: URL) {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        
        // Check multiple potential legacy locations
        // Legacy bundle identifiers/directories to migrate FROM
        let legacyLocations = [
            "com.jetsonai.clio" // Original bundle identifier used before August 2025
        ]
        
        for legacyPath in legacyLocations {
            let oldDataURL = appSupportURL.appendingPathComponent(legacyPath, isDirectory: true)
            
            // Check if legacy data exists at this location
            guard fileManager.fileExists(atPath: oldDataURL.path) else {
                continue
            }
            
            // print("🔄 Found legacy data, starting migration...")
            print("   From: \(oldDataURL.path)")
            print("   To: \(newLocation.path)")
            
            do {
                // Get contents of legacy directory
                let oldContents = try fileManager.contentsOfDirectory(at: oldDataURL, includingPropertiesForKeys: nil)
                
                var migratedFiles = 0
                var totalSize: Int64 = 0
                
                for oldFile in oldContents {
                    let fileName = oldFile.lastPathComponent
                    let newFile = newLocation.appendingPathComponent(fileName)
                    
                    // Skip if file already exists in new location
                    if fileManager.fileExists(atPath: newFile.path) {
                        print("   ⏭️ Skipping \(fileName) (already exists)")
                        continue
                    }
                    
                    // Get file size for logging
                    if let attributes = try? fileManager.attributesOfItem(atPath: oldFile.path),
                       let fileSize = attributes[.size] as? Int64 {
                        totalSize += fileSize
                    }
                    
                    // Copy file to new location
                    try fileManager.copyItem(at: oldFile, to: newFile)
                    migratedFiles += 1
                    print("   ✅ Migrated \(fileName)")
                }
                
                print("🎉 Migration completed successfully!")
                print("   Files migrated: \(migratedFiles)")
                print("   Total size: \(ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file))")
                
                // Preserve legacy data for safety
                print("📝 Legacy data preserved for safety")
                print("   You can manually delete it after verifying migration worked correctly")
                
                // Only migrate from the first found location
                return
                
            } catch {
                print("❌ Migration failed: \(error.localizedDescription)")
                print("   Please manually copy your data if needed")
            }
        }
        
        print("📁 No legacy data found for migration")
    }
}

class UpdaterViewModel: ObservableObject {
    private let updaterController: SPUStandardUpdaterController
    
    @Published var canCheckForUpdates = false
    @Published var updateAvailable = false
    @Published var latestVersion: String? = nil
    @Published var isCheckingForUpdates = false
    
    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        
        // Enable automatic update checking
        updaterController.updater.automaticallyChecksForUpdates = true
        updaterController.updater.updateCheckInterval = 24 * 60 * 60
        
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
        
        // Check for updates on launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.silentlyCheckForUpdates()
        }
    }
    
    func checkForUpdates() {
        // This is for manual checks - will show UI
        updaterController.checkForUpdates(nil)
    }
    
    func silentlyCheckForUpdates() {
        // This checks for updates in the background without showing UI unless an update is found
        isCheckingForUpdates = true
        updaterController.updater.checkForUpdatesInBackground()
        
        // Simulate check completion (in production, use Sparkle delegate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isCheckingForUpdates = false
        }
    }
}

struct CheckForUpdatesView: View {
    @ObservedObject var updaterViewModel: UpdaterViewModel
    
    var body: some View {
        Button("Check for Updates…", action: updaterViewModel.checkForUpdates)
            .disabled(!updaterViewModel.canCheckForUpdates)
    }
}

struct WindowAccessor: NSViewRepresentable {
    let callback: (NSWindow) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                callback(window)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Clio Banner
            Image("clio-banner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
                .frame(maxWidth: .infinity)
            
            VStack(spacing: 16) {
                Image(systemName: "circle.dotted")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(DarkTheme.textPrimary)
                    .symbolEffect(.variableColor.iterative, options: .repeating)
                
                Text(NSLocalizedString("auth.signing_in", comment: ""))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DarkTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}
