import SwiftUI
import AVFoundation
import Combine

enum EmotionLabel: String, CaseIterable, Identifiable {
    case happy, calm, sad, energetic, anxious, focused, bored
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum WaveStyle {
    case smooth, dual, jagged, noisy, sharp
}

struct EmotionDynamics {
    let lineColors: [Color]
    let bgGlow: Color
    let frequency: CGFloat
    let speed: Double
    let lineWidth: CGFloat
    let pulseSpeed: Double
    let notePool: [Int]
    let tempo: Double
    let style: WaveStyle
}

let DYNAMICS: [EmotionLabel: EmotionDynamics] = [
    .happy: .init(
        lineColors: [.yellow, .orange, .pink],
        bgGlow: .orange.opacity(0.45),
        frequency: 1.5,
        speed: 1.2,
        lineWidth: 3,
        pulseSpeed: 1.8,
        notePool: [60, 64, 67, 72],
        tempo: 0.25,
        style: .dual
    ),
    .calm: .init(
        lineColors: [.mint, .cyan],
        bgGlow: .teal.opacity(0.35),
        frequency: 0.5,
        speed: 0.2,
        lineWidth: 1.5,
        pulseSpeed: 0.4,
        notePool: [60, 62, 65],
        tempo: 0.8,
        style: .smooth
    ),
    .sad: .init(
        lineColors: [.indigo, .blue],
        bgGlow: .indigo.opacity(0.40),
        frequency: 0.7,
        speed: 0.3,
        lineWidth: 2,
        pulseSpeed: 0.6,
        notePool: [57, 60, 64],
        tempo: 0.9,
        style: .smooth
    ),
    .energetic: .init(
        lineColors: [.pink, .red, .yellow],
        bgGlow: .pink.opacity(0.50),
        frequency: 2.3,
        speed: 1.8,
        lineWidth: 4,
        pulseSpeed: 2.5,
        notePool: [60, 64, 67, 71],
        tempo: 0.15,
        style: .jagged
    ),
    .anxious: .init(
        lineColors: [.purple, .blue],
        bgGlow: .purple.opacity(0.45),
        frequency: 1.9,
        speed: 1.1,
        lineWidth: 2.5,
        pulseSpeed: 2.0,
        notePool: [59, 62, 65],
        tempo: 0.2,
        style: .noisy
    ),
    .focused: .init(
        lineColors: [.cyan, .blue],
        bgGlow: .blue.opacity(0.35),
        frequency: 1.1,
        speed: 0.5,
        lineWidth: 2,
        pulseSpeed: 0.9,
        notePool: [60, 63, 67],
        tempo: 0.4,
        style: .sharp
    ),
    .bored: .init(
        lineColors: [.gray],
        bgGlow: .gray.opacity(0.25),
        frequency: 0.3,
        speed: 0.1,
        lineWidth: 1.2,
        pulseSpeed: 0.3,
        notePool: [60],
        tempo: 1.2,
        style: .smooth
    )
]

@MainActor
final class MelodyEngine: ObservableObject {
    @Published var level: CGFloat = 0
    @Published var isPlaying = false

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
    private var timer: Timer?

    var emotion: EmotionLabel = .calm { didSet { restart() } }

    init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)

        engine.mainMixerNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: engine.mainMixerNode.outputFormat(forBus: 0)
        ) { [weak self] buffer, _ in
            guard let ch = buffer.floatChannelData?[0] else { return }
            let rms = sqrt(
                (0..<Int(buffer.frameLength))
                    .map { ch[$0] * ch[$0] }
                    .reduce(0, +) / Float(buffer.frameLength)
            )
            DispatchQueue.main.async {
                self?.level = min(1, CGFloat(rms * 25))
            }
        }

        try? engine.start()
    }

    func restart() {
        stop()
        play()
    }

    func play() {
        guard !isPlaying else { return }
        isPlaying = true
        scheduleNotes()
    }

    func stop() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
        player.stop()
    }

    private func scheduleNotes() {
        let dyn = DYNAMICS[emotion]!
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: dyn.tempo, repeats: true) { _ in
            let note = dyn.notePool.randomElement()!
            let freq = 440 * pow(2, Double(note - 69) / 12)
            self.playTone(freq: freq)
        }
    }

    private func playTone(freq: Double) {
        let frameCount = Int(format.sampleRate * 0.12)
        let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(frameCount)
        )!
        buffer.frameLength = AVAudioFrameCount(frameCount)

        for i in 0..<frameCount {
            let sample = sin(2 * .pi * freq * Double(i) / format.sampleRate)
            buffer.floatChannelData![0][i] = Float(sample) * 0.35
        }

        player.scheduleBuffer(buffer)
        if !player.isPlaying { player.play() }
    }
}

struct MoodWaveformView: View {
    let emotion: EmotionLabel
    let energy: CGFloat

    var body: some View {
        let dyn = DYNAMICS[emotion]!

        TimelineView(.animation) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            let phase = CGFloat(t) * dyn.speed
            let pulse = 1 + sin(t * dyn.pulseSpeed) * 0.4
            let amp = 22 * (0.3 + energy * 1.8) * pulse

            Canvas { g, size in
                let mid = size.height / 2

                for color in dyn.lineColors {
                    var path = Path()

                    for x in stride(from: 0, through: size.width, by: 2) {
                        let base = sin((x / 70) * dyn.frequency + phase) * amp

                        let y: CGFloat
                        switch dyn.style {
                        case .smooth:
                            y = mid + base
                        case .dual:
                            y = mid + base + sin((x / 30) + phase) * amp * 0.4
                        case .jagged:
                            y = mid + CGFloat(Int.random(in: -10...10)) + base
                        case .noisy:
                            y = mid + base + CGFloat.random(in: -amp * 0.3...amp * 0.3)
                        case .sharp:
                            y = mid + (base > 0 ? amp : -amp)
                        }

                        if x == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }

                    g.stroke(path, with: .color(color.opacity(0.9)), lineWidth: dyn.lineWidth)
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var engine = MelodyEngine()
    @State private var emotion: EmotionLabel = .calm
    @State private var prev: EmotionLabel = .calm
    @State private var fade: Double = 0

    var body: some View {
        ZStack {
            DYNAMICS[prev]!.bgGlow.opacity(fade).ignoresSafeArea()
            DYNAMICS[emotion]!.bgGlow.opacity(1 - fade).ignoresSafeArea()

            MoodWaveformView(emotion: emotion, energy: engine.level)
                .opacity(1 - fade)

            MoodWaveformView(emotion: prev, energy: engine.level)
                .opacity(fade)

            VStack {
                HStack {
                    Picker("Mood", selection: Binding(
                        get: { emotion },
                        set: { newValue in
                            prev = emotion
                            emotion = newValue
                            fade = 1
                            withAnimation(.easeInOut(duration: 1.0)) { fade = 0 }
                            engine.emotion = newValue
                        })
                    ) {
                        ForEach(EmotionLabel.allCases) { m in
                            Text(m.title).tag(m)
                        }
                    }

                    Spacer()

                    Button(engine.isPlaying ? "Stop" : "Play") {
                        engine.isPlaying ? engine.stop() : engine.play()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Spacer()
            }
            .padding()
        }
    }
}

