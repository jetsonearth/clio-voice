import SwiftUI

struct LicensePageView: View {
    @ObservedObject private var licenseViewModel = LicenseViewModel.shared

    var body: some View {
        VStack(spacing: 24) {
            Text("Community Edition")
                .font(.system(size: 24, weight: .bold))

            Text("This open-source build ships with every feature unlocked. No license key or trial is required—just install and start using Clio.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .frame(maxWidth: 420)

            Button("Copy Project URL") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString("https://github.com/studio-kensense/clio", forType: .string)
            }
            .buttonStyle(.borderedProminent)

            if let validation = licenseViewModel.validationMessage {
                Text(validation)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(40)
    }
}
