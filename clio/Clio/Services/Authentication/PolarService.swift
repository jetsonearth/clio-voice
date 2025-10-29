import Foundation
import IOKit
import CryptoKit

class PolarService {
    // Shared singleton instance
    static let shared = PolarService()
    
    // All Polar API calls are proxied through our backend (Fly.io); no secrets in client
    private let proxyBaseURL = "https://clio-backend-fly.fly.dev"
    
    // Product IDs are fetched from backend so you can change plans without client updates
    private var monthlyProductId: String = ""
    private var annualProductId: String = ""
    // Legacy direct API base removed (client does not talk to Polar directly)
    // private let baseURL = "https://api.polar.sh"
    
    // For development/testing - set to true to bypass API calls
    private let useTestMode = false
    
    
    struct LicenseValidationResponse: Codable {
        let status: String
        let limit_activations: Int?
        let id: String?
        let activation: ActivationResponse?
    }
    
    struct ActivationResponse: Codable {
        let id: String
    }
    
    struct ActivationRequest: Codable {
        let key: String
        let organization_id: String
        let label: String
        let meta: [String: String]
    }
    
    struct ActivationResult: Codable {
        let id: String
        let license_key: LicenseKeyInfo
    }
    
    struct LicenseKeyInfo: Codable {
        let limit_activations: Int
        let status: String
    }
    
    // MARK: - Subscription Details Models
    struct SubscriptionDetails: Codable {
        let id: String
        let status: String
        let current_period_start: String?
        let current_period_end: String?
        let customer: CustomerDetails?
        let product: ProductDetails?
        
        var expirationDate: Date? {
            guard let endDateString = current_period_end else { return nil }
            return parseISODate(endDateString)
        }
        
        private func parseISODate(_ dateString: String) -> Date? {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: dateString) ?? {
                // Fallback without fractional seconds
                let fallbackFormatter = ISO8601DateFormatter()
                fallbackFormatter.formatOptions = [.withInternetDateTime]
                return fallbackFormatter.date(from: dateString)
            }()
        }
    }
    
    struct CustomerDetails: Codable {
        let id: String
        let email: String?
    }
    
    struct ProductDetails: Codable {
        let id: String
        let name: String
        let is_recurring: Bool
        let type: String?
    }
    
    struct SubscriptionResponse: Codable {
        let items: [SubscriptionDetails]
        let pagination: PaginationInfo?
    }
    
    struct PaginationInfo: Codable {
        let total_count: Int?
        let max_page: Int?
    }
    
    // Generate a unique device identifier using multiple hardware characteristics
    private func getDeviceIdentifier() -> String {
        // Create a simpler but robust fingerprint
        let fingerprint = createSimpleFingerprint()
        
        // Hash the fingerprint to create a consistent UUID-like string
        let hashedFingerprint = hashString(fingerprint)
        
        // Format as UUID-like string for consistency
        return formatAsDeviceUUID(hashedFingerprint)
    }
    
    // Create a device fingerprint from hardware characteristics
    private func createSimpleFingerprint() -> String {
        var components: [String] = []
        
        // 1. Serial number (primary identifier)
        if let serialNumber = getMacSerialNumber() {
            components.append("SN:\(serialNumber)")
        }
        
        // 2. Hardware UUID from IOKit
        if let hardwareUUID = getHardwareUUID() {
            components.append("HW:\(hardwareUUID)")
        }
        
        // 3. Platform UUID 
        if let platformUUID = getPlatformUUID() {
            components.append("PF:\(platformUUID)")
        }
        
        // Join all components (should be very unique per machine)
        let fingerprint = components.joined(separator: "|")
        
        // Fallback to stored UUID if we can't get hardware info
        if fingerprint.isEmpty {
            return getStoredDeviceUUID()
        }
        
        return fingerprint
    }
    
    // Get hardware UUID from IOKit
    private func getHardwareUUID() -> String? {
        let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        if platformExpert == 0 { return nil }
        
        defer { IOObjectRelease(platformExpert) }
        
        if let uuid = IORegistryEntryCreateCFProperty(platformExpert, "IOPlatformUUID" as CFString, kCFAllocatorDefault, 0) {
            return (uuid.takeRetainedValue() as? String)?.uppercased()
        }
        return nil
    }
    
    // Get platform UUID (different from hardware UUID)
    private func getPlatformUUID() -> String? {
        let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        if platformExpert == 0 { return nil }
        
        defer { IOObjectRelease(platformExpert) }
        
        if let uuid = IORegistryEntryCreateCFProperty(platformExpert, "UUID" as CFString, kCFAllocatorDefault, 0) {
            return (uuid.takeRetainedValue() as? String)?.uppercased()
        }
        return nil
    }
    
    // Fallback: Get or create stored UUID
    private func getStoredDeviceUUID() -> String {
        let defaults = UserDefaults.standard
        if let storedId = defaults.string(forKey: "IoDeviceIdentifier") {
            return storedId
        }
        
        // Create and store a new UUID if none exists
        let newId = UUID().uuidString
        defaults.set(newId, forKey: "IoDeviceIdentifier")
        return newId
    }
    
    // Hash the fingerprint to create consistent identifier
    private func hashString(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let digest = SHA256.hash(data: inputData)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // Format hash as UUID-like string
    private func formatAsDeviceUUID(_ hash: String) -> String {
        // Take first 32 characters and format as UUID
        let truncated = String(hash.prefix(32))
        let uuid = "\(truncated.prefix(8))-\(truncated.dropFirst(8).prefix(4))-\(truncated.dropFirst(12).prefix(4))-\(truncated.dropFirst(16).prefix(4))-\(truncated.dropFirst(20).prefix(12))"
        return uuid.uppercased()
    }
    
    // Try to get the Mac serial number
    private func getMacSerialNumber() -> String? {
        let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        if platformExpert == 0 { return nil }
        
        defer { IOObjectRelease(platformExpert) }
        
        if let serialNumber = IORegistryEntryCreateCFProperty(platformExpert, "IOPlatformSerialNumber" as CFString, kCFAllocatorDefault, 0) {
            return (serialNumber.takeRetainedValue() as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return nil
    }
    
    // Generate a descriptive device label for Polar activation
    private func generateDeviceLabel() -> String {
        let hostname = Host.current().localizedName ?? "Mac"
        let username = NSUserName()
        
        // Get Mac model information
        let modelName = getMacModelName()
        
        // Get serial number for uniqueness
        if let serialNumber = getMacSerialNumber() {
            // Format: "Kentaro's MacBook Pro (ABC123)"
            return "\(username)'s \(modelName) (\(String(serialNumber.suffix(6))))"
        } else {
            // Fallback without serial
            return "\(username)'s \(modelName)"
        }
    }
    
    // Get Mac model name (MacBook Pro, iMac, etc.)
    private func getMacModelName() -> String {
        let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        if platformExpert == 0 { return "Mac" }
        
        defer { IOObjectRelease(platformExpert) }
        
        if let modelName = IORegistryEntryCreateCFProperty(platformExpert, "model" as CFString, kCFAllocatorDefault, 0) {
            if let modelString = (modelName.takeRetainedValue() as? Data)?.withUnsafeBytes({ bytes in
                return String(cString: bytes.bindMemory(to: CChar.self).baseAddress!)
            }) {
                // Convert model identifier to readable name
                return parseModelIdentifier(modelString)
            }
        }
        
        // Fallback to hostname if we can't get model
        return Host.current().localizedName ?? "Mac"
    }
    
    // Convert model identifier (like "Mac14,7") to readable name
    private func parseModelIdentifier(_ identifier: String) -> String {
        // Common Mac model mappings
        let modelMap: [String: String] = [
            "MacBookPro": "MacBook Pro",
            "MacBookAir": "MacBook Air", 
            "iMac": "iMac",
            "iMacPro": "iMac Pro",
            "MacPro": "Mac Pro",
            "Macmini": "Mac mini",
            "MacBook": "MacBook"
        ]
        
        // Extract base model from identifier
        for (key, value) in modelMap {
            if identifier.lowercased().contains(key.lowercased()) {
                return value
            }
        }
        
        // If it starts with "Mac" but not in our map, clean it up
        if identifier.hasPrefix("Mac") {
            return identifier.replacingOccurrences(of: "Mac", with: "Mac ")
        }
        
        return "Mac"
    }
    
    // Fetch product ids from server
    private func ensureProductIdsLoaded() async throws {
        if !monthlyProductId.isEmpty && !annualProductId.isEmpty { return }
        let url = URL(string: "\(proxyBaseURL)/api/polar/products")!
        StructuredLog.shared.log(cat: .license, evt: "fetch_product_ids_start")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            StructuredLog.shared.log(cat: .license, evt: "fetch_product_ids_http_error", lvl: .err, ["status": (response as? HTTPURLResponse)?.statusCode ?? -1])
            throw LicenseError.validationFailed
        }
        struct ProductIds: Decodable { let monthlyProductId: String; let annualProductId: String }
        let ids = try JSONDecoder().decode(ProductIds.self, from: data)
        self.monthlyProductId = ids.monthlyProductId
        self.annualProductId = ids.annualProductId
        StructuredLog.shared.log(cat: .license, evt: "fetch_product_ids_ok", ["monthly": ids.monthlyProductId.prefix(6), "annual": ids.annualProductId.prefix(6)])
    }

    // Determine which product ID to use based on license key validation
    private func determineProductPlan(for licenseKey: String) async throws -> (productId: String, planType: String) {
        var lastError: Error?
        let key = licenseKey.normalizedLicenseKey()
        StructuredLog.shared.log(cat: .license, evt: "determine_plan_start", ["key_prefix": String(key.prefix(8))])
        try await ensureProductIdsLoaded()
        
        // Try monthly first (with error handling)
        do {
            let result = try await validateLicenseForProduct(licenseKey: key, productId: monthlyProductId)
            if result.0 {  // isValid
                StructuredLog.shared.log(cat: .license, evt: "determine_plan_monthly_granted", ["requires_activation": result.1])
                return (productId: monthlyProductId, planType: "pro")
            }
        } catch {
            StructuredLog.shared.log(cat: .license, evt: "determine_plan_monthly_err", lvl: .err, ["error": String(describing: error)])
            lastError = error
        }
        
        // Try annual (with error handling)
        do {
            let result = try await validateLicenseForProduct(licenseKey: key, productId: annualProductId)
            if result.0 {  // isValid
                StructuredLog.shared.log(cat: .license, evt: "determine_plan_annual_granted", ["requires_activation": result.1])
                return (productId: annualProductId, planType: "pro")
            }
        } catch {
            StructuredLog.shared.log(cat: .license, evt: "determine_plan_annual_err", lvl: .err, ["error": String(describing: error)])
            lastError = error
        }
        
        // Both failed - throw the last error or validation failed
        StructuredLog.shared.log(cat: .license, evt: "determine_plan_failed", lvl: .err)
        throw lastError ?? LicenseError.validationFailed
    }
    // Validate license key for a specific product
    private func validateLicenseForProduct(licenseKey: String, productId: String) async throws -> (Bool, Bool, Int?) {
        let url = URL(string: "\(proxyBaseURL)/api/polar/license/validate-for-product")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let key = licenseKey.normalizedLicenseKey()
        let body: [String: Any] = [
            "licenseKey": key,
            "productId": productId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        StructuredLog.shared.log(cat: .license, evt: "validate_for_product_start", ["product": productId.prefix(6), "key_prefix": String(key.prefix(8))])
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = httpResponse as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorString = String(data: data, encoding: .utf8) {
                    StructuredLog.shared.log(cat: .license, evt: "validate_for_product_http_err", lvl: .err, ["status": httpResponse.statusCode, "body": String(errorString.prefix(200))])
                } else {
                    StructuredLog.shared.log(cat: .license, evt: "validate_for_product_http_err", lvl: .err, ["status": httpResponse.statusCode])
                }
                if (500...599).contains(httpResponse.statusCode) { throw LicenseError.serverError }
                throw LicenseError.validationFailed
            }
        }
        
        let validationResponse = try JSONDecoder().decode(LicenseValidationResponse.self, from: data)
        let isValid = validationResponse.status == "granted"
        let requiresActivation = (validationResponse.limit_activations ?? 0) > 0
        StructuredLog.shared.log(cat: .license, evt: "validate_for_product_ok", ["granted": isValid, "requires_activation": requiresActivation, "limit": validationResponse.limit_activations ?? -1])
        return (isValid, requiresActivation, validationResponse.limit_activations)
    }
    
    // Check if a license key requires activation (now supports both plans)
    func checkLicenseRequiresActivation(licenseKey: String) async throws -> Bool {
        let (productId, _) = try await determineProductPlan(for: licenseKey)
        let result = try await validateLicenseForProduct(licenseKey: licenseKey, productId: productId)
        return result.1  // requiresActivation
    }
    
    // Get license plan information (monthly vs annual)
    func getLicensePlanInfo(licenseKey: String) async throws -> Bool {
        let (productId, _) = try await determineProductPlan(for: licenseKey)
        let isAnnual = (productId == annualProductId)
        return isAnnual
    }
    
    // Activate a license key on this device
    func activateLicenseKey(_ key: String) async throws -> (activationId: String, activationsLimit: Int) {
        let normalizedKey = key.normalizedLicenseKey()
        let url = URL(string: "\(proxyBaseURL)/api/polar/license/activate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let deviceId = getDeviceIdentifier()
        let deviceLabel = generateDeviceLabel()
        
        let body: [String: Any] = [
            "licenseKey": normalizedKey,
            "label": deviceLabel,
            "meta": ["device_id": deviceId]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        StructuredLog.shared.log(cat: .license, evt: "activate_start", ["key_prefix": String(normalizedKey.prefix(8))])
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = httpResponse as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorString = String(data: data, encoding: .utf8) {
                    StructuredLog.shared.log(cat: .license, evt: "activate_http_err", lvl: .err, ["status": httpResponse.statusCode, "body": String(errorString.prefix(200))])
                    if errorString.contains("License key does not require activation") { throw LicenseError.activationNotRequired }
                    if errorString.contains("License key activation limit already reached") { throw LicenseError.activationLimitReached }
                } else {
                    StructuredLog.shared.log(cat: .license, evt: "activate_http_err", lvl: .err, ["status": httpResponse.statusCode])
                }
                if (500...599).contains(httpResponse.statusCode) { throw LicenseError.serverError }
                throw LicenseError.activationFailed
            }
        }
        
        let activationResult = try JSONDecoder().decode(ActivationResult.self, from: data)
        StructuredLog.shared.log(cat: .license, evt: "activate_ok", ["activation_id": activationResult.id.prefix(8), "limit": activationResult.license_key.limit_activations])
        return (activationId: activationResult.id, activationsLimit: activationResult.license_key.limit_activations)
    }
    // Validate a license key with an activation ID
    func validateLicenseKeyWithActivation(_ key: String, activationId: String) async throws -> Bool {
        let normalizedKey = key.normalizedLicenseKey()
        let (productId, _) = try await determineProductPlan(for: normalizedKey)
        let url = URL(string: "\(proxyBaseURL)/api/polar/license/validate-with-activation")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "licenseKey": normalizedKey,
            "productId": productId,
            "activationId": activationId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        StructuredLog.shared.log(cat: .license, evt: "validate_with_activation_start", ["key_prefix": String(normalizedKey.prefix(8)), "activation_id": activationId.prefix(8)])
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = httpResponse as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorString = String(data: data, encoding: .utf8) {
                    StructuredLog.shared.log(cat: .license, evt: "validate_with_activation_http_err", lvl: .err, ["status": httpResponse.statusCode, "body": String(errorString.prefix(200))])
                } else {
                    StructuredLog.shared.log(cat: .license, evt: "validate_with_activation_http_err", lvl: .err, ["status": httpResponse.statusCode])
                }
                if (500...599).contains(httpResponse.statusCode) { throw LicenseError.serverError }
                throw LicenseError.validationFailed
            }
        }
        
        let validationResponse = try JSONDecoder().decode(LicenseValidationResponse.self, from: data)
        let granted = validationResponse.status == "granted"
        StructuredLog.shared.log(cat: .license, evt: "validate_with_activation_ok", ["granted": granted])
        return granted
    }
    // MARK: - Subscription Details Fetching
    
    /// Fetch subscription details from Polar for a validated license key
    /// This gets the subscription expiration date and other details needed for Supabase sync
    func getSubscriptionDetails(licenseKey: String) async throws -> SubscriptionDetails? {
        let key = licenseKey.normalizedLicenseKey()
        StructuredLog.shared.log(cat: .license, evt: "sub_details_start", ["key_prefix": String(key.prefix(8))])
        let url = URL(string: "\(proxyBaseURL)/api/polar/subscription-details-by-license")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        try await ensureProductIdsLoaded()
        let body: [String: Any] = [
            "licenseKey": key
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = httpResponse as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorString = String(data: data, encoding: .utf8) {
                    StructuredLog.shared.log(cat: .license, evt: "sub_details_http_err", lvl: .err, ["status": httpResponse.statusCode, "body": String(errorString.prefix(200))])
                } else {
                    StructuredLog.shared.log(cat: .license, evt: "sub_details_http_err", lvl: .err, ["status": httpResponse.statusCode])
                }
                if (500...599).contains(httpResponse.statusCode) { throw LicenseError.serverError }
                throw LicenseError.validationFailed
            }
        }
        
        let subscriptionResponse = try JSONDecoder().decode(SubscriptionResponse.self, from: data)
        // Prefer an active subscription when available
        if let active = subscriptionResponse.items.first(where: { $0.status.lowercased() == "active" }) {
            StructuredLog.shared.log(cat: .license, evt: "sub_details_ok", ["sub_id": active.id.prefix(8), "expires": active.expirationDate?.timeIntervalSince1970 ?? 0])
            return active
        }
        
        // If there is no active subscription (e.g. canceled at period end),
        // pick the item whose period end is in the future or the latest period end.
        let sortedByEnd = subscriptionResponse.items.sorted { (a, b) in
            let aEnd = a.expirationDate ?? Date.distantPast
            let bEnd = b.expirationDate ?? Date.distantPast
            return aEnd > bEnd
        }
        if let candidate = sortedByEnd.first, let end = candidate.expirationDate, end > Date() {
            StructuredLog.shared.log(cat: .license, evt: "sub_details_ok_canceled_period", ["sub_id": candidate.id.prefix(8), "expires": end.timeIntervalSince1970])
            return candidate
        }
        
        StructuredLog.shared.log(cat: .license, evt: "sub_details_none")
        return nil
    }
    
    /// Get subscription expiration date for a license key (convenience method)
    func getSubscriptionExpirationDate(licenseKey: String) async throws -> Date? {
        let subscription = try await getSubscriptionDetails(licenseKey: licenseKey)
        return subscription?.expirationDate
    }

    // MARK: - Checkout → License resolution

    /// Resolve a license key from a Polar checkout id via our proxy
    /// The proxy should validate the checkout, locate or create the license,
    /// and return the canonical license key as a string.
    func resolveLicenseKeyFromCheckout(checkoutId: String) async throws -> String {
        let url = URL(string: "\(proxyBaseURL)/api/polar/checkout/resolve")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "checkoutId": checkoutId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        StructuredLog.shared.log(cat: .license, evt: "resolve_from_checkout_start", ["checkout_id": String(checkoutId.prefix(10))])
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        if let http = httpResponse as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            if let errorString = String(data: data, encoding: .utf8) {
                StructuredLog.shared.log(cat: .license, evt: "resolve_from_checkout_http_err", lvl: .err, ["status": http.statusCode, "body": String(errorString.prefix(200))])
            } else {
                StructuredLog.shared.log(cat: .license, evt: "resolve_from_checkout_http_err", lvl: .err, ["status": (http as? HTTPURLResponse)?.statusCode ?? -1])
            }
            if (500...599).contains(http.statusCode) { throw LicenseError.serverError }
            throw LicenseError.validationFailed
        }

        // Expected JSON: { "licenseKey": "XXXX-XXXX-XXXX-XXXX" }
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let key = json["licenseKey"] as? String, !key.isEmpty {
            StructuredLog.shared.log(cat: .license, evt: "resolve_from_checkout_ok", ["key_prefix": String(key.prefix(8))])
            return key
        }
        StructuredLog.shared.log(cat: .license, evt: "resolve_from_checkout_bad_body", lvl: .err)
        throw LicenseError.validationFailed
    }

    // MARK: - Customer Portal Session (Manage Subscription)

    /// Creates a Polar customer portal session via the proxy and returns the session URL
    /// If customerId is provided it is preferred over licenseKey
    func createCustomerPortalSession(licenseKey: String? = nil, customerId: String? = nil, returnUrl: String? = nil) async throws -> URL {
        let url = URL(string: "\(proxyBaseURL)/api/polar/customer-portal/session")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: Any] = [:]
        if let customerId = customerId, !customerId.isEmpty {
            body["customerId"] = customerId
        } else if let licenseKey = licenseKey, !licenseKey.isEmpty {
            body["licenseKey"] = licenseKey
        }
        if let returnUrl = returnUrl { body["returnUrl"] = returnUrl }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        if let http = httpResponse as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ [POLAR] Portal session failed: \(errorString)")
            }
            throw LicenseError.validationFailed
        }
        // Expected shape: { id, url, ... }
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let urlString = json["url"] as? String, let sessionURL = URL(string: urlString) {
            return sessionURL
        }
        throw LicenseError.validationFailed
    }
}

enum LicenseError: Error, LocalizedError {
    case activationFailed
    case validationFailed
    case activationLimitReached
    case activationNotRequired
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .activationFailed:
            return "Failed to activate license on this device."
        case .validationFailed:
            return "License validation failed."
        case .activationLimitReached:
            return "This license has reached its maximum number of activations."
        case .activationNotRequired:
            return "This license does not require activation."
        case .serverError:
            return "Server error while processing the request."
        }
    }
}
