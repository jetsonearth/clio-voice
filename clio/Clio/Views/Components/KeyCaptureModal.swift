import SwiftUI
import AppKit

struct KeyCaptureModal: View {
    @Binding var selectedKey: HotkeyManager.PushToTalkKey
    let onKeySelected: (HotkeyManager.PushToTalkKey) -> Void
    let onDismiss: () -> Void
    
    @State private var isListening = true
    @State private var monitor: Any?
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text(localizationManager.localizedString("hotkey.modal.title"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(localizationManager.localizedString("hotkey.modal.description"))
                    .font(.subheadline)
                    .foregroundColor(DarkTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Listening indicator
            if isListening {
                VStack(spacing: 16) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                        .symbolEffect(.pulse.byLayer, options: .repeating)
                    
                    Text(localizationManager.localizedString("hotkey.modal.listening"))
                        .font(.headline)
                        .foregroundColor(DarkTheme.textPrimary)
                    
                    Text("Press any modifier key (⌥, ⌃, ⌘, ⇧, fn)")
                        .font(.subheadline)
                        .foregroundColor(DarkTheme.textSecondary)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.accentColor.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.accentColor.opacity(0.3), lineWidth: 2)
                        )
                )
            } else {
                // Current selection display
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Text(getKeySymbol(for: selectedKey))
                            .font(.system(size: 32, weight: .medium, design: .rounded))
                            .foregroundColor(DarkTheme.textPrimary)
                        
                        Text(getKeyDisplayName(for: selectedKey))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DarkTheme.surfaceBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(DarkTheme.border, lineWidth: 1)
                            )
                    )
                    
                    Button(action: startListening) {
                        HStack(spacing: 8) {
                            Image(systemName: "record.circle")
                                .font(.system(size: 16))
                            Text(localizationManager.localizedString("hotkey.modal.record_key"))
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor)
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: {
                    stopListening()
                    onDismiss()
                }) {
                    Text(localizationManager.localizedString("general.cancel"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DarkTheme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DarkTheme.surfaceBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(DarkTheme.border, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                if !isListening {
                    Button(action: {
                        onKeySelected(selectedKey)
                        onDismiss()
                    }) {
                        Text(localizationManager.localizedString("general.save"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.accentColor)
                                    .shadow(color: Color.accentColor.opacity(0.3), radius: 2, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: {
                        stopListening()
                    }) {
                        Text(localizationManager.localizedString("general.save"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DarkTheme.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(DarkTheme.surfaceBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(DarkTheme.border, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(32)
        .frame(width: 400)
        .background(
            CardBackground(isSelected: false, cornerRadius: 20)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            // Make window key and focus it
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSApp.keyWindow?.makeKey()
            }
            // Start listening immediately when modal appears
            startListening()
        }
        .onDisappear {
            stopListening()
        }
    }
    
    private func startListening() {
        isListening = true
        
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { event in
            self.handleKeyEvent(event)
            return nil
        }
    }
    
    private func stopListening() {
        isListening = false
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        let keyCode = event.keyCode
        
        if let key = mapKeyCodeToHotkeyKey(keyCode: keyCode) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedKey = key
                stopListening()
            }
        }
    }
    
    private func mapKeyCodeToHotkeyKey(keyCode: UInt16) -> HotkeyManager.PushToTalkKey? {
        switch keyCode {
        case 58:  return .leftOption      // Left Option
        case 61:  return .rightOption     // Right Option
        case 59:  return .leftControl     // Left Control
        case 62:  return .rightControl    // Right Control
        case 63:  return .fn              // Function
        case 55:  return .leftCommand     // Left Command
        case 54:  return .rightCommand    // Right Command
        case 56:  return .leftShift       // Left Shift
        case 60:  return .rightShift      // Right Shift
        default:  return nil
        }
    }
    
    private func getKeySymbol(for key: HotkeyManager.PushToTalkKey) -> String {
        switch key {
        case .rightOption, .leftOption: return "⌥"
        case .leftControl, .rightControl: return "⌃"
        case .fn: return "fn"
        case .rightCommand, .leftCommand: return "⌘"
        case .rightShift, .leftShift: return "⇧"
        }
    }
    
    private func getKeyDisplayName(for key: HotkeyManager.PushToTalkKey) -> String {
        switch key {
        case .rightOption: return LocalizationManager.shared.localizedString("hotkey.key.right_option")
        case .leftOption: return LocalizationManager.shared.localizedString("hotkey.key.left_option")
        case .leftControl: return LocalizationManager.shared.localizedString("hotkey.key.left_control")
        case .rightControl: return LocalizationManager.shared.localizedString("hotkey.key.right_control")
        case .fn: return LocalizationManager.shared.localizedString("hotkey.key.function")
        case .rightCommand: return LocalizationManager.shared.localizedString("hotkey.key.right_command")
        case .leftCommand: return LocalizationManager.shared.localizedString("hotkey.key.left_command")
        case .rightShift: return LocalizationManager.shared.localizedString("hotkey.key.right_shift")
        case .leftShift: return LocalizationManager.shared.localizedString("hotkey.key.left_shift")
        }
    }
}