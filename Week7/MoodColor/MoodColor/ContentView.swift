//
//  ContentView.swift
//  MoodColor
//
//  Created by 孙语鸿 on 10/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var moodText: String = ""
    @State private var backgroundColor: Color = .gray
    @State private var moodName: String = "Neutral"
    @State private var moodImage: String = "neutral"
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: backgroundColor)

            VStack(spacing: 25) {
                Text("MoodColor")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 4)

                TextField("Type your mood...", text: $moodText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 40)
                    .onSubmit { updateMood(for: moodText) }

                Button("Show My Mood") {
                    updateMood(for: moodText)
                }
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(10)

                VStack(spacing: 16) {
                    Image(moodImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .shadow(radius: 12)

                    Text("Mood: \(moodName)")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding()
        }
    }

    func updateMood(for mood: String) {
        let text = mood.lowercased()
        switch text {
        case let s where s.contains("happy"):
            backgroundColor = .yellow
            moodName = "Happy"
            moodImage = "happy"
        case let s where s.contains("sad"):
            backgroundColor = .blue
            moodName = "Sad"
            moodImage = "sad"
        case let s where s.contains("angry"):
            backgroundColor = .red
            moodName = "Angry"
            moodImage = "angry"
        case let s where s.contains("calm") || s.contains("peace"):
            backgroundColor = .green
            moodName = "Calm"
            moodImage = "peace"
        default:
            backgroundColor = .gray
            moodName = "Neutral"
            moodImage = "neutral"
        }
    }
}

#Preview {
    ContentView()
}

