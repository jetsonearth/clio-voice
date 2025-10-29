import Foundation
import AppKit
import os

/// Supported browsers for current-URL extraction.
/// Kept source-compatible, but internals will call AppleScript via Process in a more defensive way.
enum BrowserType {
    case safari
    case arc
    case chrome
    case edge
    case firefox
    case brave
    case opera
    case vivaldi
    case orion
    case zen
    
    /// AppleScript resource filename (without extension) shipped under `Resources/`.
    var scriptName: String {
        switch self {
        case .safari: return "safariURL"
        case .arc: return "arcURL"
        case .chrome: return "chromeURL"
        case .edge: return "edgeURL"
        case .firefox: return "firefoxURL"
        case .brave: return "braveURL"
        case .opera: return "operaURL"
        case .vivaldi: return "vivaldiURL"
        case .orion: return "orionURL"
        case .zen: return "zenURL"
        }
    }
    
    var bundleIdentifier: String {
        switch self {
        case .safari: return "com.apple.Safari"
        case .arc: return "company.thebrowser.Browser"
        case .chrome: return "com.google.Chrome"
        case .edge: return "com.microsoft.edgemac"
        case .firefox: return "org.mozilla.firefox"
        case .brave: return "com.brave.Browser"
        case .opera: return "com.operasoftware.Opera"
        case .vivaldi: return "com.vivaldi.Vivaldi"
        case .orion: return "com.kagi.kagimacOS"
        case .zen: return "app.zen-browser.zen"
        }
    }
    
    var displayName: String {
        switch self {
        case .safari: return "Safari"
        case .arc: return "Arc"
        case .chrome: return "Google Chrome"
        case .edge: return "Microsoft Edge"
        case .firefox: return "Firefox"
        case .brave: return "Brave"
        case .opera: return "Opera"
        case .vivaldi: return "Vivaldi"
        case .orion: return "Orion"
        case .zen: return "Zen Browser"
        }
    }
    
    static var allCases: [BrowserType] {
        [.safari, .arc, .chrome, .edge, .brave, .opera, .vivaldi, .orion]
    }
    
    static var installedBrowsers: [BrowserType] {
        allCases.filter { browser in
            let workspace = NSWorkspace.shared
            return workspace.urlForApplication(withBundleIdentifier: browser.bundleIdentifier) != nil
        }
    }
    
    static func fromBundleIdentifier(_ bundleIdentifier: String) -> BrowserType? {
        allCases.first { $0.bundleIdentifier == bundleIdentifier }
    }
}

enum BrowserURLError: Error {
    case scriptNotFound
    case executionFailed
    case browserNotRunning
    case noActiveWindow
    case noActiveTab
}

final class BrowserURLService {
    static let shared = BrowserURLService()

    private let logger = Logger(subsystem: "com.jetsonai.clio", category: "BrowserURL")
    private init() {}

    /// Returns the active tab URL for a given browser by executing the bundled AppleScript.
    func getCurrentURL(from browser: BrowserType) async throws -> String {
        guard let scriptURL = Bundle.main.url(forResource: browser.scriptName, withExtension: "scpt") else {
            logger.error("script missing: \(browser.scriptName).scpt")
            throw BrowserURLError.scriptNotFound
        }

        guard isRunning(browser) else {
            logger.debug("browser not running: \(browser.displayName)")
            throw BrowserURLError.browserNotRunning
        }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = [scriptURL.path]

        let outPipe = Pipe()
        let errPipe = Pipe()
        task.standardOutput = outPipe
        task.standardError = errPipe

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            logger.error("failed to launch osascript: \(error.localizedDescription, privacy: .public)")
            throw BrowserURLError.executionFailed
        }

        let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()

        if let err = String(data: errData, encoding: .utf8), err.isEmpty == false {
            logger.error("osascript stderr: \(err, privacy: .public)")
        }

        guard let output = String(data: outData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), output.isEmpty == false else {
            logger.error("empty AppleScript output for \(browser.displayName)")
            throw BrowserURLError.noActiveTab
        }

        // Basic sanity check to return only plausible URLs
        if let url = URL(string: output), url.scheme?.isEmpty == false {
            logger.debug("url retrieved for \(browser.displayName): \(output, privacy: .public)")
            return output
        } else {
            logger.error("non-URL output: \(output, privacy: .public)")
            throw BrowserURLError.executionFailed
        }
    }

    func isRunning(_ browser: BrowserType) -> Bool {
        NSWorkspace.shared.runningApplications.contains { $0.bundleIdentifier == browser.bundleIdentifier }
    }
}