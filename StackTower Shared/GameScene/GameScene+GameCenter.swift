//
//  GameScene+GameCenter.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 09.06.26.
//

import GameKit

extension GameScene {
    func submitScoreToGameCenter() {
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
}
