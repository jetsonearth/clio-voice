import SwiftUI
import SwiftData

struct StatisticsDashboard: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var localizationManager: LocalizationManager
    @StateObject private var userProfile = UserProfileService.shared
    @StateObject private var supabaseService = SupabaseServiceSDK.shared
    @StateObject private var userStatsService = UserStatsService.shared
    @State private var speedMultiplier: Double = 0
    @State private var minutesSaved: Double = 0
    @State private var totalWords: Int = 0
    @State private var wordsPerMinute: Double = 0
    @State private var totalSpeakingMinutes: Double = 0
    
    // Performance optimization: Cache statistics to avoid expensive recalculations
    @State private var cachedTranscriptionCount: Int = 0
    @State private var lastCalculationDate: Date?
    @State private var isCalculating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Personalized Greeting
            VStack(alignment: .leading, spacing: 8) {
                HStack {
Text(userProfile.personalizedGreeting)
                        .fontScaled(size: 30, weight: .bold)
                        .foregroundColor(DarkTheme.textPrimary)
                    
                    Spacer()
                    
                    // Time-based icon
                    // Image(systemName: timeBasedIcon)
                    //     .font(.system(size: 24, weight: .medium))
                    //     .foregroundColor(DarkTheme.accent)
                }
                
                if totalWords > 0 {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        // Extract the localized format and split it around the placeholder
                        let format = localizationManager.localizedString("dashboard.words_dictated")
                        let parts = format.components(separatedBy: "%d")
                        
                        if parts.count >= 2 {
Text(parts[0])
                                .fontScaled(size: 16)
                                .foregroundColor(DarkTheme.textSecondary)
                            
Text(formatNumber(totalWords))
                                .fontScaled(size: 22, weight: .bold)
                                .foregroundColor(DarkTheme.textPrimary)
                            
Text(parts[1])
                                .fontScaled(size: 16)
                                .foregroundColor(DarkTheme.textSecondary)
                        } else {
                            // Fallback to original format if splitting fails
                            Text(String(format: format, totalWords))
                                .font(.system(size: 16))
                                .foregroundColor(DarkTheme.textSecondary)
                        }
                    }
                } else {
Text(localizationManager.localizedString("dashboard.ready_to_start"))
                        .fontScaled(size: 16)
                        .foregroundColor(DarkTheme.textSecondary)
                }
            }
            .padding(.bottom, 8)
            
            // Header Statistics Cards
            HStack(spacing: 16) {
                StatCard(
                    title: localizationManager.localizedString("dashboard.efficiency_title"),
                    value: String(format: "%.1fx", speedMultiplier),
                    subtitle: localizationManager.localizedString("dashboard.efficiency_subtitle"),
                    icon: "bolt.circle",
                    color: .white
                )
                
                StatCard(
                    title: localizationManager.localizedString("dashboard.minutes_saved"),
                    value: formatSpeakingTime(minutesSaved),
                    subtitle: localizationManager.localizedString("dashboard.time_efficiency"),
                    icon: "timelapse",
                    color: .white
                )
                
                StatCard(
                    title: localizationManager.localizedString("dashboard.time_speaking"),
                    value: formatSpeakingTime(totalSpeakingMinutes),
                    subtitle: localizationManager.localizedString("dashboard.total_speaking_time"),
                    icon: "clock.fill",
                    color: .white
                )
                
                StatCard(
                    title: localizationManager.localizedString("dashboard.words_per_minute"),
                    value: String(format: "%.0f", wordsPerMinute),
                    subtitle: localizationManager.localizedString("dashboard.speaking_rate"),
                    icon: "figure.run.circle.fill",
                    color: .white
                )
            }
        }
        .onAppear {
            loadStatistics()
        }
        .onReceive(supabaseService.$currentSession) { _ in
            // Reload stats when authentication state changes
            loadStatistics()
        }
    }
    
    private var timeBasedIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "sun.max.fill"
        case 12..<17:
            return "sun.and.horizon.fill"
        case 17..<22:
            return "moon.stars.fill"
        default:
            return "moon.fill"
        }
    }
    
    private func formatSpeakingTime(_ totalMinutes: Double) -> String {
        let hours = Int(totalMinutes) / 60
        let minutes = Int(totalMinutes) % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func loadStatistics() {
        // Performance optimization: Only calculate if needed
        guard !isCalculating else { return }
        
        Task {
            await calculateStatisticsIfNeeded()
        }
    }
    
    private func calculateStatisticsIfNeeded() async {
        // Check if we need to recalculate
        do {
            let countDescriptor = FetchDescriptor<Transcription>()
            let currentCount = try modelContext.fetchCount(countDescriptor)
            
            // Only recalculate if:
            // 1. Never calculated before
            // 2. New transcriptions added
            // 3. More than 5 minutes since last calculation (for session changes)
            let shouldRecalculate = lastCalculationDate == nil ||
                                  currentCount != cachedTranscriptionCount ||
                                  (lastCalculationDate?.timeIntervalSinceNow ?? 0) < -300
            
            guard shouldRecalculate else { return }
            
            await calculateLocalStatistics()
        } catch {
            print("❌ Error checking transcription count: \(error)")
        }
    }
    
    // UPDATED: Original local calculation method
    private func calculateLocalStatistics() async {
        isCalculating = true
        defer { isCalculating = false }
        
        do {
            // Fetch all transcriptions from local SwiftData
            let descriptor = FetchDescriptor<Transcription>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let transcriptions = try modelContext.fetch(descriptor)
            
            // Update cache info
            await MainActor.run {
                cachedTranscriptionCount = transcriptions.count
                lastCalculationDate = Date()
            }
            
            await MainActor.run {
                // Calculate total words from actual transcriptions using proper word counting
                totalWords = transcriptions.reduce(0) { total, transcription in
                    total + TextUtils.countWords(in: transcription.text)
                }
                
                var totalSpeakingTimeMinutes: Double = 0
                var totalTimeSavedMinutes: Double = 0
                
                for transcription in transcriptions {
                    let wordCount = TextUtils.countWords(in: transcription.text)
                    
                    // Calculate speaking time based on actual duration if available, 
                    // otherwise estimate at 150 WPM
                    let speakingTimeMinutes: Double
                    if transcription.duration > 0 {
                        // Use actual recorded duration (duration is in seconds)
                        speakingTimeMinutes = transcription.duration / 60.0
                        // print("📝 Transcription: \(wordCount) words, \(String(format: "%.1f", transcription.duration))s = \(String(format: "%.2f", speakingTimeMinutes))min")
                    } else {
                        // Fallback to estimation (150 WPM average speaking speed)
                        speakingTimeMinutes = Double(wordCount) / 150.0
                        // print("📝 Transcription: \(wordCount) words, estimated \(String(format: "%.2f", speakingTimeMinutes))min (150 WPM)")
                    }
                    
                    totalSpeakingTimeMinutes += speakingTimeMinutes
                    
                    // Calculate typing time (40 WPM average typing speed)
                    let typingTimeMinutes = Double(wordCount) / 40.0
                    
                    // Time saved = typing time - speaking time
                    let timeSavedMinutes = max(0, typingTimeMinutes - speakingTimeMinutes)
                    totalTimeSavedMinutes += timeSavedMinutes
                }
                
                // Set calculated values
                minutesSaved = totalTimeSavedMinutes
                totalSpeakingMinutes = totalSpeakingTimeMinutes
                
                // Calculate actual words per minute from transcriptions
                if totalSpeakingTimeMinutes > 0 {
                    wordsPerMinute = Double(totalWords) / totalSpeakingTimeMinutes
                } else {
                    wordsPerMinute = 0
                }
                
                // Calculate speed multiplier (how much faster than typing)
                if totalSpeakingTimeMinutes > 0 {
                    let equivalentTypingTime = Double(totalWords) / 40.0 // 40 WPM in minutes
                    speedMultiplier = equivalentTypingTime / totalSpeakingTimeMinutes
                } else {
                    speedMultiplier = 3.0 // Default fallback
                }
                
                // Debug final calculations
                // print("📊 Final Stats Calculation:")
                // print("   Total Words: \(totalWords)")
                // print("   Speaking Time: \(String(format: "%.1f", totalSpeakingTimeMinutes)) minutes (\(String(format: "%.0f", totalSpeakingTimeMinutes/60))h \(String(format: "%.0f", totalSpeakingTimeMinutes.truncatingRemainder(dividingBy: 60)))m)")
                // print("   WPM: \(String(format: "%.1f", wordsPerMinute)) (\(totalWords) ÷ \(String(format: "%.1f", totalSpeakingTimeMinutes)))")
                // print("   Time Saved: \(String(format: "%.1f", minutesSaved)) minutes")
                // print("   Speed Multiplier: \(String(format: "%.1f", speedMultiplier))x")
            }
        } catch {
            print("❌ Error calculating local statistics: \(error)")
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
Text(title)
                    .fontScaled(size: 16, weight: .semibold)
                    .foregroundColor(DarkTheme.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .multilineTextAlignment(.leading)
                
Text(value)
                    .fontScaled(size: 20, weight: .bold)
                    .foregroundColor(DarkTheme.textPrimary)
                    .lineLimit(1)
            }
            
Text(subtitle)
                .fontScaled(size: 11, weight: .medium)
                .foregroundColor(DarkTheme.textSecondary)
                .tracking(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
.frame(minHeight: 110)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.thinMaterial)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

struct DailyStatistic: Identifiable {
    let id = UUID()
    let date: Date
    var timeSavedMinutes: Double
    var sessionCount: Int
    var wordCount: Int
} 