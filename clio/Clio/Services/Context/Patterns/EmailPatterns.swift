import Foundation

/// Configuration class containing all email detection patterns
struct EmailPatterns {
    
    // MARK: - Window Title Patterns
    
    static let windowTitlePatterns = [
        // Gmail - specific composition patterns
        "Gmail - Compose",
        "Compose - Gmail", 
        "Gmail - .*@.*\\.(com|org|net|edu)",
        ".*@.*\\.(com|org|net|edu) - Gmail",
        "Inbox \\(.*\\) - Gmail",
        "Gmail - Inbox",
        
        // Outlook - specific patterns
        "Outlook - Compose",
        "Compose - Outlook",
        "Microsoft Outlook - .*Message",
        ".*Message - Microsoft Outlook",
        "Outlook - Mail",
        "Mail - Outlook",
        
        // Apple Mail - specific patterns
        "Mail - New Message",
        "New Message - Mail",
        "Mail - Compose",
        "Compose - Mail",
        "Message \\(.*\\) - Mail",
        "^Mail$", // Exact match for Apple Mail app
        
        // Thunderbird - specific patterns
        "Thunderbird - Compose",
        "Compose - Thunderbird",
        "Mozilla Thunderbird - .*Message",
        "Write: .* - Thunderbird",
        
        // Yahoo Mail - specific patterns
        "Yahoo Mail - Compose",
        "Compose - Yahoo Mail",
        "Yahoo! Mail - .*",
        
        // ProtonMail - specific patterns
        "ProtonMail - Compose",
        "Compose - ProtonMail",
        "ProtonMail - New message",
        
        // Chinese email providers - specific patterns
        "QQ邮箱 - 写邮件",
        "网易邮箱 - 写邮件", 
        "126邮箱 - 写邮件",
        "163邮箱 - 写邮件",
        "新浪邮箱 - 写邮件",
        "搜狐邮箱 - 写邮件",
        "阿里云邮箱 - 写邮件",
        "腾讯邮箱 - 写邮件",
        "写邮件 - QQ邮箱",
        "写邮件 - 网易邮箱",
        "写邮件 - 126邮箱",
        "写邮件 - 163邮箱",
        
        // Japanese email providers - specific patterns
        "Yahoo!メール - 作成",
        "作成 - Yahoo!メール",
        "ドコモメール - 作成",
        "ソフトバンクメール - 作成",
        "auメール - 作成",
        "メール作成 - .*",
        "新しいメッセージ - .*",
        
        // Korean email providers - specific patterns
        "네이버 메일 - 쓰기",
        "다음 메일 - 쓰기", 
        "한메일 - 쓰기",
        "카카오 메일 - 쓰기",
        "Naver Mail - Compose",
        "Daum Mail - Compose",
        "Kakao Mail - Compose",
        "메일 쓰기 - .*",
        
        // Taiwanese email providers - specific patterns
        "PChome信箱 - 寫信",
        "Yahoo信箱 - 寫信",
        "HiNet信箱 - 寫信",
        "中華電信信箱 - 寫信",
        "寫信 - .*信箱",
        "新信件 - .*",
        
        // Web-based email patterns (when in browser)
        ".*mail\\.google\\.com.*Compose.*",
        ".*outlook\\.live\\.com.*Compose.*",
        ".*mail\\.yahoo\\.com.*Compose.*",
        ".*protonmail\\.com.*Compose.*"
    ]
    
    // MARK: - Content Patterns
    
    static let contentPatterns = [
        // Email composition keywords
        "(?i)\\bcompose\\b",
        "(?i)\\bdraft\\b",
        "(?i)\\breply\\b",
        "(?i)\\bforward\\b",
        "(?i)\\binbox\\b",
        "(?i)\\bsubject:\\b",
        "(?i)\\bto:\\b",
        "(?i)\\bfrom:\\b",
        "(?i)\\bcc:\\b",
        "(?i)\\bbcc:\\b",
        
        // Email greetings/closings
        "(?i)\\bdear\\s+\\w+",
        "(?i)\\bhello\\s+\\w+",
        "(?i)\\bhi\\s+\\w+",
        "(?i)\\bbest\\s+regards\\b",
        "(?i)\\bsincerely\\b",
        "(?i)\\byours\\s+truly\\b",
        "(?i)\\bthank\\s+you\\b",
        "(?i)\\bbest\\b,",
        "(?i)\\bcheers\\b,",
        
        // Email UI elements
        "(?i)\\bsend\\s+message\\b",
        "(?i)\\bsend\\s+email\\b",
        "(?i)\\battachment\\b",
        "(?i)\\bfile\\s+attachment\\b",
        
        // Global email service keywords
        "(?i)\\bgoogle\\b.*\\bmail\\b",
        "(?i)\\bmail\\b.*\\bgoogle\\b",
        "(?i)\\boutlook\\b",
        "(?i)\\byahoo\\b.*\\bmail\\b",
        "(?i)\\bmail\\b.*\\byahoo\\b",
        "(?i)\\bproton\\b.*\\bmail\\b",
        "(?i)\\bwebmail\\b",
        
        // Chinese email provider keywords
        "(?i)\\bqq\\b.*\\b(mail|邮箱|邮件)\\b",
        "(?i)\\b(mail|邮箱|邮件)\\b.*\\bqq\\b",
        "(?i)\\b126\\b",
        "(?i)\\b163\\b",
        "(?i)\\b网易\\b",
        "(?i)\\bnetease\\b",
        "(?i)\\b新浪\\b",
        "(?i)\\bsina\\b",
        "(?i)\\b搜狐\\b", 
        "(?i)\\bsohu\\b",
        "(?i)\\b阿里云\\b",
        "(?i)\\baliyun\\b",
        "(?i)\\b腾讯\\b",
        "(?i)\\btencent\\b",
        
        // Japanese email provider keywords
        "(?i)\\bヤフー\\b",
        "(?i)\\byahoo\\b.*\\bjp\\b",
        "(?i)\\bドコモ\\b",
        "(?i)\\bdocomo\\b",
        "(?i)\\bソフトバンク\\b",
        "(?i)\\bsoftbank\\b",
        "(?i)\\bau\\b.*\\b(mail|メール)\\b",
        "(?i)\\bezweb\\b",
        
        // Korean email provider keywords
        "(?i)\\b네이버\\b",
        "(?i)\\bnaver\\b",
        "(?i)\\b다음\\b",
        "(?i)\\bdaum\\b",
        "(?i)\\b한메일\\b",
        "(?i)\\bhanmail\\b",  
        "(?i)\\b카카오\\b",
        "(?i)\\bkakao\\b",
        
        // Taiwanese email provider keywords
        "(?i)\\bpchome\\b",
        "(?i)\\bhinet\\b",
        "(?i)\\b中華電信\\b",
        "(?i)\\bseednet\\b",
        "(?i)\\b台灣\\b.*\\b(mail|信箱)\\b",
        
        // Additional fuzzy email keywords
        "(?i)\\b(send|sent|receive|received)\\b.*\\b(message|mail|email)\\b",
        "(?i)\\b(message|mail|email)\\b.*\\b(send|sent|receive|received)\\b",
        "(?i)\\b(write|writing|compose|composing)\\b.*\\b(message|mail|email)\\b",
        "(?i)\\b(new|create)\\b.*\\b(message|mail|email)\\b",
        "(?i)\\bemail\\s*(client|service|provider)\\b",
        "(?i)\\bmail\\s*(client|service|provider|box|system)\\b",
        
        // Asian language email terms
        "(?i)\\b(发送|接收|收到|写|撰写)\\b.*\\b(邮件|邮箱|信件)\\b",
        "(?i)\\b(邮件|邮箱|信件)\\b.*\\b(发送|接收|收到|写|撰写)\\b",
        "(?i)\\b(送信|受信|メール作成|新しいメール)\\b",
        "(?i)\\b(보내기|받기|메일작성|새메일)\\b",
        "(?i)\\b(寄信|收信|新信件|電子信箱)\\b",
        
        // Generic email patterns with domains
        "@.*\\.(com|org|net|edu|gov|cn|jp|kr|tw)",
        
        // Email action keywords
        "(?i)\\b(login|sign\\s*in|log\\s*in)\\b.*\\b(mail|email|webmail)\\b",
        "(?i)\\b(mail|email|webmail)\\b.*\\b(login|sign\\s*in|log\\s*in)\\b"
    ]
    
    // MARK: - Exclusion Patterns
    
    /// Development/debugging exclusion patterns - these prevent false positives
    static let exclusionPatterns = [
        "(?i).*terminal.*",
        "(?i).*xcode.*",
        "(?i).*visual studio code.*",
        "(?i).*vs code.*", 
        "(?i).*code.*detection.*",
        "(?i).*email.*detection.*", // Specifically for development contexts
        "(?i).*debug.*email.*",
        "(?i).*test.*email.*",
        "(?i).*develop.*email.*",
        "(?i).*build.*email.*",
        "(?i).*git.*email.*",
        "(?i).*github.*email.*",
        "(?i).*programming.*",
        "(?i).*coding.*",
        "(?i).*development.*",
        "(?i).*localhost.*",
        "(?i).*127\\.0\\.0\\.1.*",
        
        // AI chat platforms - these are not email
        "(?i)^chatgpt$",
        "(?i)^claude$",
        "(?i).*chatgpt.*",
        "(?i).*claude.*",
        "(?i).*openai.*",
        "(?i).*anthropic.*",
        "(?i).*gemini.*",
        "(?i).*bard.*",
        "(?i).*copilot.*",
        "(?i).*ai.*chat.*",
        "(?i).*chat.*ai.*"
    ]
    
    // MARK: - Valid Email Apps
    
    static let validEmailApps = [
        "com.apple.mail",
        "com.microsoft.outlook", 
        "com.google.Chrome", // Web email - FIXED: Chrome bundle ID is capitalized
        "com.apple.safari", // Web email
        "org.mozilla.firefox", // Web email
        "com.microsoft.edgemac", // Web email
        "com.operasoftware.opera", // Web email
        "com.brave.browser", // Web email
        "org.mozilla.thunderbird",
        "ch.protonmail.desktop",
        "com.tencent.qq",
        "com.netease.mail",
        "com.yahoo.mail"
    ]
    
    // MARK: - Configuration Constants
    
    /// Confidence calculation weights
    static let titleMatchWeight = 0.5      // Title matches are most reliable
    static let contentMatchWeight = 0.05   // Content matches less reliable
    static let maxContentConfidence = 0.3  // Cap content confidence contribution
    
    /// Detection thresholds
    static let minimumConfidence = 0.4
    static let highConfidenceThreshold = 0.7
    static let minimumTitleConfidenceThreshold = 0.8
}