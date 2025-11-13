import Foundation
import SwiftUI

enum SubscriptionTier: String, CaseIterable, Identifiable {
    case free
    case pro
    case enterprise

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro"
        case .enterprise: return "Enterprise"
        }
    }
}

struct SubscriptionFeatures {
    let tier: SubscriptionTier
    let trialDaysRemaining: Int
    let trialWordsUsed: Int

    var isInTrial: Bool { false }
    var trialDurationDays: Int { SubscriptionManager.TRIAL_DURATION_DAYS }

    var canUseBaseModels: Bool { true }
    var canUseLargeModels: Bool { true }
    var canUseCloudModels: Bool { true }
    var canUseAIEnhancement: Bool { true }
    var canUseCustomPrompts: Bool { true }
    var canUsePowerModes: Bool { true }
    var canExportTranscripts: Bool { true }
    var canSyncAcrossDevices: Bool { true }
    var prioritySupport: Bool { true }
}

struct UsageInfo {
    let limit: Double
    let unit: String
    let remaining: Double
    var isAtLimit: Bool { false }
}

struct MonthlyUsage: Codable {
    var transcriptionMinutes: Double = 0
    var enhancementWords: Double = 0
    var trialWordsUsed: Int = 0

    mutating func resetIfNeeded() {
        // No rolling window limits in community build
    }
}

enum ProFeature: String, CaseIterable, Identifiable {
    case aiEnhancement
    case cloudModels
    case powerModes
    case localDictionary
    case automation

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .aiEnhancement: return "AI Enhancement"
        case .cloudModels: return "Cloud Models"
        case .powerModes: return "Power Modes"
        case .localDictionary: return "Personal Dictionary"
        case .automation: return "Automations"
        }
    }
    
    var iconName: String {
        switch self {
        case .aiEnhancement: return "wand.and.rays"
        case .cloudModels: return "cloud.bolt.fill"
        case .powerModes: return "bolt.square.fill"
        case .localDictionary: return "book.closed.fill"
        case .automation: return "gearshape.2.fill"
        }
    }
}

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    static let TRIAL_DURATION_DAYS = 0
    static let TRIAL_WORD_LIMIT = 0

    static var trialDurationDisplayText: String {
        NSLocalizedString("subscription.unlimited", comment: "")
    }

    @Published var currentTier: SubscriptionTier = .pro
    @Published var isInTrial = false
    @Published var trialDaysRemaining: Int = 0
    @Published private(set) var trialWordsUsed: Int = 0
    @Published private(set) var monthlyUsage = MonthlyUsage()
    @Published private(set) var features: SubscriptionFeatures

    private init() {
        self.features = SubscriptionFeatures(tier: .pro, trialDaysRemaining: 0, trialWordsUsed: 0)
    }

    func updateSubscriptionState() {
        features = SubscriptionFeatures(tier: .pro, trialDaysRemaining: 0, trialWordsUsed: 0)
        currentTier = .pro
        isInTrial = false
        trialDaysRemaining = 0
        trialWordsUsed = 0
        NotificationCenter.default.post(name: .subscriptionStateChanged, object: nil)
    }

    func forceRefreshAuthentication() async {}

    func promptUpgrade(from source: String) {
        ToastBanner.shared.show(title: "Community Edition", subtitle: "All Pro features are already unlocked.")
    }

    func canAccessFeature(_ feature: ProFeature) -> Bool { true }

    func getRemainingUsage(for feature: ProFeature) -> UsageInfo? { nil }

    func updateTrialUsage(additionalMinutes: Double) async {}

    // MARK: - Legacy usage hooks (no-ops in community build)

    func startRecordingSession() {}
    func endRecordingSession() {}
    func trackEnhancement(wordCount: Int) {}
}

extension Notification.Name {
    static let subscriptionStateChanged = Notification.Name("subscriptionStateChanged")
}
