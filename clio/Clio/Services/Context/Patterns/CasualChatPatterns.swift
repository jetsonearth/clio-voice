import Foundation

/// Configuration class containing casual chat and general conversation detection patterns
struct CasualChatPatterns {
    
    // MARK: - Window Title Patterns
    
    static let windowTitlePatterns = [
        // Messaging and chat applications
        ".*Messages.*",
        ".*iMessage.*",
        ".*WhatsApp.*",
        ".*Telegram.*",
        ".*Signal.*",
        ".*Slack.*",
        ".*Discord.*",
        ".*Microsoft Teams.*",
        ".*Skype.*",
        ".*Zoom.*",
        ".*FaceTime.*",
        
        // Social media platforms
        ".*Twitter.*",
        ".*X\\.com.*",
        ".*Facebook.*",
        ".*Instagram.*",
        ".*LinkedIn.*",
        ".*TikTok.*",
        ".*YouTube.*",
        ".*Reddit.*",
        
        // Note-taking and journaling
        ".*Notes.*",
        ".*Bear.*",
        ".*Notion.*",
        ".*Obsidian.*",
        ".*Day One.*",
        ".*Journey.*",
        ".*Diary.*",
        ".*Journal.*",
        
        // Text editors (for casual writing)
        ".*TextEdit.*",
        ".*Pages.*",
        ".*Word.*",
        ".*Google Docs.*",
        ".*Drafts.*",
        ".*Ulysses.*",
        ".*iA Writer.*",
        
        // Generic document patterns
        ".*Draft.*",
        ".*Note.*",
        ".*Memo.*",
        ".*Text.*",
        ".*Document.*",
        ".*Untitled.*",
        
        // Web browsers (for general browsing/social)
        ".*Safari.*",
        ".*Chrome.*",
        ".*Firefox.*",
        ".*Edge.*"
    ]
    
    // MARK: - Content Patterns
    
    static let contentPatterns = [
        // Casual conversation starters
        "(?i)\\bhey\\s+(there|everyone|folks|guys|all)\\b",
        "(?i)\\bhello\\s+(everyone|folks|guys|all|world)\\b",
        "(?i)\\bhi\\s+(everyone|folks|guys|all|there)\\b",
        "(?i)\\bwhat'?s\\s+up\\b",
        "(?i)\\bhow\\s+(are|is)\\s+(you|everyone|things|it\\s+going)\\b",
        "(?i)\\bhope\\s+(you|everyone)\\s+(are|is)\\s+(well|doing\\s+well|good)\\b",
        
        // Casual expressions and phrases
        "(?i)\\b(awesome|amazing|cool|sweet|nice|great|fantastic|wonderful)\\b",
        "(?i)\\b(yeah|yep|yup|nope|nah|sure|okay|alright)\\b",
        "(?i)\\b(lol|haha|hehe|omg|btw|fyi|imo|imho)\\b",
        "(?i)\\b(thanks|thx|thank\\s+you|appreciate\\s+it)\\b",
        "(?i)\\b(sorry|my\\s+bad|oops|whoops)\\b",
        
        // Social media and messaging indicators
        "(?i)\\b(post|tweet|message|chat|dm|reply|comment|share|like|follow)\\b",
        "(?i)\\b(hashtag|@\\w+|#\\w+)\\b",
        "(?i)\\b(facebook|twitter|instagram|tiktok|snapchat|linkedin)\\b",
        "(?i)\\b(story|stories|feed|timeline|notification)\\b",
        
        // Personal and informal topics
        "(?i)\\b(weekend|vacation|holiday|party|celebration|birthday)\\b",
        "(?i)\\b(family|friends|kids|children|parents|spouse|partner)\\b",
        "(?i)\\b(movie|film|show|series|book|music|song|game|hobby)\\b",
        "(?i)\\b(restaurant|food|cooking|recipe|dinner|lunch|breakfast)\\b",
        "(?i)\\b(weather|sunny|rainy|cloudy|cold|hot|warm)\\b",
        "(?i)\\b(travel|trip|vacation|visit|journey|adventure)\\b",
        
        // Casual conversation fillers
        "(?i)\\b(actually|basically|literally|totally|definitely|probably|maybe)\\b",
        "(?i)\\b(i\\s+think|i\\s+guess|i\\s+mean|you\\s+know|like|um|uh)\\b",
        "(?i)\\b(anyway|so|well|okay|right|sure|exactly)\\b",
        
        // Questions and interactions
        "(?i)\\bhow\\s+was\\s+(your|the)\\b",
        "(?i)\\bwhat\\s+do\\s+you\\s+think\\s+about\\b",
        "(?i)\\bhave\\s+you\\s+(seen|heard|tried|been)\\b",
        "(?i)\\bdid\\s+you\\s+(see|hear|watch|read|try)\\b",
        "(?i)\\bare\\s+you\\s+(going|planning|thinking)\\b",
        
        // Emotional expressions
        "(?i)\\b(excited|happy|sad|worried|stressed|tired|busy|bored)\\b",
        "(?i)\\b(love|hate|like|enjoy|prefer|favorite|best|worst)\\b",
        "(?i)\\b(feel|feeling|emotion|mood|vibe)\\b",
        
        // Time and casual scheduling
        "(?i)\\b(today|tomorrow|yesterday|this\\s+(week|month|year))\\b",
        "(?i)\\b(morning|afternoon|evening|night|later|soon|recently)\\b",
        "(?i)\\b(meet|hang\\s+out|catch\\s+up|get\\s+together)\\b",
        
        // General life topics
        "(?i)\\b(work|job|school|class|home|house|apartment)\\b",
        "(?i)\\b(shopping|buy|bought|purchase|store|mall)\\b",
        "(?i)\\b(health|exercise|gym|workout|doctor|hospital)\\b",
        "(?i)\\b(pet|dog|cat|animal|puppy|kitten)\\b",
        
        // Informal speech patterns
        "(?i)\\bgonna\\b",
        "(?i)\\bwanna\\b",
        "(?i)\\bkinda\\b",
        "(?i)\\bsorta\\b",
        "(?i)\\bgotta\\b",
        "(?i)\\bdon'?t\\s+know\\b",
        "(?i)\\bcan'?t\\s+wait\\b",
        
        // Casual content indicators
        "(?i)\\b(blog|vlog|podcast|channel|video|photo|picture|pic)\\b",
        "(?i)\\b(meme|funny|hilarious|joke|laugh|smile)\\b",
        "(?i)\\b(opinion|thought|idea|suggestion|advice|tip)\\b"
    ]
    
    // MARK: - Valid Chat Apps
    
    static let validChatApps = [
        // Messaging apps
        "com.apple.MobileSMS",                    // Messages
        "com.apple.iChat",                        // iChat/Messages
        "com.whatsapp.desktop",                   // WhatsApp
        "ru.keepcoder.Telegram",                  // Telegram
        "org.signal.Signal",                      // Signal
        "com.tinyspeck.slackmacgap",              // Slack
        "com.hnc.Discord",                        // Discord
        "com.microsoft.teams",                    // Microsoft Teams
        "com.skype.skype",                        // Skype
        "us.zoom.xos",                            // Zoom
        "com.apple.FaceTime",                     // FaceTime
        
        // Social media apps
        "com.twitter.twitter-mac",                // Twitter
        "com.facebook.archon",                    // Facebook
        "com.burbn.instagram",                    // Instagram
        "com.linkedin.LinkedIn",                  // LinkedIn
        "com.zhiliaoapp.musically",               // TikTok
        "com.google.android.youtube",             // YouTube
        "com.reddit.Reddit",                      // Reddit
        
        // Note-taking and writing apps
        "com.apple.Notes",                        // Apple Notes
        "com.bear-writer.BearNotesMarkdown",      // Bear
        "com.notion.id",                          // Notion
        "md.obsidian",                            // Obsidian
        "com.dayoneapp.dayone",                   // Day One
        "com.journey.mac",                        // Journey
        
        // Text editors and writing
        "com.apple.TextEdit",                     // TextEdit
        "com.apple.iWork.Pages",                  // Pages
        "com.microsoft.Word",                     // Microsoft Word
        "com.agiletortoise.Drafts-OSX",           // Drafts
        "com.ulyssesapp.mac",                     // Ulysses
        "pro.writer.mac",                         // iA Writer
        
        // Web browsers (for social/casual browsing)
        "com.apple.Safari",                       // Safari
        "com.google.Chrome",                      // Chrome
        "org.mozilla.firefox",                    // Firefox
        "com.microsoft.edgemac",                  // Edge
        "com.brave.Browser",                      // Brave
        "com.operasoftware.Opera",                // Opera
        
        // General purpose apps
        "com.apple.finder",                       // Finder (for file management conversations)
        "com.apple.systempreferences",            // System Preferences
        "com.apple.mail",                         // Mail (for casual emails)
        
        // Communication and meeting apps
        "com.webex.meetingmanager",               // WebEx
        "com.gotomeeting.GoToMeetingHD",          // GoToMeeting
        "com.ringcentral.glip",                   // RingCentral
        "com.teamviewer.TeamViewer",              // TeamViewer
    ]
    
    // MARK: - Configuration Constants
    
    /// Confidence calculation weights
    static let titleMatchWeight = 0.2          // Title matches are less reliable for casual chat
    static let contentMatchWeight = 0.02       // Content matches very light due to general nature
    static let maxContentConfidence = 0.3      // Cap content confidence contribution
    
    /// Detection thresholds
    static let minimumConfidence = 0.1         // Very low threshold since this is a fallback context
    static let highConfidenceThreshold = 0.4   // High confidence threshold
    static let minimumTitleConfidenceThreshold = 0.2  // Low title confidence threshold
}