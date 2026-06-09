//
//  GameScene.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 01.06.26.
//

import SpriteKit
import UIKit
import GameKit
import StoreKit

final class GameScene: SKScene {

    private let worldNode = SKNode()
    private let hudNode = SKNode()
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let messageLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private let difficultyBadge = SKShapeNode(rectOf: CGSize(width: 92, height: 30), cornerRadius: 15)
    private let difficultyLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let settingsButton = SKNode()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let missFeedback = UINotificationFeedbackGenerator()

    private var stackBlocks: [SKShapeNode] = []
    private var movingBlock: SKShapeNode?
    private var movingDirection: CGFloat = 1
    private var score = 0
    private var highScore = 0
    private var cameraOffset: CGFloat = 0
    private var gameState: GameState = .idle
    private var difficulty = Difficulty.medium
    private var isSoundEnabled = true
    private var settingsSheet: SettingsSheet?
    private var onboardingSheet: OnboardingSheet?
    private var onboardingTouchStart: CGPoint?
    private var didAskForReview = false
    private var nextGoldenScore = 0

    private let blockHeight: CGFloat = 28
    private let initialBlockWidth: CGFloat = 220
    private let goldenRepairAmount: CGFloat = 34
    private let stackStartY: CGFloat = 132
    private let highScoreKey = "stackTowerHighScore"
    private let difficultyKey = "stackTowerDifficulty"
    private let soundKey = "stackTowerSoundEnabled"

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 1)
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
        difficulty = Difficulty(rawValue: UserDefaults.standard.string(forKey: difficultyKey) ?? "") ?? .medium
        isSoundEnabled = UserDefaults.standard.object(forKey: soundKey) as? Bool ?? true

        setupScene()
        showStartScreen()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layoutHUD()
    }

    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing, let block = movingBlock else { return }

        block.position.x += difficulty.blockSpeed * movingDirection
        let leftLimit = block.frame.width / 2 + 18
        let rightLimit = size.width - block.frame.width / 2 - 18

        if block.position.x > rightLimit {
            block.position.x = rightLimit
            movingDirection = -1
        } else if block.position.x < leftLimit {
            block.position.x = leftLimit
            movingDirection = 1
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if onboardingSheet != nil {
            onboardingTouchStart = location
            return
        }

        if settingsSheet != nil {
            settingsSheet?.handleTouch(at: location)
            return
        }

        if settingsButton.contains(location) {
            showSettings()
            return
        }

        switch gameState {
        case .idle, .gameOver:
            startGame()
        case .playing:
            dropCurrentBlock()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let onboardingSheet else { return }
        let end = touch.location(in: self)
        onboardingSheet.handleTouch(from: onboardingTouchStart ?? end, to: end)
        onboardingTouchStart = nil
    }

    private func setupScene() {
        removeAllChildren()
        worldNode.removeAllChildren()
        hudNode.removeAllChildren()

        addChild(worldNode)
        addChild(hudNode)
        buildBackground()
        buildHUD()
    }

    private func buildBackground() {
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

    private func buildHUD() {
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

    private func layoutHUD() {
        let topY = size.height - 72

        scoreLabel.position = CGPoint(x: 24, y: topY)
        highScoreLabel.position = CGPoint(x: 26, y: topY - 34)
        difficultyBadge.position = CGPoint(x: size.width - 124, y: topY)
        settingsButton.position = CGPoint(x: size.width - 34, y: topY)
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.66)
        subtitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.66 - 42)
    }

    private func showStartScreen() {
        gameState = .idle
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

    private func startGame() {
        gameState = .playing
        worldNode.removeAllChildren()
        stackBlocks.removeAll()
        movingBlock = nil
        cameraOffset = 0
        score = 0
        nextGoldenScore = Int.random(in: 14...22)
        messageLabel.text = ""
        subtitleLabel.text = ""
        settingsButton.isHidden = true
        impactFeedback.prepare()

        createBaseBlock()
        spawnMovingBlock(width: initialBlockWidth, y: stackStartY + blockHeight)
        updateHUD()
    }

    private func createBaseBlock() {
        let base = makeBlock(size: CGSize(width: initialBlockWidth, height: blockHeight), score: 0)
        base.position = CGPoint(x: size.width / 2, y: stackStartY)
        worldNode.addChild(base)
        stackBlocks.append(base)
    }

    private func spawnMovingBlock(width: CGFloat, y: CGFloat) {
        let isGolden = score + 1 == nextGoldenScore
        let block = makeBlock(size: CGSize(width: width, height: blockHeight), score: score + 1, isGolden: isGolden)
        block.name = isGolden ? "goldenBlock" : nil
        movingDirection = Bool.random() ? 1 : -1
        let startX = movingDirection > 0 ? width / 2 + 18 : size.width - width / 2 - 18
        block.position = CGPoint(x: startX, y: y)
        worldNode.addChild(block)
        movingBlock = block
    }

    private func dropCurrentBlock() {
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
            UserDefaults.standard.set(highScore, forKey: highScoreKey)
        }

        let nextY = stackStartY + CGFloat(stackBlocks.count) * blockHeight
        adjustCameraIfNeeded(for: nextY)
        spawnMovingBlock(width: repairedWidth, y: nextY)
    }

    private func failCurrentBlock() {
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

    private func addFallingPiece(width: CGFloat, side: CGFloat, stackCenterX: CGFloat, y: CGFloat, overlap: CGFloat) {
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

    private func adjustCameraIfNeeded(for nextY: CGFloat) {
        let target = max(0, nextY - size.height * 0.46)
        guard target > cameraOffset else { return }
        cameraOffset = target
        worldNode.run(.moveTo(y: -cameraOffset, duration: 0.18))
    }

    private func makeBlock(size: CGSize, score: Int, isGolden: Bool = false) -> SKShapeNode {
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

    private func showRepairFeedback(at position: CGPoint, restoredWidth: CGFloat) {
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

    private func color(for score: Int) -> SKColor {
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

    private func updateHUD() {
        scoreLabel.text = "\(score)"
        highScoreLabel.text = "BEST \(highScore)"
        difficultyLabel.text = difficulty.title.uppercased()
        difficultyLabel.fontColor = difficultyColor()
        difficultyBadge.fillColor = difficultyColor().withAlphaComponent(0.14)
        difficultyBadge.strokeColor = difficultyColor().withAlphaComponent(0.65)
    }

    private func difficultyColor() -> SKColor {
        switch difficulty {
        case .easy: .systemGreen
        case .medium: .systemOrange
        case .hard: .systemRed
        case .extreme: .systemPurple
        }
    }

    private func showSettings() {
        guard settingsSheet == nil, gameState != .playing else { return }
        let sheet = SettingsSheet(sceneSize: size, current: difficulty, isSoundEnabled: isSoundEnabled)
        sheet.delegate = self
        settingsSheet = sheet
        addChild(sheet)
    }

    private func showOnboarding() {
        guard onboardingSheet == nil else { return }
        let sheet = OnboardingSheet(sceneSize: size)
        sheet.delegate = self
        onboardingSheet = sheet
        addChild(sheet)
    }

    private func submitScoreToGameCenter() {
        guard GKLocalPlayer.local.isAuthenticated, score > 0 else { return }
        Task {
            try? await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: ["com.elmar.stacktower.highscore"]
            )
        }
    }

    private func requestAppReviewIfNeeded() {
        guard !didAskForReview, score >= 10 else { return }
        didAskForReview = true
        guard let view = view, let scene = view.window?.windowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}

extension GameScene: SettingsSheetDelegate {
    func settingsSheet(_ sheet: SettingsSheet, didSelect difficulty: Difficulty) {
        self.difficulty = difficulty
        UserDefaults.standard.set(difficulty.rawValue, forKey: difficultyKey)
        updateHUD()
    }

    func settingsSheet(_ sheet: SettingsSheet, didSetSoundEnabled isEnabled: Bool) {
        isSoundEnabled = isEnabled
        UserDefaults.standard.set(isEnabled, forKey: soundKey)
    }

    func settingsSheetDidRequestHowToPlay(_ sheet: SettingsSheet) {
        showOnboarding()
    }

    func settingsSheetDidDismiss(_ sheet: SettingsSheet) {
        settingsSheet = nil
    }
}

extension GameScene: OnboardingSheetDelegate {
    func onboardingSheetDidFinish(_ sheet: OnboardingSheet) {
        onboardingSheet = nil
    }
}
