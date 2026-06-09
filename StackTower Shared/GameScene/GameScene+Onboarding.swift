//
//  GameScene+Onboarding.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 09.06.26.
//

import SpriteKit

extension GameScene {
    func showOnboarding(markAsSeen: Bool = false) {
        guard onboardingSheet == nil else { return }
        shouldMarkOnboardingSeenOnFinish = markAsSeen
        let sheet = OnboardingSheet(sceneSize: size)
        sheet.delegate = self
        onboardingSheet = sheet
        addChild(sheet)
    }

    func showOnboardingIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: onboardingSeenKey) else { return }
        showOnboarding(markAsSeen: true)
    }
}

extension GameScene: OnboardingSheetDelegate {
    func onboardingSheetDidFinish(_ sheet: OnboardingSheet) {
        onboardingSheet = nil
        if shouldMarkOnboardingSeenOnFinish {
            UserDefaults.standard.set(true, forKey: onboardingSeenKey)
        }
        shouldMarkOnboardingSeenOnFinish = false
    }
}
