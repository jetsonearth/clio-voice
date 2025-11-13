import Foundation

extension UserDefaults {
    enum Keys {
        static let aiProviderApiKey = "IoAIProviderKey"
        static let licenseKey = "IoLicense"
        static let trialStartDate = "IoTrialStartDate"
        static let activationId = "IoActivationId"
    }
    
    // MARK: - AI Provider API Key
    var aiProviderApiKey: String? {
        get { string(forKey: Keys.aiProviderApiKey) }
        set { setValue(newValue, forKey: Keys.aiProviderApiKey) }
    }
    
    // MARK: - License Key
    var licenseKey: String? {
        get { string(forKey: Keys.licenseKey) }
        set { setValue(newValue, forKey: Keys.licenseKey) }
    }
    
    // MARK: - Trial Start Date
    var trialStartDate: Date? {
        get { object(forKey: Keys.trialStartDate) as? Date }
        set { setValue(newValue, forKey: Keys.trialStartDate) }
    }
    
    // MARK: - Legacy Activation ID
    var activationId: String? {
        get { string(forKey: Keys.activationId) }
        set { setValue(newValue, forKey: Keys.activationId) }
    }
}
