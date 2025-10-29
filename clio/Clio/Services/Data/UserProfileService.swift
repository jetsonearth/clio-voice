import Foundation
import SwiftUI

// MARK: - User Profile Service
@MainActor
class UserProfileService: ObservableObject {
    static let shared = UserProfileService()
    
    @Published var isSignedIn: Bool = false
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userInitials: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let signedInKey = "isUserSignedIn"
    private let userNameKey = "userName"
    private let userEmailKey = "userEmail"
    
    private init() {
        loadUserState()
    }
    
    // MARK: - Public Methods
    
    func signIn(name: String, email: String) {
        self.userName = name
        self.userEmail = email
        self.userInitials = generateInitials(from: name)
        self.isSignedIn = true
        saveUserState()
    }
    
    func signOut() {
        self.userName = ""
        self.userEmail = ""
        self.userInitials = ""
        self.isSignedIn = false
        clearUserState()
    }
    
    func updateProfile(name: String, email: String) {
        self.userName = name
        self.userEmail = email
        self.userInitials = generateInitials(from: name)
        saveUserState()
    }
    
    // MARK: - Greeting Methods
    
    var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return LocalizationManager.shared.localizedString("greeting.good_morning")
        case 12..<17:
            return LocalizationManager.shared.localizedString("greeting.good_afternoon")
        case 17..<22:
            return LocalizationManager.shared.localizedString("greeting.good_evening")
        default:
            return LocalizationManager.shared.localizedString("greeting.good_evening")
        }
    }
    
    var personalizedGreeting: String {
        if isSignedIn && !userName.isEmpty {
            return "\(timeBasedGreeting), \(userName.components(separatedBy: " ").first ?? userName)"
        } else {
            return timeBasedGreeting
        }
    }
    
    // MARK: - Private Methods
    
    private func generateInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0).uppercased() }
        return String(initials.prefix(2).joined())
    }
    
    private func loadUserState() {
        isSignedIn = userDefaults.bool(forKey: signedInKey)
        userName = userDefaults.string(forKey: userNameKey) ?? ""
        userEmail = userDefaults.string(forKey: userEmailKey) ?? ""
        userInitials = generateInitials(from: userName)
    }
    
    private func saveUserState() {
        userDefaults.set(isSignedIn, forKey: signedInKey)
        userDefaults.set(userName, forKey: userNameKey)
        userDefaults.set(userEmail, forKey: userEmailKey)
    }
    
    private func clearUserState() {
        userDefaults.removeObject(forKey: signedInKey)
        userDefaults.removeObject(forKey: userNameKey)
        userDefaults.removeObject(forKey: userEmailKey)
    }
}