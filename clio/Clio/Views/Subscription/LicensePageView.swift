import SwiftUI
import AppKit

struct LicensePageView: View {
    @ObservedObject private var licenseViewModel = LicenseViewModel.shared
    
    private let highlights: [(icon: String, title: String, detail: String)] = [
        ("checkmark.seal.fill", "Everything unlocked", "AI enhancement, streaming transcription, and personalization features are permanently enabled in this build."),
        ("lock.shield.fill", "No accounts required", "All authentication screens were removed—manage everything locally with your own API keys."),
        ("wand.and.rays", "Bring your own providers", "Groq, Gemini, and Soniox run with your credentials so you control cost and access.")
    ]
    
    private let shareLinks: [(title: String, caption: String, url: String, icon: String)] = [
        ("Share Website", "Send the official download page to a friend.", "https://www.cliovoice.com", "paperplane.fill"),
        ("Share GitHub Repo", "Fork or star the open-source project.", "https://github.com/studio-kensense/clio", "chevron.left.forwardslash.chevron.right")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                PageHeaderView(
                    title: "Community Edition",
                    subtitle: "This OSS plan gives you the full Clio experience—no license keys, no proxy services, and no feature gates."
                )
                .padding(.top, 40)
                
                overviewCard
                shareCard
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    private var overviewCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 20) {
                Label("Plan Overview", systemImage: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.accentColor)
                
                if let validation = licenseViewModel.validationMessage {
                    Text(validation)
                        .font(.system(size: 12))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Divider().background(Color.white.opacity(0.08))
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(highlights, id: \.title) { item in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: item.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.accentColor)
                                .frame(width: 28, height: 28)
                                .background(
                                    Circle()
                                        .fill(Color.accentColor.opacity(0.12))
                                )
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(DarkTheme.textPrimary)
                                Text(item.detail)
                                    .font(.system(size: 12))
                                    .foregroundColor(DarkTheme.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var shareCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                Text("Share Clio with a friend")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text("Copy a link below to point teammates to the website or to the GitHub repo for the open-source build.")
                    .font(.system(size: 12))
                    .foregroundColor(DarkTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                ForEach(shareLinks, id: \.url) { link in
                    ShareRow(title: link.title, caption: link.caption, icon: link.icon) {
                        copyLink(link.url)
                    }
                }
            }
        }
    }
    
    private func copyLink(_ value: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
    }
}

private struct ShareRow: View {
    let title: String
    let caption: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DarkTheme.textPrimary)
                Text(caption)
                    .font(.system(size: 12))
                    .foregroundColor(DarkTheme.textSecondary)
            }
            Spacer()
            AddNewButton(title, action: action, systemImage: icon)
        }
        .padding(.vertical, 6)
    }
}
