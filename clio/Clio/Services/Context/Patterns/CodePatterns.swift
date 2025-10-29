import Foundation

/// Configuration class containing all code/development detection patterns
struct CodePatterns {
    
    // MARK: - Window Title Patterns
    
    static let windowTitlePatterns = [
        // VS Code
        ".*Visual Studio Code.*",
        ".*\\.py.*VS Code.*",
        ".*\\.js.*VS Code.*",
        ".*\\.swift.*VS Code.*",
        ".*\\.tsx?.*VS Code.*",
        ".*\\.java.*VS Code.*",
        ".*\\.cpp.*VS Code.*",
        ".*\\.c.*VS Code.*",
        ".*\\.h.*VS Code.*",
        ".*\\.cs.*VS Code.*",
        ".*\\.go.*VS Code.*",
        ".*\\.rs.*VS Code.*",
        ".*\\.php.*VS Code.*",
        ".*\\.rb.*VS Code.*",
        ".*\\.kt.*VS Code.*",
        ".*\\.scala.*VS Code.*",
        
        // Cursor (AI-powered editor)
        ".*Cursor.*",
        ".*\\.py.*Cursor.*",
        ".*\\.js.*Cursor.*",
        ".*\\.swift.*Cursor.*",
        ".*\\.tsx?.*Cursor.*",
        
        // Terminal/CLI
        "^Terminal.*",
        "^iTerm.*",
        ".*zsh.*",
        ".*bash.*",
        ".*fish.*",
        ".*powershell.*",
        ".*cmd.*",
        
        // Xcode
        ".*Xcode.*",
        ".*\\.xcodeproj.*",
        ".*\\.swift.*Xcode.*",
        ".*\\.m.*Xcode.*",
        ".*\\.h.*Xcode.*",
        
        // IntelliJ family
        ".*IntelliJ IDEA.*",
        ".*PyCharm.*",
        ".*WebStorm.*",
        ".*PhpStorm.*",
        ".*RubyMine.*",
        ".*CLion.*",
        ".*GoLand.*",
        ".*Rider.*",
        ".*DataGrip.*",
        ".*Android Studio.*",
        
        // Other IDEs/Editors
        ".*Sublime Text.*",
        ".*Atom.*",
        ".*Vim.*",
        ".*Emacs.*",
        ".*Nova.*",
        ".*TextMate.*",
        ".*BBEdit.*",
        ".*Code.*Editor.*",
        
        // GitHub and Git interfaces
        ".*GitHub Desktop.*",
        ".*GitKraken.*",
        ".*Sourcetree.*",
        ".*Tower.*",
        ".*Fork.*",
        ".*git.*",
        
        // Browser developer tools
        ".*Developer Tools.*",
        ".*DevTools.*",
        ".*Web Inspector.*",
        ".*Console.*",
        
        // Package managers and build tools
        ".*npm.*",
        ".*yarn.*",
        ".*pip.*",
        ".*conda.*",
        ".*brew.*",
        ".*cargo.*",
        ".*gradle.*",
        ".*maven.*",
        ".*cmake.*",
        ".*make.*",
        
        // File patterns that suggest coding
        ".*\\.(py|js|ts|jsx|tsx|swift|java|cpp|c|h|cs|go|rs|php|rb|kt|scala|sh|yml|yaml|json|xml|sql|md).*"
    ]
    

    
    // MARK: - Valid Code Apps
    
    static let validCodeApps = [
        // Code editors and IDEs
        "com.microsoft.VSCode",                    // Visual Studio Code
        "com.todesktop.230313mzl4w4u92",          // Cursor
        "com.apple.dt.Xcode",                     // Xcode
        "com.jetbrains.intellij",                 // IntelliJ IDEA
        "com.jetbrains.pycharm",                  // PyCharm
        "com.jetbrains.webstorm",                 // WebStorm
        "com.jetbrains.phpstorm",                 // PhpStorm
        "com.jetbrains.rubymine",                 // RubyMine
        "com.jetbrains.clion",                    // CLion
        "com.jetbrains.goland",                   // GoLand
        "com.jetbrains.rider",                    // Rider
        "com.jetbrains.datagrip",                 // DataGrip
        "com.jetbrains.appcode",                  // AppCode
        "com.google.android.studio",              // Android Studio
        "com.sublimetext.4",                      // Sublime Text
        "com.github.atom",                        // Atom
        "com.panic.nova",                         // Nova
        "com.macromates.textmate",                // TextMate
        "com.barebones.bbedit",                   // BBEdit
        
        // Terminal applications
        "com.apple.Terminal",                     // Terminal
        "com.googlecode.iterm2",                  // iTerm2
        "com.panic.transmit5",                    // Transmit
        "com.hyper.hyper",                        // Hyper
        "com.github.wez.wezterm",                 // WezTerm
        
        // Git clients
        "com.github.GitHubDesktop",               // GitHub Desktop
        "com.axosoft.gitkraken",                  // GitKraken
        "com.torusknot.SourceTreeNotMAS",         // Sourcetree
        "com.fournova.Tower3",                    // Tower
        "com.DanPristupov.Fork",                  // Fork
        
        // Database tools
        "com.sequelpro.SequelPro",                // Sequel Pro
        "com.tinyapp.TablePlus",                  // TablePlus
        "org.dbeaver.DBeaver",                    // DBeaver
        "org.postgresql.pgAdmin4",                // pgAdmin
        "com.mongodb.compass",                    // MongoDB Compass
        
        // API tools
        "com.postmanlabs.mac",                    // Postman
        "com.insomnia.app",                       // Insomnia
        "com.luckymarmot.Paw",                    // Paw
        "com.httpie.desktop",                     // HTTPie Desktop
        
        // Container and deployment
        "com.docker.docker",                      // Docker Desktop
        "com.jetbrains.toolbox",                  // JetBrains Toolbox
        
        // Browsers (for web development)
        "com.google.Chrome",                      // Chrome DevTools
        "com.apple.Safari",                       // Safari Web Inspector
        "org.mozilla.firefox",                    // Firefox Developer Tools
        "com.microsoft.edgemac",                  // Edge DevTools
        "com.brave.Browser",                      // Brave DevTools
        
        // Design tools (often used by developers)
        "com.figma.Desktop",                      // Figma
        "com.bohemiancoding.sketch3",             // Sketch
        "com.adobe.xd",                           // Adobe XD
        
        // Utility and system tools
        "com.apple.ActivityMonitor",              // Activity Monitor
        "com.apple.Console",                      // Console.app
        "com.apple.SystemPreferences",            // System Preferences (for dev settings)
        
        // Note-taking (often used for code notes)
        "com.notion.id",                          // Notion
        "md.obsidian",                            // Obsidian
        "com.apple.Notes",                        // Apple Notes
        "com.bear-writer.BearNotesMarkdown",      // Bear
        
        // Communication (for development teams)
        "com.tinyspeck.slackmacgap",              // Slack
        "com.hnc.Discord",                        // Discord
        "us.zoom.xos",                            // Zoom (for pair programming)
        "com.microsoft.teams",                    // Microsoft Teams
    ]
    
    // MARK: - Configuration Constants
    
    /// Confidence calculation weights
    static let titleMatchWeight = 0.4          // Title matches are reliable
    
    /// Detection thresholds
    static let minimumConfidence = 0.3         // Lower threshold since code context is broader
    static let highConfidenceThreshold = 0.6   // High confidence threshold
    static let minimumTitleConfidenceThreshold = 0.5  // Title confidence threshold
}
