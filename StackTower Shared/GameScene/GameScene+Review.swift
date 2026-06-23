//
//  GameScene+Review.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 09.06.26.
//

import SpriteKit
import StoreKit

extension GameScene {
    func registerLaunchSession() {
        launchSessionCount = UserDefaults.standard.integer(forKey: launchSessionCountKey) + 1
        UserDefaults.standard.set(launchSessionCount, forKey: launchSessionCountKey)
    }

    func requestAppReviewIfNeeded() {
        let lastReviewRequestHighScore = UserDefaults.standard.integer(forKey: lastReviewRequestHighScoreKey)

        guard !didAskForReview,
              launchSessionCount >= 5,
              didImproveHighScoreThisRound,
              highScore > lastReviewRequestHighScore else { return }

        didAskForReview = true
        guard let view = view, let scene = view.window?.windowScene else { return }
        UserDefaults.standard.set(highScore, forKey: lastReviewRequestHighScoreKey)
        SKStoreReviewController.requestReview(in: scene)
    }
}
