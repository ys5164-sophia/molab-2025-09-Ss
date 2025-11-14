//
//  ContentView.swift
//  drawings
//
//  Created by 孙语鸿 on 11/14/25.
//

import SwiftUI
import AVFoundation
import Vision
import Combine
import UIKit

final class DrawingStore: ObservableObject {
    struct Stroke: Identifiable { let id = UUID(); var points:[CGPoint]; var color: Color; var width: CGFloat }
    @Published var strokes:[Stroke] = []
    @Published var currentColor: Color = .blue
    @Published var lineWidth: CGFloat = 8
    private var isDrawing = false
    func addPoint(_ p: CGPoint) {
        if !isDrawing { strokes.append(.init(points:[p], color: currentColor, width: lineWidth)); isDrawing = true }
        else { strokes[strokes.count-1].points.append(p) }
    }
    func endStroke() { isDrawing = false }
    func clear() { strokes.removeAll() }
}

final class HandTracker: NSObject, ObservableObject {
    @Published var normalizedIndexPoint: CGPoint? = nil
    @Published var lastConfidence: Float = 0
    @Published var frameCount: Int = 0
    private let request = VNDetectHumanHandPoseRequest()
    var orientation: CGImagePropertyOrientation = .leftMirrored

    override init() {
        super.init()
        request.maximumHandCount = 1
    }

    func process(pixelBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation)
        do {
            try handler.perform([request])
            DispatchQueue.main.async { self.frameCount += 1 }
            guard let obs = request.results?.first else {
                DispatchQueue.main.async { self.lastConfidence = 0; self.normalizedIndexPoint = nil }
                return
            }
            let pts = try obs.recognizedPoints(.all)
            if let tip = pts[.indexTip] {
                DispatchQueue.main.async { self.lastConfidence = tip.confidence }
                if tip.confidence > 0.12 {
                    var p = tip.location
                    p.y = 1 - p.y
                    p.x = 1 - p.x
                    DispatchQueue.main.async { self.normalizedIndexPoint = CGPoint(x: p.x, y: p.y) }
                    return
                }
            }
            DispatchQueue.main.async { self.normalizedIndexPoint = nil }
        } catch {
            DispatchQueue.main.async { self.lastConfidence = 0; self.normalizedIndexPoint = nil }
        }
    }
}

struct CameraView: UIViewRepresentable {
    final class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let tracker: HandTracker
        init(tracker: HandTracker) { self.tracker = tracker }
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            tracker.process(pixelBuffer: pb)
        }
    }

    @ObservedObject var tracker: HandTracker
    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "video.queue")

    func makeCoordinator() -> Coordinator { Coordinator(tracker: tracker) }

    func makeUIView(context: Context) -> Preview {
        let v = Preview()
        v.videoPreviewLayer.session = session
        v.videoPreviewLayer.videoGravity = .resizeAspectFill

        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else { return }
            queue.async {
                session.beginConfiguration()
                session.sessionPreset = .high

                let device: AVCaptureDevice? = {
                    #if targetEnvironment(simulator)
                    return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                    #else
                    return AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front)
                        ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
                        ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                    #endif
                }()

                guard let device,
                      let input = try? AVCaptureDeviceInput(device: device),
                      session.canAddInput(input) else { return }
                session.addInput(input)

                let output = AVCaptureVideoDataOutput()
                output.alwaysDiscardsLateVideoFrames = true
                output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                output.setSampleBufferDelegate(context.coordinator, queue: queue) // 用 coordinator
                guard session.canAddOutput(output) else { return }
                session.addOutput(output)

                if let c = output.connection(with: .video) {
                    c.videoOrientation = .portrait
                    #if targetEnvironment(simulator)
                    c.isVideoMirrored = false
                    tracker.orientation = .right
                    #else
                    if device.position == .front {
                        c.isVideoMirrored = true
                        tracker.orientation = .leftMirrored
                    } else {
                        c.isVideoMirrored = false
                        tracker.orientation = .right
                    }
                    #endif
                }

                session.commitConfiguration()
                session.startRunning()
            }
        }
        return v
    }

    func updateUIView(_ uiView: Preview, context: Context) {}

    final class Preview: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

struct ContentView: View {
    @StateObject private var tracker = HandTracker()
    @StateObject private var store = DrawingStore()
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        ZStack {
            GeometryReader { geo in
                CameraView(tracker: tracker)
                    .onAppear { canvasSize = geo.size }
                    .onChange(of: geo.size) { _, nv in canvasSize = nv }
                    .ignoresSafeArea()
            }

            Canvas { ctx, _ in
                for s in store.strokes {
                    var path = Path()
                    guard let first = s.points.first else { continue }
                    path.move(to: first)
                    for p in s.points.dropFirst() { path.addLine(to: p) }
                    let style = StrokeStyle(lineWidth: s.width, lineCap: .round, lineJoin: .round)
                    ctx.stroke(path, with: .color(s.color), style: style)
                }
            }
            .allowsHitTesting(false)

            if let p = tracker.normalizedIndexPoint {
                Circle().fill(.yellow).frame(width: 14, height: 14)
                    .position(x: p.x * canvasSize.width, y: p.y * canvasSize.height)
            }

            VStack {
                HStack(spacing: 12) {
                    ColorPicker("", selection: $store.currentColor).labelsHidden()
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    Slider(value: Binding(get: { Double(store.lineWidth) },
                                          set: { store.lineWidth = CGFloat($0) }), in: 2...18)
                        .frame(width: 150)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    Button { store.clear() } label: {
                        Image(systemName: "eraser.fill").padding(10)
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    Spacer()
                }
                .padding()

                HStack(spacing: 8) {
                    Text("frames: \(tracker.frameCount)")
                    Text(String(format: "conf: %.2f", tracker.lastConfidence))
                    Text(tracker.normalizedIndexPoint == nil ? "hand: ✗" : "hand: ✓")
                }
                .font(.footnote)
                .padding(8)
                .background(.black.opacity(0.4), in: Capsule())
                .foregroundColor(.white)

                Spacer()
            }
            .padding(.top, 8)
        }
        .background(.black)
        .onReceive(tracker.$normalizedIndexPoint) { np in
            guard canvasSize != .zero else { return }
            if let p = np {
                let pt = CGPoint(x: p.x * canvasSize.width, y: p.y * canvasSize.height)
                store.addPoint(pt)
            } else {
                store.endStroke()
            }
        }
    }
}

