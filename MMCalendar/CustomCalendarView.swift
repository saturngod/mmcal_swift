import SwiftUI
#if os(macOS)
struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    @State private var currentMonth: Date // Represents the first day of the month currently displayed

    private let calendar = Calendar.current

    // For month picker
    private let months = Calendar.current.monthSymbols
    @State private var selectedMonthIndex: Int

    // For year picker
    @State private var selectedYear: Int
    private let yearRange: ClosedRange<Int>

    init(selectedDate: Binding<Date>) {
        _selectedDate = selectedDate
        _currentMonth = State(initialValue: selectedDate.wrappedValue.startOfMonth())

        let components = Calendar.current.dateComponents([.year, .month], from: selectedDate.wrappedValue)
        _selectedMonthIndex = State(initialValue: (components.month ?? 1) - 1) // 0-indexed
        _selectedYear = State(initialValue: components.year ?? Calendar.current.component(.year, from: Date()))

        // Define a reasonable year range, e.g., 100 years before and 100 years after current year
        let currentYear = Calendar.current.component(.year, from: Date())
        yearRange = (currentYear - 100)...(currentYear + 100)
    }

    var body: some View {
        VStack(spacing: 10) {
            // Month and Year Pickers
            HStack {
                Picker("Month", selection: $selectedMonthIndex) {
                    ForEach(0..<months.count, id: \.self) { index in
                        Text(months[index]).tag(index)
                    }
                }
                .pickerStyle(.menu)
                .frame(minWidth: 100) // Ensure enough space for month names
                .onChange(of: selectedMonthIndex) { _ in updateCurrentMonth() }

                Picker("Year", selection: $selectedYear) {
                    ForEach(yearRange, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.menu)
                .frame(minWidth: 70) // Ensure enough space for year
                .onChange(of: selectedYear) { _ in updateCurrentMonth() }
            }
            .padding(.horizontal, 8)

            // Weekday Headers
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)

            // Days Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 5) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                        DayView(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate), action: {
                            selectedDate = date
                        })
                    } else {
                        Text("") // Empty space for days outside the current month
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private func updateCurrentMonth() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonthIndex + 1 // Convert 0-indexed to 1-indexed month
        components.day = 1 // Always set to the first day of the month

        if let newMonth = calendar.date(from: components) {
            currentMonth = newMonth
        }
    }

    private func daysInMonth() -> [Date] {
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let numDays = range.count

        var dates: [Date] = []
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) // 1 for Sunday, 7 for Saturday

        // Add leading empty days to align with the first day of the week
        // Adjusting for calendar's first weekday (e.g., Sunday=1, Monday=2)
        let startOffset = (firstWeekday - calendar.firstWeekday + 7) % 7
        for _ in 0..<startOffset {
            dates.append(Date.distantPast) // Placeholder for empty cells
        }

        // Add days of the month
        for day in 1...numDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                dates.append(date)
            }
        }
        return dates
    }
}

struct DayView: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Button(action: action) {
            Text("\(calendar.component(.day, from: date))")
                .font(.body)
                .frame(width: 30, height: 30)
                .background(isSelected ? Color.accentColor : Color.clear)
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain) // Make it look like a native button
    }
}

extension Date {
    func startOfMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
}

// Preview for CustomCalendarView
#Preview {
    struct CustomCalendarView_Previews: View {
        @State private var date = Date()
        var body: some View {
            CustomCalendarView(selectedDate: $date)
                .padding()
        }
    }
    return CustomCalendarView_Previews()
}

#endif
