import SwiftUI

// Temporarily commented out until Supabase dependency is added
/*
struct MigrationDetailsView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var migrationData: LicenseUserMigration?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection
                    
                    // Migration Status
                    statusSection
                    
                    // Legacy Data Details
                    if let migration = migrationData {
                        legacyDataSection(migration)
                    }
                    
                    // What happens during migration
                    migrationProcessSection
                    
                    // Actions
                    actionsSection
                }
                .padding(24)
            }
            .frame(width: 500)
            .navigationTitle("Migration Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            migrationData = LicenseUserMigration.fromUserDefaults()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Legacy License Migration")
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("Transfer your existing license data to your new account")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Status")
                .font(.system(size: 16, weight: .semibold))
            
            HStack(spacing: 12) {
                statusIcon
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(statusTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(userViewModel.migrationStatus.displayText)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(statusBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(statusBorderColor, lineWidth: 1)
                    )
            )
        }
    }
    
    private func legacyDataSection(_ migration: LicenseUserMigration) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Legacy Data Found")
                .font(.system(size: 16, weight: .semibold))
            
            VStack(spacing: 12) {
                if let licenseKey = migration.legacyLicenseKey {
                    DataRow(
                        label: "License Key",
                        value: "\(licenseKey.prefix(8))...",
                        icon: "key.fill",
                        color: .green
                    )
                }
                
                if let activationId = migration.legacyActivationId {
                    DataRow(
                        label: "Activation ID",
                        value: "\(activationId.prefix(8))...",
                        icon: "checkmark.seal.fill",
                        color: .accentColor
                    )
                }
                
                if let trialStart = migration.legacyTrialStartDate {
                    DataRow(
                        label: "Trial Started",
                        value: formatDate(trialStart),
                        icon: "calendar.circle.fill",
                        color: .orange
                    )
                }
                
                DataRow(
                    label: "Previous User",
                    value: migration.hasLaunchedBefore ? "Yes" : "No",
                    icon: "person.circle.fill",
                    color: migration.hasLaunchedBefore ? .green : .secondary
                )
            }
        }
    }
    
    private var migrationProcessSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What Happens During Migration")
                .font(.system(size: 16, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 12) {
                MigrationStep(
                    number: 1,
                    title: "Data Transfer",
                    description: "Your license key and activation data will be securely transferred to your new account."
                )
                
                MigrationStep(
                    number: 2,
                    title: "Account Upgrade",
                    description: "Your account will be upgraded to match your current license status."
                )
                
                MigrationStep(
                    number: 3,
                    title: "Seamless Transition",
                    description: "You'll continue to have the same access level without interruption."
                )
                
                MigrationStep(
                    number: 4,
                    title: "Legacy Cleanup",
                    description: "Old license data will be preserved but marked as migrated."
                )
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            if userViewModel.migrationStatus.showMigrationButton {
                Button(action: {
                    Task {
                        await userViewModel.forceMigration()
                    }
                }) {
                    HStack {
                        if case .inProgress = userViewModel.migrationStatus {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                                .scaleEffect(0.8)
                        }
                        
                        Text(case .inProgress = userViewModel.migrationStatus ? "Migrating..." : "Start Migration")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(DarkTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor)
                    )
                }
                .buttonStyle(.plain)
                .disabled(case .inProgress = userViewModel.migrationStatus)
            }
            
            // Info text
            Text("Migration is safe and reversible. Your original data will not be deleted.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Helper Properties
    
    private var statusIcon: some View {
        Group {
            switch userViewModel.migrationStatus {
            case .pending:
                Image(systemName: "clock.circle.fill")
                    .foregroundColor(.orange)
            case .notNeeded:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .needed:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.accentColor)
            case .inProgress:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                    .scaleEffect(0.8)
            case .completed:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .failed:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }
        }
        .font(.system(size: 20))
    }
    
    private var statusTitle: String {
        switch userViewModel.migrationStatus {
        case .pending: return "Checking..."
        case .notNeeded: return "No Migration Needed"
        case .needed: return "Migration Available"
        case .inProgress: return "Migration in Progress"
        case .completed: return "Migration Completed"
        case .failed: return "Migration Failed"
        }
    }
    
    private var statusBackgroundColor: Color {
        switch userViewModel.migrationStatus {
        case .pending: return .orange.opacity(0.1)
        case .notNeeded: return .green.opacity(0.1)
        case .needed: return .accentColor.opacity(0.1)
        case .inProgress: return .accentColor.opacity(0.1)
        case .completed: return .green.opacity(0.1)
        case .failed: return .red.opacity(0.1)
        }
    }
    
    private var statusBorderColor: Color {
        switch userViewModel.migrationStatus {
        case .pending: return .orange.opacity(0.3)
        case .notNeeded: return .green.opacity(0.3)
        case .needed: return .accentColor.opacity(0.3)
        case .inProgress: return .accentColor.opacity(0.3)
        case .completed: return .green.opacity(0.3)
        case .failed: return .red.opacity(0.3)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct DataRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

struct MigrationStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 24, height: 24)
                
                Text("\(number)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

#Preview {
    MigrationDetailsView()
        .environmentObject(UserViewModel())
}
*/