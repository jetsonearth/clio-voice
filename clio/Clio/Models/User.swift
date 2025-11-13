import Foundation

// MARK: - User Models

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let fullName: String?
    let avatarUrl: String?
    let createdAt: Date
    let updatedAt: Date
    
    // Subscription related
    let subscriptionStatus: SubscriptionStatus
    let subscriptionPlan: SubscriptionPlan?
    let subscriptionExpiresAt: Date?
    let trialEndsAt: Date?
    // Feature access
    let features: UserFeatures
    
    // Usage statistics (added for hybrid local/cloud stats)
    let totalWordsTranscribed: Int?
    let totalSpeakingMinutes: Double?
    let totalSessions: Int?
    let totalTimeSavedMinutes: Double?
    let averageWpm: Double?
    let lastActivityAt: Date?
    let trialWordsUsed: Int?
    let trialMinutesUsed: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case subscriptionStatus = "subscription_status"
        case subscriptionPlan = "subscription_plan"
        case subscriptionExpiresAt = "subscription_expires_at"
        case trialEndsAt = "trial_ends_at"
        case features
        case totalWordsTranscribed = "total_words_transcribed"
        case totalSpeakingMinutes = "total_speaking_minutes"
        case totalSessions = "total_sessions"
        case totalTimeSavedMinutes = "total_time_saved_minutes"
        case averageWpm = "average_wpm"
        case lastActivityAt = "last_activity_at"
        case trialWordsUsed = "trial_words_used"
        case trialMinutesUsed = "trial_minutes_used"
    }
    
    // Custom initializer for Supabase data with individual feature booleans
    init(from supabaseData: [String: Any]) throws {
        guard let id = supabaseData["id"] as? String,
              let email = supabaseData["email"] as? String else {
            throw DecodingError.keyNotFound(CodingKeys.id, DecodingError.Context(codingPath: [], debugDescription: "Missing required fields"))
        }
        
        self.id = id
        self.email = email
        self.fullName = supabaseData["full_name"] as? String
        self.avatarUrl = supabaseData["avatar_url"] as? String
        
        // Parse dates with multiple formatters to handle various Supabase formats
        func parseDate(_ dateString: String?) -> Date? {
            guard let dateString = dateString else { return nil }
            
            // Try common Supabase formats
            let formatters = [
                "yyyy-MM-dd HH:mm:ss.SSSSSSXX",   // 2025-07-17 15:55:03.600673+00
                "yyyy-MM-dd HH:mm:ss.SSSSSSX",    // with single timezone digit
                "yyyy-MM-dd HH:mm:ssXX",          // without microseconds
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXX", // ISO format with T
                "yyyy-MM-dd'T'HH:mm:ssXX"         // ISO without microseconds
            ]
            
            for format in formatters {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            
            // Final fallback to ISO8601DateFormatter
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return isoFormatter.date(from: dateString)
        }
        
        self.createdAt = parseDate(supabaseData["created_at"] as? String) ?? Date()
        self.updatedAt = parseDate(supabaseData["updated_at"] as? String) ?? Date()
        self.subscriptionExpiresAt = parseDate(supabaseData["subscription_expires_at"] as? String)
        self.trialEndsAt = parseDate(supabaseData["trial_ends_at"] as? String)
        
        // Debug logging for trial_ends_at
        if let trialString = supabaseData["trial_ends_at"] as? String {
            // print("🔍 [USER] Raw trial_ends_at from Supabase: '\(trialString)'")
            // print("🔍 [USER] Parsed trial_ends_at: \(self.trialEndsAt?.description ?? "nil")")
        }
        
        // Parse subscription data
        if let statusString = supabaseData["subscription_status"] as? String {
            self.subscriptionStatus = SubscriptionStatus(rawValue: statusString) ?? .none
            // print("🔍 [USER] Parsed subscription_status: '\(statusString)' → \(self.subscriptionStatus)")
        } else {
            self.subscriptionStatus = .none
            // print("🔍 [USER] subscription_status is nil, setting to .none")
        }
        
        if let planString = supabaseData["subscription_plan"] as? String {
            self.subscriptionPlan = SubscriptionPlan(rawValue: planString)
            // print("🔍 [USER] Parsed subscription_plan: '\(planString)' → \(self.subscriptionPlan?.rawValue ?? "nil")")
        } else {
            self.subscriptionPlan = nil
            // print("🔍 [USER] subscription_plan is nil or not a string. Raw value: \(supabaseData["subscription_plan"] ?? "missing")")
        }
        
        // Map individual feature booleans to UserFeatures struct
        self.features = UserFeatures(
            unlimitedTranscriptions: supabaseData["unlimited_transcriptions"] as? Bool ?? false,
            aiEnhancement: supabaseData["ai_enhancement"] as? Bool ?? false,
            cloudSync: supabaseData["cloud_sync"] as? Bool ?? false,
            advancedSettings: supabaseData["advanced_settings"] as? Bool ?? false,
            prioritySupport: supabaseData["priority_support"] as? Bool ?? false,
            teamFeatures: supabaseData["team_features"] as? Bool ?? false
        )
        
        // Parse usage statistics (newly added fields)
        // Note: Supabase returns DECIMAL values as strings, so we need to parse them
        self.totalWordsTranscribed = supabaseData["total_words_transcribed"] as? Int
        
        // Parse decimal values that come as strings from Supabase
        if let minutesString = supabaseData["total_speaking_minutes"] as? String {
            self.totalSpeakingMinutes = Double(minutesString)
        } else {
            self.totalSpeakingMinutes = supabaseData["total_speaking_minutes"] as? Double
        }
        
        self.totalSessions = supabaseData["total_sessions"] as? Int
        
        if let timeSavedString = supabaseData["total_time_saved_minutes"] as? String {
            self.totalTimeSavedMinutes = Double(timeSavedString)
        } else {
            self.totalTimeSavedMinutes = supabaseData["total_time_saved_minutes"] as? Double
        }
        
        if let wpmString = supabaseData["average_wpm"] as? String {
            self.averageWpm = Double(wpmString)
        } else {
            self.averageWpm = supabaseData["average_wpm"] as? Double
        }
        
        self.lastActivityAt = parseDate(supabaseData["last_activity_at"] as? String)
        self.trialWordsUsed = supabaseData["trial_words_used"] as? Int
        
        if let trialMinutesString = supabaseData["trial_minutes_used"] as? String {
            self.trialMinutesUsed = Double(trialMinutesString)
        } else {
            self.trialMinutesUsed = supabaseData["trial_minutes_used"] as? Double
        }
    }
}

// MARK: - Subscription Models

enum SubscriptionStatus: String, Codable, CaseIterable {
    case trial = "trial"
    case active = "active"
    case pastDue = "past_due"
    case canceled = "canceled"
    case expired = "expired"
    case none = "none"
    
    var displayName: String {
        switch self {
        case .trial: return "Free Trial"
        case .active: return "Active"
        case .pastDue: return "Past Due"
        case .canceled: return "Canceled"
        case .expired: return "Expired"
        case .none: return "Free"
        }
    }
    
    var canUseApp: Bool {
        switch self {
        case .trial, .active:
            return true
        case .pastDue, .canceled, .expired, .none:
            return false
        }
    }
}

enum SubscriptionPlan: String, Codable, CaseIterable {
    case basic = "basic"
    case pro = "pro"
    case team = "team"
    
    var displayName: String {
        switch self {
        case .basic: return "Basic"
        case .pro: return "Pro"
        case .team: return "Team"
        }
    }
    
    var monthlyPrice: String {
        switch self {
        case .basic: return "$9"
        case .pro: return "$19"
        case .team: return "$49"
        }
    }
}

struct UserFeatures: Codable {
    let unlimitedTranscriptions: Bool
    let aiEnhancement: Bool
    let cloudSync: Bool
    let advancedSettings: Bool
    let prioritySupport: Bool
    let teamFeatures: Bool
    
    static let free = UserFeatures(
        unlimitedTranscriptions: false,
        aiEnhancement: false,
        cloudSync: false,
        advancedSettings: false,
        prioritySupport: false,
        teamFeatures: false
    )
    
    static let trial = UserFeatures(
        unlimitedTranscriptions: true,
        aiEnhancement: true,
        cloudSync: false,
        advancedSettings: true,
        prioritySupport: false,
        teamFeatures: false
    )
    
    static let basic = UserFeatures(
        unlimitedTranscriptions: true,
        aiEnhancement: true,
        cloudSync: true,
        advancedSettings: true,
        prioritySupport: false,
        teamFeatures: false
    )
    
    static let pro = UserFeatures(
        unlimitedTranscriptions: true,
        aiEnhancement: true,
        cloudSync: true,
        advancedSettings: true,
        prioritySupport: true,
        teamFeatures: false
    )
    
    static let team = UserFeatures(
        unlimitedTranscriptions: true,
        aiEnhancement: true,
        cloudSync: true,
        advancedSettings: true,
        prioritySupport: true,
        teamFeatures: true
    )
}

// MARK: - Authentication Models

enum AuthenticationState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated(User)
    case error(String)
    
    var isAuthenticated: Bool {
        if case .authenticated = self {
            return true
        }
        return false
    }
    
    var user: User? {
        if case .authenticated(let user) = self {
            return user
        }
        return nil
    }
    
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.unauthenticated, .unauthenticated):
            return true
        case (.authenticating, .authenticating):
            return true
        case let (.authenticated(lhsUser), .authenticated(rhsUser)):
            return lhsUser.id == rhsUser.id
        case let (.error(lhsError), .error(rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

struct AuthCredentials: Codable {
    let email: String
    let password: String
}

struct RegisterCredentials: Codable {
    let email: String
    let password: String
    let fullName: String?
}

// MARK: - API Response Models

struct SupabaseAuthUser: Codable {
    let id: String
    let email: String
    let userMetadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case userMetadata = "user_metadata"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        
        // Handle user_metadata as optional dictionary
        if let metadataContainer = try? container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .userMetadata) {
            var metadata: [String: Any] = [:]
            for key in metadataContainer.allKeys {
                if let value = try? metadataContainer.decode(String.self, forKey: key) {
                    metadata[key.stringValue] = value
                } else if let value = try? metadataContainer.decode(Bool.self, forKey: key) {
                    metadata[key.stringValue] = value
                }
            }
            userMetadata = metadata
        } else {
            userMetadata = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}

struct AuthResponse: Codable {
    let user: SupabaseAuthUser
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

struct UserSession: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let user: User
    
    var isExpired: Bool {
        Date() > expiresAt
    }
    
    var shouldRefresh: Bool {
        // Refresh if token expires within 5 minutes
        Date().addingTimeInterval(300) > expiresAt
    }
}

extension User {
    init(
        id: String,
        email: String,
        fullName: String?,
        subscriptionStatus: SubscriptionStatus,
        subscriptionPlan: SubscriptionPlan?,
        features: UserFeatures
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.avatarUrl = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.subscriptionStatus = subscriptionStatus
        self.subscriptionPlan = subscriptionPlan
        self.subscriptionExpiresAt = nil
        self.trialEndsAt = nil
        self.features = features
        self.totalWordsTranscribed = nil
        self.totalSpeakingMinutes = nil
        self.totalSessions = nil
        self.totalTimeSavedMinutes = nil
        self.averageWpm = nil
        self.lastActivityAt = nil
        self.trialWordsUsed = nil
        self.trialMinutesUsed = nil
    }

    static func makeLocalUser(id: String = UUID().uuidString, email: String, fullName: String?) -> User {
        User(
            id: id,
            email: email,
            fullName: fullName,
            subscriptionStatus: .active,
            subscriptionPlan: .pro,
            features: .pro
        )
    }
}

// MARK: - Legacy License Integration

struct LicenseUserMigration {
    let legacyLicenseKey: String?
    let legacyActivationId: String?
    let legacyTrialStartDate: Date?
    let hasLaunchedBefore: Bool
    
    static func fromUserDefaults() -> LicenseUserMigration {
        let userDefaults = UserDefaults.standard
        return LicenseUserMigration(
            legacyLicenseKey: userDefaults.licenseKey,
            legacyActivationId: userDefaults.activationId,
            legacyTrialStartDate: userDefaults.trialStartDate,
            hasLaunchedBefore: userDefaults.bool(forKey: "ClioHasLaunchedBefore")
        )
    }
}
