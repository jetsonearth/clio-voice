import SwiftUI

struct TranscribingProgressBar: View {
    @Binding var progress: CGFloat
    let cornerRadius: CGFloat = 4
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.clear)
                
                // White fill that progresses from left to right
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .frame(width: geometry.size.width * progress)
            }
        }
    }
}

//#Preview {
//    ZStack {
//        Color.black
//        TranscribingProgressBar()
//            .frame(width: 95, height: 8)
//    }
//    .frame(width: 120, height: 40)
//}
