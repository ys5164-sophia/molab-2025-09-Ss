//
//  gameApp.swift
//  game
//
//  Created by 孙语鸿 on 10/10/25.
//

import SpriteKit
import UIKit

fileprivate struct PhysicsCategory {
    static let none: UInt32      = 0
    static let ball: UInt32      = 0x1 << 0
    static let platform: UInt32  = 0x1 << 1
    static let border: UInt32    = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    private var ball: SKShapeNode!
    private var scoreLabel: SKLabelNode!
    private var aliveLabel: SKLabelNode!
    
    private(set) var isRunning = false
    private var alive = true
    private var score: Int = 0 {
        didSet { scoreLabel.text = "Score: \(score)" }
    }
    
    private var inputAx: CGFloat = 0
    private var inputAy: CGFloat = 0
    
    private var platform: SKNode?
    
    private let accelScale: CGFloat = 300.0
    private let maxSpeed: CGFloat = 400.0
    private let ballRadiusFactor: CGFloat = 0.03
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 6/255, green: 18/255, blue: 35/255, alpha: 1.0)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        let inset: CGFloat = 2
        let borderBody = SKPhysicsBody(edgeLoopFrom: frame.insetBy(dx: inset, dy: inset))
        borderBody.categoryBitMask = PhysicsCategory.border
        borderBody.contactTestBitMask = PhysicsCategory.ball
        borderBody.collisionBitMask = PhysicsCategory.ball
        borderBody.restitution = 0
        self.physicsBody = borderBody
        
        setupHUD()
        setupBall()
        ensureSinglePlatform()
        
        isRunning = false
        alive = true
    }
    
    private func setupHUD() {
        scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        scoreLabel.fontSize = 18
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: size.width - 18, y: size.height - 34)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
        score = 0
        
        aliveLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        aliveLabel.fontSize = 14
        aliveLabel.horizontalAlignmentMode = .left
        aliveLabel.position = CGPoint(x: 18, y: size.height - 36)
        aliveLabel.zPosition = 100
        addChild(aliveLabel)
    }
    
    private func setupBall() {
        let r = min(size.width, size.height) * ballRadiusFactor
        ball = SKShapeNode(circleOfRadius: r)
        ball.fillColor = SKColor(red: 1.0, green: 200/255, blue: 120/255, alpha: 1.0)
        ball.strokeColor = .clear
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        ball.zPosition = 10
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: r)
        if let pb = ball.physicsBody {
            pb.allowsRotation = false
            pb.linearDamping = 0.6
            pb.friction = 0
            pb.restitution = 0
            pb.mass = 0.2
            pb.categoryBitMask = PhysicsCategory.ball
            pb.contactTestBitMask = PhysicsCategory.platform | PhysicsCategory.border
            pb.collisionBitMask = PhysicsCategory.platform | PhysicsCategory.border
        }
        addChild(ball)
    }
    
    private func spawnPlatform() {
        platform?.removeFromParent()
        platform = nil
        
        let pad: CGFloat = 22
        let w = CGFloat.random(in: 80...200)
        let h = CGFloat.random(in: 16...44)
        let x = CGFloat.random(in: pad...(size.width - pad - w)) + w/2
        let y = CGFloat.random(in: pad...(size.height - pad - h)) + h/2
        
        let node = SKShapeNode(rectOf: CGSize(width: w, height: h), cornerRadius: 6)
        node.fillColor = SKColor(red: 160/255, green: 220/255, blue: 255/255, alpha: 0.96)
        node.strokeColor = SKColor(white: 1.0, alpha: 0.06)
        node.position = CGPoint(x: x, y: y)
        node.zPosition = 5
        node.name = "platform"
        
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: w, height: h))
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.platform
        node.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        node.physicsBody?.collisionBitMask = PhysicsCategory.ball
        
        addChild(node)
        platform = node
    }
    
    private func ensureSinglePlatform() {
        if platform == nil { spawnPlatform() }
    }
    
    func setTilt(ax: CGFloat, ay: CGFloat) {
        inputAx = max(-1, min(1, ax))
        inputAy = max(-1, min(1, ay))
    }
    
    func startGame() {
        platform?.removeFromParent()
        platform = nil
        ensureSinglePlatform()
        
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        ball.physicsBody?.velocity = .zero
        
        score = 0
        alive = true
        isRunning = true
        children.filter { $0.name == "overlay" }.forEach { $0.removeFromParent() }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isRunning && alive else { return }
        
        if let body = ball.physicsBody {
            let fx = inputAx * accelScale * body.mass
            let fy = inputAy * accelScale * body.mass
            body.applyForce(CGVector(dx: fx, dy: fy))
            
            let v = body.velocity
            let speed = sqrt(v.dx * v.dx + v.dy * v.dy)
            if speed > maxSpeed {
                let scale = maxSpeed / speed
                body.velocity = CGVector(dx: v.dx * scale, dy: v.dy * scale)
            }
        }
        
        let r = (ball.frame.width / 2)
        if ball.position.x - r <= 0 || ball.position.x + r >= size.width ||
            ball.position.y - r <= 0 || ball.position.y + r >= size.height {
            handleDeath()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let aCat = contact.bodyA.categoryBitMask
        let bCat = contact.bodyB.categoryBitMask
        if (aCat == PhysicsCategory.ball && bCat == PhysicsCategory.platform) ||
            (aCat == PhysicsCategory.platform && bCat == PhysicsCategory.ball) {
            
            guard let node = (contact.bodyA.categoryBitMask == PhysicsCategory.platform
                              ? contact.bodyA.node
                              : contact.bodyB.node) else { return }
            
            if node.userData?["hit"] as? Bool != true {
                node.userData = node.userData ?? NSMutableDictionary()
                node.userData?["hit"] = true
                score += 1
                
                DispatchQueue.main.async {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                
                let fade = SKAction.sequence([.fadeOut(withDuration: 0.12), .removeFromParent()])
                node.run(fade) { [weak self] in
                    guard let self = self else { return }
                    if self.platform == node { self.platform = nil }
                    self.spawnPlatform()
                }
            }
        }
        
        if (aCat == PhysicsCategory.ball && bCat == PhysicsCategory.border) ||
            (aCat == PhysicsCategory.border && bCat == PhysicsCategory.ball) {
            handleDeath()
        }
    }
    
    private func handleDeath() {
        guard alive else { return }
        alive = false
        isRunning = false
        
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 0.78, height: 140), cornerRadius: 12)
        overlay.fillColor = SKColor(white: 0.02, alpha: 0.8)
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.zPosition = 500
        overlay.name = "overlay"
        addChild(overlay)
        
        let title = SKLabelNode(text: "game over")
        title.fontName = "HelveticaNeue-Bold"
        title.fontSize = 32
        title.position = CGPoint(x: 0, y: 18)
        overlay.addChild(title)
        
        let s = SKLabelNode(text: "final score: \(score)")
        s.fontName = "HelveticaNeue"
        s.fontSize = 18
        s.position = CGPoint(x: 0, y: -18)
        overlay.addChild(s)
        
        DispatchQueue.main.async {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    
}
