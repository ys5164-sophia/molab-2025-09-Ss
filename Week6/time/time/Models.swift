
import Foundation
import Combine

enum Activity: String, CaseIterable, Identifiable, Codable {
    case study = "Study"
    case work = "Work"
    case fun = "Entertainment"
    case none = "Spare"

    var id: String { rawValue }
}

struct DayRecord: Identifiable, Codable {
    let id: UUID
    var date: Date
    var slots: [Activity]

    init(id: UUID = UUID(), date: Date, slots: [Activity]) {
        self.id = id
        self.date = date
        self.slots = slots
    }
}

class TimeData: ObservableObject {
    @Published var records: [DayRecord] = [] {
        didSet { save() }
    }

    private let storageKey = "TimeDataRecords"

    init() {
        load()
        if records.isEmpty {
            let today = Date()
            let slots = Array(repeating: Activity.none, count: 48)
            records.append(DayRecord(date: today, slots: slots))
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([DayRecord].self, from: data) {
            records = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func record(for date: Date) -> DayRecord {
        if let index = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return records[index]
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
}
