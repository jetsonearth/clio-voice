//import Foundation
//
//// Simple CLI runner for DisfluencyCleaner
//// Usage examples:
////   TEXT-ONLY:
////     swift Clio/Clio/Services/Text/SpeechToken.swift \
////           Clio/Clio/Services/Text/CleanerConfig.swift \
////           Clio/Clio/Services/Text/DisfluencyCleaner.swift \
////           Clio/Clio/Services/Text/clean.swift \
////           --mode text --s "So, um, I think we should, you know, call her."
////
////   TIMESTAMPS (token:start-end pairs, space-separated):
////     swift Clio/Clio/Services/Text/SpeechToken.swift \
////           Clio/Clio/Services/Text/CleanerConfig.swift \
////           Clio/Clio/Services/Text/DisfluencyCleaner.swift \
////           Clio/Clio/Services/Text/clean.swift \
////           --mode timestamps \
////           --ts "We:0-80 should:90-160 ,:160-160 like:400-450 ,:450-450 start:520-600 now:610-680 .:680-680"
//
//// MARK: - Arg parsing
//
//struct Args {
//    var mode: String = "auto" // auto|text|timestamps
//    var s: String? = nil
//    var ts: String? = nil
//}
//
//func parseArgs() -> Args {
//    var a = Args()
//    var it = CommandLine.arguments.dropFirst().makeIterator()
//    while let k = it.next() {
//        switch k {
//        case "--mode": a.mode = it.next() ?? a.mode
//        case "--s": a.s = it.next()
//        case "--ts": a.ts = it.next()
//        default: break
//        }
//    }
//    return a
//}
//
//// MARK: - Tokenization helpers
//
//func tokenizeTextOnly(_ s: String) -> [SpeechToken] {
//    let punct: Set<Character> = [",", ".", "?", "!", "—", "-", "…", ":", ";"]
//    var out: [SpeechToken] = []
//    var current = ""
//    for ch in s {
//        if punct.contains(ch) {
//            if !current.isEmpty { out.append(.init(text: current)); current.removeAll() }
//            out.append(.init(text: String(ch)))
//        } else if ch.isWhitespace {
//            if !current.isEmpty { out.append(.init(text: current)); current.removeAll() }
//        } else {
//            current.append(ch)
//        }
//    }
//    if !current.isEmpty { out.append(.init(text: current)) }
//    return out
//}
//
//// Parse format: token:start-end with tokens separated by spaces
//func parseTimestampPairs(_ line: String) -> [SpeechToken] {
//    var tokens: [SpeechToken] = []
//    for part in line.split(separator: " ") {
//        let seg = String(part)
//        if let colon = seg.firstIndex(of: ":") {
//            let tok = String(seg[..<colon])
//            let rest = String(seg[seg.index(after: colon)...])
//            if let dash = rest.firstIndex(of: "-") {
//                let sStr = String(rest[..<dash])
//                let eStr = String(rest[rest.index(after: dash)...])
//                if let sMs = Int(sStr), let eMs = Int(eStr) {
//                    tokens.append(.init(text: tok, startMs: sMs, endMs: eMs))
//                    continue
//                }
//            }
//        }
//        // Fallback: plain token with no timestamps
//        tokens.append(.init(text: seg))
//    }
//    return tokens
//}
//
//// MARK: - Main
//
//let args = parseArgs()
//var cfg = CleanerConfig()
//switch args.mode.lowercased() {
//case "text": cfg.mode = .textOnly
//case "timestamps": cfg.mode = .timestamps
//default: cfg.mode = .auto
//}
//
//let cleaner = DisfluencyCleaner()
//
//let tokens: [SpeechToken]
//if let s = args.s {
//    tokens = tokenizeTextOnly(s)
//} else if let ts = args.ts {
//    tokens = parseTimestampPairs(ts)
//} else {
//    // Read from stdin as a single line (text-only)
//    if let line = readLine() {
//        tokens = tokenizeTextOnly(line)
//    } else {
//        fputs("No input provided. Use --s or --ts.\n", stderr)
//        exit(1)
//    }
//}
//
//let result = cleaner.clean(tokens, cfg: cfg)
//print(result)
//
//






