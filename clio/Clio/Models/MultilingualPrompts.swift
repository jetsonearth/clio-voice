import Foundation

// MARK: - Multilingual Prompt System
enum MultilingualPrompts {
    
    // MARK: - Configuration
    /// When true, returns concise filler word lists instead of full instructions with examples
    private static let useCompactFillerWords = true
    
    // MARK: - Language Detection Utilities
    static func getSelectedLanguages() -> Set<String> {
        // Debug logging for language source
        let hasMultiLanguages = UserDefaults.standard.data(forKey: "SelectedLanguages") != nil
        let singleLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
        if RuntimeConfig.enableVerboseLogging {
            print("🌐 [LANG DEBUG] Multi-language setting exists: \(hasMultiLanguages), Single language: \(singleLanguage)")
        }
        
        guard let selectedLanguagesData = UserDefaults.standard.data(forKey: "SelectedLanguages") else {
            // Fallback to single language selection
            let selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
            if RuntimeConfig.enableVerboseLogging {
                print("🌐 [LANG DEBUG] Using single language fallback: \(selectedLanguage)")
            }
            return [selectedLanguage == "auto" ? "en" : selectedLanguage]
        }
        
        do {
            let selectedLanguages = try JSONDecoder().decode(Set<String>.self, from: selectedLanguagesData)
            // Sort to prioritize non-English languages first (for OCR language order)
            let sortedLanguages = Array(selectedLanguages).sorted { first, second in
                // Non-English languages go first
                if first == "en" && second != "en" { return false }
                if first != "en" && second == "en" { return true }
                return first < second
            }
            if RuntimeConfig.enableVerboseLogging {
                print("🌐 [LANG DEBUG] Using multi-language selection (prioritized): \(sortedLanguages.joined(separator: ", "))")
            }
            return selectedLanguages.isEmpty ? Set(["en"]) : Set(sortedLanguages)
        } catch {
            // Fallback to single language selection
            let selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en"
            if RuntimeConfig.enableVerboseLogging {
                print("🌐 [LANG DEBUG] Multi-language decode failed, using single: \(selectedLanguage)")
            }
            return [selectedLanguage == "auto" ? "en" : selectedLanguage]
        }
    }
    
    static func isMultilingualContext() -> Bool {
        let languages = getSelectedLanguages()
        return languages.count > 1 || languages.contains("auto")
    }
    
    static func getLanguagePromptInstructions() -> String {
        let languages = getSelectedLanguages()
        
        if languages.count == 1 && !languages.contains("auto") {
            let language = languages.first!
            return getMonolingualInstructions(for: language)
        } else {
            return getMultilingualInstructions(for: languages)
        }
    }
    
    // MARK: - Monolingual Instructions
    private static func getMonolingualInstructions(for language: String) -> String {
        switch language {
        case "en":
            return """
            LANGUAGE PROCESSING:
            - The input is expected to be in English only
            - Maintain natural English grammar and expression patterns
            - Preserve any technical terms, acronyms, or proper nouns
            """
            
        case "zh", "zh-cn", "zh-hans":
            return """
            语言处理指示:
            - 输入预期仅为中文
            - 保持自然的中文语法和表达模式
            - 保留任何技术术语、缩写或专有名词
            - 使用适当的中文标点符号
            """
            
        case "zh-tw", "zh-hant":
            return """
            語言處理指示:
            - 輸入預期僅為繁體中文
            - 保持自然的繁體中文語法和表達模式
            - 保留任何技術術語、縮寫或專有名詞
            - 使用適當的繁體中文標點符號
            """
            
        case "ko":
            return """
            언어 처리 지침:
            - 입력은 한국어만 예상됩니다
            - 자연스러운 한국어 문법과 표현 패턴을 유지하세요
            - 기술 용어, 약어 또는 고유 명사를 보존하세요
            - 적절한 한국어 문장 부호를 사용하세요
            """
            
        case "ja":
            return """
            言語処理指示:
            - 入力は日本語のみが予想されます
            - 自然な日本語の文法と表現パターンを維持してください
            - 技術用語、略語、または固有名詞を保持してください
            - 適切な日本語の句読点を使用してください
            """
            
        case "es":
            return """
            INSTRUCCIONES DE PROCESAMIENTO DE IDIOMA:
            - Se espera que la entrada sea solo en español
            - Mantener patrones gramaticales y de expresión naturales del español
            - Preservar cualquier término técnico, acrónimo o nombre propio
            """
            
        case "fr":
            return """
            INSTRUCTIONS DE TRAITEMENT LINGUISTIQUE:
            - L'entrée est attendue uniquement en français
            - Maintenir les modèles grammaticaux et d'expression naturels français
            - Préserver tous les termes techniques, acronymes ou noms propres
            """
            
        case "de":
            return """
            SPRACHVERARBEITUNGSANWEISUNGEN:
            - Die Eingabe wird nur auf Deutsch erwartet
            - Natürliche deutsche Grammatik- und Ausdrucksmuster beibehalten
            - Alle technischen Begriffe, Akronyme oder Eigennamen bewahren
            """
            
        default:
            return """
            LANGUAGE PROCESSING:
            - Process the input in the detected language
            - Maintain natural grammar and expression patterns for the language
            - Preserve any technical terms, acronyms, or proper nouns
            """
        }
    }
    
    // MARK: - Multilingual Instructions with Code-Switching
    private static func getMultilingualInstructions(for languages: Set<String>) -> String {
        let languageList = Array(languages).sorted()
        let languageNames = languageList.map { getLanguageName($0) }.joined(separator: ", ")
        
        var instructions = """
        MULTILINGUAL PROCESSING & CODE-SWITCHING PRESERVATION:
        - The input may contain multiple languages: \(languageNames)
        - CRITICAL: Preserve all code-switching (language mixing) exactly as spoken
        - DO NOT translate between languages — maintain the original language choice for each phrase
        - Respect the speaker's natural multilingual expression patterns
        - Keep rhetorical tag questions and politeness particles that add meaning (EN: “right?”, “okay?”; ZH: “对吧？”, “是不是？”, “好吗？”) 
        - Keep transitional connectors (EN: “so”, “therefore”; ZH: “所以”, “因此”) when they link clauses; remove only when redundant
        
        """
        
        // Add specific bilingual examples based on language combinations
        if languages.contains("en") && (languages.contains("zh") || languages.contains("zh-cn") || languages.contains("zh-hans")) {
            instructions += """
            ENGLISH-CHINESE CODE-SWITCHING EXAMPLES:
            Input: "我今天要去 meeting，然后 review 一下 documents"
            Output: "我今天要去 meeting，然后 review 一下 documents"
            
            Input: "Can you help me 翻译 this 文件？"
            Output: "Can you help me 翻译 this 文件？"
            
            Input: "We can ship on Friday, 对吧？"
            Output: "We can ship on Friday, 对吧？"
            
            Input: "我们先用 Python，right? 然后看看 Rust 要不要换。"
            Output: "我们先用 Python，right? 然后看看 Rust 要不要换。"
            
            """
        }
        
        if languages.contains("en") && languages.contains("ko") {
            instructions += """
            ENGLISH-KOREAN CODE-SWITCHING EXAMPLES:
            Input: "오늘 meeting에서 presentation을 해야 해요"
            Output: "오늘 meeting에서 presentation을 해야 해요"
            
            Input: "Can you check the 파일 I sent you?"
            Output: "Can you check the 파일 I sent you?"
            
            """
        }
        
        if languages.contains("en") && languages.contains("ja") {
            instructions += """
            ENGLISH-JAPANESE CODE-SWITCHING EXAMPLES:
            Input: "今日のmeetingでpresentationします"
            Output: "今日のmeetingでpresentationします"
            
            Input: "Please review this ドキュメント"
            Output: "Please review this ドキュメント"
            
            """
        }
        
        if languages.contains("en") && languages.contains("es") {
            instructions += """
            ENGLISH-SPANISH CODE-SWITCHING EXAMPLES:
            Input: "Vamos a tener un meeting mañana about the proyecto"
            Output: "Vamos a tener un meeting mañana about the proyecto"
            
            Input: "Can you enviar the documento por favor?"
            Output: "Can you enviar the documento por favor?"
            
            """
        }
        
        instructions += """
        IMPORTANT RULES:
        - Never "correct" code-switching by translating mixed languages
        - Preserve the speaker's choice of which language to use for specific terms
        - Clean up grammar and remove fillers while maintaining language mixing
        - If unsure about language boundaries, err on the side of preservation
        """
        
        return instructions
    }
    
    // MARK: - Language-Specific Filler Words
    
    /// Returns just the filler words for a specific language (compact format for prompt integration)
    static func getFillerWordsOnly(for language: String) -> String? {
        return getFillerWordsArray(for: language)?.joined(separator: ", ")
    }
    
    /// Returns compact filler words for all selected languages (perfect for AI prompt integration)
    static func getCompactFillerWords() -> String {
        let selectedLanguages = getSelectedLanguages()
        // When language is auto-detected, provide a broad, explicit set (avoid vague wording)
        var languagesToUse: [String]
        if selectedLanguages.contains("auto") {
            // High-coverage defaults for editing tasks
            languagesToUse = ["en", "zh"]
        } else {
            languagesToUse = Array(selectedLanguages)
        }

        let relevantFillers = languagesToUse
            .compactMap { getFillerWordsArray(for: $0) }
            .flatMap { $0 }

        // Provide a concrete cross-lingual fallback rather than a vague description
        return relevantFillers.isEmpty
            ? "um, uh, like, you know, 嗯, 呃, 那个, 就是"
            : relevantFillers.joined(separator: ", ")
    }
    
    /// Returns language-specific filler word examples when specific languages are selected (not auto-detect)
    /// The examples are conservative: retain meaningful tag questions and structural transitions; remove hesitation tokens and duplicates.
    static func getLanguageSpecificFillerExamples() -> String {
        let languages = getSelectedLanguages()
        
        // Only generate language-specific examples when specific languages are selected (not auto-detect)
        if languages.contains("auto") {
            return ""
        }
        
        var fillerExamples = ""
        
        for language in languages.sorted() {
            if let languageFillers = getFillerWordsForLanguage(language) {
                fillerExamples += languageFillers + "\n\n"
            }
        }
        
        return fillerExamples.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Get filler word examples for a specific language
    private static func getFillerWordsForLanguage(_ language: String) -> String? {
        switch language {
        case "zh", "zh-cn", "zh-hans":
            if useCompactFillerWords {
                return "嗯, 呃, 啊, 那个, 就是, 怎么说, 就是说, 那什么, 额, 哎"
            } else {
                return """
                CHINESE FILLER WORDS TO REMOVE (保留语气/礼貌结尾):
                嗯, 呃, 啊, 那个, 就是, 怎么说, 就是说, 那什么, 额, 哎
                
                保留以下具有语气或礼貌功能的表达（不要删除）:
                - 句尾反问/确认: 「对吧？」「是不是？」「好吗？」
                - 结构性连接词（用于承接/因果）: 「所以」「因此」
                
                示例:
                输入: "嗯，那个，我觉得，呃，这个问题，就是，比较复杂，对吧？"
                输出: "我觉得这个问题比较复杂，对吧？"
                
                输入: "所以，嗯，我们就是说，需要考虑一下。"
                输出: "所以我们需要考虑一下。"
                """
            }
            
        case "zh-tw", "zh-hant":
            if useCompactFillerWords {
                return "那個, 嗯, 呃, 這個, 就是說, 怎麼說, 你知道, 那什麼"
            } else {
                return """
                TRADITIONAL CHINESE FILLER WORDS TO REMOVE（保留語氣/禮貌結尾）:
                那個, 嗯, 呃, 這個, 就是說, 怎麼說, 你知道, 那什麼
                
                保留具有語氣或禮貌功能的表達（不要刪除）:
                - 句尾反問/確認: 「對吧？」「是不是？」「好嗎？」
                - 結構性連接詞（用於承接/因果）: 「所以」「因此」
                
                範例:
                輸入: "嗯，我覺得，這個問題，就是說，可能比較複雜，對吧？"
                輸出: "我覺得這個問題可能比較複雜，對吧？"
                
                輸入: "所以，嗯，我們就是說，需要再討論一下。"
                輸出: "所以我們需要再討論一下。"
                """
            }
            
        case "en":
            if useCompactFillerWords {
                return "um, uh, like, you know, I mean, kind of, sort of, basically, literally"
            } else {
                return """
                ENGLISH FILLER WORDS TO REMOVE (retain tag questions and meaningful transitions):
                um, uh, like, you know, I mean, kind of, sort of, basically, literally
                
                Keep when meaningful:
                - Tag questions: "right?", "okay?", "is that okay?"
                - Transitions: "So" when it signals consequence/summary
                
                Examples:  
                Input: "So, um, I think we should, like, you know, meet at 3, right?"
                Output: "So I think we should meet at 3, right?"
                
                Input: "I mean, basically we need to, uh, finish this."
                Output: "We need to finish this."
                """
            }
            
        case "ja":
            if useCompactFillerWords {
                return "えー, あの, そのー, えーと, あのー, うーん"
            } else {
                return """
                JAPANESE FILLER WORDS TO REMOVE (conservative):
                えー, あの, そのー, えーと, あのー, うーん
                
                例:
                入力: "えー、あの、今日はそのー会議があります"
                出力: "今日は会議があります"
                
                入力: "うーん、えーと、それは難しいですね"
                出力: "それは難しいですね"
                """
            }
            
        case "ko":
            if useCompactFillerWords {
                return "음, 어, 에, 그, 뭐, 약간"
            } else {
                return """
                KOREAN FILLER WORDS TO REMOVE (conservative):
                음, 어, 에, 그, 뭐, 약간
                
                예:
                입력: "음, 그 오늘 어 회의가 있어요"
                출력: "오늘 회의가 있어요"
                
                입력: "뭐 약간 어려워요"
                출력: "어려워요"
                """
            }
            
        case "es":
            if useCompactFillerWords {
                return "eh, este, pues, o sea, bueno, digamos"
            } else {
                return """
                SPANISH FILLER WORDS TO REMOVE (conservador):
                eh, este, pues, o sea, bueno, digamos
                
                Mantener cuando sea significativo:
                - Etiquetas retóricas / confirmación: "¿verdad?", "¿de acuerdo?"
                - Transiciones: "Entonces" cuando indica consecuencia
                
                Ejemplos:
                Entrada: "Eh, o sea, tenemos que terminar esto, ¿verdad?"
                Salida: "Tenemos que terminar esto, ¿verdad?"
                
                Entrada: "Pues, digamos, es difícil"
                Salida: "Es difícil"
                """
            }
            
        case "fr":
            return """
            FRENCH FILLER WORDS TO REMOVE (prudent):
            euh, bah, ben, hein
            
            Exemples:
            Entrée: "Euh, je pense que, bah, on doit finir ça"
            Sortie: "Je pense qu'on doit finir ça"
            
            Entrée: "Ben, euh, c'est difficile"
            Sortie: "C'est difficile"
            """
            
        case "de":
            return """
            GERMAN FILLER WORDS TO REMOVE (vorsichtig):
            äh, hm
            
            Beispiele:
            Eingabe: "Äh, hm, ich denke, dass wir das beenden sollten"
            Ausgabe: "Ich denke, dass wir das beenden sollten"
            
            Eingabe: "Äh, hm, das ist schwierig"
            Ausgabe: "Das ist schwierig"
            """
            
        case "it":
            return """
            ITALIAN FILLER WORDS TO REMOVE:
            eh, ehm, beh, allora, dunque, insomma, cioè, diciamo, praticamente, tipo, sai, capisce, vero, no, mah, boh, così, ecco, vabbè
            
            Examples:
            Input: "Allora, ehm, ieri sono andato al mercato, cioè, per comprare, eh, delle verdure, no"
            Output: "Ieri sono andato al mercato per comprare delle verdure"
            
            Input: "Cioè, praticamente, diciamo che è difficile"
            Output: "È difficile"
            """
            
        case "pt":
            return """
            PORTUGUESE FILLER WORDS TO REMOVE:
            né, então, assim, tipo, sabe, é, ah, eh, bem, aí, quer dizer, ou seja, digamos, como, bom, enfim, sei lá, é isso, né não
            
            Examples:
            Input: "Então, né, eu fui ao mercado, assim, para comprar, tipo, verduras, sabe"
            Output: "Eu fui ao mercado para comprar verduras"
            
            Input: "Enfim, quer dizer, vamos dizer que é difícil"
            Output: "É difícil"
            """
            
        case "ru":
            return """
            RUSSIAN FILLER WORDS TO REMOVE:
            э, эм, ну, вот, как бы, типа, короче, значит, так сказать, собственно, в общем, кстати, блин, да, нет
            
            Examples:
            Input: "Ну, э, я думаю, что, как бы, нам стоит, вот, пойти в кино, да?"
            Output: "Я думаю, что нам стоит пойти в кино."
            
            Input: "В общем, это, эм, типа сложно, короче."
            Output: "Это сложно."
            """
            
        case "ar":
            return """
            ARABIC FILLER WORDS TO REMOVE:
            يعني, طيب, إذن, أم, إيه, هو, بس, خلاص, كده, أصل, فهمتني, مش كده, ازاي, ايوة, لا
            
            Examples:
            Input: "يعني، طيب، أنا أعتقد إنه، إيه، لازم نروح السينما، مش كده؟"
            Output: "أنا أعتقد إنه لازم نروح السينما."
            
            Input: "هو، بس، ده صعب، يعني، فهمتني؟"
            Output: "ده صعب."
            """
            
        case "hi":
            return """
            HINDI FILLER WORDS TO REMOVE:
            अच्छा, हाँ, नहीं, तो, फिर, यानी, मतलब, बस, अरे, अच्छा, ठीक है, क्या, कैसे, जैसे, वैसे
            
            Examples:
            Input: "अच्छा, तो, मैं सोचता हूँ कि, यानी, हमें सिनेमा जाना चाहिए, हाँ?"
            Output: "मैं सोचता हूँ कि हमें सिनेमा जाना चाहिए।"
            
            Input: "बस, यानी, यह मुश्किल है, ठीक है।"
            Output: "यह मुश्किल है।"
            """
            
        case "nl":
            return """
            DUTCH FILLER WORDS TO REMOVE:
            eh, uhm, nou, ja, nee, dus, zo, gewoon, eigenlijk, zeg maar, weet je, hoor, toch, ofzo, namelijk
            
            Examples:
            Input: "Eh, nou, ik denk dat we, uhm, eigenlijk naar de film moeten, weet je."
            Output: "Ik denk dat we naar de film moeten."
            
            Input: "Dus, zo, het is gewoon moeilijk, hoor."
            Output: "Het is moeilijk."
            """
            
        case "pl":
            return """
            POLISH FILLER WORDS TO REMOVE:
            ee, no, tak, więc, znaczy, wiesz, kurde, właśnie, po prostu, jakby, w sumie, ogólnie, prawda, czy nie, hmm
            
            Examples:
            Input: "Ee, no, myślę że, znaczy, powinniśmy iść do kina, wiesz?"
            Output: "Myślę że powinniśmy iść do kina."
            
            Input: "W sumie, to jest, ee, po prostu trudne, prawda?"
            Output: "To jest trudne."
            """
            
        case "tr":
            return """
            TURKISH FILLER WORDS TO REMOVE:
            yani, işte, şey, böyle, hani, ya, ee, mm, tamam, peki, evet, hayır, falan, biliyorsun, değil mi
            
            Examples:
            Input: "Yani, işte, bence sinemaya gitmeliyiz, şey, böyle, değil mi?"
            Output: "Bence sinemaya gitmeliyiz."
            
            Input: "Ee, bu şey, yani, zor, biliyorsun."
            Output: "Bu zor."
            """
            
        case "vi":
            return """
            VIETNAMESE FILLER WORDS TO REMOVE:
            ừ, à, thì, mà, này, kia, đó, ấy, nhỉ, ha, hả, ơi, ồ, uhm, err
            
            Examples:
            Input: "Ừ, thì, tôi nghĩ là, à, chúng ta nên đi xem phim, nhỉ?"
            Output: "Tôi nghĩ là chúng ta nên đi xem phim."
            
            Input: "Mà, này, khó lắm, à."
            Output: "Khó lắm."
            """
            
        case "id":
            return """
            INDONESIAN FILLER WORDS TO REMOVE:
            eh, mm, ya, jadi, terus, gitu, sih, kok, deh, dong, kan, emang, kayak, gimana, tau
            
            Examples:
            Input: "Eh, jadi, gue pikir kita harus, mm, nonton film, gitu deh."
            Output: "Gue pikir kita harus nonton film."
            
            Input: "Ya, ini, eh, susah banget, dong."
            Output: "Ini susah banget."
            """
            
        case "th":
            return """
            THAI FILLER WORDS TO REMOVE:
            เอ่อ, อืม, นะ, จ้ะ, ค่ะ, ครับ, แล้ว, ก็, นี่, นั่น, โน่น, เนี่ย, เหรอ, สิ, หละ
            
            Examples:
            Input: "เอ่อ นะ ผมคิดว่า อืม เราควรไปดูหนัง ค่ะ"
            Output: "ผมคิดว่าเราควรไปดูหนัง"
            
            Input: "ก็ นี่ มัน ยาก มาก เหรอ"
            Output: "มันยากมาก"
            """
            
        default:
            return nil
        }
    }
    
    // MARK: - Dynamic Filler Word Builder
    
    /// Filler removal aggressiveness level. Read from UserDefaults key "FillerAggressiveness": "strict" | "balanced" | "lenient" (default: balanced)
    private static func getFillerAggressiveness() -> String {
        let value = UserDefaults.standard.string(forKey: "FillerAggressiveness")?.lowercased() ?? "balanced"
        switch value {
        case "strict", "lenient": return value
        default: return "balanced"
        }
    }
    
    /// Get filler words as array for a specific language (for dynamic prompt building)
    static func getFillerWordsArray(for language: String) -> [String]? {
        switch language {
        case "zh", "zh-cn", "zh-hans":
            // High-confidence fillers only (avoid removing tag/stance particles like 呢/吧 or structural connectors like 然后)
            return ["嗯", "呃", "啊", "那个", "就是", "怎么说", "就是说", "那什么", "额", "哎"]
            
        case "zh-tw", "zh-hant":
            // High-confidence fillers only; avoid removing structural/stance markers
            return ["那個", "嗯", "呃", "這個", "就是說", "怎麼說", "你知道", "那什麼"]
            
        case "en":
            // Safer list: exclude tag questions and structural markers (right, alright, so, well)
            return ["um", "uh", "like", "you know", "I mean", "kind of", "sort of", "basically", "literally"]
            
        case "ja":
            // Restrict to classic hesitation fillers only
            return ["えー", "あの", "そのー", "えーと", "あのー", "うーん"]
            
        case "ko":
            // Restrict to hesitation fillers; avoid structural connectors (그래서/근데)
            return ["음", "어", "에", "그", "뭐", "약간"]
            
        case "es":
            // Safer Spanish fillers; exclude polite/semantic markers (por favor, claro, verdad, a ver, entonces)
            return ["eh", "este", "pues", "o sea", "bueno", "digamos"]
            
        case "fr":
            // Safer French fillers; avoid structural connectors (alors, donc) and contentful phrases
            return ["euh", "bah", "ben", "hein"]
            
        case "de":
            // Safer German fillers; avoid semantic adverbs like eigentlich/halt
            return ["äh", "hm"]
            
        default:
            return nil
        }
    }
    
    /// Build dynamic filler word instruction based on selected languages
    static func buildDynamicFillerInstruction() -> String {
        let selectedLanguages = getSelectedLanguages()
        let level = getFillerAggressiveness()
        let relevantFillers = selectedLanguages
            .compactMap { getFillerWordsArray(for: $0) }
            .flatMap { $0 }
        let fillerString = relevantFillers.isEmpty ? "common hesitation tokens" : relevantFillers.joined(separator: ", ")
        
        switch level {
        case "strict":
            return "1. Remove filler words, guess words, stutters, and repetitions across languages (e.g., \(fillerString)). Keep tag questions and politeness markers that add meaning (EN: ‘right?’, ‘okay?’; ZH: ‘对吧？’, ‘是不是？’, ‘好吗？’). Keep transitional connectors (e.g., ‘so’, ‘因此/所以’) when they link clauses."
        case "lenient":
            return "1. Prefer to keep discourse markers that convey tone, stance, or politeness. Remove only obvious hesitation tokens, stutters, and duplicate fillers (e.g., \(fillerString)). Always keep tag questions (EN: ‘right?’, ‘okay?’; ZH: ‘对吧？’, ‘是不是？’, ‘好吗？’) and meaningful transitions (e.g., ‘so’, ‘因此/所以’)."
        default: // balanced
            return "1. Remove common hesitation tokens, stutters, and duplicated fillers (e.g., \(fillerString)). Keep discourse markers when they serve as tag questions, confirmations, politeness, or structural transitions. Examples: ‘We can ship Friday, right?’ → keep ‘right?’; ‘我们今天先试试，对吧？’ → keep ‘对吧？’."
        }
    }
    
    // MARK: - Helper Functions
    private static func getLanguageName(_ code: String) -> String {
        switch code {
        case "en": return "English"
        case "zh", "zh-cn", "zh-hans": return "Chinese (Simplified)"
        case "zh-tw", "zh-hant": return "Chinese (Traditional)"
        case "ko": return "Korean"
        case "ja": return "Japanese"
        case "es": return "Spanish"
        case "fr": return "French"
        case "de": return "German"
        case "it": return "Italian"
        case "pt": return "Portuguese"
        case "ru": return "Russian"
        case "ar": return "Arabic"
        case "hi": return "Hindi"
        case "auto": return "Auto-detect"
        default: return "Unknown (\(code))"
        }
    }
    
    // MARK: - Few-Shot Examples Generation
    static func getFewShotExamples() -> String {
        let languages = getSelectedLanguages()
        // For monolingual contexts, provide monolingual examples
        if languages.count == 1 && !languages.contains("auto") {
            return getMonolingualExamples(for: languages.first!)
        }
        
        // For multilingual contexts, include ONLY mixed code-switching examples (mutually exclusive with monolingual)
        return getMultilingualExamples(for: languages)
    }
    
    private static func getMonolingualExamples(for language: String) -> String {
        switch language {
        case "en":
            return """
            Examples:
            Raw: "So I went to the... wait, actually, let me start over. Yesterday I went to this restaurant and, um, the service was just, just awful."
            Enhanced: "Yesterday I went to this restaurant and the service was awful."
            
            Raw: "Uh, um, well my mom called and she's like... well, she was sort of like, you know, worried about my, my... my brother because he's just, just gaming all day."
            Enhanced: "My mom called and she was worried about my brother because he's just gaming all day."
            """
        case "zh", "zh-cn", "zh-hans":
            return """
            Examples:
            Raw: "我昨天去了... 不对，等等，我重新说。嗯，那个，我昨天晚上去看电影，但是，但是剧情很，很... 怎么说呢，就是很混乱。"
            Enhanced: "我昨天晚上去看电影，但是剧情很混乱。"
            
            Raw: "嗯，我妈打电话说... 那个，怎么说呢，她担心我爸最近，最近老是，老是忘东忘西的。"
            Enhanced: "我妈打电话说她担心我爸最近老是忘东忘西。"
            """
        case "ko":
            return """
            예시:
            Raw: "어제 친구랑... 아니 잠깐, 다시 말할게요. 음, 그, 어제 쇼핑을, 쇼핑을 갔는데 갑자기, 갑자기... 뭐라고 하지, 비가 막 왔어요."
            Enhanced: "어제 쇼핑을 갔는데 갑자기 비가 막 왔어요."
            
            Raw: "음, 어, 제 형이 요즘에, 요즘에... 그러니까, 일을 그만두고, 그만두고 싶어해요. 왜냐하면, 왜냐하면 스트레스가 너무, 너무 심해서요."
            Enhanced: "제 형이 요즘에 일을 그만두고 싶어해요. 왜냐하면 스트레스가 너무 심해서요."
            """
        case "ja":
            return """
            例:
            Raw: "昨日友達と... あ、ちょっと待って、えーと、昨日レストランに行ったんですけど、あの、あの、サービスがひどくて、ひどくて。"
            Enhanced: "昨日レストランに行ったんですけど、サービスがひどくて。"
            
            Raw: "えーと、母が電話してきて、なんというか、あの、弟のことを心配してて、心配してて。最近ゲームばっかり、ゲームばっかりやってるから。"
            Enhanced: "母が電話してきて、弟のことを心配してて。最近ゲームばっかりやってるから。"
            """
        case "fr":
            return """
            Exemples:
            Raw: "Alors, euh, hier je suis allé au... non attendez, en fait, hier soir je suis allé au restaurant et, euh, le service était vraiment, vraiment nul."
            Enhanced: "Hier soir je suis allé au restaurant et le service était vraiment nul."
            
            Raw: "Euh, ben, ma mère m'a appelé et elle était, elle était genre inquiète pour mon, mon... mon frère parce qu'il joue, il joue aux jeux vidéo toute la journée."
            Enhanced: "Ma mère m'a appelé et elle était inquiète pour mon frère parce qu'il joue aux jeux vidéo toute la journée."
            """
        case "de":
            return """
            Beispiele:
            Raw: "Also, äh, gestern bin ich zu diesem... nein warte, eigentlich, gestern Abend bin ich ins Restaurant gegangen und, äh, der Service war einfach, einfach schrecklich."
            Enhanced: "Gestern Abend bin ich ins Restaurant gegangen und der Service war einfach schrecklich."
            
            Raw: "Äh, nun ja, meine Mutter hat angerufen und sie war so, so besorgt über meinen, meinen... meinen Bruder, weil er nur noch, nur noch Videospiele spielt."
            Enhanced: "Meine Mutter hat angerufen und sie war besorgt über meinen Bruder, weil er nur noch Videospiele spielt."
            """
        case "ru":
            return """
            Примеры:
            Raw: "Вчера я пошёл в... нет, подождите, вообще-то, вчера вечером я пошёл в ресторан и, э-э, обслуживание было просто, просто ужасное."
            Enhanced: "Вчера вечером я пошёл в ресторан и обслуживание было просто ужасное."
            
            Raw: "Э-э, ну, мама позвонила и она была, она была как бы обеспокоена моим, моим... моим братом, потому что он только, только в игры играет весь день."
            Enhanced: "Мама позвонила и она была обеспокоена моим братом, потому что он только в игры играет весь день."
            """
        case "es":
            return """
            Ejemplos:
            Raw: "Ayer fui al... no espera, en realidad, ayer por la noche fui al restaurante y, eh, el servicio era simplemente, simplemente horrible."
            Enhanced: "Ayer por la noche fui al restaurante y el servicio era simplemente horrible."
            
            Raw: "Eh, bueno, mi mamá me llamó y estaba como, estaba como preocupada por mi, mi... mi hermano porque solo, solo juega videojuegos todo el día."
            Enhanced: "Mi mamá me llamó y estaba preocupada por mi hermano porque solo juega videojuegos todo el día."
            """
        default:
            return ""
        }
    }
    private static func getMultilingualExamples(for languages: Set<String>) -> String {
        var examples = "Examples of preserving code-switching:\n\n"
        
        if languages.contains("en") && (languages.contains("zh") || languages.contains("zh-cn") || languages.contains("zh-hans")) {
            examples += """
            Raw: "嗯，那个，我们的，我们的team最近在做这个... 等等，怎么说呢，就是，就是... 在做这个machine learning的，machine learning的project，但是，就是你知道吧，遇到了很多，很多challenge。然后反正首先就是，就是data quality很，很差，然后呢，然后我们的manager，他一直就，一直push我们要，要faster delivery，但是我觉得，我觉得这个timeline很，很unrealistic。"
            
            Enhanced: "我们的team最近在做这个machine learning project，但是遇到了很多challenge。首先就是data quality很差，然后我们的manager一直push我们要faster delivery，但是我觉得这个timeline很unrealistic。"
            """
        }
        
        if languages.contains("en") && languages.contains("es") {
            examples += """
            Raw: "Ayer fui al... no espera, yesterday I went to this meeting y, eh, el presentation fue muy, muy... como se dice, confusing porque, porque they kept switching entre, entre español and English todo el tiempo."
            
            Enhanced: "Yesterday I went to this meeting y el presentation fue muy confusing porque they kept switching entre español and English todo el tiempo."
            """
        }
        
        if languages.contains("en") && languages.contains("ja") {
            examples += """
            Raw: "今日の、えーと、今日のmeeting で、あの、あの、presentation を、presentationをしなければ... wait, I mean, しなければならないんですが、あの、very nervous です。"
            
            Enhanced: "今日のmeeting でpresentationをしなければならないんですが、very nervousです。"
            """
        }
        
        if languages.contains("en") && languages.contains("ko") {
            examples += """
            Raw: "오늘, 음, 오늘 meeting에서, uh, presentation을, presentation을 해야 하는데, 어, very nervous해요. 왜냐하면, 왜냐하면 boss가, boss가 올 거거든요."
            
            Enhanced: "오늘 meeting에서 presentation을 해야 하는데, very nervous해요. 왜냐하면 boss가 올 거거든요."
            """
        }
        // General behaviors across languages (spelling, numbers, spacing)
        return examples.isEmpty ? "" : examples
    }
}
