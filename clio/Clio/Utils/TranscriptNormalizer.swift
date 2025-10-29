import Foundation

// Lightweight multilingual numeric/text normalizer for transcripts.
enum TranscriptNormalizer {
    struct Options {
        // Do not emit 0ms/0s/0h by default; leave zero-valued time phrases unchanged
        var zeroGuardForTime: Bool = true
        // Do not treat articles (a/an) as 1 for time units ("a second" stays as-is)
        var forbidArticleOneForTime: Bool = true
        static let `default` = Options()
    }

    static func normalize(_ text: String, locale: Locale = .current, options: Options = .default) -> String {
        var s = normalizeDashesAndSpaces(text)
        s = unifyUnicodeDigitsAndSymbols(s)
        s = normalizeChinesePercent(s)
        s = normalizeEnglishPercent(s)
        s = normalizeLocalizedPercent(s)
        s = normalizeCurrency(s, locale: locale)
        s = normalizeTimeUnits(s, options: options)
        s = normalizeLengthUnits(s)
        s = normalizeMassUnits(s, options: options)
        return tidySpaces(s)
    }

    // MARK: - Units
    private static func normalizeTimeUnits(_ s: String, options: Options) -> String {
        var out = s
        // milliseconds
        out = replaceDigitsPlusUnit(out, unitWords: [
            "millisecond","milliseconds","毫秒","ms",
            "milliseconde","millisecondes",
            "Millisekunde","Millisekunden",
            "миллисекунда","миллисекунды","миллисекунд",
            "مللي ثانية","ملليثانية",
            "ミリ秒",
            "밀리초",
            "मिलीसेकंड"
        ], replacement: "ms", isTimeUnit: true, options: options)
        out = replaceWordsPlusUnit(out, unitWords: [
            "millisecond","milliseconds","毫秒",
            "milliseconde","millisecondes",
            "Millisekunde","Millisekunden",
            "миллисекунда","миллисекунды","миллисекунд",
            "مللي ثانية","ملليثانية",
            "ミリ秒",
            "밀리초",
            "मिलीसेकंड"
        ], replacement: "ms", isTimeUnit: true, options: options)

        // seconds (single-letter "s" only for digits)
        out = replaceDigitsPlusUnit(out, unitWords: [
            "second","seconds","秒","sec","s",
            "seconde","secondes",
            "Sekunde","Sekunden",
            "секунда","секунды","секунд",
            "ثانية","ثواني",
            "초",
            "सेकंड"
        ], replacement: "s", isTimeUnit: true, options: options, extraGuard: { _, unit in unit.lowercased() != "ms" })
        out = replaceWordsPlusUnit(out, unitWords: [
            "second","seconds","秒","sec",
            "seconde","secondes",
            "Sekunde","Sekunden",
            "секунда","секунды","секунд",
            "ثانية","ثواني",
            "초",
            "सेकंड"
        ], replacement: "s", isTimeUnit: true, options: options)

        // minutes
        out = replaceDigitsPlusUnit(out, unitWords: [
            "minute","minutes","分钟","分","min",
            "Minute","Minuten",
            "минута","минуты","минут",
            "دقيقة","دقائق",
            "분",
            "मिनट"
        ], replacement: "min", isTimeUnit: true, options: options)
        out = replaceWordsPlusUnit(out, unitWords: [
            "minute","minutes","分钟","分",
            "Minute","Minuten",
            "минута","минуты","минут",
            "دقيقة","دقائق",
            "분",
            "मिनट"
        ], replacement: "min", isTimeUnit: true, options: options)

        // hours (single-letter "h" only for digits)
        out = replaceDigitsPlusUnit(out, unitWords: [
            "hour","hours","小时","时","hr","h",
            "heure","heures",
            "Stunde","Stunden",
            "час","часа","часов",
            "ساعة","ساعات",
            "時間","時",
            "시간",
            "घंटा","घंटे"
        ], replacement: "h", isTimeUnit: true, options: options)
        out = replaceWordsPlusUnit(out, unitWords: [
            "hour","hours","小时","时","hr",
            "heure","heures",
            "Stunde","Stunden",
            "час","часа","часов",
            "ساعة","ساعات",
            "時間","時",
            "시간",
            "घंटा","घंटे"
        ], replacement: "h", isTimeUnit: true, options: options)
        return out
    }

    private static func normalizeLengthUnits(_ s: String) -> String {
        var out = s
        out = replaceNumberPlusUnit(out, unitWords: [
            "meter","meters","metre","metres","米",
            "mètre","mètres",
            "Meter",
            "метр","метра","метров",
            "متر",
            "メートル",
            "미터",
            "मीटर"
        ], replacement: "m")

        out = replaceNumberPlusUnit(out, unitWords: [
            "centimeter","centimeters","centimetre","centimetres","厘米","公分",
            "centimètre","centimètres",
            "Zentimeter",
            "сантиметр","сантиметра","сантиметров",
            "सنتيمتر",
            "センチメートル",
            "센티미터",
            "सेंटीमीटर"
        ], replacement: "cm")

        out = replaceNumberPlusUnit(out, unitWords: [
            "millimeter","millimeters","millimetre","millimetres","毫米",
            "millimètre","millimètres",
            "Millimeter",
            "миллиметр","миллиметра","миллиметров",
            "ملليمتر",
            "ミリメートル",
            "밀리미터",
            "मिलीमीटर"
        ], replacement: "mm")
        return out
    }

    private static func normalizeMassUnits(_ s: String, options: Options) -> String {
        var out = s
        // kilograms
        out = replaceDigitsPlusUnit(out, unitWords: [
            "kilogram","kilograms","kilo","kilos","公斤","千克","kg",
            "kilogramme","kilogrammes","kilo","kilos",
            "Kilogramm","Kilo","Kilos",
            "килограмм","килограмма","килограммов",
            "كيلوغرام","كيلو",
            "キログラム","キロ",
            "킬로그램","키로",
            "किलोग्राम"
        ], replacement: "kg", isTimeUnit: false, options: options)
        out = replaceWordsPlusUnit(out, unitWords: [
            "kilogram","kilograms","kilo","kilos","公斤","千克",
            "kilogramme","kilogrammes","kilo","kilos",
            "Kilogramm","Kilo","Kilos",
            "килограмм","килограмма","килограммов",
            "كيلوغرام","كيلو",
            "キログラム","キロ",
            "킬로그램","키로",
            "किलोग्राम"
        ], replacement: "kg", isTimeUnit: false, options: options)

        // grams (single-letter "g" only for digits)
        out = replaceDigitsPlusUnit(out, unitWords: [
            "gram","grams","克","g",
            "gramme","grammes",
            "Gramm",
            "грамм","грамма","граммов",
            "غرام",
            "グラム",
            "그램",
            "ग्राम"
        ], replacement: "g", isTimeUnit: false, options: options)
        out = replaceWordsPlusUnit(out, unitWords: [
            "gram","grams","克",
            "gramme","grammes",
            "Gramm",
            "грамм","грамма","граммов",
            "غرام",
            "グラム",
            "그램",
            "ग्राम"
        ], replacement: "g", isTimeUnit: false, options: options)
        return out
    }

    // MARK: - Percent
    private static func normalizeEnglishPercent(_ s: String) -> String {
        var out = s
        let pattern = #"(?:^|(?<=\s))([A-Za-z -]+|\d+(?:\.\d+)?)[\s%]*(percent|percentage)\b"#
        out = replacing(out, pattern: pattern) { m in
            let raw = m[1]
            let n = parseMixedNumber(raw) ?? Double(normalizeDigits(raw))
            guard let v = n else { return m[0] }
            return formatNumber(v) + "%"
        }
        let zhPattern = #"(?:^|(?<=\s))([零〇一二两三四五六七八九十百千万亿点0-9\.]+)[\s%]*(percent|percentage)\b"#
        out = replacing(out, pattern: zhPattern) { m in
            let raw = m[1]
            guard let v = chineseToDouble(raw) ?? Double(normalizeDigits(raw)) else { return m[0] }
            return formatNumber(v) + "%"
        }
        return out
    }

    private static func normalizeChinesePercent(_ s: String) -> String {
        var out = s
        let pattern = #"百分之([零〇一二两三四五六七八九十百千万亿点0-9\.]+)"#
        out = replacing(out, pattern: pattern) { m in
            let raw = m[1]
            guard let v = chineseToDouble(raw) ?? Double(normalizeDigits(raw)) else { return m[0] }
            return formatNumber(v) + "%"
        }
        return out
    }

    private static func normalizeLocalizedPercent(_ s: String) -> String {
        var out = s
        let percentTerms = [
            "pour cent", "pourcentage",
            "prozent", "prozentsatz",
            "процент", "процента", "процентов",
            "بالمئة", "في المئة",
            "パーセント", "퍼센트",
            "प्रतिशत"
        ]
        let termsRegex = percentTerms.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
        let pattern = #"(?:^|(?<=\s))([A-Za-z\p{L} \-]+|[0-9]+(?:\.[0-9]+)?)[\s%]*((?:(terms)))\b"#
            .replacingOccurrences(of: "(terms)", with: termsRegex)
        out = replacing(out, pattern: pattern) { m in
            let raw = m[1]
            let n = parseMixedNumber(raw) ?? Double(normalizeDigits(raw))
            guard let v = n else { return m[0] }
            return formatNumber(v) + "%"
        }
        return out
    }

    // MARK: - Currency
    private static func normalizeCurrency(_ s: String, locale: Locale) -> String {
        var out = s
        out = replacing(out, pattern: #"\$\s*([0-9][0-9,]*(?:\.\d+)?)"#) { m in
            "$" + normalizeDigits(m[1])
        }
        out = replacing(out, pattern: #"\bUSD\s*([0-9][0-9,]*(?:\.\d+)?)\b"#) { m in
            "$" + normalizeDigits(m[1])
        }
        out = replacing(out, pattern: #"(?:^|(?<=\s))([A-Za-z -]+)\s+dollars?\b"#) { m in
            let raw = m[1]
            guard let v = englishWordsToDouble(raw) else { return m[0] }
            return "$" + formatNumber(v, plainDigits: true)
        }
        return out
    }

    // MARK: - Generic number+unit
    private static func replaceNumberPlusUnit(
        _ s: String,
        unitWords: [String],
        replacement: String,
        extraGuard: ((String, String) -> Bool)? = nil
    ) -> String {
        var out = s
        let unitsRegex = unitWords.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
        let p1 = #"(?:^|(?<=\s))(\d+(?:\.\d+)?)[\s—–-]*((?:(units)))\b"#
            .replacingOccurrences(of: "(units)", with: unitsRegex)
        out = replacing(out, pattern: p1) { m in
            let num = normalizeDigits(m[1])
            let unit = m[2]
            if let g = extraGuard, !g(num, unit) { return m[0] }
            return num + replacement
        }
        let p2 = #"(?:^|(?<=\s))([A-Za-z\p{L} -]+)[\s—–-]+((?:(units)))\b"#
            .replacingOccurrences(of: "(units)", with: unitsRegex)
        out = replacing(out, pattern: p2) { m in
            let words = m[1]
            guard let val = englishWordsToDouble(words) ?? chineseToDouble(words) ?? koreanHangulToDouble(words) else { return m[0] }
            return formatNumber(val) + replacement
        }
        let p3 = #"([零〇一二两三四五六七八九十百千万亿點点0-9\.]+)((?:(units)))\b"#
            .replacingOccurrences(of: "(units)", with: unitsRegex)
        out = replacing(out, pattern: p3) { m in
            let raw = m[1]
            guard let val = chineseToDouble(raw) ?? Double(normalizeDigits(raw)) else { return m[0] }
            return formatNumber(val) + replacement
        }
        return out
    }

    // Digits + unit only (for ambiguous abbreviations like "s", "g", "h")
    private static func replaceDigitsPlusUnit(
        _ s: String,
        unitWords: [String],
        replacement: String,
        isTimeUnit: Bool,
        options: Options,
        extraGuard: ((String, String) -> Bool)? = nil
    ) -> String {
        var out = s
        let unitsRegex = unitWords.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
        let p1 = #"(?:^|(?<=\s))(\d+(?:\.\d+)?)[\s—–-]*((?:(units)))\b"#
            .replacingOccurrences(of: "(units)", with: unitsRegex)
        out = replacing(out, pattern: p1) { m in
            let num = normalizeDigits(m[1])
            let unit = m[2]
            if isTimeUnit, options.zeroGuardForTime, (Double(num) ?? 0.0) == 0.0 {
                return m[0]
            }
            if let g = extraGuard, !g(num, unit) { return m[0] }
            return num + replacement
        }
        return out
    }

    // Words/Chinese numerals + unit (exclude ambiguous one-letter abbreviations in unitWords)
    private static func replaceWordsPlusUnit(
        _ s: String,
        unitWords: [String],
        replacement: String,
        isTimeUnit: Bool,
        options: Options
    ) -> String {
        var out = s
        let unitsRegex = unitWords.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
        let p2 = #"(?:^|(?<=\s))([A-Za-z\p{L} -]+)[\s—–-]+((?:(units)))\b"#
            .replacingOccurrences(of: "(units)", with: unitsRegex)
        out = replacing(out, pattern: p2) { m in
            let words = m[1]
            // Optional guard: don't treat bare "a/an" as 1 for time units
            if isTimeUnit, options.forbidArticleOneForTime {
                let toks = words.lowercased().replacingOccurrences(of: "-", with: " ").split(whereSeparator: { !$0.isLetter }).map(String.init)
                if toks.count == 1, (toks[0] == "a" || toks[0] == "an") { return m[0] }
            }
            guard let val = englishWordsToDouble(words) ?? chineseToDouble(words) ?? koreanHangulToDouble(words) else { return m[0] }
            if isTimeUnit, options.zeroGuardForTime, val == 0 { return m[0] }
            return formatNumber(val) + replacement
        }
        let p3 = #"([零〇一二两三四五六七八九十百千万亿點点0-9\.]+)((?:(units)))\b"#
            .replacingOccurrences(of: "(units)", with: unitsRegex)
        out = replacing(out, pattern: p3) { m in
            let raw = m[1]
            guard let val = chineseToDouble(raw) ?? Double(normalizeDigits(raw)) else { return m[0] }
            if isTimeUnit, options.zeroGuardForTime, val == 0 { return m[0] }
            return formatNumber(val) + replacement
        }
        return out
    }

    // MARK: - Parsing
    private static func parseMixedNumber(_ s: String) -> Double? {
        if let d = Double(normalizeDigits(s)) { return d }
        if let d = englishWordsToDouble(s) { return d }
        if let d = chineseToDouble(s) { return d }
        if let d = koreanHangulToDouble(s) { return d }
        return nil
    }

    private static func englishWordsToDouble(_ s: String) -> Double? {
        let tokens = s
            .lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .split(whereSeparator: { !$0.isLetter })
            .map(String.init)
        if tokens.isEmpty { return nil }
        let small: [String:Int] = [
            "zero":0,"one":1,"two":2,"three":3,"four":4,"five":5,"six":6,"seven":7,"eight":8,"nine":9,
            "ten":10,"eleven":11,"twelve":12,"thirteen":13,"fourteen":14,"fifteen":15,"sixteen":16,"seventeen":17,"eighteen":18,"nineteen":19
        ]
        let tens: [String:Int] = [
            "twenty":20,"thirty":30,"forty":40,"fifty":50,"sixty":60,"seventy":70,"eighty":80,"ninety":90
        ]
        let scales: [String:Int] = ["hundred":100,"thousand":1000,"million":1_000_000,"billion":1_000_000_000]
        var total = 0
        var current = 0
        var sawAny = false
        var i = 0
        var invalid = false
        while i < tokens.count {
            let t = tokens[i]
            if t == "and" { i += 1; continue }
            if let v = small[t] { current += v; sawAny = true; i += 1; continue }
            if let v = tens[t] { current += v; sawAny = true; i += 1; continue }
            if t == "a" || t == "an" { current += 1; sawAny = true; i += 1; continue }
            if let scale = scales[t] {
                if scale == 100 { if current == 0 { current = 1 }; current *= scale }
                else { total += current * scale; current = 0 }
                sawAny = true; i += 1; continue
            }
            if t == "point" {
                var frac = 0.0; var place = 0.1; i += 1
                while i < tokens.count { let dTok = tokens[i]; if let d = small[dTok] { frac += Double(d) * place; place /= 10; i += 1 } else { invalid = true; break } }
                if !invalid { total += current; return Double(total) + frac } else { break }
            }
            invalid = true; break
        }
        if !sawAny || invalid { return nil }
        total += current
        return Double(total)
    }

    private static func chineseToDouble(_ s: String) -> Double? {
        let raw = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.isEmpty { return nil }
        if let d = Double(normalizeDigits(raw)) { return d }
        let numMap: [Character:Int] = ["零":0,"〇":0,"一":1,"二":2,"两":2,"三":3,"四":4,"五":5,"六":6,"七":7,"八":8,"九":9]
        let unitMap: [Character:Int] = ["十":10,"百":100,"千":1000]
        var integerPart = raw
        var decimalPart = ""
        if let r = raw.firstIndex(of: "点") { integerPart = String(raw[..<r]); decimalPart = String(raw[raw.index(after: r)...]) }
        func parseSection(_ t: String) -> Int {
            var section = 0; var number = 0
            for ch in t {
                if let u = unitMap[ch] { if number == 0 { number = 1 }; section += number * u; number = 0 }
                else if let n = numMap[ch] { number = n }
                else if let d = Int(String(ch)) { number = d }
            }
            return section + number
        }
        var total = 0; var temp = integerPart
        for (unitChar, unitVal) in [("兆",1_000_000_000_000),("億",100_000_000),("亿",100_000_000),("万",10_000)] {
            if let r = temp.firstIndex(of: Character(unitChar)) { let left = String(temp[..<r]); let right = String(temp[temp.index(after: r)...]); total += parseSection(left) * unitVal; temp = right }
        }
        total += parseSection(temp)
        var result = Double(total)
        if !decimalPart.isEmpty { var place = 0.1; for ch in decimalPart { let d = numMap[ch] ?? Int(String(ch)) ?? 0; result += Double(d) * place; place /= 10 } }
        return result
    }

    private static func koreanHangulToDouble(_ s: String) -> Double? {
        let raw = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.isEmpty { return nil }
        let hasHangul = raw.unicodeScalars.contains { (0x1100...0x11FF).contains(Int($0.value)) || (0x3130...0x318F).contains(Int($0.value)) || (0xAC00...0xD7AF).contains(Int($0.value)) }
        if !hasHangul { return nil }
        let digitMap: [Character:Int] = ["영":0,"공":0,"일":1,"이":2,"삼":3,"사":4,"오":5,"육":6,"칠":7,"팔":8,"구":9]
        let unitMap: [Character:Int] = ["십":10,"백":100,"천":1000]
        var integerPart = raw; var decimalPart = ""
        if let r = raw.firstIndex(of: "점") { integerPart = String(raw[..<r]); decimalPart = String(raw[raw.index(after: r)...]) }
        func parseSection(_ t: String) -> Int {
            var section = 0; var number = 0
            for ch in t {
                if let u = unitMap[ch] { if number == 0 { number = 1 }; section += number * u; number = 0 }
                else if let n = digitMap[ch] { number = n }
                else if let d = Int(String(ch)) { number = d }
            }
            return section + number
        }
        var total = 0; var temp = integerPart
        for (unitChar, unitVal) in [("조",1_000_000_000_000),("억",100_000_000),("만",10_000)] {
            if let r = temp.firstIndex(of: Character(unitChar)) { let left = String(temp[..<r]); let right = String(temp[temp.index(after: r)...]); total += parseSection(left) * unitVal; temp = right }
        }
        total += parseSection(temp)
        var result = Double(total)
        if !decimalPart.isEmpty { var place = 0.1; for ch in decimalPart { let d = digitMap[ch] ?? Int(String(ch)) ?? 0; result += Double(d) * place; place /= 10 } }
        return result
    }

    private static func unifyUnicodeDigitsAndSymbols(_ s: String) -> String {
        var out = ""; out.reserveCapacity(s.count)
        for scalar in s.unicodeScalars {
            let v = scalar.value; let mapped: UnicodeScalar
            switch v {
            case 0x0660...0x0669: mapped = UnicodeScalar(0x30 + (v - 0x0660))!
            case 0x06F0...0x06F9: mapped = UnicodeScalar(0x30 + (v - 0x06F0))!
            case 0x0966...0x096F: mapped = UnicodeScalar(0x30 + (v - 0x0966))!
            case 0xFF10...0xFF19: mapped = UnicodeScalar(0x30 + (v - 0xFF10))!
            case 0x066A: mapped = UnicodeScalar(0x25)!
            default: mapped = scalar
            }
            out.unicodeScalars.append(mapped)
        }
        return out
    }

    // MARK: - Utilities
    private static func normalizeDashesAndSpaces(_ s: String) -> String {
        s.replacingOccurrences(of: "\u{2014}", with: "-")
         .replacingOccurrences(of: "\u{2013}", with: "-")
         .replacingOccurrences(of: "\u{00A0}", with: " ")
    }

    private static func tidySpaces(_ s: String) -> String {
        let collapsed = s.replacingOccurrences(of: #"[ \t]{2,}"#, with: " ", options: .regularExpression)
        return collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizeDigits(_ s: String) -> String {
        s.replacingOccurrences(of: #"[,\s]"#, with: "", options: .regularExpression)
    }

    private static func formatNumber(_ d: Double, plainDigits: Bool = false) -> String {
        if plainDigits { return d.rounded() == d ? String(Int(d)) : String(d) }
        if d.rounded() == d { return String(Int(d)) }
        var str = String(d)
        while str.last == "0" { str.removeLast() }
        if str.last == "." { str.removeLast() }
        return str
    }

    private static func replacing(_ s: String, pattern: String, _ replacer: ([String]) -> String) -> String {
        guard let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return s }
        let ns = s as NSString
        var result = s; var offset = 0
        for match in re.matches(in: s, options: [], range: NSRange(location: 0, length: ns.length)) {
            var groups: [String] = []
            groups.append(ns.substring(with: match.range))
            for i in 1..<match.numberOfRanges { let r = match.range(at: i); groups.append(r.location != NSNotFound ? ns.substring(with: r) : "") }
            let replacement = replacer(groups)
            let r = NSRange(location: match.range.location + offset, length: match.range.length)
            if let rr = Range(r, in: result) { result.replaceSubrange(rr, with: replacement); offset += replacement.count - r.length }
        }
        return result
    }
}
