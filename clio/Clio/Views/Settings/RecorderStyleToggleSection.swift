import SwiftUI

struct RecorderStyleToggleSection: View {
	@EnvironmentObject private var whisperState: WhisperState
	@AppStorage("RecorderStyleIsNotch") private var isNotch: Bool = false

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack(spacing: 12) {
				Image(systemName: "rectangle.on.rectangle")
					.font(.system(size: 20))
					.foregroundColor(.accentColor)
					.frame(width: 24, height: 24)

				VStack(alignment: .leading, spacing: 2) {
					Text("Recorder Style")
						.font(.headline)
						.foregroundColor(DarkTheme.textPrimary)
					Text("Toggle to use the notch recorder; off uses the mini recorder")
						.font(.subheadline)
						.foregroundColor(DarkTheme.textSecondary)
				}

				Spacer()

				Toggle("", isOn: Binding(
					get: { isNotch },
					set: { newValue in
						isNotch = newValue
						whisperState.recorderType = newValue ? "notch" : "mini"
						
						// Ensure mutual exclusivity - hide the other recorder type
						if newValue {
							// Switching to notch - hide mini recorder
							whisperState.miniWindowManager?.hide()
						} else {
							// Switching to mini - hide notch recorder
							whisperState.notchWindowManager?.hide()
						}
					}
				))
				.toggleStyle(SwitchToggleStyle(tint: DarkTheme.accent))
				.scaleEffect(1.0)
			}
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(DarkTheme.textPrimary.opacity(0.03))
				.overlay(
					RoundedRectangle(cornerRadius: 12)
						.stroke(DarkTheme.textPrimary.opacity(0.1), lineWidth: 1)
				)
		)
		.onAppear {
			// Keep AppStorage and state in sync on load
			whisperState.recorderType = isNotch ? "notch" : "mini"
		}
	}
}


