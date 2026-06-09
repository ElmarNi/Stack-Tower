//
//  GameScene+UI.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 09.06.26.
//

import SpriteKit

extension GameScene {
    func buildHUD() {
        scoreLabel.fontSize = 42
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .center
        hudNode.addChild(scoreLabel)

        highScoreLabel.fontSize = 14
        highScoreLabel.fontColor = SKColor(white: 1, alpha: 0.65)
        highScoreLabel.horizontalAlignmentMode = .left
        hudNode.addChild(highScoreLabel)

        difficultyBadge.fillColor = SKColor(red: 0.98, green: 0.73, blue: 0.22, alpha: 1)
        difficultyBadge.strokeColor = .clear
        hudNode.addChild(difficultyBadge)

        difficultyLabel.fontSize = 12
        difficultyLabel.fontColor = SKColor(red: 0.12, green: 0.10, blue: 0.06, alpha: 1)
        difficultyLabel.verticalAlignmentMode = .center
        difficultyBadge.addChild(difficultyLabel)

        let gearCircle = SKShapeNode(circleOfRadius: 22)
        gearCircle.fillColor = SKColor(white: 0.92, alpha: 1)
        gearCircle.strokeColor = SKColor(white: 0.80, alpha: 1)
        gearCircle.lineWidth = 1
        gearCircle.name = "settings"
        settingsButton.addChild(gearCircle)

        let gearLabel = SKLabelNode(fontNamed: "Arial")
        gearLabel.text = "⚙️"
        gearLabel.fontSize = 20
        gearLabel.verticalAlignmentMode = .center
        gearLabel.horizontalAlignmentMode = .center
        gearLabel.position = .zero
        gearLabel.name = "settings"
        settingsButton.addChild(gearLabel)
        hudNode.addChild(settingsButton)

        messageLabel.fontSize = 34
        messageLabel.fontColor = .white
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.verticalAlignmentMode = .center
        hudNode.addChild(messageLabel)

        subtitleLabel.fontSize = 16
        subtitleLabel.fontColor = SKColor(white: 1, alpha: 0.68)
        subtitleLabel.horizontalAlignmentMode = .center
        subtitleLabel.verticalAlignmentMode = .center
        hudNode.addChild(subtitleLabel)

        layoutHUD()
        updateHUD()
    }

    func layoutHUD() {
        let topY = size.height - 72

        scoreLabel.position = CGPoint(x: 24, y: topY)
        highScoreLabel.position = CGPoint(x: 26, y: topY - 34)
        difficultyBadge.position = CGPoint(x: size.width - 124, y: topY)
        settingsButton.position = CGPoint(x: size.width - 34, y: topY)
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.66)
        subtitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.66 - 42)
    }

    func updateHUD() {
        scoreLabel.text = "\(score)"
        highScoreLabel.text = "BEST \(highScore)"
        difficultyLabel.text = difficulty.title.uppercased()
        difficultyLabel.fontColor = difficultyColor()
        difficultyBadge.fillColor = difficultyColor().withAlphaComponent(0.14)
        difficultyBadge.strokeColor = difficultyColor().withAlphaComponent(0.65)
    }

    func difficultyColor() -> SKColor {
        switch difficulty {
        case .easy: .systemGreen
        case .medium: .systemOrange
        case .hard: .systemRed
        case .extreme: .systemPurple
        }
    }
}
