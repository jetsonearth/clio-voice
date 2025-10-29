import SwiftUI

struct StandardModal<Content: View>: View {
    let title: String
    let width: CGFloat
    let height: CGFloat?
    let onClose: () -> Void
    let primaryButtonTitle: String?
    let primaryButtonAction: (() -> Void)?
    let isPrimaryButtonEnabled: Bool
    let secondaryButtonTitle: String?
    let secondaryButtonAction: (() -> Void)?
    let content: Content
    // Optional: customize the title font size for specific modals
    let titleFontSize: CGFloat?
    
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    init(
        title: String,
        width: CGFloat = 420,
        height: CGFloat? = nil,
        onClose: @escaping () -> Void,
        primaryButtonTitle: String? = nil,
        primaryButtonAction: (() -> Void)? = nil,
        isPrimaryButtonEnabled: Bool = true,
        secondaryButtonTitle: String? = nil,
        secondaryButtonAction: (() -> Void)? = nil,
        titleFontSize: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.width = width
        self.height = height
        self.onClose = onClose
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonAction = primaryButtonAction
        self.isPrimaryButtonEnabled = isPrimaryButtonEnabled
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonAction = secondaryButtonAction
        self.content = content()
        self.titleFontSize = titleFontSize
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            headerView
            
            // Main content
            ScrollView {
                VStack(spacing: 20) {
                    content
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            
            // Footer with buttons (only show if there are buttons)
            if hasFooterButtons {
                Divider()
                    .foregroundColor(DarkTheme.border)
                
                footerView
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .frame(width: width, height: height)
        .onExitCommand {
            onClose()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: titleFontSize ?? 24, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DarkTheme.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(DarkTheme.surfaceBackground)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)
        }
    }
    
    private var footerView: some View {
        HStack(spacing: 12) {
            // Secondary button (usually Cancel)
            if let secondaryTitle = secondaryButtonTitle {
                Button(secondaryTitle) {
                    secondaryButtonAction?()
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DarkTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(DarkTheme.surfaceBackground)
                        .overlay(
                            Capsule()
                                .stroke(DarkTheme.border, lineWidth: 1)
                        )
                )
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            
            Spacer()
            
            // Primary button (usually Save/Submit)
            if let primaryTitle = primaryButtonTitle {
                Button(action: {
                    primaryButtonAction?()
                }) {
                    Text(primaryTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isPrimaryButtonEnabled ? DarkTheme.accent : DarkTheme.textTertiary)
                        )
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .disabled(!isPrimaryButtonEnabled)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
    }
    
    private var hasFooterButtons: Bool {
        primaryButtonTitle != nil || secondaryButtonTitle != nil
    }
}

// MARK: - Convenience Initializers

extension StandardModal {
    /// Create a modal with Save/Cancel buttons
    static func saveCancel<T: View>(
        title: String,
        width: CGFloat = 420,
        height: CGFloat? = nil,
        onSave: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        isSaveEnabled: Bool = true,
        @ViewBuilder content: () -> T
    ) -> StandardModal<T> {
        StandardModal<T>(
            title: title,
            width: width,
            height: height,
            onClose: onCancel,
            primaryButtonTitle: LocalizationManager.shared.localizedString("general.save"),
            primaryButtonAction: onSave,
            isPrimaryButtonEnabled: isSaveEnabled,
            secondaryButtonTitle: LocalizationManager.shared.localizedString("general.cancel"),
            secondaryButtonAction: onCancel,
            content: content
        )
    }
    
    /// Create a modal with only a close button (no footer buttons)
    static func closeOnly<T: View>(
        title: String,
        width: CGFloat = 420,
        height: CGFloat? = nil,
        onClose: @escaping () -> Void,
        @ViewBuilder content: () -> T
    ) -> StandardModal<T> {
        StandardModal<T>(
            title: title,
            width: width,
            height: height,
            onClose: onClose,
            content: content
        )
    }
    
    /// Create a modal with custom button configuration
    static func custom<T: View>(
        title: String,
        width: CGFloat = 420,
        height: CGFloat? = nil,
        onClose: @escaping () -> Void,
        primaryButton: (title: String, action: () -> Void, enabled: Bool)? = nil,
        secondaryButton: (title: String, action: () -> Void)? = nil,
        @ViewBuilder content: () -> T
    ) -> StandardModal<T> {
        StandardModal<T>(
            title: title,
            width: width,
            height: height,
            onClose: onClose,
            primaryButtonTitle: primaryButton?.title,
            primaryButtonAction: primaryButton?.action,
            isPrimaryButtonEnabled: primaryButton?.enabled ?? true,
            secondaryButtonTitle: secondaryButton?.title,
            secondaryButtonAction: secondaryButton?.action,
            content: content
        )
    }
}