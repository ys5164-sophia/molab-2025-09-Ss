//
//  gameApp.swift
//  game
//
//  Created by 孙语鸿 on 10/10/25.
//

import UIKit
import SpriteKit
import CoreMotion

class gameViewController: UIViewController {
    private let motionManager = CMMotionManager()
    private var skView: SKView!
    private var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)
        
        scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        startMotion()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        skView.frame = view.bounds
        scene.size = view.bounds.size
    }
    
    private func startMotion() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        
        func currentOrientation() -> UIInterfaceOrientation {
            if let scene = view.window?.windowScene {
                return scene.interfaceOrientation
            }
            return .portrait
        }

        var smoothAx: CGFloat = 0
        var smoothAy: CGFloat = 0
        let alpha: CGFloat = 0.15
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self = self, let m = motion, let scene = self.scene else { return }

            let gx = CGFloat(m.gravity.x)
            let gy = CGFloat(m.gravity.y)

            var ax: CGFloat = 0
            var ay: CGFloat = 0
            
            switch currentOrientation() {
            case .portrait:
                ax = gx
                ay = -gy
            case .portraitUpsideDown:
                ax = -gx
                ay = gy
            case .landscapeLeft:
                ax = -gy
                ay = -gx
            case .landscapeRight:
                ax = gy
                ay = gx
            default:
                ax = gx
                ay = -gy
            }
            let clamp: (CGFloat) -> CGFloat = { max(-1, min(1, $0 * 1.2)) }
            ax = clamp(ax)
            ay = clamp(ay)
            
            smoothAx = smoothAx + alpha * (ax - smoothAx)
            smoothAy = smoothAy + alpha * (ay - smoothAy)
            
            scene.setTilt(ax: smoothAx, ay: smoothAy)
            
            if !scene.isRunning && (abs(smoothAx) > 0.03 || abs(smoothAy) > 0.03) {
                scene.startGame()
            }
        }
    }
}
