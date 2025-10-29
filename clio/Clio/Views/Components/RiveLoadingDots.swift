import SwiftUI
import RiveRuntime

struct RiveLoadingDots: View {
    let color: Color
    @State private var riveViewModel: RiveViewModel?
    @State private var hasError = false
    
    var body: some View {
        Group {
            if let viewModel = riveViewModel, !hasError {
                viewModel.view()
                    .frame(width: 50, height: 25)
                    .background(Color.clear)
            } else {
                // Fallback animation using SwiftUI
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                            .scaleEffect(1.0 + 0.3 * sin(Date().timeIntervalSince1970 * 2 + Double(index) * 0.5))
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: Date().timeIntervalSince1970)
                    }
                }
                .frame(width: 50, height: 25)
                .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                    // Trigger animation updates
                }
            }
        }
        .onAppear {
            loadRiveAnimation()
        }
    }
    
    private func loadRiveAnimation() {
        // Use async task to prevent blocking main thread and potential race conditions
        Task { @MainActor in
            do {
                // Add explicit resource bundle check
                guard let resourcePath = Bundle.main.path(forResource: "loading_dots", ofType: "riv"),
                      FileManager.default.fileExists(atPath: resourcePath) else {
                    print("Rive file 'loading_dots.riv' not found in bundle, using fallback animation")
                    hasError = true
                    return
                }
                
                // Try to load the Rive animation with error handling
                let viewModel = try RiveViewModel(fileName: "loading_dots")
                self.riveViewModel = viewModel
            } catch {
                print("Failed to load Rive animation: \(error)")
                hasError = true
            }
        }
    }
}