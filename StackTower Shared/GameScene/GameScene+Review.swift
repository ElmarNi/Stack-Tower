//
//  GameScene+Review.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 09.06.26.
//

import SpriteKit
import StoreKit

extension GameScene {
    func requestAppReviewIfNeeded() {
        guard !didAskForReview, score >= 10 else { return }
        didAskForReview = true
        guard let view = view, let scene = view.window?.windowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}
