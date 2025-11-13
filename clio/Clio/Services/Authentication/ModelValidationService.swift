import Foundation
import CryptoKit

/// Service for server-side model validation and access control
@MainActor
class ModelValidationService: ObservableObject {
    static let shared = ModelValidationService()
    
    // Cache for model validation results (avoid repeated server calls)
    private var validationCache: [String: (result: Bool, timestamp: Date)] = [:]
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    // Known model specifications for validation
    private let modelSpecs: [String: ModelSpec] = [
        "ggml-small": ModelSpec(
            name: "ggml-small",
            tier: .free,
            expectedSizeBytes: 244_000_000, // ~244MB
            expectedSHA256: "expected_hash_here"
        ),
        "ggml-large-v3-turbo": ModelSpec(
            name: "ggml-large-v3-turbo",
            tier: .pro,
            expectedSizeBytes: 1_540_000_000, // ~1.54GB
            expectedSHA256: "expected_hash_here"
        ),
        // Note: Actual size for q5_0 is ~547–575 MiB depending on release.
        // We keep a mid-point with 10% tolerance to avoid false negatives.
        "ggml-large-v3-turbo-q5_0": ModelSpec(
            name: "ggml-large-v3-turbo-q5_0",
            tier: .pro,
            expectedSizeBytes: 574_000_000, // ~547–575 MiB
            expectedSHA256: "expected_hash_here"
        ),
        "ggml-large-v3-turbo-q8_0": ModelSpec(
            name: "ggml-large-v3-turbo-q8_0",
            tier: .pro,
            expectedSizeBytes: 874_188_075, // Exact file size
            expectedSHA256: "expected_hash_here"
        )
    ]
    
    private init() {}
    
    /// Validates if user can access a specific model with server-side verification
    func validateModelAccess(_ model: WhisperModel) async -> Bool {
        // Removed temporary email-based override that bypassed server validation
        
        // Check cache first
        if let cached = validationCache[model.name],
           Date().timeIntervalSince(cached.timestamp) < cacheTimeout {
            return cached.result
        }
        
        // NEW: Local validation based on user subscription tier – no network call
        let result = performLocalValidation(model)
        
        // Cache result
        validationCache[model.name] = (result: result, timestamp: Date())
        
        return result
    }
    
    /// Validates model file integrity against known specifications
    func validateModelFile(_ model: WhisperModel, at path: URL) async -> Bool {
        // If we don't have a known specification for this model yet, treat it as valid but log a warning.
        guard let spec = modelSpecs[model.name] else {
            print("⚠️ [MODEL] Unknown model specification: \(model.name) – skipping strict integrity checks")
            // Basic existence check only
            return FileManager.default.fileExists(atPath: path.path)
        }
        
        // Check file exists
        guard FileManager.default.fileExists(atPath: path.path) else {
            print("❌ [MODEL] Model file not found: \(path.path)")
            return false
        }
        
        // Check file size (quick validation)
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            
            // Allow 10% variance in file size
            let tolerance = Double(spec.expectedSizeBytes) * 0.1
            let sizeRange = (spec.expectedSizeBytes - Int64(tolerance))...(spec.expectedSizeBytes + Int64(tolerance))
            
            if !sizeRange.contains(fileSize) {
                print("❌ [MODEL] Model file size mismatch: \(fileSize) bytes, expected: \(spec.expectedSizeBytes) bytes")
                return false
            }
        } catch {
            print("❌ [MODEL] Failed to get file attributes: \(error)")
            return false
        }
        
        // TODO: Add SHA256 hash validation for stronger integrity checking
        // This would require computing the hash of the entire file
        
        return true
    }
    
    // MARK: - Local Validation (no network)
    private func performLocalValidation(_ model: WhisperModel) -> Bool {
        // 1. Free model (Clio Flash) is always available
        if model.name == "ggml-small" {
            return true
        }
        
        // SECURITY: Cloud models (like Soniox) require pro/trial subscription
        let isCloudModel = model.name.contains("soniox")
        
        // Community build: heuristics downgraded to always allow usage.
        if isCloudModel {
            print("ℹ️ [MODEL] Allowing cloud model \(model.name) in community build.")
        }
        return true
    }
    
    /// Clears validation cache (useful for testing or subscription changes)
    func clearCache() {
        validationCache.removeAll()
    }
}

// MARK: - Supporting Types

struct ModelSpec {
    let name: String
    let tier: ModelTier
    let expectedSizeBytes: Int64
    let expectedSHA256: String
}

enum ModelTier {
    case free
    case pro
    case ultra
}

enum ModelValidationError: Error {
    case invalidResponse
    case serverError(Int)
    case networkError
    case invalidModel
}
