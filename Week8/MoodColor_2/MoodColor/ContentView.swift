//
//  ContentView.swift
//  MoodColor
//
//  Created by 孙语鸿 on 10/24/25.
//

import SwiftUI
import UIKit

struct Mood: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let emoji: String
    let color: ColorData
    let image: String
}

struct ColorData: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }

    static func from(_ color: Color) -> ColorData {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return ColorData(red: Double(red),
                         green: Double(green),
                         blue: Double(blue),
                         opacity: Double(alpha))
    }
}

struct MoodRecord: Codable {
    let mood: Mood
    let date: Date
}

struct ContentView: View {
    @State private var selectedMood: Mood? = nil
    @State private var hasSavedToday = false
    @AppStorage("moodHistory") private var storedData: Data = Data()
    @State private var moodHistory: [(mood: Mood, date: Date)] = []

    let moods: [Mood] = [
        Mood(name: "Happy", emoji: "😊", color: .from(.yellow), image: "happy"),
        Mood(name: "Sad", emoji: "😢", color: .from(.blue), image: "sad"),
        Mood(name: "Angry", emoji: "😡", color: .from(.red), image: "angry"),
        Mood(name: "Calm", emoji: "😌", color: .from(.green), image: "peace"),
        Mood(name: "Awkward", emoji: "😅", color: .from(.purple), image: "awkward"),
        Mood(name: "Neutral", emoji: "😐", color: .from(.gray), image: "neutral")
    ]

    var body: some View {
        ZStack {
            (selectedMood?.color.color ?? .gray)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: selectedMood)

            VStack(spacing: 28) {
                Text("MoodColor Diary")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 4)

                if let mood = selectedMood {
                    VStack(spacing: 12) {
                        Image(mood.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .shadow(radius: 8)

                        Text("Today you feel \(mood.name.lowercased()) \(mood.emoji)")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                } else {
                    Text("Choose your mood 👇")
                        .foregroundColor(.white.opacity(0.8))
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                    ForEach(moods) { mood in
                        Button {
                            withAnimation(.spring()) {
                                selectedMood = mood
                                hasSavedToday = false
                            }
                        } label: {
                            Text(mood.emoji)
                                .font(.system(size: 45))
                                .padding()
                                .background(.white.opacity(selectedMood?.name == mood.name ? 0.4 : 0.2))
                                .cornerRadius(14)
                        }
                    }
                }
                .padding(.horizontal, 30)

                if selectedMood != nil && !hasSavedToday {
                    Button {
                        saveMood()
                    } label: {
                        Label("Save Today’s Mood", systemImage: "heart.fill")
                            .padding()
                            .background(.white.opacity(0.25))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }

                if !moodHistory.isEmpty {
                    List {
                        ForEach(moodHistory.indices, id: \.self) { index in
                            let item = moodHistory[index]
                            HStack {
                                Text(item.mood.emoji)
                                Text(item.mood.name)
                                    .font(.headline)
                                Spacer()
                                Text(item.date, style: .date)
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                Button {
                                    deleteMood(at: index)
                                } label: {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                        .padding(.leading, 8)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .listRowBackground(item.mood.color.color.opacity(0.15))
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .cornerRadius(12)
                }

                Spacer()
            }
            .padding(.top, 80)
            .padding()
            .onAppear {
                if isFirstLaunch() { clearHistory() }
                loadHistory()
            }
        }
    }

    func saveMood() {
        guard let mood = selectedMood else { return }
        let newEntry = (mood: mood, date: Date())
        moodHistory.insert(newEntry, at: 0)
        saveToStorage()
        withAnimation { hasSavedToday = true }
    }

    func deleteMood(at index: Int) {
        moodHistory.remove(at: index)
        saveToStorage()
    }

    func saveToStorage() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(moodHistory.map { MoodRecord(mood: $0.mood, date: $0.date) }) {
            storedData = data
        }
    }

    func loadHistory() {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([MoodRecord].self, from: storedData) {
            moodHistory = decoded.map { ($0.mood, $0.date) }
        }
    }

    func isFirstLaunch() -> Bool {
        let key = "hasLaunchedBefore"
        let launchedBefore = UserDefaults.standard.bool(forKey: key)
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: key)
            return true
        }
        return false
    }

    func clearHistory() {
        moodHistory.removeAll()
        storedData = Data()
    }
}

#Preview {
    ContentView()
}
