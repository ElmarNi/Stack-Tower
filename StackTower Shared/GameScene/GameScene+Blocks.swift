//
//  GameScene+Blocks.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 09.06.26.
//

import SpriteKit

extension GameScene {
    func createBaseBlock() {
        let base = makeBlock(size: CGSize(width: initialBlockWidth, height: blockHeight), score: 0)
        base.position = CGPoint(x: size.width / 2, y: stackStartY)
        worldNode.addChild(base)
        stackBlocks.append(base)
    }

    func spawnMovingBlock(width: CGFloat, y: CGFloat) {
        let isGolden = score + 1 == nextGoldenScore
        let block = makeBlock(size: CGSize(width: width, height: blockHeight), score: score + 1, isGolden: isGolden)
        block.name = isGolden ? "goldenBlock" : nil
        movingDirection = Bool.random() ? 1 : -1
        let startX = movingDirection > 0 ? width / 2 + 18 : size.width - width / 2 - 18
        block.position = CGPoint(x: startX, y: y)
        worldNode.addChild(block)
        movingBlock = block
    }

    func dropCurrentBlock() {
        guard let current = movingBlock, let previous = stackBlocks.last else { return }

        let overlap = min(current.frame.maxX, previous.frame.maxX) - max(current.frame.minX, previous.frame.minX)
        guard overlap > 8 else {
            failCurrentBlock()
            return
        }

        let stackCenterX = previous.position.x
        let trimmedAmount = current.frame.width - overlap
        let trimmedSide: CGFloat = current.position.x > previous.position.x ? 1 : -1

        let wasGolden = current.name == "goldenBlock"
        let repairedWidth = wasGolden ? min(initialBlockWidth, overlap + goldenRepairAmount) : overlap

        current.removeFromParent()
        let locked = makeBlock(size: CGSize(width: repairedWidth, height: blockHeight), score: score + 1, isGolden: wasGolden)
        locked.position = CGPoint(x: stackCenterX, y: current.position.y)
        worldNode.addChild(locked)
        stackBlocks.append(locked)

        if !wasGolden, trimmedAmount > 3 {
            addFallingPiece(width: trimmedAmount, side: trimmedSide, stackCenterX: stackCenterX, y: current.position.y, overlap: overlap)
        } else if wasGolden {
            showRepairFeedback(at: locked.position, restoredWidth: repairedWidth - overlap)
            nextGoldenScore = score + Int.random(in: 16...24)
        }

        movingBlock = nil
        score += 1
        impactFeedback.impactOccurred(intensity: min(1, 0.45 + CGFloat(score) * 0.025))
        updateHUD()

        if score > highScore {
            highScore = score
            didImproveHighScoreThisRound = true
            UserDefaults.standard.set(highScore, forKey: highScoreKey)
        }

        let nextY = stackStartY + CGFloat(stackBlocks.count) * blockHeight
        adjustCameraIfNeeded(for: nextY)
        spawnMovingBlock(width: repairedWidth, y: nextY)
    }

    func addFallingPiece(width: CGFloat, side: CGFloat, stackCenterX: CGFloat, y: CGFloat, overlap: CGFloat) {
        let piece = makeBlock(size: CGSize(width: width, height: blockHeight), score: score + 1)
        let offset = (overlap + width) / 2 * side
        piece.position = CGPoint(x: stackCenterX + offset, y: y)
        worldNode.addChild(piece)
        piece.run(.sequence([
            .group([
                .moveBy(x: side * 48, y: -220, duration: 0.55),
                .rotate(byAngle: side * .pi / 2, duration: 0.55),
                .fadeOut(withDuration: 0.55)
            ]),
            .removeFromParent()
        ]))
    }

    func adjustCameraIfNeeded(for nextY: CGFloat) {
        let target = max(0, nextY - size.height * 0.46)
        guard target > cameraOffset else { return }
        cameraOffset = target
        worldNode.run(.moveTo(y: -cameraOffset, duration: 0.18))
    }

    func makeBlock(size: CGSize, score: Int, isGolden: Bool = false) -> SKShapeNode {
        let block = SKShapeNode(rectOf: size, cornerRadius: 6)
        block.fillColor = isGolden ? SKColor(red: 1.00, green: 0.78, blue: 0.20, alpha: 1) : color(for: score)
        block.strokeColor = isGolden ? SKColor(red: 1.00, green: 0.95, blue: 0.56, alpha: 1) : SKColor(white: 1, alpha: 0.18)
        block.lineWidth = isGolden ? 2 : 1
        block.zPosition = 2

        let shine = SKShapeNode(rectOf: CGSize(width: size.width - 10, height: 5), cornerRadius: 2.5)
        shine.fillColor = SKColor(white: 1, alpha: isGolden ? 0.38 : 0.16)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: 0, y: size.height * 0.25)
        block.addChild(shine)

        if isGolden {
            let pulse = SKAction.sequence([
                .scale(to: 1.04, duration: 0.35),
                .scale(to: 1.0, duration: 0.35)
            ])
            block.run(.repeatForever(pulse), withKey: "goldenPulse")
        }

        return block
    }

    func showRepairFeedback(at position: CGPoint, restoredWidth: CGFloat) {
        guard restoredWidth > 1 else { return }

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "+ REPAIR"
        label.fontSize = 18
        label.fontColor = SKColor(red: 1.00, green: 0.86, blue: 0.24, alpha: 1)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: position.x, y: position.y + 40)
        label.zPosition = 20
        worldNode.addChild(label)

        label.run(.sequence([
            .group([
                .moveBy(x: 0, y: 34, duration: 0.7),
                .fadeOut(withDuration: 0.7)
            ]),
            .removeFromParent()
        ]))
    }

    func color(for score: Int) -> SKColor {
        let colors: [SKColor] = [
            SKColor(red: 0.28, green: 0.78, blue: 0.96, alpha: 1),
            SKColor(red: 0.44, green: 0.63, blue: 1.00, alpha: 1),
            SKColor(red: 0.62, green: 0.49, blue: 0.96, alpha: 1),
            SKColor(red: 0.96, green: 0.42, blue: 0.70, alpha: 1),
            SKColor(red: 0.98, green: 0.62, blue: 0.28, alpha: 1),
            SKColor(red: 0.54, green: 0.86, blue: 0.47, alpha: 1)
        ]
        return colors[score % colors.count]
    }
}
