import SwiftUI

/// Legacy "upgrade" modal replaced with a lightweight acknowledgement that all features are unlocked.
struct UpgradePromptView: View {
    let feature: ProFeature?
    @Environment(\.dismiss) private var dismiss

    init(feature: ProFeature? = nil) {
        self.feature = feature
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
                .background(Color.white.opacity(0.2))
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Clio Community Edition ships with every feature enabled. There is no paywall, trial, or licensing step required.")
                        .font(.system(size: 16))
                        .foregroundColor(DarkTheme.textSecondary)

                    featureDetail

                    tipCard(
                        icon: "key.fill",
                        title: "Add Your API Keys",
                        description: "Manage Groq and Soniox credentials under Settings → Cloud API Keys. They are stored locally in the Keychain."
                    )

                    tipCard(
                        icon: "wand.and.rays",
                        title: "Customize Enhancement",
                        description: "Tweak prompts, editing strength, and vocabulary in the Personalization section to match your writing style."
                    )

                    tipCard(
                        icon: "bolt.square.fill",
                        title: "Automate Your Output",
                        description: "Snippets, replacements, and clipboard actions let you push transcripts straight into your apps."
                    )
                }
                .padding(32)
            }

            Button(action: { dismiss() }) {
                Text("Got it!")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.25), radius: 10)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
        .frame(width: 560, height: 520)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No Upgrade Needed")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(DarkTheme.textPrimary)
            Text("You're already on the fully unlocked community build.")
                .font(.system(size: 16))
                .foregroundColor(DarkTheme.textSecondary)
        }
        .padding(.horizontal, 32)
        .padding(.top, 28)
        .padding(.bottom, 20)
    }

    @ViewBuilder
    private var featureDetail: some View {
        if let feature {
            GlassmorphismCard(padding: 20) {
                HStack(spacing: 12) {
                    Image(systemName: feature.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(feature.displayName) is ready to use")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DarkTheme.textPrimary)
                        Text("Community builds expose every pro workflow so you can script or customize freely.")
                            .font(.system(size: 14))
                            .foregroundColor(DarkTheme.textSecondary)
                    }
                    Spacer()
                }
            }
        }
    }

    private func tipCard(icon: String, title: String, description: String) -> some View {
        GlassmorphismCard(padding: 20) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.accentColor)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DarkTheme.textPrimary)
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                Spacer()
            }
        }
    }
}
