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
    let pulseSpeed: Double       
}

let DYNAMICS: [EmotionLabel: EmotionDynamics] = [
    .happy: .init(
        lineColors: [.yellow, .orange, .pink],
        particleColors: [.yellow.opacity(0.9), .orange.opacity(0.8), .pink.opacity(0.7)],
        bgGlow: .orange.opacity(0.35),
        amplitude: 28,
        frequency: 1.4,
        speed: 1.0,
        lineWidth: 2.4,
        particleCount: 140,
        particleSpeed: 30...70,
        pulseSpeed: 1.4
    ),

    .calm: .init(
        lineColors: [.mint, .teal, .blue.opacity(0.7)],
        particleColors: [.mint.opacity(0.7), .teal.opacity(0.6), .blue.opacity(0.5)],
        bgGlow: .teal.opacity(0.32),
        amplitude: 8,
        frequency: 0.7,
        speed: 0.25,
        lineWidth: 1.4,
        particleCount: 70,
        particleSpeed: 6...16,
        pulseSpeed: 0.4
    ),

    .sad: .init(
        lineColors: [.blue, .indigo, .purple.opacity(0.7)],
        particleColors: [.blue.opacity(0.7), .indigo.opacity(0.6)],
        bgGlow: .indigo.opacity(0.32),
        amplitude: 16,
        frequency: 0.9,
        speed: 0.2,
        lineWidth: 1.6,
        particleCount: 80,
        particleSpeed: 8...18,
        pulseSpeed: 0.7
    ),

    .energetic: .init(
        lineColors: [.pink, .red, .orange],
        particleColors: [.pink.opacity(0.9), .red.opacity(0.8), .orange.opacity(0.8)],
        bgGlow: .pink.opacity(0.4),
        amplitude: 32,
        frequency: 1.8,
        speed: 1.6,
        lineWidth: 2.6,
        particleCount: 180,
        particleSpeed: 50...110,
        pulseSpeed: 2.0
    ),

    .anxious: .init(
        lineColors: [.purple, .blue.opacity(0.6), .black.opacity(0.3)],
        particleColors: [.purple.opacity(0.7), .blue.opacity(0.5)],
        bgGlow: .purple.opacity(0.34),
        amplitude: 22,
        frequency: 1.7,
        speed: 0.8,
        lineWidth: 1.8,
        particleCount: 130,
        particleSpeed: 18...40,
        pulseSpeed: 1.7
    ),

    .focused: .init(
        lineColors: [.indigo, .blue, .teal],
        particleColors: [.indigo.opacity(0.8), .teal.opacity(0.6)],
        bgGlow: .indigo.opacity(0.30),
        amplitude: 10,
        frequency: 1.2,
        speed: 0.4,
        lineWidth: 1.8,
        particleCount: 90,
        particleSpeed: 10...24,
        pulseSpeed: 0.9
    ),

    .romantic: .init(
        lineColors: [.red, .pink, .purple],
        particleColors: [.red.opacity(0.7), .pink.opacity(0.7)],
        bgGlow: .red.opacity(0.30),
        amplitude: 18,
        frequency: 1.0,
        speed: 0.45,
        lineWidth: 2.0,
        particleCount: 100,
        particleSpeed: 12...26,
        pulseSpeed: 0.8
    ),

    .nostalgic: .init(
        lineColors: [.teal, .cyan, .yellow.opacity(0.6)],
        particleColors: [.teal.opacity(0.7), .cyan.opacity(0.6)],
        bgGlow: .teal.opacity(0.28),
        amplitude: 14,
        frequency: 0.95,
        speed: 0.35,
        lineWidth: 1.8,
        particleCount: 85,
        particleSpeed: 9...22,
        pulseSpeed: 0.75
    ),

    .angry: .init(
        lineColors: [.red, .orange, .black.opacity(0.3)],
        particleColors: [.red.opacity(0.85), .orange.opacity(0.75)],
        bgGlow: .red.opacity(0.40),
        amplitude: 30,
        frequency: 2.0,
        speed: 1.3,
        lineWidth: 2.8,
        particleCount: 170,
        particleSpeed: 60...130,
        pulseSpeed: 2.2
    ),

    // Bored：灰蓝，振幅小、速度慢，脉冲也很慢
    .bored: .init(
        lineColors: [.gray, .blue.opacity(0.25), .white.opacity(0.25)],
        particleColors: [.gray.opacity(0.6)],
        bgGlow: .gray.opacity(0.22),
        amplitude: 6,
        frequency: 0.6,
        speed: 0.15,
        lineWidth: 1.2,
        particleCount: 60,
        particleSpeed: 4...12,
        pulseSpeed: 0.5
    )
]

let EMOTION_TO_STREAM_URL: [EmotionLabel: String] = [
    .calm:      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    .happy:     "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    .sad:       "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
    .energetic: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
    .focused:   "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3",
    .anxious:   "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3",
    .romantic:  "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3",
    .nostalgic: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3",
    .angry:     "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3",
    .bored:     "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3"
]


@MainActor
final class MusicPlayer: ObservableObject {
    static let shared = MusicPlayer()

    private var player: AVPlayer?
    @Published var currentMood: EmotionLabel?
    @Published var isPlaying: Bool = false
    @Published var message: String?

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            message = "Audio session error: \(error.localizedDescription)"
        }
    }

    func play(for mood: EmotionLabel) {
        currentMood = mood
        guard let urlString = EMOTION_TO_STREAM_URL[mood],
              let url = URL(string: urlString) else {
            message = "No online track configured for \(mood.title)."
            isPlaying = false
            return
        }

        print("🎧 Start streaming \(mood.title) from: \(url.absoluteString)")

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.play()
        isPlaying = true
        message = nil
    }

    func toggle() {
        guard let p = player else { return }
        if p.timeControlStatus == .playing {
            p.pause()
            isPlaying = false
        } else {
            p.play()
            isPlaying = true
        }
    }
}

struct MoodWaveformView: View {
    let emotion: EmotionLabel
    private var dyn: EmotionDynamics { DYNAMICS[emotion]! }

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let phase = CGFloat(t) * CGFloat(dyn.speed) * .pi
            let pulse = 1.0 + 0.4 * sin(t * dyn.pulseSpeed * 2 * .pi)

            Canvas { ctx, size in
                let midY = size.height / 2
                let width = size.width

                let colors = dyn.lineColors
                let amplitude = dyn.amplitude
                let frequency = dyn.frequency
                let baseWidth = dyn.lineWidth

                for (i, color) in colors.enumerated() {
                    var path = Path()
                    let amp = amplitude * CGFloat(pulse) * (1.0 - CGFloat(i) * 0.3)
                    let freq = frequency * (1.0 + CGFloat(i) * 0.25)
                    let lw = baseWidth * (1.0 - CGFloat(i) * 0.15) * CGFloat(0.9 + 0.2 * pulse)

                    let step: CGFloat = 2.0
                    var x: CGFloat = 0
                    while x <= width {
                        let y1 = sin((x / 40.0) * 2 * .pi * freq + phase) * amp
                        let y2 = sin((x / 23.0) * 2 * .pi * (freq * 0.53) + phase * 0.7) * (amp * 0.35)
                        let y = midY + y1 + y2
                        if x == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
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
                    particles = makeParticles(
                        count: dyn.particleCount,
                        in: size,
                        colors: dyn.particleColors,
                        speed: dyn.particleSpeed
                    )
                }
                update(&particles, in: size, speed: dyn.particleSpeed, dt: 1.0 / 60.0)

                for p in particles {
                    let r = CGRect(
                        x: p.pos.x - p.size/2,
                        y: p.pos.y - p.size/2,
                        width: p.size,
                        height: p.size
                    )
                    g.fill(Circle().path(in: r), with: .color(p.color))
                }
            }
        }
    }

    private func makeParticles(
        count: Int,
        in size: CGSize,
        colors: [Color],
        speed: ClosedRange<Double>
    ) -> [Particle] {
        (0..<count).map { _ in
            Particle(
                pos: CGPoint(
                    x: .random(in: 0...size.width),
                    y: .random(in: 0...size.height)
                ),
                vel: CGVector(
                    dx: Double.random(in: speed) * (Bool.random() ? 1 : -1),
                    dy: Double.random(in: speed) * (Bool.random() ? 1 : -1)
                ),
                size: CGFloat.random(in: 1.2...3.0),
                color: colors.randomElement() ?? .white.opacity(0.7)
            )
        }
    }

    private func update(
        _ ps: inout [Particle],
        in size: CGSize,
        speed: ClosedRange<Double>,
        dt: Double
    ) {
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

struct MoodVisuals: View {
    let emotion: EmotionLabel
    var body: some View {
        ZStack {
            MoodParticleFieldView(emotion: emotion)
            MoodWaveformView(emotion: emotion).padding(12)
        }
        .allowsHitTesting(false)
    }
}

struct ContentView: View {
    @State private var emotion: EmotionLabel = .calm
    @State private var previousEmotion: EmotionLabel = .calm
    @State private var crossfade: Double = 0.0   // 0 = new, 1 = previous
    @StateObject private var player = MusicPlayer.shared

    private var emotionBinding: Binding<EmotionLabel> {
        Binding(
            get: { emotion },
            set: { newValue in
                previousEmotion = emotion
                emotion = newValue
                crossfade = 1.0
                withAnimation(.easeInOut(duration: 0.75)) { crossfade = 0.0 }
                player.play(for: newValue)
            }
        )
    }

    var body: some View {
        ZStack {
            let newColor = DYNAMICS[emotion]!.bgGlow
            let oldColor = DYNAMICS[previousEmotion]!.bgGlow
            oldColor.ignoresSafeArea().opacity(crossfade)
            newColor.ignoresSafeArea().opacity(1 - crossfade)
            MoodVisuals(emotion: emotion)
                .opacity(1 - crossfade)
            MoodVisuals(emotion: previousEmotion)
                .opacity(crossfade)
                .scaleEffect(1.02 - 0.02 * (1 - crossfade))
                .blur(radius: 5 * (1 - crossfade))

            VStack {
                HStack(spacing: 12) {
                    Text("Today's Mood")
                        .font(.headline)

                    Picker("Select Mood", selection: emotionBinding) {
                        ForEach(EmotionLabel.allCases) { e in
                            Text(e.title).tag(e)
                        }
                    }
                    .pickerStyle(.menu)

                    Spacer()

                    Button {
                        player.toggle()
                    } label: {
                        Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
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
                    Text(msg)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.top, 6)
                }

                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.75), value: crossfade)
    }
}

