import SwiftUI

struct CompactPermissionCard: View {
    let icon: String
    let title: String
    let isGranted: Bool
    let buttonAction: () -> Void
    let checkPermission: () -> Void
    var isOptional: Bool = false
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    private var statusColor: Color {
        if isOptional && !isGranted {
            return .gray // Gray when optional and not granted
        }
        return isGranted ? .accentColor : .orange
    }
    
    private var statusText: String {
        if isOptional && !isGranted {
            return "Optional"
        }
        return isGranted ? localizationManager.localizedString("settings.status.enabled") : localizationManager.localizedString("settings.status.disabled")
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with status indicator
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(statusColor)
            }
            
            // Title
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(DarkTheme.textPrimary)
                .multilineTextAlignment(.center)
            
            // Status badge (replaces description)
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                Text(statusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.15))
            )
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.13)) // Same dark grey as BeautifulPermissionCard
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .onTapGesture {
            if !isGranted && !isOptional {
                buttonAction()
            }
        }
        .onAppear {
            checkPermission()
        }
    }
}