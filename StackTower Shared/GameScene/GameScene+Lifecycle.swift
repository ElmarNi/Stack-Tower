//
//  GameScene+Lifecycle.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 09.06.26.
//

import SpriteKit

extension GameScene {
    func setupScene() {
        removeAllChildren()
        resetWorldPosition()
        worldNode.removeAllChildren()
        hudNode.removeAllChildren()

        addChild(worldNode)
        addChild(hudNode)
        buildBackground()
        buildHUD()
    }
}
