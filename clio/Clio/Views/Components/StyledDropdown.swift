import SwiftUI

struct StyledDropdown<T: Hashable>: View {
    let title: String
    let icon: String
    let options: [T]
    let selectedOption: T?
    let defaultText: String
    let optionDisplayText: (T) -> String
    let onSelectionChanged: (T?) -> Void
    
    @State private var isHovered = false
    
    init(
        title: String = "",
        icon: String,
        options: [T],
        selectedOption: T?,
        defaultText: String = "Select option",
        optionDisplayText: @escaping (T) -> String = { "\($0)" },
        onSelectionChanged: @escaping (T?) -> Void
    ) {
        self.title = title
        self.icon = icon
        self.options = options
        self.selectedOption = selectedOption
        self.defaultText = defaultText
        self.optionDisplayText = optionDisplayText
        self.onSelectionChanged = onSelectionChanged
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: title.isEmpty ? 0 : 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DarkTheme.textPrimary)
            }
            
            Menu {
                if !defaultText.isEmpty {
                    Button(defaultText) {
                        onSelectionChanged(nil)
                    }
                    
                    if !options.isEmpty {
                        Divider()
                    }
                }
                
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    Button(optionDisplayText(option)) {
                        onSelectionChanged(option)
                    }
                }
            } label: {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundColor(DarkTheme.textSecondary)
                        
                        Text(selectedOption != nil ? optionDisplayText(selectedOption!) : defaultText)
                            .font(.system(size: 13))
                            .foregroundColor(DarkTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(DarkTheme.textSecondary)
                        .rotationEffect(.degrees(isHovered ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(DarkTheme.surfaceBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    isHovered ? 
                                        Color.accentColor.opacity(0.5) : 
                                        DarkTheme.textSecondary.opacity(0.2), 
                                    lineWidth: 1
                                )
                        )
                )
                .scaleEffect(isHovered ? 1.02 : 1.0)
                .shadow(
                    color: isHovered ? Color.accentColor.opacity(0.1) : .clear,
                    radius: isHovered ? 8 : 0
                )
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
        }
    }
}

// MARK: - Convenience Initializers

extension StyledDropdown where T == String {
    init(
        title: String = "",
        icon: String,
        options: [String],
        selectedOption: String?,
        defaultText: String = "Select option",
        onSelectionChanged: @escaping (String?) -> Void
    ) {
        self.init(
            title: title,
            icon: icon,
            options: options,
            selectedOption: selectedOption,
            defaultText: defaultText,
            optionDisplayText: { $0 },
            onSelectionChanged: onSelectionChanged
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        StyledDropdown(
            title: "Recognition Model",
            icon: "cpu",
            options: ["Whisper Tiny", "Whisper Base", "Whisper Large v3"],
            selectedOption: "Whisper Large v3",
            defaultText: "System Default"
        ) { selection in
            print("Selected: \(selection ?? "Default")")
        }
        
        StyledDropdown(
            icon: "globe",
            options: ["English", "Spanish", "French", "German"],
            selectedOption: nil,
            defaultText: "Choose Language"
        ) { selection in
            print("Language: \(selection ?? "Auto")")
        }
        
        StyledDropdown(
            title: "AI Provider",
            icon: "brain.head.profile",
            options: ["OpenAI", "Anthropic", "Gemini", "Ollama"],
            selectedOption: "OpenAI",
            defaultText: "Select Provider"
        ) { selection in
            print("Provider: \(selection ?? "None")")
        }
    }
    .padding(40)
    .background(DarkTheme.cardBackground)
} 