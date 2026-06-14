//
//  GameScene+Background.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 09.06.26.
//

import SpriteKit

extension GameScene {
    func buildBackground() {
        let top = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        top.fillColor = SKColor(red: 0.13, green: 0.17, blue: 0.28, alpha: 1)
        top.strokeColor = .clear
        top.zPosition = -20
        addChild(top)

        for index in 0..<18 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.2...2.6))
            star.fillColor = .white.withAlphaComponent(CGFloat.random(in: 0.18...0.48))
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 18...(max(18, size.width - 18))),
                y: CGFloat.random(in: size.height * 0.28...size.height - 40)
            )
            star.zPosition = -10
            star.run(.repeatForever(.sequence([
                .fadeAlpha(to: 0.15, duration: 1.1 + Double(index) * 0.03),
                .fadeAlpha(to: 0.48, duration: 1.1 + Double(index) * 0.03)
            ])))
            addChild(star)
        }
    }
}
