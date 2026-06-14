//
//  GameViewController.swift
//  StackTower iOS
//
//  Created by Elmar Ibrahimli on 20.05.26.
//

import UIKit
import SpriteKit
import GameKit

final class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        authenticateGameCenter()

        if let view = self.view as? SKView {
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            view.presentScene(scene)
        }
    }

    private func authenticateGameCenter() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in

            if let vc = viewController {
                self.present(vc, animated: true)
                return
            }

            if GKLocalPlayer.local.isAuthenticated {
                print("Game Center logged in")
            } else {
                print("Game Center not available: \(error?.localizedDescription ?? "")")
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
