//
//  timeApp.swift
//  time
//
//  Created by 孙语鸿 on 10/3/25.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var data: TimeData
    @State private var currentWeekStart = Date().startOfWeek() 
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { changeWeek(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(weekTitle(for: currentWeekStart))
                    .font(.title2).bold()
                Spacer()
                Button(action: { changeWeek(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 16) {
                    let days = allDaysInWeek(from: currentWeekStart)
                    
                    ForEach(days, id: \.self) { day in
                        HStack(alignment: .top, spacing: 12) {
                            Text(dayTitle(for: day))
                                .frame(width: 60, alignment: .leading)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            let slots = data.record(for: day).slots
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 24),
                                spacing: 1
                            ) {
                                ForEach(slots.indices, id: \.self) { i in
                                    Rectangle()
                                        .fill(color(for: slots[i]))
                                        .frame(height: 10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }
    
    func changeWeek(by value: Int) {
        if let newWeek = Calendar.current.date(byAdding: .weekOfYear, value: value, to: currentWeekStart) {
            currentWeekStart = newWeek.startOfWeek()
        }
    }
    
    func weekTitle(for start: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start)!
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    func allDaysInWeek(from start: Date) -> [Date] {
        (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: start)
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
