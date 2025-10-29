import SwiftUI
import Foundation

struct AIEditingStrengthView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @AppStorage("ai.editingStrength") private var strengthRaw: String = AIEditingStrength.full.rawValue

    private var strength: AIEditingStrength {
        get { AIEditingStrength(rawValue: strengthRaw) ?? .light }
        set { strengthRaw = newValue.rawValue }
    }

    // Sample preview content (static) to illustrate the difference
    private let sampleInput = "嗯 我第一次去 Kyoto 的时候 是在 April 吧 哦不是 是 March 的时候 就是 Sakura season 还没完全开始的时候 但已经很 gorgeous 了"
    private let sampleLight = "我第一次去 Kyoto 的时候，是在 March 的时候，Sakura season 还没完全开始的时候，但已经很 gorgeous 了"
    private let sampleFull = "我第一次去 Kyoto，是在 March。Sakura season 还没完全开始，但已经很 gorgeous。"

    @State private var editingPromptStrength: AIEditingStrength?
    @State private var promptDraft: String = ""
    @State private var lightHasCustomPrompt: Bool = AIPrompts.hasPromptOverride(for: .light)
    @State private var fullHasCustomPrompt: Bool = AIPrompts.hasPromptOverride(for: .full)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                enhancementToggleRow
                    .padding(.horizontal, 40)

                HStack(alignment: .top, spacing: 16) {
                    strengthColumn(
                        title: localizationManager.localizedString("ai_strength.light.title"),
                        subtitle: localizationManager.localizedString("ai_strength.light.subtitle"),
                        bullets: [
                            localizationManager.localizedString("ai_strength.light.bullet1"),
                            localizationManager.localizedString("ai_strength.light.bullet2"),
                            localizationManager.localizedString("ai_strength.light.bullet3")
                        ],
                        icon: "leaf",
                        selected: strength == .light,
                        hasCustomPrompt: lightHasCustomPrompt,
                        onSelect: { strengthRaw = AIEditingStrength.light.rawValue },
                        onEdit: { beginEditing(.light) }
                    )

                    strengthColumn(
                        title: localizationManager.localizedString("ai_strength.full.title"),
                        subtitle: localizationManager.localizedString("ai_strength.full.subtitle"),
                        bullets: [
                            localizationManager.localizedString("ai_strength.full.bullet1"),
                            localizationManager.localizedString("ai_strength.full.bullet2"),
                            localizationManager.localizedString("ai_strength.full.bullet3")
                        ],
                        icon: "scribble.variable",
                        selected: strength == .full,
                        hasCustomPrompt: fullHasCustomPrompt,
                        onSelect: { strengthRaw = AIEditingStrength.full.rawValue },
                        onEdit: { beginEditing(.full) }
                    )
                }
                .padding(.horizontal, 40)
                .opacity(enhancementService.isEnhancementEnabled ? 1 : 0.45)
                .disabled(!enhancementService.isEnhancementEnabled)

                // previewSection has been intentionally disabled per design request
                // previewSection
                //    .padding(.horizontal, 40)
                //    .padding(.bottom, 40)
            }
            .padding(.top, 32)
        }
        // Match Personal Terms page base size
        .frame(minWidth: 600, minHeight: 500)
        .onChange(of: strengthRaw) { _ in
            // Post a notification so services can react immediately (AIEnhancementService will observe this later)
            NotificationCenter.default.post(name: Notification.Name("AIEditingStrengthChanged"), object: nil)
        }
        .onAppear {
            refreshCustomFlags()
        }
        .sheet(item: $editingPromptStrength) { strength in
            PromptEditorSheet(
                strength: strength,
                text: $promptDraft,
                onSave: {
                    AIPrompts.savePromptOverride(promptDraft, for: strength)
                    refreshCustomFlags()
                    editingPromptStrength = nil
                },
                onCancel: {
                    editingPromptStrength = nil
                }
            )
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(localizationManager.localizedString("ai_strength.title"))
                .fontScaled(size: 30, weight: .semibold)
                .foregroundColor(DarkTheme.textPrimary)
            Text(localizationManager.localizedString("ai_strength.subtitle"))
                .fontScaled(size: 14)
                .foregroundColor(DarkTheme.textSecondary)
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 16)
    }

    private var enhancementToggleRow: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(DarkTheme.accent.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "pencil.and.scribble")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DarkTheme.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(localizationManager.localizedString("settings.ai_enhancement"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                Text(localizationManager.localizedString("settings.ai_enhancement.description"))
                    .font(.system(size: 12))
                    .foregroundColor(DarkTheme.textSecondary)
                Text(
                    localizationManager.localizedString(
                        enhancementService.isEnhancementEnabled ? "ai_strength.toggle.on_hint" : "ai_strength.toggle.off_hint"
                    )
                )
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DarkTheme.textSecondary.opacity(0.9))
            }

            Spacer()

            Toggle("", isOn: enhancementToggleBinding)
                .toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
                .scaleEffect(1.0)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colorScheme == .dark ? DarkTheme.textPrimary.opacity(0.07) : Color.black.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(DarkTheme.textPrimary.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private var enhancementToggleBinding: Binding<Bool> {
        Binding(
            get: { enhancementService.isEnhancementEnabled },
            set: { enhancementService.isEnhancementEnabled = $0 }
        )
    }

    private func strengthColumn(title: String, subtitle: String, bullets: [String], icon: String, selected: Bool, hasCustomPrompt: Bool, onSelect: @escaping () -> Void, onEdit: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            strengthCard(
                title: title,
                subtitle: subtitle,
                bullets: bullets,
                icon: icon,
                selected: selected,
                onTap: onSelect
            )

            editPromptButton(
                label: localizationManager.localizedString("power_mode.modal.edit_prompt"),
                hasCustomPrompt: hasCustomPrompt,
                onEdit: onEdit
            )
        }
        .frame(maxWidth: .infinity)
    }

    private func strengthCard(title: String, subtitle: String, bullets: [String], icon: String, selected: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DarkTheme.accent)
                        .frame(width: 18, height: 18)
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                    if title == localizationManager.localizedString("ai_strength.full.title") {
                        Text(localizationManager.localizedString("badge.recommended"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(DarkTheme.accent)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                            .background(
                                Capsule()
                                    .fill(DarkTheme.accent.opacity(0.15))
                            )
                            .padding(.leading, 6)
                    }
                    if selected {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DarkTheme.accent)
                    }
                }
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(DarkTheme.textSecondary)

                ForEach(bullets, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Circle().fill(DarkTheme.textSecondary.opacity(0.6)).frame(width: 4, height: 4).padding(.top, 6)
                        Text(item)
                            .font(.system(size: 12))
                            .foregroundColor(DarkTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(20)
            // Ensure both cards share the same size and are a bit taller
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(colorScheme == .dark ? DarkTheme.textPrimary.opacity(selected ? 0.15 : 0.08) : Color.black.opacity(selected ? 0.08 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selected ? DarkTheme.accent.opacity(0.6) : DarkTheme.textPrimary.opacity(0.15), lineWidth: selected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func editPromptButton(label: String, hasCustomPrompt: Bool, onEdit: @escaping () -> Void) -> some View {
        Button(action: onEdit) {
            HStack(spacing: 10) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                Spacer()
                if hasCustomPrompt {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DarkTheme.accent)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(DarkTheme.accent.opacity(0.15))
                        )
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? DarkTheme.textPrimary.opacity(0.08) : Color.black.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(hasCustomPrompt ? DarkTheme.accent.opacity(0.35) : DarkTheme.textPrimary.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func beginEditing(_ strength: AIEditingStrength) {
        promptDraft = AIPrompts.currentPrompt(for: strength)
        editingPromptStrength = strength
    }

    private func refreshCustomFlags() {
        lightHasCustomPrompt = AIPrompts.hasPromptOverride(for: .light)
        fullHasCustomPrompt = AIPrompts.hasPromptOverride(for: .full)
    }

    // MARK: - Preview section disabled
    //    private var previewSection: some View {
    //        VStack(alignment: .leading, spacing: 12) {
    //            Text(localizationManager.localizedString("ai_strength.preview.title"))
    //                .font(.system(size: 14, weight: .semibold))
    //                .foregroundColor(DarkTheme.textPrimary)
    //
    //            VStack(spacing: 10) {
    //                labeledText(localizationManager.localizedString("ai_strength.preview.input"), sampleInput)
    //                if strength == .light {
    //                    labeledText(localizationManager.localizedString("ai_strength.preview.output_light"), sampleLight)
    //                } else {
    //                    labeledText(localizationManager.localizedString("ai_strength.preview.output_full"), sampleFull)
    //                }
    //            }
    //        }
    //    }

    private func labeledText(_ label: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(DarkTheme.textSecondary)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(DarkTheme.textPrimary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DarkTheme.textPrimary.opacity(0.06))
                )
        }
    }
}

private struct PromptEditorSheet: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    let strength: AIEditingStrength
    @Binding var text: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(DarkTheme.textSecondary)
            }

            TextEditor(text: $text)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .padding(16)
                .frame(minHeight: 320)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(editorBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(editorBorder, lineWidth: 1)
                        )
                )
                .scrollContentBackground(.hidden)

            Spacer(minLength: 0)

            HStack(spacing: 12) {
                Button(localizationManager.localizedString("general.cancel")) {
                    onCancel()
                    dismiss()
                }
                .font(.system(size: 14, weight: .semibold))
                .buttonStyle(.bordered)
                .controlSize(.large)
                .frame(minWidth: 110)

                Button(localizationManager.localizedString("general.reset")) {
                    text = AIPrompts.defaultPrompt(for: strength)
                }
                .font(.system(size: 14, weight: .semibold))
                .buttonStyle(.bordered)
                .controlSize(.large)
                .frame(minWidth: 110)

                Spacer()

                Button(localizationManager.localizedString("general.save")) {
                    onSave()
                    dismiss()
                }
                .font(.system(size: 14, weight: .semibold))
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(DarkTheme.accent)
                .frame(minWidth: 120)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(28)
        .frame(minWidth: 640, minHeight: 520)
    }

    private var title: String {
        switch strength {
        case .light:
            return localizationManager.localizedString("ai_strength.light.title")
        case .full:
            return localizationManager.localizedString("ai_strength.full.title")
        }
    }

    private var subtitle: String {
        switch strength {
        case .light:
            return localizationManager.localizedString("ai_strength.light.subtitle")
        case .full:
            return localizationManager.localizedString("ai_strength.full.subtitle")
        }
    }

    private var editorBackground: Color {
        colorScheme == .dark ? DarkTheme.textPrimary.opacity(0.06) : Color.black.opacity(0.04)
    }

    private var editorBorder: Color {
        colorScheme == .dark ? DarkTheme.textPrimary.opacity(0.12) : Color.black.opacity(0.08)
    }
}
