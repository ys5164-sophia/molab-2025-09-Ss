//
//  ContentView.swift
//  MoodColor
//
//  Created by 孙语鸿 on 10/24/25.
//

import SwiftUI
import AVFoundation
import Combine

enum EmotionLabel: String, CaseIterable, Identifiable {
    case happy, calm, sad, energetic, anxious, focused, romantic, nostalgic, angry, bored
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

struct EmotionDynamics {
    let lineColors: [Color]
    let particleColors: [Color]
    let bgGlow: Color
    let amplitude: CGFloat
    let frequency: CGFloat
    let speed: Double
    let lineWidth: CGFloat
    let particleCount: Int
    let particleSpeed: ClosedRange<Double>
}

let DYNAMICS: [EmotionLabel: EmotionDynamics] = [
    .happy: .init(lineColors: [.yellow, .orange, .pink],
                  particleColors: [.yellow.opacity(0.9), .orange.opacity(0.8), .pink.opacity(0.7)],
                  bgGlow: .orange.opacity(0.25),
                  amplitude: 18, frequency: 1.3, speed: 0.9, lineWidth: 2.0,
                  particleCount: 120, particleSpeed: 20...60),
    .calm: .init(lineColors: [.mint, .teal, .blue.opacity(0.6)],
                 particleColors: [.mint.opacity(0.7), .teal.opacity(0.6), .blue.opacity(0.5)],
                 bgGlow: .teal.opacity(0.22),
                 amplitude: 10, frequency: 0.9, speed: 0.25, lineWidth: 1.5,
                 particleCount: 80, particleSpeed: 8...20),
    .sad: .init(lineColors: [.blue, .indigo, .purple.opacity(0.5)],
                particleColors: [.blue.opacity(0.7), .indigo.opacity(0.6)],
                bgGlow: .indigo.opacity(0.22),
                amplitude: 14, frequency: 1.0, speed: 0.18, lineWidth: 1.5,
                particleCount: 70, particleSpeed: 6...16),
    .energetic: .init(lineColors: [.pink, .red, .orange],
                      particleColors: [.pink.opacity(0.9), .red.opacity(0.8), .orange.opacity(0.8)],
                      bgGlow: .pink.opacity(0.28),
                      amplitude: 26, frequency: 1.6, speed: 1.4, lineWidth: 2.2,
                      particleCount: 160, particleSpeed: 40...90),
    .anxious: .init(lineColors: [.purple, .blue.opacity(0.5), .black.opacity(0.2)],
                    particleColors: [.purple.opacity(0.7), .blue.opacity(0.5)],
                    bgGlow: .purple.opacity(0.20),
                    amplitude: 16, frequency: 1.5, speed: 0.55, lineWidth: 1.8,
                    particleCount: 110, particleSpeed: 14...36),
    .focused: .init(lineColors: [.indigo, .blue, .teal],
                    particleColors: [.indigo.opacity(0.8), .teal.opacity(0.6)],
                    bgGlow: .indigo.opacity(0.24),
                    amplitude: 8, frequency: 1.1, speed: 0.35, lineWidth: 1.6,
                    particleCount: 90, particleSpeed: 10...22),
    .romantic: .init(lineColors: [.red, .pink, .purple],
                     particleColors: [.red.opacity(0.7), .pink.opacity(0.7)],
                     bgGlow: .red.opacity(0.22),
                     amplitude: 14, frequency: 1.0, speed: 0.38, lineWidth: 1.8,
                     particleCount: 95, particleSpeed: 10...26),
    .nostalgic: .init(lineColors: [.teal, .cyan, .yellow.opacity(0.5)],
                      particleColors: [.teal.opacity(0.7), .cyan.opacity(0.6)],
                      bgGlow: .teal.opacity(0.2),
                      amplitude: 12, frequency: 0.95, speed: 0.32, lineWidth: 1.7,
                      particleCount: 85, particleSpeed: 9...22),
    .angry: .init(lineColors: [.red, .orange, .black.opacity(0.2)],
                  particleColors: [.red.opacity(0.85), .orange.opacity(0.7)],
                  bgGlow: .red.opacity(0.26),
                  amplitude: 22, frequency: 1.7, speed: 1.2, lineWidth: 2.2,
                  particleCount: 150, particleSpeed: 50...110),
    .bored: .init(lineColors: [.gray, .blue.opacity(0.2), .white.opacity(0.2)],
                  particleColors: [.gray.opacity(0.6)],
                  bgGlow: .gray.opacity(0.14),
                  amplitude: 6, frequency: 0.8, speed: 0.12, lineWidth: 1.2,
                  particleCount: 60, particleSpeed: 4...12)
]

let EMOTION_TO_LOCAL_TRACKS: [EmotionLabel: [String]] = [
    .calm: ["calm1"],
    .happy: ["happy1"],
    .sad: ["sad1"],
    .energetic: ["energetic1"],
    .focused: ["focus1"]
]

@MainActor
final class MusicPlayer: ObservableObject {
    static let shared = MusicPlayer()
    private var player: AVAudioPlayer?
    @Published var currentMood: EmotionLabel?
    @Published var isPlaying: Bool = false
    @Published var message: String?

    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            message = "Audio session error: \(error.localizedDescription)"
        }
    }

    func play(for mood: EmotionLabel) {
        currentMood = mood
        guard let name = EMOTION_TO_LOCAL_TRACKS[mood]?.first,
              let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            message = "No local MP3 found for \(mood.title)."
            isPlaying = false
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            isPlaying = true
            message = nil
        } catch {
            message = "Playback failed: \(error.localizedDescription)"
            isPlaying = false
        }
    }

    func toggle() {
        guard let p = player else { return }
        if p.isPlaying { p.pause(); isPlaying = false } else { p.play(); isPlaying = true }
    }
}

struct MoodWaveformView: View {
    let emotion: EmotionLabel
    private var dyn: EmotionDynamics { DYNAMICS[emotion]! }

    var body: some View {
        TimelineView(.animation) { context in
            let seconds = context.date.timeIntervalSinceReferenceDate
            let phase = CGFloat(seconds) * CGFloat(dyn.speed) * .pi

            Canvas { ctx, size in
                let midY = size.height / 2
                let width = size.width

                let colors = dyn.lineColors
                let amplitude = dyn.amplitude
                let frequency = dyn.frequency
                let baseWidth = dyn.lineWidth

                for (i, color) in colors.enumerated() {
                    var path = Path()
                    let amp = amplitude * (1.0 - CGFloat(i) * 0.3)
                    let freq = frequency * (1.0 + CGFloat(i) * 0.2)
                    let lw = baseWidth * (1.0 - CGFloat(i) * 0.15)

                    let step: CGFloat = 2.0
                    var x: CGFloat = 0
                    while x <= width {
                        let y1 = sin((x / 40.0) * 2 * .pi * freq + phase) * amp
                        let y2 = sin((x / 23.0) * 2 * .pi * (freq * 0.53) + phase * 0.7) * (amp * 0.35)
                        let y = midY + y1 + y2
                        if x == 0 { path.move(to: CGPoint(x: x, y: y)) }
                        else { path.addLine(to: CGPoint(x: x, y: y)) }
                        x += step
                    }

                    ctx.stroke(path, with: .color(color.opacity(0.8)), lineWidth: lw)
                }
            }
        }
    }
}

private struct Particle: Identifiable {
    let id = UUID()
    var pos: CGPoint
    var vel: CGVector
    var size: CGFloat
    var color: Color
}

struct MoodParticleFieldView: View {
    let emotion: EmotionLabel
    @State private var particles: [Particle] = []
    @State private var lastSize: CGSize = .zero

    var body: some View {
        let dyn = DYNAMICS[emotion]!
        TimelineView(.animation) { _ in
            Canvas { g, size in
                if size != lastSize || particles.isEmpty {
                    lastSize = size
                    particles = makeParticles(count: dyn.particleCount, in: size, colors: dyn.particleColors, speed: dyn.particleSpeed)
                }
                update(&particles, in: size, speed: dyn.particleSpeed, dt: 1.0 / 60.0)

                for p in particles {
                    let r = CGRect(x: p.pos.x - p.size/2, y: p.pos.y - p.size/2, width: p.size, height: p.size)
                    g.fill(Circle().path(in: r), with: .color(p.color))
                }
            }
        }
    }

    private func makeParticles(count: Int, in size: CGSize, colors: [Color], speed: ClosedRange<Double>) -> [Particle] {
        (0..<count).map { _ in
            Particle(
                pos: CGPoint(x: .random(in: 0...size.width), y: .random(in: 0...size.height)),
                vel: CGVector(dx: Double.random(in: speed) * (Bool.random() ? 1 : -1),
                              dy: Double.random(in: speed) * (Bool.random() ? 1 : -1)),
                size: CGFloat.random(in: 1.2...3.0),
                color: colors.randomElement() ?? .white.opacity(0.7)
            )
        }
    }

    private func update(_ ps: inout [Particle], in size: CGSize, speed: ClosedRange<Double>, dt: Double) {
        let w = size.width, h = size.height, maxV = speed.upperBound
        for i in ps.indices {
            ps[i].pos.x += ps[i].vel.dx * dt
            ps[i].pos.y += ps[i].vel.dy * dt
            if ps[i].pos.x < 0 { ps[i].pos.x += w }
            if ps[i].pos.x > w { ps[i].pos.x -= w }
            if ps[i].pos.y < 0 { ps[i].pos.y += h }
            if ps[i].pos.y > h { ps[i].pos.y -= h }
            ps[i].vel.dx += Double.random(in: -4...4) * dt
            ps[i].vel.dy += Double.random(in: -4...4) * dt
            ps[i].vel.dx = max(min(ps[i].vel.dx, maxV), -maxV)
            ps[i].vel.dy = max(min(ps[i].vel.dy, maxV), -maxV)
        }
    }
}

struct MoodBackground: View {
    let emotion: EmotionLabel
    var body: some View {
        ZStack {
            MoodParticleFieldView(emotion: emotion)
            MoodWaveformView(emotion: emotion).padding(12)
        }
        .ignoresSafeArea()
    }
}

struct ContentView: View {
    @State private var emotion: EmotionLabel = .calm
    @State private var previousEmotion: EmotionLabel = .calm
    @State private var crossfade: Double = 0.0    // 0 = new fully visible, 1 = previous fully visible
    @StateObject private var player = MusicPlayer.shared

    // Custom binding lets us capture the old value and animate
    private var emotionBinding: Binding<EmotionLabel> {
        Binding(
            get: { emotion },
            set: { newValue in
                previousEmotion = emotion
                emotion = newValue
                crossfade = 1.0
                withAnimation(.easeInOut(duration: 0.6)) { crossfade = 0.0 }
            }
        )
    }

    var body: some View {
        ZStack {
            // Crossfade stack: previous on top, new underneath
            MoodBackground(emotion: emotion)               // new
                .opacity(1.0 - crossfade)
                .scaleEffect(1.0)                          // stable
            MoodBackground(emotion: previousEmotion)       // previous
                .opacity(crossfade)
                .scaleEffect(1.02 - 0.02 * (1.0 - crossfade)) // subtle depth
                .blur(radius: 4.0 * (1.0 - crossfade))

            VStack {
                HStack(spacing: 12) {
                    Text("Today's Mood").font(.headline)

                    Picker("Select Mood", selection: emotionBinding) {
                        ForEach(EmotionLabel.allCases) { e in
                            Text(e.title).tag(e)
                        }
                    }
                    .pickerStyle(.menu)

                    Spacer()

                    Button {
                        if player.currentMood == emotion && player.isPlaying {
                            player.toggle()
                        } else {
                            player.play(for: emotion)
                        }
                    } label: {
                        Image(systemName: (player.currentMood == emotion && player.isPlaying) ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.top, 12)
                .padding(.horizontal, 12)

                if let msg = player.message {
                    Text(msg).font(.footnote).foregroundStyle(.red).padding(.top, 6)
                }

                Spacer()
            }
        }
        // Ensure any state-driven updates also animate
        .animation(.easeInOut(duration: 0.6), value: crossfade)
    }
}
