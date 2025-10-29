import SwiftUI
import Sparkle

struct UpdateStatusBadge: View {
    @ObservedObject var updaterViewModel: UpdaterViewModel
    @State private var updateStatus: UpdateStatus = .checking
    @State private var latestVersion: String? = nil
    @State private var isHovering = false
    @State private var pulseAnimation = false
    
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    enum UpdateStatus {
        case checking
        case upToDate
        case updateAvailable
        case error
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Subtle Status Icon
            statusIcon
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(iconColor)
            
            // Status and Version Text
            HStack(spacing: 4) {
                Text(statusText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(DarkTheme.textSecondary)
                
                Text("•")
                    .font(.system(size: 8))
                    .foregroundColor(DarkTheme.textSecondary.opacity(0.5))
                
                Text("v\(currentVersion)")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(DarkTheme.textSecondary.opacity(0.8))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(DarkTheme.textPrimary.opacity(isHovering ? 0.08 : 0.05))
        )
        .opacity(isHovering ? 1.0 : 0.8)
        .animation(.smooth(duration: 0.2), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            if updateStatus == .updateAvailable {
                updaterViewModel.checkForUpdates()
            }
        }
        .help(helpText)
        .onAppear {
            checkForUpdates()
        }
        .onChange(of: updaterViewModel.isCheckingForUpdates) { _ in
            checkForUpdates()
        }
        .onChange(of: updaterViewModel.updateAvailable) { _ in
            checkForUpdates()
        }
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch updateStatus {
        case .checking:
            Image(systemName: "arrow.triangle.2.circlepath")
        case .upToDate:
            Image(systemName: "checkmark.circle")
        case .updateAvailable:
            Image(systemName: "arrow.up.circle.fill")
        case .error:
            Image(systemName: "exclamationmark.triangle")
        }
    }
    
    private var iconColor: Color {
        switch updateStatus {
        case .checking:
            return DarkTheme.textSecondary.opacity(0.6)
        case .upToDate:
            return DarkTheme.textSecondary
        case .updateAvailable:
            return DarkTheme.accent
        case .error:
            return DarkTheme.textSecondary.opacity(0.4)
        }
    }
    
    private var statusText: String {
        switch updateStatus {
        case .checking:
            return "Checking"
        case .upToDate:
            return "Up to date"
        case .updateAvailable:
            return "Update ready"
        case .error:
            return "Check failed"
        }
    }
    
    private var helpText: String {
        switch updateStatus {
        case .checking:
            return "Checking for updates..."
        case .upToDate:
            return "Clio is up to date (v\(currentVersion))"
        case .updateAvailable:
            if let latest = latestVersion {
                return "Version \(latest) is available. Click to update"
            }
            return "A new version is available. Click to update"
        case .error:
            return "Unable to check for updates"
        }
    }
    
    private func checkForUpdates() {
        // Use the actual checking state from the updater
        if updaterViewModel.isCheckingForUpdates {
            updateStatus = .checking
        } else if updaterViewModel.updateAvailable {
            updateStatus = .updateAvailable
            pulseAnimation = true
        } else {
            updateStatus = .upToDate
            pulseAnimation = false
        }
    }
}