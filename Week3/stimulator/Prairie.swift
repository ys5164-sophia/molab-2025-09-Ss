//
//  stimulatorApp.swift
//  stimulator
//
//  Created by 孙语鸿 on 9/26/25.
//

import UIKit //If it creates an error, change the stimulator to iPhone

func makeGrasslandImage(size: CGSize = .init(width: 1024, height: 1024)) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
        
        func drawGradient(colors: [UIColor], rect: CGRect) {
            let cgColors = colors.map { $0.cgColor } as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgColors, locations: nil)!
            cg.drawLinearGradient(gradient, start: CGPoint(x: rect.midX, y: rect.minY), end: CGPoint(x: rect.midX, y: rect.maxY), options: [])
        }
        
        drawGradient(colors: [UIColor.systemBlue, UIColor.cyan], rect: CGRect(x: 0, y: 0, width: 1024, height: 600))
        drawGradient(colors: [UIColor.green, UIColor.systemGreen], rect: CGRect(x: 0, y: 600, width: 1024, height: 424))

        func drawEmoji(_ emoji: String, x: Int, y: Int, fontSize: CGFloat) {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize)
            ]
            NSString(string: emoji).draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
        }
        
        for _ in 0..<15 {
            let x = Int.random(in: 50...950)
            let y = Int.random(in: 50...500)
            let size = CGFloat.random(in: 40...90)
            drawEmoji("☁️", x: x, y: y, fontSize: size)
        }
        
        let groundEmojis = ["🌱", "🌸"]
        for _ in 0..<30 {
            let emoji = groundEmojis.randomElement()!
            let x = Int.random(in: 20...950)
            let y = Int.random(in: 620...1000)
            let size = CGFloat.random(in: 30...70)
            drawEmoji(emoji, x: x, y: y, fontSize: size)
        }
    }
    return image
}
