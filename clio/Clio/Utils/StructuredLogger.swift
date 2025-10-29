import Foundation
import SwiftUI

// MARK: - Structured Logging Core

public enum LogCat: String, CaseIterable {
    case audio, hotkey, transcript, stream, ui, license, sys
}

public enum LogLevel: String {
    case info = "INFO"
    case warn = "WARN"
    case err  = "ERR"
}

public struct LogEvent {
    public let tMs: Int
    public let sess: String
    public let rec: String?
    public let lvl: LogLevel
    public let cat: LogCat
    public let evt: String
    public let fields: [String: Any]

    func formatKV(_ key: String, _ value: Any) -> String {
        switch value {
        case let s as String:
            if s.contains(" ") || s.contains("=") { return "\(key)=\"\(s)\"" }
            return "\(key)=\(s)"
        case let b as Bool:
            return "\(key)=\(b)"
        case let i as Int:
            return "\(key)=\(i)"
        case let d as Double:
            return "\(key)=\(Int(d))" // keep short
        default:
            return "\(key)=\(String(describing: value))"
        }
    }

    public func line() -> String {
        var parts: [String] = []
        parts.append(String(format: "t=%06d", tMs))
        parts.append("sess=\(sess)")
        if let rec { parts.append("rec=\(rec)") }
        parts.append("lvl=\(lvl.rawValue)")
        parts.append("cat=\(cat.rawValue)")
        parts.append("evt=\(evt)")
        for (k, v) in fields {
            parts.append(formatKV(k, v))
        }
        return parts.joined(separator: " ")
    }
}

public final class StructuredLog: ObservableObject {
    public static let shared = StructuredLog()

    @Published public var isOverlayVisible: Bool = false
    @Published public var enabledCats: Set<LogCat> = Set(LogCat.allCases)
    @Published public var verbose: Bool = false
    @Published public var recentLines: [String] = []

    private let start = DispatchTime.now()
    private let sessId: String
    private var recId: String?

    // Ring buffer (O(1) append)
    private let maxLines = 1500
    private var buffer: [String?] = []
    private var writeIndex: Int = 0
    private var lineCount: Int = 0
    private let lock = NSLock()

    // Runtime toggles
    private let defaults = UserDefaults.standard
    private let bundleID = Bundle.main.bundleIdentifier ?? "com.cliovoice.clio"

    // Persistent file logging
    private var fileHandle: FileHandle?
    private var logFileURL: URL?
    private var bytesWritten: Int = 0
    private let maxLogFileBytes: Int = 5 * 1024 * 1024 // 5 MB per file

    private init() {
        self.sessId = StructuredLog.makeShortId()
        self.buffer = Array(repeating: nil, count: maxLines)
        loadToggles()
        // Auto-enable file capture when performance logging is enabled
        if UserDefaults.standard.bool(forKey: "DebugPerformanceLogging") || UserDefaults.standard.bool(forKey: "DebugStructuredFileLogging") {
            startFileCapture()
        }
    }

    // MARK: Public API
    public func setRecording(id: String?) {
        recId = id
    }

    public func log(cat: LogCat, evt: String, lvl: LogLevel = .info, _ fields: [String: Any] = [:]) {
        guard isCatEnabled(cat) else { return }
        let t = Int(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
        let ev = LogEvent(tMs: t, sess: sessId, rec: recId, lvl: lvl, cat: cat, evt: evt, fields: fields)
        let line = ev.line()
        append(line)
        if defaults.bool(forKey: "DebugConsoleMirrorStdout") {
            fputs(line + "\n", stdout)
        }
    }

    public func snapshotToClipboard() {
        let text = joinedLines()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    public func snapshotToFile() -> URL? {
        do {
            let dir = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("Logs/Clio", isDirectory: true)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd-HHmmss"
            let url = dir.appendingPathComponent("diag-\(formatter.string(from: Date())).log")
            try joinedLines().data(using: .utf8)?.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    public func toggleOverlay() {
        isOverlayVisible.toggle()
    }

    public func enableCat(_ cat: LogCat, _ enabled: Bool) {
        if enabled { enabledCats.insert(cat) } else { enabledCats.remove(cat) }
        defaults.set(enabled, forKey: keyFor(cat))
    }

    // MARK: Internals
    private func isCatEnabled(_ cat: LogCat) -> Bool {
        // Gate by master switch in production
        let master = defaults.bool(forKey: "DebugConsoleEnabled")
        if !master { return false }
        return enabledCats.contains(cat)
    }

    private func append(_ line: String) {
        lock.lock(); defer { lock.unlock() }
        // Write into ring buffer at writeIndex
        buffer[writeIndex] = line
        writeIndex = (writeIndex + 1) % maxLines
        if lineCount < maxLines { lineCount += 1 }

        // Also write to persistent file if enabled
        if let fh = fileHandle {
            if let data = (line + "\n").data(using: .utf8) {
                do {
                    try fh.write(contentsOf: data)
                    bytesWritten += data.count
                    if bytesWritten >= maxLogFileBytes {
                        rotateLogFile()
                    }
                } catch {
                    // If write fails, close file to avoid repeated errors
                    try? fh.close()
                    fileHandle = nil
                }
            }
        }

        // Prepare a lightweight recent tail (up to 150)
        let tailCount = min(150, lineCount)
        var tail: [String] = []
        tail.reserveCapacity(tailCount)
        // Start from the newest entries and collect backwards
        var idx = (writeIndex - 1 + maxLines) % maxLines
        for _ in 0..<tailCount {
            if let s = buffer[idx] { tail.append(s) }
            idx = (idx - 1 + maxLines) % maxLines
        }
        tail.reverse()

        // Only publish UI updates if the overlay is actually visible
        if isOverlayVisible {
            DispatchQueue.main.async {
                self.recentLines = tail
                self.objectWillChange.send()
            }
        }
    }

    private func joinedLines() -> String {
        lock.lock(); defer { lock.unlock() }
        var out: [String] = []
        out.reserveCapacity(lineCount)
        let startIdx = (writeIndex - lineCount + maxLines) % maxLines
        var idx = startIdx
        for _ in 0..<lineCount {
            if let s = buffer[idx] { out.append(s) }
            idx = (idx + 1) % maxLines
        }
        return out.joined(separator: "\n")
    }

    private func loadToggles() {
        if defaults.object(forKey: "DebugConsoleEnabled") == nil {
            // Default to enabled so the overlay appears on first use
            defaults.set(true, forKey: "DebugConsoleEnabled")
        }
        var cats = Set<LogCat>()
        for c in LogCat.allCases {
            if defaults.object(forKey: keyFor(c)) == nil {
                defaults.set(true, forKey: keyFor(c))
            }
            if defaults.bool(forKey: keyFor(c)) { cats.insert(c) }
        }
        self.enabledCats = cats
        self.verbose = defaults.bool(forKey: "DebugConsoleVerbose")
    }

    private func keyFor(_ c: LogCat) -> String { "DebugLog_\(c.rawValue)" }

    static func makeShortId() -> String {
        let chars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        return String((0..<3).map { _ in chars.randomElement()! })
    }

    // MARK: - Persistent file logging helpers
    private func logsDirectory() throws -> URL {
        let dir = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Logs/Clio", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func openNewLogFile() {
        do {
            let dir = try logsDirectory()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd-HHmmss"
            let url = dir.appendingPathComponent("session-\(formatter.string(from: Date()))-\(sessId).log")
            FileManager.default.createFile(atPath: url.path, contents: nil)
            let fh = try FileHandle(forWritingTo: url)
            fh.seekToEndOfFile()
            self.fileHandle = fh
            self.logFileURL = url
            self.bytesWritten = 0
            // Write a tiny header
            if let header = "# Clio structured log session sess=\(sessId) bundle=\(bundleID)\n".data(using: .utf8) {
                try? fh.write(contentsOf: header)
                bytesWritten += header.count
            }
        } catch {
            self.fileHandle = nil
            self.logFileURL = nil
        }
    }

    private func rotateLogFile() {
        // Close current handle and open a new one with an incremented suffix
        try? fileHandle?.close()
        fileHandle = nil
        openNewLogFile()
    }

    public func startFileCapture() {
        if fileHandle != nil { return }
        openNewLogFile()
    }

    public func stopFileCapture() {
        try? fileHandle?.close()
        fileHandle = nil
    }
}

// MARK: - SwiftUI Overlay

public struct LogOverlayView: View {
    @ObservedObject private var log = StructuredLog.shared
    @State private var filter: Set<LogCat> = Set(LogCat.allCases)
    @State private var lines: [String] = []

    public init() {}

    public var body: some View {
        VStack(spacing: 8) {
            // Controls
            HStack(spacing: 12) {
                Toggle("Audio", isOn: Binding(
                    get: { log.enabledCats.contains(.audio) },
                    set: { log.enableCat(.audio, $0) }
                ))
                Toggle("Hotkey", isOn: Binding(
                    get: { log.enabledCats.contains(.hotkey) },
                    set: { log.enableCat(.hotkey, $0) }
                ))
                Toggle("Stream", isOn: Binding(
                    get: { log.enabledCats.contains(.stream) },
                    set: { log.enableCat(.stream, $0) }
                ))
                Toggle("Transcript", isOn: Binding(
                    get: { log.enabledCats.contains(.transcript) },
                    set: { log.enableCat(.transcript, $0) }
                ))
                Toggle("UI", isOn: Binding(
                    get: { log.enabledCats.contains(.ui) },
                    set: { log.enableCat(.ui, $0) }
                ))
                Toggle("License", isOn: Binding(
                    get: { log.enabledCats.contains(.license) },
                    set: { log.enableCat(.license, $0) }
                ))
                Spacer()
                Button("Snapshot → Clipboard") { StructuredLog.shared.snapshotToClipboard() }
                Button("Save Snapshot") {
                    if let url = StructuredLog.shared.snapshotToFile() {
                        StructuredLog.shared.log(cat: .sys, evt: "snapshot_saved", lvl: .info, ["path": url.path])
                    }
                }
                Button("Close") { StructuredLog.shared.toggleOverlay() }
            }
            .toggleStyle(.switch)
            .font(.system(size: 11, weight: .regular))

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(renderedLines(), id: \.self) { line in
                            Text(verbatim: line)
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .background(.black.opacity(0.85))
                .onChange(of: log.isOverlayVisible) { _ in
                    // force refresh
                }
            }
            .frame(minHeight: 200)
        }
        .padding(8)
        .background(.black.opacity(0.85))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.2)))
        .cornerRadius(8)
        .padding(8)
    }

    private func renderedLines() -> [String] {
        return StructuredLog.shared.recentLines
    }
}
