
import SwiftUI

struct StatsView: View {
    @EnvironmentObject var data: TimeData
    @State private var currentWeekStart = Date().startOfWeek()

    var body: some View {
        VStack {
            Text("Weekly View")
                .font(.title2)
                .padding()

            ScrollView {
                let days = allDaysInWeek(from: currentWeekStart)

                ForEach(days, id: \ .self) { day in
                    VStack(alignment: .leading) {
                        Text(dayTitle(for: day))
                            .font(.caption)

                        let slots = data.record(for: day).slots
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 24)) {
                            ForEach(slots.indices, id: \ .self) { i in
                                Rectangle()
                                    .fill(color(for: slots[i]))
                                    .frame(height: 10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    func allDaysInWeek(from start: Date) -> [Date] {
        (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: start)
        }
    }

    func dayTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d"
        return formatter.string(from: date)
    }

    func color(for act: Activity) -> Color {
        switch act {
        case .study: return .green
        case .work: return .blue
        case .fun: return .orange
        case .none: return .gray.opacity(0.2)
        }
    }
}

extension Date {
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: comps) ?? self
    }
}
