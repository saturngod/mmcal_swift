import SwiftUI

#if os(iOS)

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var myanmarDateString = "Loading..."
    @State private var astrologicalInfo = [String]()
    @State private var errorMessage: String?
    @State private var showDatePicker = false // Note: This seems unused in the provided code for triggering the sheet.
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                if horizontalSizeClass == .regular {
                    iPadLayout
                } else {
                    iPhoneLayout
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack) // Use stack style to avoid sidebar on iPad for this custom layout
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
        .onAppear {
            loadMyanmarCalendar(for: selectedDate)
        }
    }
    
    // MARK: - UI Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var iPhoneLayout: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                dateSelectionSection
                resultSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    private var iPadLayout: some View {
        VStack(spacing: 24) {
            headerSection
            
            HStack(alignment: .top, spacing: 24) {
                // Left Column: Date Picker
                ScrollView {
                    dateSelectionSection
                }
                .frame(maxWidth: 420)
                
                // Right Column: Results
                ScrollView {
                    resultSection
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var resultSection: some View {
        VStack(spacing: 24) {
            if let error = errorMessage {
                errorSection(error)
            } else {
                myanmarDateSection
                astrologicalSection
            }
            Spacer(minLength: 20)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Myanmar Calendar")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Traditional Myanmar Date Converter")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var dateSelectionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text("Select Date")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            // Inline graphical date picker
            DatePicker("Choose Date", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                .onChange(of: selectedDate) { _, newDate in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        loadMyanmarCalendar(for: newDate)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .padding(20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var myanmarDateSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "globe.asia.australia.fill")
                    .foregroundColor(.orange)
                Text("Myanmar Date")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Text(myanmarDateString)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .padding(20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var astrologicalSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(.purple)
                Text("Astrological Information")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if !astrologicalInfo.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(Array(astrologicalInfo.enumerated()), id: \.offset) { index, info in
                        astrologicalInfoCard(info: info, index: index)
                    }
                }
            } else {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                    Text("No astrological information available")
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func astrologicalInfoCard(info: String, index: Int) -> some View {
        let components = info.split(separator: ":", maxSplits: 1)
        let title = String(components.first ?? "")
        let value = components.count > 1 ? String(components[1]).trimmingCharacters(in: .whitespaces) : ""
        
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .indigo, .teal]
        let color = colors[index % colors.count]
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForInfo(title))
                    .foregroundColor(color)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value.isEmpty ? title : value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(2)
        }
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
    
    
    private var datePickerSheet: some View {
        NavigationView {
            ZStack {
                // Glassmorphism background with blur
                VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                    .ignoresSafeArea()
                // Gradient overlay for depth
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.10),
                        Color.purple.opacity(0.10),
                        Color.blue.opacity(0.18)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 20) {
                        // Prominent drag indicator
                        Capsule()
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: 48, height: 7)
                            .padding(.top, 12)
                        
                        // Icon and title
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            VStack(spacing: 4) {
                                Text("Select Date")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text("Choose a date to convert to Myanmar calendar")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        // Divider for separation
                        Divider()
                            .background(Color.gray.opacity(0.15))
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 18)
                    
                    // Date Picker Card with glass effect
                    VStack(spacing: 24) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white.opacity(0.25))
                                .background(
                                    VisualEffectBlur(blurStyle: .systemMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                )
                                .shadow(color: .blue.opacity(0.08), radius: 16, x: 0, y: 8)
                            DatePicker("Choose Date", selection: $selectedDate, displayedComponents: [.date])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .labelsHidden()
                        }
                        .padding(.horizontal, 8)
                        
                        // Action Buttons with haptic feedback
                        HStack(spacing: 16) {
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                showDatePicker = false
                            }) {
                                HStack {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 15, weight: .semibold))
                                    Text("Cancel")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.gray.opacity(0.12))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                                )
                            }
                            
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                showDatePicker = false
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    loadMyanmarCalendar(for: selectedDate)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 15, weight: .semibold))
                                    Text("Apply")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(color: .purple.opacity(0.18), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal, 8)
                        
                        // Selected Date Preview
                        VStack(spacing: 8) {
                            Text("Selected Date")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text(formattedDate(selectedDate))
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.12))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(24, UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .first?.windows.first?.safeAreaInsets.bottom ?? 24))
                    .animation(.easeInOut(duration: 0.25), value: selectedDate)
                    Spacer(minLength: 0)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 0)
                }
            }
            .navigationBarHidden(true)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
    
    private func errorSection(_ error: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(error)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color.red.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Helper Functions
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func iconForInfo(_ info: String) -> String {
        switch info.lowercased() {
        case "pyathada": return "star.fill"
        case "sabbath": return "moon.fill"
        case "yatyaza": return "sun.max.fill"
        case "nagahle": return "flame.fill"
        case "mahabote": return "crown.fill"
        case "nakhat": return "sparkles"
        case "myanmar year": return "calendar"
        case "myanmar month": return "calendar.circle"
        case "myanmar day": return "calendar.day.timeline.left"
        case "weekday": return "calendar.day.timeline.right"
        default: return "info.circle.fill"
        }
    }
    
    private func loadMyanmarCalendar(for date: Date = Date()) {
        do {
            // Extract date components from the selected date
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            
            guard let year = components.year,
                  let month = components.month,
                  let day = components.day else {
                errorMessage = "Invalid date components"
                return
            }
            
            // Create Myanmar calendar instance for the selected date
            let myanmarCalendar = try MyanmarCalendar(year: year, month: month, day: day)
            
            myanmarDateString = myanmarCalendar.getCurrentMyanmarDateString() ?? "Unable to get date"
            
            astrologicalInfo = []
            
            if let pyathada = myanmarCalendar.pyathada, !pyathada.isEmpty {
                astrologicalInfo.append("Pyathada: \(pyathada)")
            }
            
            if let sabbath = myanmarCalendar.sabbath, !sabbath.isEmpty {
                astrologicalInfo.append("Sabbath: \(sabbath)")
            }
            
            if let yatyaza = myanmarCalendar.yatyaza, !yatyaza.isEmpty {
                astrologicalInfo.append("Yatyaza: \(yatyaza)")
            }
            
            if let nagahle = myanmarCalendar.nagahle {
                astrologicalInfo.append("Nagahle: \(nagahle)")
            }
            
            if let mahabote = myanmarCalendar.mahabote {
                astrologicalInfo.append("Mahabote: \(mahabote)")
            }
            
            if let nakhat = myanmarCalendar.nakhat {
                astrologicalInfo.append("Nakhat: \(nakhat)")
            }
            
            // Add Myanmar year, month, and day info
            if let myanmarYear = myanmarCalendar.myanmarYear {
                astrologicalInfo.append("Myanmar Year: \(myanmarYear)")
            }
            
            if let myanmarMonth = myanmarCalendar.myanmarMonth {
                astrologicalInfo.append("Myanmar Month: \(myanmarMonth)")
            }
            
            if let myanmarDay = myanmarCalendar.myanmarDay {
                astrologicalInfo.append("Myanmar Day: \(myanmarDay)")
            }
            
            if let weekday = myanmarCalendar.weekday {
                let weekdays = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
                if weekday >= 0 && weekday < weekdays.count {
                    astrologicalInfo.append("Weekday: \(weekdays[weekday])")
                }
            }
            
            errorMessage = nil
            
        } catch {
            errorMessage = error.localizedDescription
            astrologicalInfo = []
            myanmarDateString = "Error loading date"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - VisualEffectBlur for glassmorphism
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#endif
