import SwiftUI

struct TranslucentBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    init(material: NSVisualEffectView.Material = .underWindowBackground, 
         blendingMode: NSVisualEffectView.BlendingMode = .behindWindow) {
        self.material = material
        self.blendingMode = blendingMode
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        visualEffectView.isEmphasized = true
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        visualEffectView.isEmphasized = true
    }
}

extension View {
    func translucentBackground(material: NSVisualEffectView.Material = .underWindowBackground,
                              blendingMode: NSVisualEffectView.BlendingMode = .behindWindow) -> some View {
        ZStack {
            TranslucentBackground(material: material, blendingMode: blendingMode)
                .ignoresSafeArea()
            
            self
                .background(Color.clear)
        }
    }
}