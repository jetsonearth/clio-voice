import SwiftUI

struct CommunityProfileSection: View {
    @ObservedObject private var profile = UserProfileService.shared
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var lastSavedName: String = ""
    @State private var lastSavedEmail: String = ""
    
    var body: some View {
        SettingsSection(
            icon: "person.crop.circle",
            title: "Community Profile",
            subtitle: "Update the name and email that appear around the app"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Display name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(saveProfile)
                
                TextField("Email address", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                    .onSubmit(saveProfile)
                
                HStack {
                    AddNewButton("Save Profile", action: saveProfile, systemImage: "square.and.arrow.down")
                        .disabled(!hasChanges || name.trimmed.isEmpty || email.trimmed.isEmpty)
                    if hasChanges {
                        Text("Unsaved changes")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            name = profile.userName
            email = profile.userEmail
            lastSavedName = profile.userName
            lastSavedEmail = profile.userEmail
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
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
