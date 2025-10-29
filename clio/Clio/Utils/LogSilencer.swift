import Foundation
import Darwin

// Global print() override to avoid changing all call sites.
// When silenced, it's a no-op; otherwise it defers to Swift.print.
public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    // In Release, stdout is redirected by LogSilencer; this check mainly gates Debug logging.
    if RuntimeConfig.shouldSilenceAllLogs { return }
    let message = items.map { String(describing: $0) }.joined(separator: separator)
    Swift.print(message, terminator: terminator)
}

/// Silences all app logs (print, stdout/stderr, and OSLog/Logger) for distributed builds.
/// Activate as early as possible in app startup.
enum LogSilencer {
    private static var activated: Bool = false

    static func activate() {
        #if DEBUG
        // In Debug, only activate when explicitly requested by runtime flag
        guard RuntimeConfig.shouldSilenceAllLogs, !activated else { return }
        #else
        // In Release, always activate for all users, regardless of defaults
        guard !activated else { return }
        #endif
        activated = true

        // 1) Silence unified logging (os_log / Logger)
        setenv("OS_ACTIVITY_MODE", "disable", 1)

        // 2) Redirect stdout and stderr to /dev/null to silence print() and any C-level writes
        freopen("/dev/null", "a", stdout)
        freopen("/dev/null", "a", stderr)
    }
}
