//
//  timeApp.swift
//  time
//
//  Created by 孙语鸿 on 10/3/25.
//

import SwiftUI

struct RecordView: View {
    @EnvironmentObject var data: TimeData
    @State private var selectedDate = Date()
    @State private var currentActivity: Activity = .study
    
    var body: some View {
        VStack {
            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding()
            
            Picker("Category", selection: $currentActivity) {
                ForEach(Activity.allCases.filter { $0 != .none }) { act in
                    Text(act.rawValue).tag(act)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            let slots = data.record(for: selectedDate).slots
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                ForEach(slots.indices, id: \.self) { i in
                    Rectangle()
                        .fill(color(for: slots[i]))
                        .frame(height: 30)
                        .onTapGesture {
                            data.updateSlot(date: selectedDate, index: i, activity: currentActivity)
                        }
                }
            }
            .padding()
        }
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
