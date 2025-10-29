import Foundation

/// Centralized configuration for support contact information.
/// Reads from `Info.plist` and allows optional runtime override via UserDefaults.
struct SupportConfig {
    /// Key name used in Info.plist to specify the default support email address.
    private static let infoPlistKey: String = "SupportEmail"
    /// UserDefaults override key. Useful for hotfixing without rebuilding.
    private static let overrideDefaultsKey: String = "SupportEmailRecipient"

    /// The support email recipient used by the app. Resolution order:
    /// 1) UserDefaults override `SupportEmailRecipient`
    /// 2) Info.plist key `SupportEmail`
    /// 3) Fallback default
    static var supportEmail: String {
        if let override = UserDefaults.standard.string(forKey: overrideDefaultsKey),
           override.isEmpty == false {
            return override
        }

        if let infoValue = Bundle.main.object(forInfoDictionaryKey: infoPlistKey) as? String,
           infoValue.isEmpty == false {
            return infoValue
        }

        // Safe fallback. Update as needed.
        return "support@cliovoice.com"
    }
}


