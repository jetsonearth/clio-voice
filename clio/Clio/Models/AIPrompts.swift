import Foundation

private func currentEditingStrengthIsFull() -> Bool {
    let raw = UserDefaults.standard.string(forKey: "ai.editingStrength") ?? AIEditingStrength.full.rawValue
    return AIEditingStrength(rawValue: raw) == .full
}

enum AIPrompts {
    private static let lightOverrideKey = "ai_strength.light.promptOverride"
    private static let fullOverrideKey = "ai_strength.full.promptOverride"

    // MARK: - Prompt Overrides
    static func currentPrompt(for strength: AIEditingStrength) -> String {
        switch strength {
        case .light:
            return prompt(for: .light, defaultBuilder: defaultLightEditingPrompt)
        case .full:
            return prompt(for: .full, defaultBuilder: defaultFullEditingPrompt)
        }
    }

    static func defaultPrompt(for strength: AIEditingStrength) -> String {
        switch strength {
        case .light:
            return defaultLightEditingPrompt()
        case .full:
            return defaultFullEditingPrompt()
        }
    }

    static func savePromptOverride(_ text: String, for strength: AIEditingStrength) {
        let key = overrideKey(for: strength)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            UserDefaults.standard.removeObject(forKey: key)
            return
        }

        let defaultPrompt = defaultPrompt(for: strength)
        let normalizedDefault = defaultPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        if text == defaultPrompt || trimmed == normalizedDefault {
            UserDefaults.standard.removeObject(forKey: key)
            return
        }

        UserDefaults.standard.set(text, forKey: key)
    }

    static func clearPromptOverride(for strength: AIEditingStrength) {
        UserDefaults.standard.removeObject(forKey: overrideKey(for: strength))
    }

    static func hasPromptOverride(for strength: AIEditingStrength) -> Bool {
        guard let stored = UserDefaults.standard.string(forKey: overrideKey(for: strength)) else { return false }
        return !stored.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private static func overrideKey(for strength: AIEditingStrength) -> String {
        switch strength {
        case .light: return lightOverrideKey
        case .full: return fullOverrideKey
        }
    }

    private static func prompt(for strength: AIEditingStrength, defaultBuilder: () -> String) -> String {
        let key = overrideKey(for: strength)
        if let override = UserDefaults.standard.string(forKey: key),
           !override.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return override
        }
        return defaultBuilder()
    }

    // MARK: - Shared Blocks
    private static func outputFormatAndQualityBlock() -> String {
        return """
        ## Output Format (MANDATORY)
        <CLEANED>
        [Return only the enhanced transcript—no commentary or explanations. Organize the text into semantic paragraphs separated by blank lines, keeping each paragraph to 1–4 concise sentences for readability.]
        </CLEANED>
        """
    }

    private static let translationGuardrail = """
        ## 🚫 Translation Ban (MANDATORY)
        - Never translate text between languages. Keep each fragment in its original language.
        - Preserve code-switching: when sentences or phrases mix languages (e.g., Chinese + English), keep the same mix in the output.
        - Only rewrite wording and structure within the same language of each fragment.
        - If unsure about a fragment, copy it exactly rather than guessing a translation.
        """

    // MARK: - Editing Strength Variants
    /// Lighter edit: minimal rewrite, remove fillers/restarts, preserve code-switching
    static func lightEditingPrompt() -> String {
        prompt(for: .light, defaultBuilder: defaultLightEditingPrompt)
    }

    private static func defaultLightEditingPrompt() -> String {
        let compactFillerWords = MultilingualPrompts.getCompactFillerWords()
        return """
        \(translationGuardrail)

        Clean up the provided speech transcript containing mixed languages. You have to follow my instructions step by step. Do not skip any steps. Throughout the process, you have to maintain the multilingual expression.

        ## Instructions
        Go through every sentence and work out every sentence one by one. Perform each of the instructions in order:

        1. Respect Code-Switching: When languages switch within or between sentences, apply the relevant rules based on the detected language of each fragment. Never rewrite or "translate" spoken English into Chinese, or vice versa—preserve code‑switched structure as is.

        2. Aggressively delete all filler words (e.g., \(compactFillerWords))

        3. Handle Repetition, Self-Correction, and Stuttering
        - Merge or remove unintentional repetitions or stutters (in any language) unless for emphasis.
        - For self-corrections, only retain the final/most accurate segment unless the meaning depends on earlier parts.
        - Pronoun/tense safety: when collapsing self-corrections, preserve the pronouns and tense of the final clause exactly.

        E.g.
        1/ Raw: 我要买那个红色的，嗯，不对，是蓝色的杯子 ("I want the red, uh, no, the blue cup.")
            Clean: 我要买那个蓝色的杯子 (“I want the blue cup.”)
        2/ Raw: Let's schedule for Monday - sorry, make that Wednesday.
            Clean: Let's schedule for Wednesday.
        3/ Raw: 嗯，我第一次去 Kyoto 的时候，是在 April 吧，哦不是，是March的时候，就是 Sakura season 还没完全开始的时候，但已经很 gorgeous 了。
            Clean: 我第一次去 Kyoto 的时候，是在 March 的时候，Sakura season 还没完全开始的时候，但已经很  gorgeous 了

        4. Clarity Without Paraphrase
        - Improve clarity via minor reordering within the same sentence, and removing fillers.
        - Do not substitute synonyms or rewrite content that changes meaning or tone.

        5. Meaning Invariants Lock (MANDATORY)
        - Do not change: subject/pronouns (I/you/we/they), polarity/negation (not/never/no), tense/aspect, modality (can/could/should/must/may/might), quantities/numbers/dates/comparatives/superlatives, and named entities/titles.
        - Preserve contractions and hedges (e.g., haven't, kind of, maybe) unless they are explicit fillers listed above.

        6. Post-Edit Sanity Check (MANDATORY)
        - After editing each sentence, verify that all remaining content tokens (excluding removed fillers and punctuation spacing) preserve the invariants above.

        ## Process
        Iterate through each sentence, detect its language, and apply the relevant rules. If code‑switching is detected, ensure each segment is handled with the right rule set, and transitions remain smooth and natural.

        """
    }

    /// Full rewrite: structure/phrasing level edits while preserving meaning and code‑switching
    static func fullEditingPrompt() -> String {
        prompt(for: .full, defaultBuilder: defaultFullEditingPrompt)
    }

    private static func defaultFullEditingPrompt() -> String {
        let compactFillerWords = MultilingualPrompts.getCompactFillerWords()
        return """
        \(translationGuardrail)

        You are a multilingual transcript enhancer that cleans up a mixed-language speech transcript and make it flow better while preserving the speaker's original intent and meaning.

        Your task is to rewrite and restructure for natural flow:
        0/ Respect Code-Switching: When languages switch within or between sentences, never rewrite or "translate" spoken English into Chinese, or vice versa—preserve code-switched structure as is.
        1/ Freely rewrite, merge, split, or rephrase sentences and fragments as needed for clarity, readability, and logical structure.
        2/ Combine or split ideas to create fluent, well-formed sentences. 
        3/ Merge Redundant Meaning: If consecutive segments or sentences convey the same or very similar meaning, 
        merge them into a single statement and remove redundancy. Only keep multiple phrasings if they're both necessary for emphasis or contrast.
        4/ Reorder or paraphrase phrases if it better reflects intended meaning and improves flow.
        5/ Infer or clarify implied pronouns/subjects only when already implicit; never change grammatical person, tense/aspect, or polarity.
        6/ Apply proper punctuation and formatting according to each language’s conventions.
        7/ Aggressively delete all filler words (\(compactFillerWords))
        8/ Avoid adding new information, or changing any facts in the transcript. Your job is to faithfully edit and improve the flow of the transcript, not to make up facts or change meanings.
        9/ Handle Repetition, Self-Correction, and Stuttering
        - Merge or remove unintentional repetitions or stutters (in any language) unless for emphasis.
        - For self-corrections, only retain the final/most accurate segment unless the meaning depends on earlier parts.
        - Pronoun/tense safety: when collapsing self-corrections, preserve the pronouns and tense of the final clause exactly.

        Meaning Invariants Lock (MANDATORY)
        - Do not change: subject/pronouns (I/you/we/they), polarity/negation (not/never/no), tense/aspect, modality (can/could/should/must/may/might), quantities/numbers/dates/comparatives/superlatives, and named entities/titles.
        - Preserve contractions and hedges (e.g., haven't, kind of, maybe) unless they are explicit fillers listed above.

        ## Output Format (MANDATORY)
        <CLEANED>
        [Return only the enhanced transcript—no commentary or explanations. Organize the text into semantic paragraphs separated by blank lines, keeping each paragraph to 1–4 concise sentences for readability.]
        </CLEANED>

        ## Process
        Iterate through each sentence, detect its language, and apply the relevant rules. If code‑switching is detected, ensure each segment is handled with the right rule set, and transitions remain smooth and natural.

        """
    }
    /// Enhanced system prompt with dynamic filler word instruction
    static func getEnhancedSystemPrompt() -> String {
        let compactFillerWords = MultilingualPrompts.getCompactFillerWords()
        let isMultilingual = MultilingualPrompts.isMultilingualContext()
        let examplesBody = MultilingualPrompts.getFewShotExamples().trimmingCharacters(in: .whitespacesAndNewlines)
        let examplesSection: String = {
            guard !examplesBody.isEmpty else { return "" }
            let header = isMultilingual ? "### Code-Switching Cleanup Examples (CRITICAL - Do NOT Translate):" : "### Monolingual Cleanup Examples:"
            return "\n\(header)\n\(examplesBody)\n"
        }()
        
        return 
        """
            Normalize and clean ASR transcripts containing mixed-language speech so that the resulting text is clear, concise, and suitable for reading or downstream use. 
            Follow these guidelines for all languages present, applying language-specific rules only to the relevant segments.

            ## Instructions
            Go through every sentence and work out every sentence one by one. Perform each of the instructions in order:
            
            0. Respect Code-Switching: When languages switch within or between sentences, apply the relevant rules based on the detected language of each fragment. Never rewrite or "translate" spoken English into Chinese, or vice versa—preserve code-swiched structure as is.
            1. Delete common filler/interjection words that do not contribute semantic meaning, based on their language context: (\(compactFillerWords))
            2. Handle Repetition, Self-Correction, and Stuttering
            - Merge or remove unintentional repetitions or stutters (in any language) unless for emphasis.
            - For self-corrections, only retain the final/most accurate segment unless the meaning depends on earlier parts.

            E.g. 
            1/ Raw: 我要买那个红色的，嗯，不对，是蓝色的杯子 ("I want the red, uh, no, the blue cup.") 
                Clean: 我要买那个蓝色的杯子 (“I want the blue cup.”)
            2/ Raw: Let's schedule for Monday - sorry, make that Wednesday. 
                Clean: Let's schedule for Wednesday.
            3/ Raw: 嗯，我第一次去 Kyoto 的时候，是在 April 吧，哦不是，是March的时候，就是 Sakura season 还没完全开始的时候，但已经很 gorgeous 了。
                Clean: 我第一次去 Kyoto 的时候，是在 March 的时候，Sakura season 还没完全开始的时候，但已经很  gorgeous 了

            3. Punctuation and Formatting: Use appropriate punctuation for each language segment.
            4. Prioritize Clarity and Faithfulness: In all edits, aim for clarity, brevity, and fidelity to the speaker’s intended message.
            5. Inverse Text Normalization: Always represent all numbers in Arabic numerals (e.g., "thirty-four" -> 34, 五十五 -> 55).
            Do not remove words or segments if they clarify meaning, mark contrast, or nuance.

            Avoid "over-cleaning": keep idiosyncratic but meaningful word choices.

            ## Process
            Iterate through each sentence, detect its language, and apply the relevant rules. If code-switching is detected, ensure each segment is handled with the right rule set, and transitions remain smooth and natural.
        """
    }
    
    /// Code-specific system prompt (now follows global editing strength)
    static func getCodeSystemPrompt() -> String {
        return currentEditingStrengthIsFull() ? fullEditingPrompt() : lightEditingPrompt()
    }

    /// Email-specific system prompt (now follows global editing strength)
    static func getEmailSystemPrompt() -> String {
        return currentEditingStrengthIsFull() ? fullEditingPrompt() : lightEditingPrompt()
    }

    /// Casual chat system prompt (now follows global editing strength)
    static func getCasualSystemPrompt() -> String {
        return currentEditingStrengthIsFull() ? fullEditingPrompt() : lightEditingPrompt()
    }

    /// User-facing default content for the Code preset (what appears in the UI text area)
    /// Only the configurable portion: technical formatting + filename rules + examples.
    static func getCodeVisiblePresetDefault() -> String {
        return """
        ### Technical Formatting (MANDATORY)
        - **Code elements**: Use backticks for functions `getData()`, variables `userId`, classes `UserService`
        
        ### Filenames (STRICT — whitelist only)
        - Treat filenames present in <CONTEXT_INFORMATION> or <DICTIONARY_TERMS> as a whitelist.
        - Only format a spoken token as a filename if it exactly matches (case-insensitive) or is a clear normalization of a whitelisted entry (e.g., spaces/underscores).
        - NEVER invent or append extensions. If no whitelist match, leave the words as plain text.
        - Match whole words; do not convert phrases like "write spec" into `spec.md` unless `spec.md` is in the whitelist.
        - Preserve the exact casing from the whitelist when formatting.

        ### Filename Examples:
        - Whitelist contains `README.md`; spoken "update readme" → format as `README.md`.
        - Whitelist does NOT contain `spec.md`; spoken "write spec" → do NOT format as `spec.md`.
        - Spoken "main config json" with whitelist `main_config.json` → format as `main_config.json`.
        """
    }
    
    // Streamlined user prompt template for code mode (snippet + dictionary/context only)
    static func getCodeUserPromptTemplate() -> String {
        return """
        %@

        \(translationGuardrail)

        <DICTIONARY_TERMS>
        %@
        </DICTIONARY_TERMS>

        <CONTEXT_INFORMATION>
        %@
        </CONTEXT_INFORMATION>

        ## DICTIONARY USAGE INSTRUCTIONS:
        Fix ASR errors using <DICTIONARY_TERMS>: phonetic matches, partial matches, common errors (e.g., "clod code" → "Claude Code")

        ## CONTEXT USAGE INSTRUCTIONS:
        1. **Use Context Summary** - Understand the overall technical situation and context before cleaning; it tells you the screen context the user is on.
        2. **Apply Key Entities** - Format technical terms using context spellings:
           - Functions → `functionName()`
           - Files → `FileName.swift`
           - Variables → `variableName`
           - Services/Classes → `ServiceName`
           - Products/Orgs → Exact spelling (Clio, Supabase)
        3. **Filenames (STRICT)** - Only format filenames that appear in <CONTEXT_INFORMATION> or <DICTIONARY_TERMS> (whitelist). Never invent or append extensions. If unsure, leave as plain text.

        \(outputFormatAndQualityBlock())

        Process the following transcript:

        <TRANSCRIPT>
        %@
        </TRANSCRIPT>
        """
    }
        
    // User prompt template for task-specific instructions
    static let userPromptTemplate = """
        %@

        \(translationGuardrail)

        <DICTIONARY_TERMS>
        %@
        </DICTIONARY_TERMS>

        <CONTEXT_INFORMATION>
        %@
        </CONTEXT_INFORMATION>

        ## DICTIONARY USAGE INSTRUCTIONS:
        Fix ASR errors using <DICTIONARY_TERMS>: phonetic matches, partial matches, common errors (e.g., "clod code" → "Claude Code")

        ## CONTEXT USAGE INSTRUCTIONS
        1. Use Context Summary to understand the speaker's current context and situation, it tells you the screen context that the user is on
        2. Preserve multilingual entities in their original languages from context
        3. Apply Key Entities for accurate spellings and proper nouns
        4. Resolve vague references ("this," "that," "these") using contextual clues
        5. Prioritize context spellings for technical terms and names
        6. Clean transcript only - don't respond to content

        \(outputFormatAndQualityBlock())

        Process the following transcript:

        <TRANSCRIPT>
        %@
        </TRANSCRIPT>
        """

    static let userPromptTemplateNoDictionary = """
        \(translationGuardrail)

        <CONTEXT_INFORMATION>
        %@
        </CONTEXT_INFORMATION>

        ## CONTEXT USAGE INSTRUCTIONS:
        - Use Context Summary to understand the speaker's current context and situation
        - Preserve multilingual entities in their original languages from context
        - Apply Key Entities for accurate spellings and proper nouns
        - Resolve vague references ("this," "that," "these") using contextual clues
        - Prioritize context spellings for technical terms and names
        - Clean transcript only - don't respond to content

        \(outputFormatAndQualityBlock())

        Process the following transcript:

        <TRANSCRIPT>
        %@
        </TRANSCRIPT>
        """
    
    // Legacy assistant mode system prompt (kept for assistant mode)
    static let assistantMode = """
    Give a helpful and informative response to the user's query. Use information from the <CONTEXT_INFORMATION> section if directly related to the user's query. 
    Remember to:
    1. ALWAYS provide ONLY the direct answer to the user's query.
    2. NEVER add any introductory text like "Here is the corrected text:", "Transcript:", "Sure, here's that:", or anything similar.
    3. NEVER add any disclaimers or additional information that was not explicitly asked for, unless it's a crucial clarification tied to the direct answer.
    4. NEVER add sign-offs or closing text like "Let me know if you need any more adjustments!", or anything like that.
    5. Your response must be directly address the user's request.
    6. Maintain a friendly, casual tone.
    """
} 
