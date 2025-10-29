import Foundation

public struct CleanerConfig {
    public var basePauseMs: Int = 180
    public var minPauseMs: Int = 120
    public var maxPauseMs: Int = 300
    public var stutterWindowMs: Int = 200
    public var enableZhRules: Bool = true
    public var enableEnRules: Bool = true
    public var mode: Mode = .auto
    public var dropLeadingSoftPunctuation: Bool = true
    public var dropTrailingSoftPunctuation: Bool = true

    public enum Mode {
        /// If tokens contain timestamps, use pause-aware analysis; otherwise fall back to text-only.
        case auto
        /// Use only text/commas/punctuation boundaries, ignore timestamps even if present.
        case textOnly
        /// Require timestamps to apply pause-aware rules; if missing, behave like textOnly.
        case timestamps
    }

    public init() {}
}







