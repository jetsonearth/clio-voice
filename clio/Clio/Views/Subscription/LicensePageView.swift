import SwiftUI
import AppKit

struct LicensePageView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @ObservedObject private var licenseViewModel = LicenseViewModel.shared
    
    private struct PlanHighlight: Identifiable {
        let icon: String
        let titleKey: String
        let detailKey: String
        
        var id: String { titleKey }
    }
    
    private struct PlanShareLink: Identifiable {
        let titleKey: String
        let captionKey: String
        let url: String
        let icon: String
        
        var id: String { url }
    }
    
    private let highlights: [PlanHighlight] = [
        .init(icon: "checkmark.seal.fill", titleKey: "plan.highlight.everything.title", detailKey: "plan.highlight.everything.detail"),
        .init(icon: "lock.shield.fill", titleKey: "plan.highlight.accounts.title", detailKey: "plan.highlight.accounts.detail"),
        .init(icon: "wand.and.rays", titleKey: "plan.highlight.providers.title", detailKey: "plan.highlight.providers.detail")
    ]
    
    private let shareLinks: [PlanShareLink] = [
        .init(titleKey: "plan.share.website.title", captionKey: "plan.share.website.caption", url: "https://www.cliovoice.com", icon: "paperplane.fill"),
        .init(titleKey: "plan.share.repo.title", captionKey: "plan.share.repo.caption", url: "https://github.com/jetsonearth/clio-voice", icon: "chevron.left.forwardslash.chevron.right")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                PageHeaderView(
                    title: localizationManager.localizedString("plan.community.title"),
                    subtitle: localizationManager.localizedString("plan.community.subtitle")
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
                Label(localizationManager.localizedString("plan.overview.heading"), systemImage: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.accentColor)
                
                if let validation = licenseViewModel.validationMessage {
                    Text(validation)
                        .font(.system(size: 12))
                        .foregroundColor(DarkTheme.textSecondary)
                }
                
                Divider().background(Color.white.opacity(0.08))
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(highlights) { item in
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
                                Text(localizationManager.localizedString(item.titleKey))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(DarkTheme.textPrimary)
                                Text(localizationManager.localizedString(item.detailKey))
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
                Text(localizationManager.localizedString("plan.share.title"))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(localizationManager.localizedString("plan.share.subtitle"))
                    .font(.system(size: 12))
                    .foregroundColor(DarkTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                ForEach(shareLinks) { link in
                    ShareRow(
                        title: localizationManager.localizedString(link.titleKey),
                        caption: localizationManager.localizedString(link.captionKey),
                        buttonTitle: localizationManager.localizedString(link.titleKey),
                        icon: link.icon
                    ) {
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
    let buttonTitle: String
    let icon: String
    let action: () -> Void
    
    @State private var showConfirmation = false
    @State private var resetTask: Task<Void, Never>?
    
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
            Button(action: handleTap) {
                HStack(spacing: 6) {
                    ZStack {
                        Image(systemName: icon)
                            .opacity(showConfirmation ? 0 : 1)
                        Image(systemName: "checkmark")
                            .opacity(showConfirmation ? 1 : 0)
                    }
                    .font(.system(size: 12, weight: .semibold))
                    Text(buttonTitle)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.accentColor)
                )
            }
            .buttonStyle(.borderless)
            .animation(.easeInOut(duration: 0.2), value: showConfirmation)
        }
        .padding(.vertical, 6)
        .onDisappear {
            resetTask?.cancel()
        }
    }
    
    private func handleTap() {
        action()
        resetTask?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            showConfirmation = true
        }
        resetTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    showConfirmation = false
                }
            }
        }
    }
}
