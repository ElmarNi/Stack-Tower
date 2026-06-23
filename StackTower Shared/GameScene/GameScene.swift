//
//  GameScene.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 01.06.26.
//

import SpriteKit
import UIKit

final class GameScene: SKScene {

    let worldNode = SKNode()
    let hudNode = SKNode()
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    let highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    let messageLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    let difficultyBadge = SKShapeNode(rectOf: CGSize(width: 92, height: 30), cornerRadius: 15)
    let difficultyLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    let settingsButton = SKNode()
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    let missFeedback = UINotificationFeedbackGenerator()

    var stackBlocks: [SKShapeNode] = []
    var movingBlock: SKShapeNode?
    var movingDirection: CGFloat = 1
    var score = 0
    var highScore = 0
    var cameraOffset: CGFloat = 0
    var gameState: GameState = .idle
    var difficulty = Difficulty.medium
    var isSoundEnabled = true
    var settingsSheet: SettingsSheet?
    var onboardingSheet: OnboardingSheet?
    var onboardingTouchStart: CGPoint?
    var shouldMarkOnboardingSeenOnFinish = false
    var didAskForReview = false
    var didImproveHighScoreThisRound = false
    var launchSessionCount = 0
    var nextGoldenScore = 0

    let blockHeight: CGFloat = 28
    let initialBlockWidth: CGFloat = 220
    let goldenRepairAmount: CGFloat = 34
    let stackStartY: CGFloat = 132
    let highScoreKey = "stackTowerHighScore"
    let difficultyKey = "stackTowerDifficulty"
    let soundKey = "stackTowerSoundEnabled"
    let onboardingSeenKey = "stackTowerHasSeenOnboarding"
    let launchSessionCountKey = "stackTowerLaunchSessionCount"
    let lastReviewRequestHighScoreKey = "stackTowerLastReviewRequestHighScore"

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 1)
        registerLaunchSession()
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
        difficulty = Difficulty(rawValue: UserDefaults.standard.string(forKey: difficultyKey) ?? "") ?? .medium
        isSoundEnabled = UserDefaults.standard.object(forKey: soundKey) as? Bool ?? true

        setupScene()
        showStartScreen()
        showOnboardingIfNeeded()
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
}
