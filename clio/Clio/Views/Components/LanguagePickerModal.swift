import SwiftUI

struct LanguagePickerModal: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss
    @State private var animateElements = false
    @State private var hoveredLanguage: String? = nil
    
    private let languages = LocalizationManager.supportedLanguages
    
    // Language flag emojis mapping
    private func flagForLanguage(_ code: String) -> String {
        switch code {
        case "en": return "🇺🇸"
        case "es": return "🇪🇸" 
        case "fr": return "🇫🇷"
        case "de": return "🇩🇪"
        case "it": return "🇮🇹"
        case "ja": return "🇯🇵"
        case "ko": return "🇰🇷"
        case "zh-Hans": return "🇨🇳"
        case "zh-Hant": return "🇹🇼"
        case "ru": return "🇷🇺"
        case "hi": return "🇮🇳"
        default: return "🌐"
        }
    }
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Modal content
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("App Language")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(DarkTheme.textPrimary)
                    
                    Text("Choose your interface language")
                        .font(.system(size: 14))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                .padding(.top, 32)
                .padding(.bottom, 24)
                
                // Language grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(languages, id: \.code) { language in
                            ModalLanguageCard(
                                code: language.code,
                                name: language.name,
                                nativeName: language.nativeName,
                                flag: flagForLanguage(language.code),
                                isSelected: language.code == localizationManager.currentLanguage,
                                isHovered: hoveredLanguage == language.code,
                                action: {
                                    // Immediate selection with haptic feedback
                                    NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
                                    localizationManager.setLanguage(language.code)
                                    
                                    // Brief delay for visual feedback, then dismiss
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        dismiss()
                                    }
                                }
                            )
                            .scaleEffect(animateElements ? 1.0 : 0.8)
                            .opacity(animateElements ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(languages.firstIndex(where: { $0.code == language.code }) ?? 0) * 0.05), value: animateElements)
                            .onHover { hovering in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    hoveredLanguage = hovering ? language.code : nil
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxHeight: 400)
                
                Spacer()
            }
            .frame(width: 500, height: 600)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(animateElements ? 1.0 : 0.9)
            .opacity(animateElements ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateElements)
        }
        .onAppear {
            withAnimation {
                animateElements = true
            }
        }
    }
}

struct ModalLanguageCard: View {
    let code: String
    let name: String
    let nativeName: String
    let flag: String
    let isSelected: Bool
    let isHovered: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Flag
                Text(flag)
                    .font(.system(size: 32))
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isHovered)
                
                // Language names
                VStack(spacing: 4) {
                    Text(nativeName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .accentColor : DarkTheme.textPrimary)
                    
                    Text(name)
                        .font(.system(size: 13))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                .multilineTextAlignment(.center)
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.accentColor)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    // Placeholder to maintain consistent height
                    Color.clear
                        .frame(height: 16)
                }
            }
            .frame(width: 140, height: 120)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ? 
                            Color.accentColor.opacity(0.15) :
                            (isHovered ? DarkTheme.textPrimary.opacity(0.05) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? 
                                    Color.accentColor.opacity(0.6) : 
                                    (isHovered ? DarkTheme.textPrimary.opacity(0.2) : Color.clear),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.3), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LanguagePickerModal()
        .environmentObject(LocalizationManager.shared)
}
