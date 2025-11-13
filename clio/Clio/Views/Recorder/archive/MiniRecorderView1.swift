// import SwiftUI

// struct MiniRecorderView: View {
//     @ObservedObject var recordingEngine: RecordingEngine
//     @ObservedObject var recorder: Recorder
//     @EnvironmentObject var windowManager: MiniWindowManager
//     @State private var isShowing = false
//     @State private var hasInitialized = false
    
//     var body: some View {
//         ZStack {
//                 Capsule()
//                     .fill(.clear)
//                     .background(
//                         ZStack {
//                             // Base dark background
//                             Color.black.opacity(0.9)
                            
//                             // Subtle gradient overlay
//                             LinearGradient(
//                                 colors: [
//                                     Color.black.opacity(0.95),
//                                     Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.9)
//                                 ],
//                                 startPoint: .top,
//                                 endPoint: .bottom
//                             )
                            
//                             // Very subtle visual effect for depth
//                             VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
//                                 .opacity(0.05)
//                         }
//                         .clipShape(Capsule())
//                     )
//                     .overlay {
//                         // Subtle inner border
//                         Capsule()
//                             .strokeBorder(DarkTheme.textPrimary.opacity(0.1), lineWidth: 0.5)
//                     }
//                     .overlay {
//                         HStack(spacing: 0) {
//                             // Record Button - on the left
//                             NotchRecordButton(
//                                 isRecording: recordingEngine.isRecording,
//                                 isProcessing: recordingEngine.isProcessing
//                             ) {
//                                 Task { await recordingEngine.toggleRecord() }
//                             }
//                             .frame(width: 24)
//                             .padding(.leading, 8)
                            
//                             // Visualizer - centered and expanded
//                             Group {
//                                 if recordingEngine.isProcessing {
//                                     WaveVisualizer(color: Color(red: 0.8, green: 0.8, blue: 0.82))
//                                 } else {
//                                     AudioVisualizer(
//                                         audioMeter: recorder.audioMeter,
//                                         color: Color(red: 0.8, green: 0.8, blue: 0.82),
//                                         isActive: recordingEngine.isRecording
//                                     )
//                                 }
//                             }
//                             .frame(maxWidth: .infinity)
//                             .padding(.horizontal, 4)
                            
//                         }
//                         .padding(.vertical, 4)
//                     }
//                     .scaleEffect(isShowing ? 1.0 : 0.8)
//                     .opacity(isShowing ? 1.0 : 0.0)
                
//         }
//         .task {
//             // Use task instead of onAppear for faster execution
//             if !hasInitialized {
//                 hasInitialized = true
//                 withAnimation(.spring(response: 0.25, dampingFraction: 0.85, blendDuration: 0)) {
//                     isShowing = true
//                 }
//             }
//         }
//         .onChange(of: windowManager.isVisible) { newValue in
//             if !newValue {
//                 withAnimation(.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)) {
//                     isShowing = false
//                 }
//             }
//         }
//     }
// }

