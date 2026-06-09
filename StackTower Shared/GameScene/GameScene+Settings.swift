//
//  GameScene+Settings.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 09.06.26.
//

import SpriteKit

extension GameScene {
    func showSettings() {
        guard settingsSheet == nil, gameState != .playing else { return }
        let sheet = SettingsSheet(sceneSize: size, current: difficulty, isSoundEnabled: isSoundEnabled)
        sheet.delegate = self
        settingsSheet = sheet
        addChild(sheet)
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
