//
//  GameScene+Screens.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 09.06.26.
//

import SpriteKit

extension GameScene {
    func showStartScreen() {
        gameState = .idle
        resetWorldPosition()
        worldNode.removeAllChildren()
        stackBlocks.removeAll()
        movingBlock = nil
        cameraOffset = 0
        score = 0

        createBaseBlock()
        messageLabel.text = "Stack Tower"
        subtitleLabel.text = "Tap to stack the moving blocks"
        settingsButton.isHidden = false
        updateHUD()
    }
}
