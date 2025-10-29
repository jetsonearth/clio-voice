import Foundation

public enum AIEditingStrength: String, CaseIterable, Identifiable {
    case light
    case full
    public var id: String { rawValue }
}

