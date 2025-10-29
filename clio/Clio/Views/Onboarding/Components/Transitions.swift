import SwiftUI

// Shared transitions for onboarding/update flows
extension AnyTransition {
    /// A soft, ethereal fade used for primer/update pages.
    /// Inserts with a subtle scale-up from 0.98 and fades in; removes with a gentle fade/scale.
    static var ethereal: AnyTransition {
        let insertion = AnyTransition.opacity
            .combined(with: .scale(scale: 0.98, anchor: .center))
        let removal = AnyTransition.opacity
            .combined(with: .scale(scale: 1.02, anchor: .center))
        return .asymmetric(insertion: insertion, removal: removal)
    }
}
