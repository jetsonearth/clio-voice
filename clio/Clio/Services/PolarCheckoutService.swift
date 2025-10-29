import Foundation
import SwiftUI

class PolarCheckoutService: ObservableObject {
    // Production configuration
    private let baseURL = "https://api.polar.sh/v1"
    private let accessToken = "polar_oat_FVbypDzJ8Xz23OqA1XoONbc1Fgn35jPceOOw94OdDOV"
    private let organizationId = "20b9df96-882f-45a8-968b-2745946bd63f"
    
    // Product IDs
    private let proMonthlyProductId = "bea600bb-5259-46bd-99b3-73459e97c595"
    private let proYearlyProductId = "55dde27e-75b9-4586-82ec-15236cfd5cd4"
    private let offlineProductId = "e9e95593-b845-4027-8c03-be1e4f96063d"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func createProCheckout(isYearly: Bool) async throws -> String {
        let url = URL(string: "\(baseURL)/checkouts/")!
        
        let productId = isYearly ? proYearlyProductId : proMonthlyProductId
        
        let body: [String: Any] = [
            "products": [productId],
            "success_url": "https://www.cliovoice.com/?success=true&checkout_id={CHECKOUT_ID}",
            "cancel_url": "https://www.cliovoice.com/?cancel=true#pricing"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("🚀 Creating Polar checkout for \(isYearly ? "yearly" : "monthly") plan...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PolarError.invalidResponse
        }
        
        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("❌ Polar API Error: \(httpResponse.statusCode)")
            if let errorData = errorData {
                print("Error details: \(errorData)")
            }
            throw PolarError.requestFailed(httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let checkoutURL = json?["url"] as? String else {
            print("❌ Invalid response: missing checkout URL")
            throw PolarError.invalidResponse
        }
        
        print("✅ Checkout created successfully: \(checkoutURL)")
        return checkoutURL
    }
    
    func createOfflineCheckout() async throws -> String {
        let url = URL(string: "\(baseURL)/checkouts/")!
        
        let body: [String: Any] = [
            "products": [offlineProductId],
            "success_url": "https://www.cliovoice.com/?success=true&checkout_id={CHECKOUT_ID}",
            "cancel_url": "https://www.cliovoice.com/?cancel=true#pricing"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("🚀 Creating Polar checkout for offline plan...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PolarError.invalidResponse
        }
        
        if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
            let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("❌ Polar API Error: \(httpResponse.statusCode)")
            if let errorData = errorData {
                print("Error details: \(errorData)")
            }
            throw PolarError.requestFailed(httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let checkoutURL = json?["url"] as? String else {
            print("❌ Invalid response: missing checkout URL")
            throw PolarError.invalidResponse
        }
        
        print("✅ Offline checkout created successfully: \(checkoutURL)")
        return checkoutURL
    }
    
    @MainActor
    func openProCheckout(isYearly: Bool) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let checkoutURL = try await createProCheckout(isYearly: isYearly)
            
            if let url = URL(string: checkoutURL) {
                NSWorkspace.shared.open(url)
            }
        } catch {
            print("Failed to create Pro checkout: \(error)")
            errorMessage = "Failed to open checkout. Please try again."
        }
        
        isLoading = false
    }
    
    @MainActor
    func openOfflineCheckout() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let checkoutURL = try await createOfflineCheckout()
            
            if let url = URL(string: checkoutURL) {
                NSWorkspace.shared.open(url)
            }
        } catch {
            print("Failed to create Offline checkout: \(error)")
            errorMessage = "Failed to open checkout. Please try again."
        }
        
        isLoading = false
    }
}

enum PolarError: Error {
    case requestFailed(Int)
    case invalidResponse
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError:
            return "Network error occurred"
        }
    }
}