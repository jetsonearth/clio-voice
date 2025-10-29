import SwiftUI

// Temporarily commented out until Supabase dependency is added
/*
struct EditProfileView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var avatarUrl: String = ""
    @State private var hasChanges = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Avatar Section
                avatarSection
                
                // Form Fields
                formSection
                
                // Error Message
                if let errorMessage = userViewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                    )
                }
                
                Spacer()
            }
            .padding(24)
            .frame(width: 400)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveProfile()
                        }
                    }
                    .disabled(!hasChanges || userViewModel.isLoading)
                }
            }
        }
        .onAppear {
            loadCurrentProfile()
        }
        .onChange(of: fullName) { checkForChanges() }
        .onChange(of: avatarUrl) { checkForChanges() }
    }
    
    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                if !avatarUrl.isEmpty, let url = URL(string: avatarUrl) {
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
            
            Button("Change Avatar") {
                // TODO: Implement avatar upload
                // For now, you could use a URL input or file picker
            }
            .font(.system(size: 14))
            .foregroundColor(.accentColor)
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            // Full Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Enter your full name", text: $fullName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16))
            }
            
            // Email (read-only)
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16))
                    .disabled(true)
                    .foregroundColor(.secondary)
            }
            
            // Avatar URL (optional)
            VStack(alignment: .leading, spacing: 8) {
                Text("Avatar URL (Optional)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("https://example.com/avatar.jpg", text: $avatarUrl)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16))
            }
        }
    }
    
    private func loadCurrentProfile() {
        guard let user = userViewModel.currentUser else { return }
        
        fullName = user.fullName ?? ""
        email = user.email
        avatarUrl = user.avatarUrl ?? ""
    }
    
    private func checkForChanges() {
        guard let user = userViewModel.currentUser else {
            hasChanges = false
            return
        }
        
        hasChanges = fullName != (user.fullName ?? "") || 
                    avatarUrl != (user.avatarUrl ?? "")
    }
    
    private func saveProfile() async {
        userViewModel.clearError()
        
        let newAvatarUrl = avatarUrl.isEmpty ? nil : avatarUrl
        let newFullName = fullName.isEmpty ? nil : fullName
        
        await userViewModel.updateProfile(
            fullName: newFullName,
            avatarUrl: newAvatarUrl
        )
        
        if userViewModel.errorMessage == nil {
            dismiss()
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(UserViewModel())
}
*/