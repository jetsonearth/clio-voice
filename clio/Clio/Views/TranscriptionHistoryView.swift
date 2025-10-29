import SwiftUI
import SwiftData
import KeyboardShortcuts

struct TranscriptionHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var localizationManager: LocalizationManager
    @State private var searchText = ""
    @State private var showDeleteConfirmation = false
    @State private var isViewCurrentlyVisible = false
    // @State private var selectedDateRange: DateRange = .all
    @State private var selectedTranscription: Transcription?
    @State private var showDeleteAlert = false
    @State private var transcriptionToDelete: Transcription?
    @State private var showClearAllConfirmation = false
    @State private var isClearingAll = false
    
    // Pagination states
    @State private var displayedTranscriptions: [Transcription] = []
    @State private var isLoading = false
    @State private var hasMoreContent = true
    
    // Cursor-based pagination - track the last timestamp
    @State private var lastTimestamp: Date?
    private let pageSize = 20

    // Retranscribe UI state
    @State private var retranscribingIds: Set<UUID> = []
    
    // Computed property to group transcriptions by date
    private var groupedTranscriptions: [Date: [Transcription]] {
        Dictionary(grouping: displayedTranscriptions) { transcription in
            Calendar.current.startOfDay(for: transcription.timestamp)
        }
    }
    
    // New query: Fetches only the ID of the most recent transcription to minimize data loading.
    // Renamed to latestTranscriptionIndicator to reflect its purpose.
    @Query(Self.createLatestTranscriptionIndicatorDescriptor()) private var latestTranscriptionIndicator: [Transcription]
    
    // Static function to create the FetchDescriptor for the latest transcription indicator
    private static func createLatestTranscriptionIndicatorDescriptor() -> FetchDescriptor<Transcription> {
        var descriptor = FetchDescriptor<Transcription>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return descriptor
    }
    
    // Cursor-based query descriptor
    private func cursorQueryDescriptor(after timestamp: Date? = nil) -> FetchDescriptor<Transcription> {
        var descriptor = FetchDescriptor<Transcription>(
            sortBy: [SortDescriptor(\Transcription.timestamp, order: .reverse)]
        )
        
        // Build the predicate based on search text and timestamp cursor
        if let timestamp = timestamp {
            if !searchText.isEmpty {
                descriptor.predicate = #Predicate<Transcription> { transcription in
                    (transcription.text.localizedStandardContains(searchText) ||
                    (transcription.enhancedText?.localizedStandardContains(searchText) ?? false)) &&
                    transcription.timestamp < timestamp
                }
            } else {
                descriptor.predicate = #Predicate<Transcription> { transcription in
                    transcription.timestamp < timestamp
                }
            }
        } else if !searchText.isEmpty {
            descriptor.predicate = #Predicate<Transcription> { transcription in
                transcription.text.localizedStandardContains(searchText) ||
                (transcription.enhancedText?.localizedStandardContains(searchText) ?? false)
            }
        }
        
        descriptor.fetchLimit = pageSize
        return descriptor
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Main Content with Statistics Dashboard as Header
                    VStack(spacing: 16) {
                        // Statistics Dashboard
                        StatisticsDashboard()
                            .padding(.horizontal, 40)
                            .padding(.top, 40)
                        
                        // Search Bar
                        searchBar
                            .padding(.horizontal, 40)
                        
                        if displayedTranscriptions.isEmpty && !isLoading {
                            emptyStateView
                                .padding(.horizontal, 40)
                        } else {
                            // Wispr Flow-style flat list for maximum performance
                            LazyVStack(spacing: 20) {
                                ForEach(Array(displayedTranscriptions.enumerated()), id: \.element.id) { index, transcription in
                                    VStack(spacing: 0) {
                                        // Date header (only if different from previous)
                                        if shouldShowDateHeader(for: transcription, at: index) {
                                            HStack {
                                                Text(formatSectionDate(Calendar.current.startOfDay(for: transcription.timestamp)))
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.secondary)
                                                    .padding(.leading, 16)
                                                Spacer()
                                                if index == 0 { // Show Clear All in the first section header only
                                                    Button(action: { showClearAllConfirmation = true }) {
                                                        HStack(spacing: 6) {
                                                            if isClearingAll { ProgressView().controlSize(.small) }
                                                            Image(systemName: "trash")
                                                            Text("Clear All")
                                                        }
                                                        .font(.system(size: 12, weight: .medium))
                                                    }
                                                    .disabled(isClearingAll)
                                                    .buttonStyle(.borderless)
                                                    .padding(.trailing, 16)
                                                }
                                            }
                                            .padding(.vertical, 8)
                                            .background(Color.clear)
                                        }
                                        
                                        // Simple transcription row
                                        SimpleTranscriptionRow(
                                            transcription: transcription,
                                            onDelete: { deleteTranscription(transcription) },
                                            onReTranscribe: { reTranscribeAudio(transcription) },
                                            isRetranscribing: retranscribingIds.contains(transcription.id)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                            
                            if hasMoreContent {
                                Button(action: {
                                    loadMoreContent()
                                }) {
                                    HStack(spacing: 8) {
                                        if isLoading {
                                            ProgressView()
                                                .controlSize(.small)
                                                .frame(width: 16, height: 16)
                                        }
                                        Text(isLoading ? localizationManager.localizedString("general.loading") : localizationManager.localizedString("transcription.load_more"))
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(DarkTheme.textPrimary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.thinMaterial)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(isLoading)
                                .padding(.top, 12)
                                .padding(.horizontal, 40)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                    // Add bottom padding for content
                    .padding(.bottom, 0)
                }
            }
            
            // No selection toolbar needed
        }
        // Confirm clear all alert
        .alert("Delete All Transcriptions?", isPresented: $showClearAllConfirmation) {
            Button("Delete All", role: .destructive) {
                Task { await clearAllTranscriptions() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all transcription texts and their audio files.")
        }
        .onAppear {
            isViewCurrentlyVisible = true
            Task {
                await loadInitialContent()
            }
        }
        .onDisappear {
            isViewCurrentlyVisible = false
        }
        .onChange(of: searchText) { _, _ in
            Task {
                await resetPagination()
                await loadInitialContent()
            }
        }
        // Improved change detection for new transcriptions
        .onChange(of: latestTranscriptionIndicator.first?.id) { oldId, newId in
            guard isViewCurrentlyVisible else { return } // Only proceed if the view is visible

            // Check if a new transcription was added or the latest one changed
            if newId != oldId {
                // Only refresh if we're on the first page (no pagination cursor set)
                // or if the view is active and new content is relevant.
                if lastTimestamp == nil {
                    Task {
                        await loadInitialContent()
                    }
                } else {
                    // Reset pagination to show the latest content
                    Task {
                        await resetPagination()
                        await loadInitialContent()
                    }
                }
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(DarkTheme.textSecondary)
            TextField(localizationManager.localizedString("transcription.search.placeholder"), text: $searchText)
                .font(.system(size: 16, weight: .regular, design: .default))
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.thinMaterial)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.vertical, 16)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            // Hero section with animated illustration
            VStack(spacing: 32) {
                // Audio visualization bars (static but animated)
//                EmptyStateAudioBars()
                
                // Content section
                VStack(spacing: 16) {
                    Text(localizationManager.localizedString("transcription.empty.title"))
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(DarkTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(localizationManager.localizedString("transcription.empty.subtitle"))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(DarkTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                .padding(.horizontal, 40)
            }
            .padding(.top, 60)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(DarkTheme.border.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(32)
        .onAppear {
            animationScale = 1.1
        }
    }
    
    @State private var animationScale: CGFloat = 1.0
    
    // Selection toolbar removed - no longer needed
    
    private func loadInitialContent() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Reset cursor
            lastTimestamp = nil
            
            // Fetch initial page without a cursor
            let items = try modelContext.fetch(cursorQueryDescriptor())
            
            await MainActor.run {
                displayedTranscriptions = items
                // Update cursor to the timestamp of the last item
                lastTimestamp = items.last?.timestamp
                // If we got fewer items than the page size, there are no more items
                hasMoreContent = items.count == pageSize
            }
        } catch {
            print("Error loading transcriptions: \(error)")
        }
    }
    
    private func loadMoreContent() {
        guard !isLoading, hasMoreContent, let lastTimestamp = lastTimestamp else { return }
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                // Fetch next page using the cursor
                let newItems = try modelContext.fetch(cursorQueryDescriptor(after: lastTimestamp))
                
                await MainActor.run {
                    // Append new items to the displayed list
                    displayedTranscriptions.append(contentsOf: newItems)
                    // Update cursor to the timestamp of the last new item
                    self.lastTimestamp = newItems.last?.timestamp
                    // If we got fewer items than the page size, there are no more items
                    hasMoreContent = newItems.count == pageSize
                }
            } catch {
                print("Error loading more transcriptions: \(error)")
            }
        }
    }
    
    private func resetPagination() async {
        await MainActor.run {
            displayedTranscriptions = []
            lastTimestamp = nil
            hasMoreContent = true
            isLoading = false
        }
    }
    
    private func deleteTranscription(_ transcription: Transcription) {
        // First delete the audio file if it exists
        if let urlString = transcription.audioFileURL,
           let url = URL(string: urlString) {
            try? FileManager.default.removeItem(at: url)
        }
        
        modelContext.delete(transcription)
        
        // No selection state to update
        
        // Refresh the view
        Task {
            try? await modelContext.save()
            await loadInitialContent()
        }
    }
    
    private func clearAllTranscriptions() async {
        guard !isClearingAll else { return }
        await MainActor.run { isClearingAll = true }
        defer { Task { await MainActor.run { isClearingAll = false } } }
        do {
            var descriptor = FetchDescriptor<Transcription>()
            // No predicate: fetch all
            let allTranscriptions = try modelContext.fetch(descriptor)
            // Delete audio files
            for transcription in allTranscriptions {
                if let urlString = transcription.audioFileURL,
                   let url = URL(string: urlString),
                   FileManager.default.fileExists(atPath: url.path) {
                    try? FileManager.default.removeItem(at: url)
                }
                modelContext.delete(transcription)
            }
            try? modelContext.save()
            await loadInitialContent()
        } catch {
            print("Error clearing all transcriptions: \(error)")
        }
    }
    
    // Delete selected transcriptions method removed - no longer needed
    
    // No selection toggle needed
    
    private func reTranscribeAudio(_ transcription: Transcription) {
        // Resolve original URL
        var resolvedURL: URL? = nil
        if let urlString = transcription.audioFileURL,
           let candidate = URL(string: urlString),
           FileManager.default.fileExists(atPath: candidate.path) {
            resolvedURL = candidate
        } else if let urlString = transcription.audioFileURL,
                  let candidate = URL(string: urlString) {
            // Fallback: if original WAV was compressed and removed, try .m4a with same basename
            let m4aURL = candidate.deletingPathExtension().appendingPathExtension("m4a")
            if FileManager.default.fileExists(atPath: m4aURL.path) {
                resolvedURL = m4aURL
                // Update the model to point at the compressed file for future actions
                transcription.audioFileURL = m4aURL.absoluteString
                try? modelContext.save()
            }
        }

        guard let audioURL = resolvedURL else {
            print("❌ Audio file not found for re-transcription")
            return
        }
        
        print("🔄 Starting Soniox re-transcription for: \(transcription.id)")
        retranscribingIds.insert(transcription.id)
        
        Task {
            do {
                let reTranscriptionService = AudioFileReTranscriptionService(modelContext: modelContext)
                let updatedTranscription = try await reTranscriptionService.reTranscribeWithSoniox(
                    audioURL: audioURL,
                    originalTranscription: transcription
                )
                
                // Save the updated transcription
                await MainActor.run {
                    do {
                        retranscribingIds.remove(transcription.id)
                        try modelContext.save()
                        print("✅ Re-transcription completed and saved: \(updatedTranscription.text)")
                        // Refresh the view
                        Task {
                            await loadInitialContent()
                        }
                    } catch {
                        print("❌ Failed to save re-transcription: \(error.localizedDescription)")
                    }
                }
            } catch {
                await MainActor.run {
                    retranscribingIds.remove(transcription.id)
                }
                print("❌ Re-transcription failed: \(error.localizedDescription)")
            }
        }
    }
    
    // No select all functionality needed
    
    // Performance optimization: Check if we should show date header
    private func shouldShowDateHeader(for transcription: Transcription, at index: Int) -> Bool {
        guard index > 0 else { return true } // Always show for first item
        
        let currentDate = Calendar.current.startOfDay(for: transcription.timestamp)
        let previousDate = Calendar.current.startOfDay(for: displayedTranscriptions[index - 1].timestamp)
        
        return currentDate != previousDate
    }
    
    private func formatSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return localizationManager.localizedString("transcription.date.today")
        } else if calendar.isDateInYesterday(date) {
            return localizationManager.localizedString("transcription.date.yesterday")
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            // Same year - show month and day
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            return formatter.string(from: date)
        } else {
            // Different year - show full date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

struct CircularCheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(configuration.isOn ? DarkTheme.accent : DarkTheme.textTertiary)
                .font(.system(size: 18))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty State Supporting Components

//struct EmptyStateAudioBars: View {
//    private let barCount = 15
//    private let barWidth: CGFloat = 2.5
//    private let barSpacing: CGFloat = 2.0
//    private let minHeight: CGFloat = 4.0
//    private let maxHeight: CGFloat = 16.0
//    
//    @State private var barHeights: [CGFloat] = []
//    @State private var animationPhase: Double = 0
//    
//    var body: some View {
//        HStack(spacing: barSpacing) {
//            ForEach(0..<barCount, id: \.self) { index in
//                RoundedRectangle(cornerRadius: 1.5)
//                    .fill(
//                        LinearGradient(
//                            colors: [
//                                DarkTheme.accent.opacity(0.8),
//                                DarkTheme.accent.opacity(0.4)
//                            ],
//                            startPoint: .top,
//                            endPoint: .bottom
//                        )
//                    )
//                    .frame(width: barWidth, height: barHeights.count > index ? barHeights[index] : minHeight)
//                    .shadow(color: DarkTheme.accent.opacity(0.3), radius: 1, x: 0, y: 0.5)
//            }
//        }
//        .onAppear {
//            setupInitialHeights()
//            startAnimation()
//        }
//    }
//    
//    private func setupInitialHeights() {
//        barHeights = (0..<barCount).map { index in
//            let normalizedIndex = Double(index) / Double(barCount - 1)
//            let centerDistance = abs(normalizedIndex - 0.5) * 2.0
//            let height = minHeight + (maxHeight - minHeight) * CGFloat(exp(-centerDistance * centerDistance * 2.0))
//            return height
//        }
//    }
//    
//    private func startAnimation() {
//        withAnimation(.linear(duration: 0.1).repeatForever(autoreverses: false)) {
//            animationPhase = 1.0
//        }
//        
//        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//            updateBarHeights()
//        }
//    }
//    
//    private func updateBarHeights() {
//        withAnimation(.easeInOut(duration: 0.8)) {
//            for index in 0..<barCount {
//                let normalizedIndex = Double(index) / Double(barCount - 1)
//                let wave1 = sin(animationPhase * 2.0 + normalizedIndex * .pi * 4.0)
//                let wave2 = sin(animationPhase * 1.5 + normalizedIndex * .pi * 2.0) * 0.5
//                let combined = (wave1 + wave2) * 0.5 + 0.5
//                let height = minHeight + (maxHeight - minHeight) * CGFloat(combined) * 0.7
//                barHeights[index] = height
//            }
//        }
//        
//        animationPhase += 0.1
//    }
//}

struct FeatureHighlight: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon container
            ZStack {
                Circle()
                    .fill(DarkTheme.accent.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DarkTheme.accent)
            }
            
            // Text content
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DarkTheme.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(DarkTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
