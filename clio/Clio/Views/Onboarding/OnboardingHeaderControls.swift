import SwiftUI

struct OnboardingHeaderControls: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var showLanguageSelection = false
    
    var body: some View {
        HStack {
            Spacer()
        }
        .padding(.horizontal, 60)
        .padding(.top, 60)
    }
}

//#Preview {
//    OnboardingHeaderControls()
//        .environmentObject(LocalizationManager.shared)
//}
