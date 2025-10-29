import SwiftUI

struct LicenseView: View {
    @ObservedObject private var licenseViewModel = LicenseViewModel.shared
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 15) {
            Text(localizationManager.localizedString("license.management.title"))
                .font(.headline)
            
            if case .licensed = licenseViewModel.licenseState {
                VStack(spacing: 10) {
                    Text(localizationManager.localizedString("license.status.activated"))
                        .foregroundColor(.green)
                    
                    Button(role: .destructive, action: {
                        licenseViewModel.removeLicense()
                    }) {
                        Text(localizationManager.localizedString("license.action.remove"))
                    }
                }
            } else {
                TextField(localizationManager.localizedString("license.placeholder.enter_key"), text: $licenseViewModel.licenseKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 300)
                
                Button(action: {
                    Task {
                        await licenseViewModel.validateLicense()
                    }
                }) {
                    if licenseViewModel.isValidating {
                        ProgressView()
                            .frame(width: 20, height: 20)
                    } else {
                        Text(localizationManager.localizedString("license.action.activate"))
                    }
                }
                .disabled(licenseViewModel.isValidating)
            }
            
            if let message = licenseViewModel.validationMessage {
                Text(message)
                    .foregroundColor(licenseViewModel.licenseState == .licensed ? .green : .red)
                    .font(.caption)
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