import SwiftUI

// Temporarily commented out until Supabase dependency is added
/*
struct ProfileView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var showEditProfile = false
    @State private var showMigrationDetails = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if userViewModel.isAuthenticated {
                    authenticatedContent
                } else {
                    unauthenticatedContent
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(userViewModel)
        }
        .sheet(isPresented: $showMigrationDetails) {
            MigrationDetailsView()
                .environmentObject(userViewModel)
        }
    }
    
    // MARK: - Authenticated Content
    
    private var authenticatedContent: some View {
        VStack(spacing: 32) {
            // Profile Header
            profileHeaderSection
            
            // Account Information
            accountInfoSection
            
            // Subscription Section
            subscriptionSection
            
            // Migration Status (if applicable)
            if userViewModel.migrationStatus.showMigrationButton {
                migrationSection
            }
            
            // Account Actions
            accountActionsSection
        }
    }
    
    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                if let avatarUrl = userViewModel.currentUser?.avatarUrl,
                   let url = URL(string: avatarUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.accentColor)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.accentColor)
                }
            }
            
            // User Info
            VStack(spacing: 4) {
                Text(userViewModel.currentUser?.fullName ?? "User")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(userViewModel.currentUser?.email ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            // Edit Button
            Button("Edit Profile") {
                showEditProfile = true
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10)
        )
    }
    
    private var accountInfoSection: some View {
        ProfileSection(title: "Account Information", icon: "person.circle") {
            VStack(spacing: 12) {
                ProfileInfoRow(
                    label: "Member since",
                    value: formatDate(userViewModel.currentUser?.createdAt)
                )
                
                ProfileInfoRow(
                    label: "Account ID",
                    value: userViewModel.currentUser?.id.prefix(8).appending("...") ?? "N/A"
                )
                
                ProfileInfoRow(
                    label: "Status",
                    value: userViewModel.subscriptionStatusText,
                    valueColor: statusColor
                )
            }
        }
    }
    
    private var subscriptionSection: some View {
        ProfileSection(title: "Subscription", icon: "creditcard.circle") {
            VStack(spacing: 16) {
                // Current Plan
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Plan")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(userViewModel.currentUser?.subscriptionPlan?.displayName ?? "Free")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    if let plan = userViewModel.currentUser?.subscriptionPlan {
                        Text(plan.monthlyPrice)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Trial Info (if applicable)
                if let user = userViewModel.currentUser,
                   user.subscriptionStatus == .trial,
                   let trialEnd = user.trialEndsAt {
                    
                    let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: trialEnd).day ?? 0
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "clock.circle.fill")
                                .foregroundColor(.orange)
                            Text("Free Trial")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        
                        Text("\(max(0, daysRemaining)) days remaining")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    if userViewModel.currentUser?.subscriptionStatus == .trial {
                        Button("Upgrade Plan") {
                            // Open upgrade flow
                            userViewModel.openSubscriptionManagement()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                    }
                    
                    Button("Manage Billing") {
                        userViewModel.openSubscriptionManagement()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                }
            }
        }
    }
    
    private var migrationSection: some View {
        ProfileSection(title: "Legacy License Migration", icon: "arrow.triangle.2.circlepath.circle") {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Legacy Data Found")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text(userViewModel.migrationStatus.displayText)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                if case .failed = userViewModel.migrationStatus {
                    HStack(spacing: 12) {
                        Button("Retry Migration") {
                            Task {
                                await userViewModel.forceMigration()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        
                        Button("Details") {
                            showMigrationDetails = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                } else if userViewModel.migrationStatus.showMigrationButton {
                    Button("Start Migration") {
                        Task {
                            await userViewModel.forceMigration()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
        }
    }
    
    private var accountActionsSection: some View {
        ProfileSection(title: "Account Actions", icon: "gearshape.circle") {
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        await userViewModel.refreshUserProfile()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Account")
                        Spacer()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                
                Button(action: {
                    Task {
                        await userViewModel.signOut()
                    }
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                        Spacer()
                    }
                    .foregroundColor(.red)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
        }
    }
    
    // MARK: - Unauthenticated Content
    
    private var unauthenticatedContent: some View {
        VStack(spacing: 32) {
            // Welcome Section
            VStack(spacing: 16) {
                Image(systemName: "person.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor.opacity(0.6))
                
                Text("Sign In to Your Account")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Access your profile, manage subscriptions, and sync your settings across devices.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Authentication View - DISABLED (using main app auth instead)
            // AuthenticationView()
            //     .environmentObject(userViewModel)
            
            Text("Please sign in through the main app authentication.")
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    // MARK: - Helper Properties
    
    private var statusColor: Color {
        guard let user = userViewModel.currentUser else { return .secondary }
        
        switch user.subscriptionStatus {
        case .trial, .active:
            return .green
        case .pastDue:
            return .orange
        case .canceled, .expired:
            return .red
        case .none:
            return .secondary
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct ProfileSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8)
        )
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(UserViewModel())
        .frame(width: 800, height: 600)
}
*/