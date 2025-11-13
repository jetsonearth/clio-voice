import SwiftUI

struct LicenseView: View {
    @ObservedObject private var licenseViewModel = LicenseViewModel.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 18) {
            Text(localizationManager.localizedString("license.management.title"))
                .font(.headline)

            Text("Clio Community Edition is fully unlocked—no license or activation key is required.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .frame(maxWidth: 360)

            if !(licenseViewModel.licenseKey.isEmpty) {
                VStack(spacing: 10) {
                    Text("A legacy key is still stored locally. You can clear it to remove stale data.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button(role: .destructive) {
                        licenseViewModel.removeLicense()
                    } label: {
                        Text("Clear Legacy License Data")
                    }
                }
            }
        }
        .padding()
    }
}

struct LicenseView_Previews: PreviewProvider {
    static var previews: some View {
        LicenseView()
    }
} 
