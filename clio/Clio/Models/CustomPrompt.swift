import Foundation
import SwiftUI

enum PromptIcon: String, Codable, CaseIterable {
    // Document & Text
    case documentFill = "doc.text.fill"
    case textbox = "textbox"
    case sealedFill = "checkmark.seal.fill"
    
    // Communication
    case chatFill = "bubble.left.and.bubble.right.fill"
    case messageFill = "message.fill"
    case emailFill = "envelope.fill"
    
    // Professional
    case meetingFill = "person.2.fill"
    case presentationFill = "person.wave.2.fill"
    case briefcaseFill = "briefcase.fill"
    
    // Technical
    case codeFill = "curlybraces"
    case terminalFill = "terminal.fill"
    case gearFill = "gearshape.fill"
    
    // Content
    case blogFill = "doc.text.image.fill"
    case notesFill = "note"
    case bookFill = "book.fill"
    case bookmarkFill = "bookmark.fill"
    case pencilFill = "pencil.circle.fill"
    
    // Media & Creative
    case videoFill = "video.fill"
    case micFill = "mic.fill"
    case musicFill = "music.note"
    case photoFill = "photo.fill"
    case brushFill = "paintbrush.fill"
    
    var title: String {
        switch self {
        // Document & Text
        case .documentFill: return "Document"
        case .textbox: return "Textbox"
        case .sealedFill: return "Sealed"
            
        // Communication
        case .chatFill: return "Chat"
        case .messageFill: return "Message"
        case .emailFill: return "Email"
            
        // Professional
        case .meetingFill: return "Meeting"
        case .presentationFill: return "Presentation"
        case .briefcaseFill: return "Briefcase"
            
        // Technical
        case .codeFill: return "Code"
        case .terminalFill: return "Terminal"
        case .gearFill: return "Settings"
            
        // Content
        case .blogFill: return "Blog"
        case .notesFill: return "Notes"
        case .bookFill: return "Book"
        case .bookmarkFill: return "Bookmark"
        case .pencilFill: return "Edit"
            
        // Media & Creative
        case .videoFill: return "Video"
        case .micFill: return "Audio"
        case .musicFill: return "Music"
        case .photoFill: return "Photo"
        case .brushFill: return "Design"
        }
    }
}

struct CustomPrompt: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let promptText: String
    var isActive: Bool
    let icon: PromptIcon
    let description: String?
    let isPredefined: Bool
    let triggerWords: [String]
    
    init(
        id: UUID = UUID(),
        title: String,
        promptText: String,
        isActive: Bool = false,
        icon: PromptIcon = .documentFill,
        description: String? = nil,
        isPredefined: Bool = false,
        triggerWords: [String] = []
    ) {
        self.id = id
        self.title = title
        self.promptText = promptText
        self.isActive = isActive
        self.icon = icon
        self.description = description
        self.isPredefined = isPredefined
        self.triggerWords = triggerWords
    }
}

// MARK: - UI Extensions
extension CustomPrompt {
    func promptIcon(isSelected: Bool, onTap: @escaping () -> Void, onEdit: ((CustomPrompt) -> Void)? = nil, onDelete: ((CustomPrompt) -> Void)? = nil) -> some View {
        VStack(spacing: 8) {
            // Minimal background + icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Color.accentColor.opacity(0.35) : Color.primary.opacity(0.15), lineWidth: isSelected ? 1.5 : 1)
                    )
                    .shadow(color: Color.black.opacity(isSelected ? 0.18 : 0.10), radius: isSelected ? 10 : 6, x: 0, y: isSelected ? 5 : 3)

                Image(systemName: icon.rawValue)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .accentColor : .primary)
            }
            .frame(width: 48, height: 48)

            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .lineLimit(1)
                    .frame(maxWidth: 70)

                if let first = triggerWords.first {
                    HStack(spacing: 2) {
                        Image(systemName: "mic.fill").font(.system(size: 7))
                        Text("\"\(first)...\"\(triggerWords.count > 1 ? " +\(triggerWords.count - 1)" : "")")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: 70)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .onTapGesture(perform: onTap)
        .contextMenu {
            if let onEdit = onEdit {
                Button { onEdit(self) } label: { Label("Edit", systemImage: "pencil") }
            }
            if let onDelete = onDelete, !isPredefined {
                Button(role: .destructive) { onDelete(self) } label: { Label("Delete", systemImage: "trash") }
            }
        }
    }
    
    // Static method to create an "Add New" button with the same styling as the prompt icons
    static func addNewButton(action: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)

                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.accentColor)
            }
            .frame(width: 48, height: 48)

            VStack(spacing: 2) {
                Text("Add New")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: 70)

                Spacer().frame(height: 16)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
} 