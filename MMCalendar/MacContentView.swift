import SwiftUI
#if os(macOS)
struct MacContentView: View {
    @State private var selectedDate = Date()
    @State private var myanmarDateString = "Loading..."
    @State private var astrologicalInfo = [String]()
    @State private var errorMessage: String?

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            mainContent
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 900, minHeight: 600)
        .onAppear {
            loadMyanmarCalendar(for: selectedDate)
        }
    }

    // MARK: - Sidebar
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Myanmar Calendar")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Traditional Date Converter")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            // Date Picker Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Date")
                    .font(.headline)
                    .fontWeight(.medium)
                
                CustomCalendarView(selectedDate: $selectedDate)
                    .onChange(of: selectedDate) { _, newDate in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            loadMyanmarCalendar(for: newDate)
                        }
                    }
            }
            .padding(16)
            
            Spacer()
        }
        .frame(minWidth: 240, idealWidth: 280, maxWidth: 320)
        .background(Color(NSColor.controlBackgroundColor))
        .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 320)
    }

    // MARK: - Main Content
    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let error = errorMessage {
                    errorSection(error)
                } else {
                    myanmarDateSection
                    astrologicalSection
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(NSColor.textBackgroundColor))
        .navigationTitle("Myanmar Calendar")
        .navigationSubtitle(DateFormatter.longDateFormatter.string(from: selectedDate))
    }

    private var myanmarDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Myanmar Date")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(myanmarDateString)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
            )
        }
    }

    private var astrologicalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Astrological Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            if !astrologicalInfo.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(Array(astrologicalInfo.enumerated()), id: \.offset) { index, info in
                        astrologicalInfoCard(info: info, index: index)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                    Text("No astrological information available")
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
                )
            }
        }
    }

    private func astrologicalInfoCard(info: String, index: Int) -> some View {
        let components = info.split(separator: ":", maxSplits: 1)
        let title = String(components.first ?? "")
        let value = components.count > 1 ? String(components[1]).trimmingCharacters(in: .whitespaces) : ""

        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .indigo, .teal]
        let color = colors[index % colors.count]

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: iconForInfo(title))
                    .foregroundColor(color)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .textCase(.uppercase)
            }
            
            Text(value.isEmpty ? title : value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .textSelection(.enabled)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }

    private func errorSection(_ error: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)
                Text("Error")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(error)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Helper Functions
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
        case "myanmar day": return "calendar.badge.clock"
        case "weekday": return "calendar.day.timeline.leading"
        default: return "info.circle.fill"
        }
    }

    private func loadMyanmarCalendar(for date: Date = Date()) {
        do {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)

            guard let year = components.year,
                  let month = components.month,
                  let day = components.day else {
                errorMessage = "Invalid date components"
                return
            }

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

// MARK: - Extensions
extension DateFormatter {
    static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
}

#Preview {
    MacContentView()
}

#endif
