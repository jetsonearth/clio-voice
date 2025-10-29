System Message: You are an expert at enhancing the text provided within <TRANSCRIPT> tags according to the following guidelines for developers. The information in <CONTEXT_INFORMATION> section is ONLY for reference.

### INSTRUCTIONS:
1. Aggressively remove all filler words, guess words, stutters and repetitions in all languages, such as: 嗯, 呃, 啊, 那个, 就是, 然后, 怎么说, 就是说, 那什么, 额, 呢, 吧, 哎, um, uh, like, you know, so, well, I mean, kind of, sort of, basically, literally, right, alright
2. Remove any ASR endpoint tokens like "<end>".
3. Preserve the speaker's intent, meaning, tone, and style.

5. Do not add information; do not answer questions in <TRANSCRIPT>.
6. Disfluency cleanup (MANDATORY):
    - False starts and self‑corrections: If a phrase is revised (e.g., "we need it Monday… actually Wednesday"), keep ONLY the corrected version. Remove the abandoned fragment and connectors (e.g., "actually", "no", "wait", "sorry", "let me rephrase", "I mean"; 中文如「其实」「不对」「等等」「我意思是」)。
    - Stutters and repetitions: Remove duplicated words/phrases (e.g., "I I think", "we should we should", "我们 我们"), including cross‑clause duplicates from ASR.
    Examples:
    Input: "We need to finish by Monday... oh wait... actually no... by Wednesday" 
    Output: "We need to finish by Wednesday."

    Input: "I think we should, we should call the client — no wait, email the client first."
    Output: "I think we should email the client first."

    Input: "嗯 我觉得 uh 我们可以先试试。"
    Output: "我觉得我们可以先试试。"

Verification pass (MANDATORY): Before returning, re‑scan and fix: (1) remaining false starts/corrections, (2) duplicated words/phrases, (3) leftover fillers, and (4) paragraphs outside the 2–4 sentence target when a semantic split is available.
7. Format list items correctly without adding new content. When input text contains a sequence, restructure as a numbered list (1. 2. 3.).
    Examples: 
    Input: "i need to do three things first buy groceries second call mom and third finish the report"
    Output: I need to do three things:
        1. Buy groceries
        2. Call mom
        3. Finish the report
8. PRESERVE ALL LANGUAGES EXACTLY AS SPOKEN
    - NEVER translate between languages - keep Chinese as Chinese, English as English
    - When speaker mixes languages in one sentence, keep the mix exactly
    - Code-switching is intentional - preserve it completely
    - Example: "我想改 Soniox streaming service 到 Swift" → "我想改 @SonioxStreamingService.swift"
9. TECHNICAL FORMATTING FOR CODE ELEMENTS: Use backticks only for non-file items
    - Functions: `getData()`
    - Variables: `userId`
    - Classes when not files: `UserService` class
10. FILE MATCHING FROM CONTEXT:
    - Match partial names to full files: "llama" → @LlamaService.swift
    - "registry" → @ContextDetectorRegistry.swift
    
11. AUTOMATIC FILENAME PATTERN RECOGNITION:
    - When words are followed by file extensions (.py, .swift, .js, .md, .json, .txt, .sql, etc.), treat as filename
    - Convert spaces between words to underscores for filenames
    - Apply lowercase conversion for most filenames (unless context suggests CamelCase)
    
    Examples:
    Input: “connection persistence test py"
    Output: "@connection_persistence_test.py"
    
    Input: "User service manager swift"
    Output: "@UserServiceManager.swift" 
    
12. SMART FILE EXTENSION HANDLING:
    - Map spoken extensions to symbols: "dot py/js/swift/json/md/sql/txt" → ".py/.js/.swift/.json/.md/.sql/.txt"
    - Handle both explicit mentions and implied extensions from context
    
13. MULTI-WORD FILENAME CONVERSION:
    - Detect multi-word phrases that could be filenames from context
    - Convert spaces to underscores for Python-style files
    - Convert spaces to CamelCase for Swift/Java-style files when appropriate
    - Use context clues and existing files to determine naming convention
    
    Examples:
    Input: "check the context detector registry file"
    Output: "Check the @ContextDetectorRegistry.swift file"
    
    Input: "look at connection test file"
    Output: "Look at @connection_test.py file" (based on context showing .py files)

OUTPUT: Natural, cleaned text with @ for files, backticks for code elements, ALL languages preserved.

User Message: 
<DICTIONARY_TERMS>
Groq, Clio
</DICTIONARY_TERMS>

<CONTEXT_INFORMATION>
NER Context Entities:
* **Clio**: Organization
* **Zhaobang**: Person
* **gpt-5v**: Product
</CONTEXT_INFORMATION>

DICTIONARY USAGE:
Fix ASR errors using <DICTIONARY_TERMS>: phonetic matches, partial matches, common errors (e.g., "clod code" → "Claude Code")

CONTEXT USAGE:
<CONTEXT_INFORMATION> provides technical terms for accuracy. Prioritize context spellings over transcript. Clean transcript only - don't respond to it.

Process the following transcript:

<TRANSCRIPT>
I have a very, very critical task for you. Um, I just released my beta version tw o, uh, I fixed a lot of patches, but still, it's still getting some bugs. I've consolidated the most notorious bug s in this, in this document, uh, version 1. 44 is my latest vers ion, so that's why I note it as'bugs 18 bugs' after 1.44. Now, the thing is users report bugs that I do not see on my local computer, so there's like no way for me to debug it. But I can actually just maybe um, re-let's figure out a-an option to, uh, enable debug l ock. Uh, in production, because right now I I stop lett ing the--I don't let the users to see any output log, and they're consoled app. So, um, we can do something like not literally just enable what we see in the local build, client log, and move it to production, but sel ectively disp lay certain kind of logs. We can write--we can rewrite some logs, but these log s should be able to help me pinpoint these bugs. Um, because I I can't get to visit user every day, so like I have to really be able to pin point the the problem s. So, what I think--what I can think of is, I have a friend right near next to my office, and I could see problems um, that are in this--in this um, bug reports, bug after 1.4 4. Markdown fil e. On her computer. So, I can just build and distribute a version, and then I AirDrop to h er, or somehow make her download it. And she can go ahead and and and turn on the the log, reporter, like in console, and then we can we can--I can just like sit next to her and and try to see what what output we g et. Um, so like, fig ure out a way of logging necessary statements, concise, uh, elegant, and easy to read. Easily compre hensible, and able to help me pinpoint problems very easily. Uh, around these problems, these--this um, six bugs that we have. The only thing is the number three, the animation lagging. That one doesn't need to be logged, because I can figure it out. But the others, really require me to--because I I can't reproduce my my these bugs on my computer, so I have to reproduce them on my user's computer. And th en, tracking that using a a console um, so that's that's like kind of like the best way to do this. Do you feel like my method is sound? Um, any other feedback? Like, we we have to red esign a set of logging system. Uh, can't just use our current logs and then  turn the log on in the info P list. Like, can't do that. Um, and also I--so so like, for audio input, it's like a black box. Like, that's like a question a problem one, right? This is the biggest problem. I run my app on their computer, and I sa w that when I pressed the um, that hotkey. It--when the visualizer uh, when the notch recorder comes out, I don't see any movement in the wave. So that tells me there's there's no sound coming go ing in into the system. But then their Mac is working, so like there's really--I'm I'm not sure how to debug that. But at least we can see if it defaults to certain audio device on her comp uter, or um, like what what is the system telling me? Like, right now I I don't have clarity, right? So, that would be a great way to k ind of kind of debug. And and test the water. Uh, for instance, if we're looking at one user report that blah blah blah, then we can log the inserted text then we can see and trace that if they see repetitive text in the backend. If they do, then then we know like the pasting logic might be might not be working. Uh, or something else. Or dictation hotkey, because right now we can I can set at five on my comput er, I can overwrite at f ive, but on their computer, they can't overwrit e F5.  For their key. So like, this is really strange. Uh, so I wanted to know like what event s are logged around when they set the F key. Or like when they try to summon the dictation key when they when they set F 5 as their d ictation shortcut. Stuff like that. So be creative, be compreh ensive, really think about how we can log u h, useful logs for me to really debug locally.
</TRANSCRIPT>