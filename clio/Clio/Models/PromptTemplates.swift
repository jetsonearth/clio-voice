import Foundation

struct TemplatePrompt: Identifiable {
    let id: UUID
    let title: String
    let promptText: String
    let icon: PromptIcon
    let description: String
    
    func toCustomPrompt() -> CustomPrompt {
        CustomPrompt(
            id: UUID(),  // Generate new UUID for custom prompt
            title: title,
            promptText: promptText,
            icon: icon,
            description: description,
            isPredefined: false
        )
    }
}

enum PromptTemplates {
    static var all: [TemplatePrompt] {
        createTemplatePrompts()
    }
    
    static func createTemplatePrompts() -> [TemplatePrompt] {
        [
            TemplatePrompt(
                id: UUID(),
                title: "Default",
                promptText: """
                Clean this transcript while maintaining conversational tone.
                Break into logical paragraphs if needed.
                
                \(MultilingualPrompts.getFewShotExamples())
                """.trimmingCharacters(in: .whitespacesAndNewlines),
                icon: .sealedFill,
                description: "Default mode to improve clarity and accuracy of the transcription"
            ),
            
            TemplatePrompt(
                id: UUID(),
                title: "Email",
                promptText: """
                Format as a professional business email:
                - Include appropriate greeting and closing
                - Organize into clear paragraphs with professional tone
                - Present action items, requests, or important details clearly
                - Maintain multilingual expressions if present in professional context
                
                \(MultilingualPrompts.getFewShotExamples())
                """.trimmingCharacters(in: .whitespacesAndNewlines),
                icon: .emailFill,
                description: "Template for converting casual messages into professional email format"
            ),
            
            // COMMENTED OUT - Meeting Notes template temporarily disabled
            /*
            TemplatePrompt(
                id: UUID(),
                title: "Meeting Notes",
                promptText: """
                    You are an AI assistant tasked with processing a voice-dictated transcript from a meeting and converting it into a structured format. Your goal is to repurpose the raw transcript into meeting notes, a summary, action items, and bullet points. This will help meeting participants and other stakeholders quickly understand the key points and outcomes of the meeting.

                    Here is the raw transcript from the voice dictation:

                    <transcript>
                    {{TRANSCRIPT}}
                    </transcript>

                    Please process this transcript and provide the following outputs:

                    1. Meeting Notes:
                    Create a structured set of meeting notes that capture the main topics discussed, decisions made, and any important details. Organize these notes in a logical order, using headings and subheadings as appropriate.

                    2. Summary:
                    Write a concise summary (2-3 paragraphs) that captures the essence of the meeting, including its purpose, main discussion points, and outcomes.

                    3. Action Items:
                    Identify and list all action items mentioned in the meeting. Each action item should include:
                    - The task to be completed
                    - The person responsible (if mentioned)
                    - Any deadlines or due dates (if specified)

                    4. Bullet Points:
                    Create a list of key takeaways or main points from the meeting in bullet point format. These should be concise and highlight the most important information from the discussion.

                    Please provide your output in the following format, using the specified XML tags:

                    <meeting_notes>
                    [Insert structured meeting notes here]
                    </meeting_notes>

                    <summary>
                    [Insert concise summary here]
                    </summary>

                    <action_items>
                    [Insert list of action items here]
                    </action_items>

                    <bullet_points>
                    [Insert list of key takeaways or main points here]
                    </bullet_points>

                    Ensure that your output is clear, concise, and accurately reflects the content of the original transcript. If there are any ambiguities or unclear portions in the transcript, use your best judgment to interpret the information, 
                    but do not add any speculative or fictional content.
                """,
                icon: .meetingFill,
                description: "Template for structuring meeting notes and action items"
            ),
            */
            
            // COMMENTED OUT - Additional templates temporarily disabled
            /*
            TemplatePrompt(
                id: UUID(),
                title: "Daily Journal",
                promptText: """
                Primary Rules:
                1. Preserve personal voice and emotional expression
                2. Keep personal tone and natural language
                3. Structure into morning, afternoon, evening sections
                4. Preserve emotions and reflections
                5. Highlight important moments
                6. Maintain chronological flow
                7. Keep authentic reactions and feelings

                Output Format:
                ### Morning
                Morning section

                ### Afternoon
                Afternoon section

                ### Evening
                Evening section

                Summary:: Key events, mood, highlights, learnings(Add it here)
                """,
                icon: .bookFill,
                description: "Template for converting voice notes into structured daily journal entries"
            ),
            
            TemplatePrompt(
                id: UUID(),
                title: "Task List",
                promptText: """
                Primary Rules:
                1. Preserve speaker's task organization style
                2. Convert into markdown checklist format
                3. Start each task with "- [ ]"
                4. Group related tasks together as subtasks
                5. Add priorities if mentioned
                6. Keep deadlines if specified
                7. Maintain original task descriptions

                Output Format:
                - [ ] Main task 1
                    - [ ] Subtask 1.1
                    - [ ] Subtask 1.2
                - [ ] Task 2 (Deadline: date)
                - [ ] Task 3
                    - [ ] Subtask 3.1
                - [ ] Follow-up item 1
                - [ ] Follow-up item 2
                """,
                icon: .pencilFill,
                description: "Template for converting voice notes into markdown task lists"
            ),
            
            TemplatePrompt(
                id: UUID(),
                title: "Quick Notes",
                promptText: """
                Primary Rules:
                1. Preserve speaker's thought process and emphasis
                2. Keep it brief and clear
                3. Use bullet points for key information
                4. Preserve important details
                5. Remove filler words while keeping style
                6. Maintain core message and intent
                7. Keep original terminology and phrasing

                Output Format:
                ## Main Topic
                • Main point 1
                  - Supporting detail
                  - Additional info
                • Main point 2
                  - Related informations
                """,
                icon: .micFill,
                description: "Template for converting voice notes into quick, organized notes"
            )
            */
            
        ]
    }
}
