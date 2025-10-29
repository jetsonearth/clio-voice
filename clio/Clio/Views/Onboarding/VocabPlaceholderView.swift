import SwiftUI
import AppKit
import AVKit

// MARK: - Personalization Showcase (3 steps) inserted after Command Try It
struct VocabPlaceholderView: View {
    @ObservedObject var viewModel: ProfessionalOnboardingViewModel
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var step: Int = 0 // 0=Personal Terms, 1=Voice Shortcuts, 2=Style Presets
    @State private var player: AVPlayer? = nil
    
    var body: some View {
        ZStack {
            // Full-bleed background from vocab.png
            VocabBackground()
                .ignoresSafeArea()
            
            // Full layout: header, centered content, bottom nav with optional skip
            VStack(spacing: 0) {
                OnboardingHeaderControls()
                
                Spacer(minLength: 0)
                
                contentCard
                
                Spacer(minLength: 0)
                
                // Bottom nav matches Try It layout: centered back + primary
                HStack(spacing: 8) {
                    StyledBackButton {
                        if step == 0 { 
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                viewModel.previousScreen() 
                            }
                        } else { withAnimation { step -= 1 } }
                    }
                    StyledActionButton(
                        title: step < 2 ? localizationManager.localizedString("onboarding.primer.continue") : localizationManager.localizedString("onboarding.primer.finish"),
                        action: {
                            if step < 2 {
                                withAnimation { step += 1 }
                            } else {
                                hasCompletedOnboarding = true
                            }
                        },
                        isDisabled: false,
                        showArrow: true
                    )
                }
                .padding(.bottom, 96)
            }
        }
        .ignoresSafeArea()
        .frame(minWidth: 1200, minHeight: 800)
        .onChange(of: step) { newValue in
            if newValue == 2 { startVideoIfNeeded() } else { stopVideo() }
        }
        .onAppear { if step == 2 { startVideoIfNeeded() } }
        .onDisappear { stopVideo() }
    }
    
    // MARK: - Content Card
    private var contentCard: some View {
        Group {
            switch step {
            case 0:
                mediaCard(title: localizationManager.localizedString("onboarding.personalization.title.personal_terms"), subtitle: localizationManager.localizedString("onboarding.personalization.subtitle.personal_terms"), media: AnyView(
                    MeasuredImageView(name: "personalterm")
                ))
            case 1:
                mediaCard(title: localizationManager.localizedString("onboarding.personalization.title.voice_shortcuts"), subtitle: localizationManager.localizedString("onboarding.personalization.subtitle.voice_shortcuts"), media: AnyView(
                    MeasuredImageView(name: "voiceshortcut")
                ))
            default:
                mediaCard(title: localizationManager.localizedString("onboarding.personalization.title.style_presets"), subtitle: localizationManager.localizedString("onboarding.personalization.subtitle.style_presets"), media: AnyView(
                    MeasuredVideoContainer(player: player)
                ))
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)))
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: step)
    }
    
    private func mediaCard(title: String, subtitle: String, media: AnyView) -> some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(DarkTheme.textPrimary)
                    .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 2)
                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundColor(DarkTheme.textPrimary.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 720)
                    .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 1)
            }
            
            media
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.28), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.45), radius: 18, x: 0, y: 8)
        }
    }
    
    // MARK: - Video helpers
    private func startVideoIfNeeded() {
        guard player == nil else { player?.play(); return }
        if let url = findResourceURL(name: "stylepreset", type: "mp4") {
            let p = AVPlayer(url: url)
            player = p
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: p.currentItem, queue: .main) { _ in
                p.seek(to: .zero)
                p.play()
            }
            p.play()
        }
    }
    private func stopVideo() {
        player?.pause()
    }
}

// MARK: - Media components
private struct MeasuredVideoContainer: View {
    let player: AVPlayer?
    private let maxWidth: CGFloat = 760
    private let maxHeight: CGFloat = 460
    
    var body: some View {
        Group {
            if let p = player, let item = p.currentItem {
                let size = naturalSize(for: item)
                let scale = min(maxWidth / max(size.width, 1), maxHeight / max(size.height, 1), 1)
                let w = size.width * scale
                let h = size.height * scale
                VideoPlayer(player: p)
                    .frame(width: w, height: h)
                    .disabled(true)
            } else {
                Color.black.opacity(0.6)
                    .frame(width: maxWidth, height: maxHeight * 9/16)
                    .overlay(ProgressView().scaleEffect(1.0))
            }
        }
    }
    
    private func naturalSize(for item: AVPlayerItem) -> CGSize {
        let asset = item.asset
        if let track = asset.tracks(withMediaType: .video).first {
            var size = track.naturalSize
            let tx = track.preferredTransform
            size = CGSize(width: abs(size.applying(tx).width), height: abs(size.applying(tx).height))
            return size
        }
        return CGSize(width: 1280, height: 720)
    }
}

private struct MeasuredImageView: View {
    let name: String
    private let maxWidth: CGFloat = 760
    private let maxHeight: CGFloat = 460
    
    var body: some View {
        Group {
            if let img = loadImage(name: name) {
                let size = img.size
                let scale = min(maxWidth / max(size.width, 1), maxHeight / max(size.height, 1), 1)
                let w = size.width * scale
                let h = size.height * scale
                Image(nsImage: img)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .frame(width: w, height: h)
            } else {
                Color.black.frame(width: maxWidth, height: maxHeight * 0.6)
            }
        }
    }
    
    private func loadImage(name: String) -> NSImage? {
        // Prefer assets by name
        if let named = NSImage(named: name) { return named }
        // Fallback: look for common raster formats in the app bundle
        let exts = ["png", "jpg", "jpeg"]
        for ext in exts {
            if let path = Bundle.main.path(forResource: name, ofType: ext) {
                if let img = NSImage(contentsOfFile: path) { return img }
            }
        }
        return nil
    }
}

// MARK: - Full-bleed background using vocab.png
struct VocabBackground: View {
    var body: some View {
        GeometryReader { proxy in
            Group {
                if let img = loadVocabImage() {
                    Image(nsImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                } else {
                    Color.black
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
    
    private func loadVocabImage() -> NSImage? {
        if let named = NSImage(named: "vocab") { return named }
        let exts = ["png", "jpg", "jpeg"]
        for ext in exts {
            if let path = Bundle.main.path(forResource: "vocab", ofType: ext),
               let img = NSImage(contentsOfFile: path) { return img }
        }
        return nil
    }
}

// MARK: - Bundle helper
private func findResourceURL(name: String, type: String) -> URL? {
    if let url = Bundle.main.url(forResource: name, withExtension: type) { return url }
    if let path = Bundle.main.path(forResource: name, ofType: type) { return URL(fileURLWithPath: path) }
    return nil
}
