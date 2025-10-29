import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var feedbackType: FeedbackType = .issue
    @State private var userEmail: String = ""
    @State private var message: String = ""
    @State private var isBlockingIssue: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    enum FeedbackType: String, CaseIterable {
        case issue = "Report an issue"
        case feedback = "Share feedback"
        
        var localizedTitle: String {
            switch self {
            case .issue:
                return LocalizationManager.shared.localizedString("feedback.tab.report_issue")
            case .feedback:
                return LocalizationManager.shared.localizedString("feedback.tab.share_feedback")
            }
        }
        
        var placeholder: String {
            switch self {
            case .issue:
                return LocalizationManager.shared.localizedString("feedback.placeholder.issue")
            case .feedback:
                return LocalizationManager.shared.localizedString("feedback.placeholder.feedback")
            }
        }
        
        var subject: String {
            switch self {
            case .issue:
                return LocalizationManager.shared.localizedString("feedback.subject.bug_report")
            case .feedback:
                return LocalizationManager.shared.localizedString("feedback.subject.general_feedback")
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Tab Selection
            tabSelectionView
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            
            // Form Content
            ScrollView {
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizationManager.localizedString("feedback.field.email"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DarkTheme.textSecondary)
                        
                        DarkTextField(
                            placeholder: localizationManager.localizedString("feedback.placeholder.email"),
                            text: $userEmail
                        )
                        .accessibilityLabel("Email address (optional)")
                    }
                    
                    // Message Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizationManager.localizedString("feedback.field.message"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DarkTheme.textSecondary)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $message)
                                .font(.system(size: 14))
                                .scrollContentBackground(.hidden)
                                .background(DarkTheme.surfaceBackground)
                                .foregroundColor(DarkTheme.textPrimary)
                                .frame(minHeight: 120)
                                .padding(.horizontal, 2)
                                .padding(.vertical, 8)
                            if message.isEmpty {
                                Text(feedbackType.placeholder)
                                    .foregroundColor(DarkTheme.textTertiary)
                                    .padding(.top, 14)
                                    .padding(.leading, 8)
                                    .allowsHitTesting(false)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(DarkTheme.surfaceBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(DarkTheme.border, lineWidth: 1)
                        )
                        .accessibilityLabel("Message content")
                        .accessibilityValue(message.isEmpty ? feedbackType.placeholder : message)
                    }
                    
                    // Blocking Issue Toggle (only for bug reports)
                    if feedbackType == .issue {
                        blockingIssueToggle
                    }
                    
                    // System Info Preview
                    systemInfoView
                }
                .padding(.horizontal, 24)
            }
            
            Divider()
                .foregroundColor(DarkTheme.border)
                .padding(.top, 20)
            
            // Footer
            footerView
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .frame(width: 500, height: 600)
        .onExitCommand {
            dismiss()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Feedback Form")
        .alert(localizationManager.localizedString("feedback.success.title"), isPresented: $showSuccessAlert) {
            Button(localizationManager.localizedString("general.ok")) {
                dismiss()
            }
        } message: {
            Text(localizationManager.localizedString("feedback.success.message"))
        }
        .alert(localizationManager.localizedString("feedback.error.title"), isPresented: $showErrorAlert) {
            Button(localizationManager.localizedString("general.ok")) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationManager.localizedString("feedback.title"))
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                    
                    Text(localizationManager.localizedString("feedback.subtitle"))
                        .font(.system(size: 14))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
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
    
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            ForEach(FeedbackType.allCases, id: \.self) { type in
                Button(action: { 
                    feedbackType = type
                    message = "" // Clear message when switching tabs
                }) {
                    Text(type.localizedTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(feedbackType == type ? DarkTheme.textPrimary : DarkTheme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Group {
                                if feedbackType == type {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(DarkTheme.accent.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(DarkTheme.accent.opacity(0.3), lineWidth: 1)
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.clear)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
    }
    
    private var blockingIssueToggle: some View {
        HStack(spacing: 12) {
            Button(action: { isBlockingIssue.toggle() }) {
                Image(systemName: isBlockingIssue ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isBlockingIssue ? DarkTheme.accent : DarkTheme.textTertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Mark as blocking issue")
            .accessibilityValue(isBlockingIssue ? "Enabled" : "Disabled")
            
            Text(localizationManager.localizedString("feedback.checkbox.blocking"))
                .font(.system(size: 14))
                .foregroundColor(DarkTheme.textSecondary)
            
            Spacer()
        }
    }
    
    private var systemInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(DarkTheme.textSecondary)
                
                Text(localizationManager.localizedString("feedback.info.system_info"))
                    .font(.system(size: 12))
                    .foregroundColor(DarkTheme.textSecondary)
                
                Spacer()
            }
            
            Text("• App Version: \(getAppVersion())\n• macOS: \(getOSVersion())\n• Device: \(getDeviceInfo())")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(DarkTheme.textTertiary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .glassmorphismCard(cornerRadius: 8)
        }
    }
    
    private var footerView: some View {
        VStack(spacing: 16) {
            // HStack {
            //     Text("To troubleshoot, check out our ")
            //         .font(.system(size: 12))
            //         .foregroundColor(DarkTheme.textSecondary)
            //     +
            //     Text("User Guide")
            //         .font(.system(size: 12, weight: .medium))
            //         .foregroundColor(DarkTheme.accent)
            //     
            //     Spacer()
            //     
            //     Image(systemName: "paperclip")
            //         .font(.system(size: 14))
            //         .foregroundColor(DarkTheme.textTertiary)
            // }
            
            HStack(spacing: 12) {
                Button(localizationManager.localizedString("general.cancel")) {
                    dismiss()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(DarkTheme.textSecondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DarkTheme.surfaceBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(DarkTheme.border, lineWidth: 1)
                        )
                )
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: submitFeedback) {
                    HStack(spacing: 8) {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(0.8)
                        } else {
                            Text(localizationManager.localizedString("feedback.button.send"))
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? DarkTheme.textTertiary : DarkTheme.accent)
                    )
                }
                .buttonStyle(.plain)
                .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                .keyboardShortcut(.return, modifiers: .command)
                .accessibilityLabel("Send feedback message")
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    // MARK: - Actions
    
    private func submitFeedback() {
        isSubmitting = true
        
        Task {
            do {
                try await sendToFormSubmit()
                await MainActor.run {
                    showSuccessAlert = true
                    isSubmitting = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                    isSubmitting = false
                }
            }
        }
    }
    
    private func sendToFormSubmit() async throws {
        let url = URL(string: "https://formsubmit.co/ajax/zhaobang.jet.wu@gmail.com")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Some FormSubmit protections expect browser-like headers for AJAX endpoints
        request.setValue("https://cliovoice.com", forHTTPHeaderField: "Origin")
        request.setValue("https://cliovoice.com/feedback", forHTTPHeaderField: "Referer")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        let systemInfo = """
        
        ---
        System Information:
        App Version: \(getAppVersion())
        macOS: \(getOSVersion())
        Device: \(getDeviceInfo())
        Timestamp: \(Date().ISO8601Format())
        Blocking Issue: \(isBlockingIssue ? "Yes" : "No")
        """
        
        let fullMessage = message.trimmingCharacters(in: .whitespacesAndNewlines) + systemInfo
        let subjectLine = isBlockingIssue && feedbackType == .issue ? 
            localizationManager.localizedString("feedback.subject.urgent_bug") :
            String(format: localizationManager.localizedString("feedback.subject.bug_format"), feedbackType.subject)
        
        let body: [String: Any] = [
            "_subject": subjectLine,
            "email": userEmail.isEmpty ? "anonymous@cliovoice.com" : userEmail,
            "message": fullMessage,
            "type": feedbackType.rawValue,
            "_template": "table",
            "_captcha": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw FeedbackError.invalidResponse
        }

        // Always inspect JSON body as FormSubmit returns success information there
        if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // success can be a string "true"/"false" in FormSubmit responses
            let successString = responseData["success"] as? String
            let successBool = responseData["success"] as? Bool
            let message = responseData["message"] as? String
            let isSuccess = successBool == true || successString == "true"
            if !isSuccess {
                if let message = message, message.lowercased().contains("activation") {
                    throw FeedbackError.activationRequired
                }
                if httpResponse.statusCode >= 400 {
                    throw FeedbackError.httpError(statusCode: httpResponse.statusCode)
                }
                throw FeedbackError.submissionFailed
            }
        } else if httpResponse.statusCode >= 400 {
            throw FeedbackError.httpError(statusCode: httpResponse.statusCode)
        }
    }
    
    // MARK: - System Info Helpers
    
    private func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
    
    private func getOSVersion() -> String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
    
    private func getDeviceInfo() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }
}

// MARK: - Error Types

enum FeedbackError: LocalizedError {
    case invalidResponse
    case submissionFailed
    case httpError(statusCode: Int)
    case activationRequired
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return LocalizationManager.shared.localizedString("feedback.error.invalid_response")
        case .submissionFailed:
            return LocalizationManager.shared.localizedString("feedback.error.submission_failed")
        case .httpError(let statusCode):
            return String(format: LocalizationManager.shared.localizedString("feedback.error.http_error"), statusCode)
        case .activationRequired:
            return LocalizationManager.shared.localizedString("feedback.error.activation_required")
        }
    }
}

// MARK: - Custom Text View

struct MacTextView: NSViewRepresentable {
    @Binding var text: String
    // Placeholder is now handled by a SwiftUI overlay. Keep the property to
    // avoid large callsite changes but do not render it inside NSTextView.
    let placeholder: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        // Configure scroll view
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.documentView = textView
        
        // Configure text view
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isRichText = false
        textView.font = NSFont.systemFont(ofSize: 14)
        textView.textColor = NSColor.controlTextColor
        textView.backgroundColor = NSColor.controlBackgroundColor
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        
        // Add background and border
        scrollView.wantsLayer = true
        scrollView.layer?.cornerRadius = 12
        scrollView.layer?.borderWidth = 1
        scrollView.layer?.borderColor = NSColor.separatorColor.cgColor
        scrollView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        // Set delegate
        textView.delegate = context.coordinator
        
        // Do not inject placeholder text into the NSTextView; SwiftUI overlays
        // a placeholder above this view so the text view always remains
        // editable when focused.
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        if textView.string != text {
            textView.string = text
            textView.textColor = NSColor.controlTextColor
        }
    }
    
    // Placeholder is rendered by SwiftUI overlay; nothing to do here.
    private func updatePlaceholder(textView: NSTextView) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: MacTextView
        
        init(_ parent: MacTextView) {
            self.parent = parent
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            // No-op: placeholder is not injected into the text view
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            // Ensure normal text color when typing
            textView.textColor = NSColor.controlTextColor
            
            DispatchQueue.main.async {
                self.parent.text = textView.string
            }
        }
        
        func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            // Keep binding in sync after editing ends
            DispatchQueue.main.async {
                self.parent.text = textView.string.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
}

// MARK: - Preview

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
            .preferredColorScheme(.dark)
    }
}