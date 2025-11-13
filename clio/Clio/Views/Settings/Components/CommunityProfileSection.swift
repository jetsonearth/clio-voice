import SwiftUI

struct CommunityProfileSection: View {
    @ObservedObject private var profile = UserProfileService.shared
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var lastSavedName: String = ""
    @State private var lastSavedEmail: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Small header outside the card (matching keyboard shortcuts style)
            Text("PERSONAL PROFILE")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DarkTheme.textSecondary.opacity(0.8))
                .textCase(.uppercase)
                .tracking(0.5)
            
            // Card content
            VStack(alignment: .leading, spacing: 16) {
                // Name field with label
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DarkTheme.textPrimary)
                    TextField("Display name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(saveProfile)
                }
                
                // Email field with label
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DarkTheme.textPrimary)
                    TextField("Email address", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                        .onSubmit(saveProfile)
                }
                
                // Save button (smaller)
                HStack(spacing: 12) {
                    AddNewButton("Save Profile", 
                                action: saveProfile, 
                                isEnabled: hasChanges && !name.trimmed.isEmpty && !email.trimmed.isEmpty,
                                systemImage: "square.and.arrow.down",
                                size: .small)
                    
                    if hasChanges {
                        Text("Unsaved changes")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DarkTheme.textPrimary.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .onAppear {
            name = profile.userName
            email = profile.userEmail
            lastSavedName = profile.userName
            lastSavedEmail = profile.userEmail
        }
        .onDisappear {
            saveProfileIfNeeded()
        }
        .onReceive(profile.$userName) { newValue in
            name = newValue
            lastSavedName = newValue
        }
        .onReceive(profile.$userEmail) { newValue in
            email = newValue
            lastSavedEmail = newValue
        }
    }
    
    private var hasChanges: Bool {
        name.trimmed != lastSavedName || email.trimmed.lowercased() != lastSavedEmail.lowercased()
    }
    
    private func saveProfile() {
        let trimmedName = name.trimmed
        let trimmedEmail = email.trimmed.lowercased()
        guard !trimmedName.isEmpty, !trimmedEmail.isEmpty else { return }
        profile.updateProfile(name: trimmedName, email: trimmedEmail)
        lastSavedName = trimmedName
        lastSavedEmail = trimmedEmail
    }
    
    private func saveProfileIfNeeded() {
        guard hasChanges else { return }
        saveProfile()
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
