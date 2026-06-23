//
//  GameScene+GameFlow.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 09.06.26.
//

import SpriteKit

extension GameScene {
    func resetWorldPosition() {
        worldNode.removeAllActions()
        worldNode.position = .zero
    }

    func startGame() {
        gameState = .playing
        resetWorldPosition()
        worldNode.removeAllChildren()
        stackBlocks.removeAll()
        movingBlock = nil
        cameraOffset = 0
        score = 0
        didImproveHighScoreThisRound = false
        nextGoldenScore = Int.random(in: 14...22)
        messageLabel.text = ""
        subtitleLabel.text = ""
        settingsButton.isHidden = true
        impactFeedback.prepare()

        createBaseBlock()
        spawnMovingBlock(width: initialBlockWidth, y: stackStartY + blockHeight)
        updateHUD()
    }

    func failCurrentBlock() {
        gameState = .gameOver
        missFeedback.notificationOccurred(.error)
        movingBlock?.run(.sequence([
            .group([.rotate(byAngle: .pi * 0.24, duration: 0.18), .moveBy(x: 0, y: -180, duration: 0.36), .fadeOut(withDuration: 0.36)]),
            .removeFromParent()
        ]))
        movingBlock = nil
        submitScoreToGameCenter()
        requestAppReviewIfNeeded()

        messageLabel.text = "Game Over"
        subtitleLabel.text = "Score \(score) - tap to restart"
        settingsButton.isHidden = false
    }
}
