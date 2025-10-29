import SwiftUI

struct HotkeyConflictModal: View {
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("F-key is currently used by the system")
                .font(.title3).bold()
            Text("To use this key as a single-key shortcut, choose one of the options below.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            VStack(alignment: .leading, spacing: 10) {
                Button("Open Keyboard settings (enable \"Use F1, F2…\")") {
                    hotkeyManager.openKeyboardSettings()
                }
                Button("Open Keyboard shortcuts (change Dictation)") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.keyboard?KeyboardShortcuts") {
                        NSWorkspace.shared.open(url)
                    } else {
                        hotkeyManager.openKeyboardSettings()
                    }
                }
                Button("Try Fn+F5 (no settings change)") {
                    onDismiss()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Button("Cancel") { onDismiss() }
                Spacer()
                Button("I changed it – Retry") {
                    hotkeyManager.retryRegisterCurrentHotkey()
                    onDismiss()
                }.keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 460)
    }
}




