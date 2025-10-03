//
//  timeApp.swift
//  time
//
//  Created by 孙语鸿 on 10/3/25.
//

import Foundation
import Combine

enum Activity: String, CaseIterable, Identifiable {
    case study = "Study"
    case work = "Work"
    case fun = "Entertainment"
    case none = "Spare"
    
    var id: String { rawValue }
}

struct DayRecord: Identifiable {
    let id = UUID()
    var date: Date
    var slots: [Activity]
}

class TimeData: ObservableObject {
    @Published var records: [DayRecord] = []
    
    init() {
        let today = Date()
        let slots = Array(repeating: Activity.none, count: 48)
        records.append(DayRecord(date: today, slots: slots))
    }
    
    func record(for date: Date) -> DayRecord {
        if let existing = records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return existing
        } else {
            let new = DayRecord(date: date, slots: Array(repeating: Activity.none, count: 48))
            records.append(new)
            return new
        }
    }
    
    func updateSlot(date: Date, index: Int, activity: Activity) {
        if let i = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            records[i].slots[index] = activity
        }
    }
    
    func stats(for date: Date) -> [Activity: Int] {
        let record = record(for: date)
        var dict: [Activity: Int] = [:]
        for act in record.slots {
            dict[act, default: 0] += 30 
        }
        return dict
    }
}
