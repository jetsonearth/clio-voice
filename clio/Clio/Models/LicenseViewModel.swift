import Foundation
import AppKit

@MainActor
final class LicenseViewModel: ObservableObject {
    enum LicenseState {
        case community
    }

    static let shared = LicenseViewModel()

    @Published private(set) var licenseState: LicenseState = .community
    @Published var licenseKey: String = ""
    @Published var isValidating = false
    @Published var validationMessage: String?

    private init() {}

    var canUseApp: Bool { true }
    func startTrial() {}

    func validateLicense() async {
        await MainActor.run {
            validationMessage = "The open-source build does not require a license."
        }
    }

    func removeLicense() {
        licenseKey = ""
        validationMessage = nil
    }
}
