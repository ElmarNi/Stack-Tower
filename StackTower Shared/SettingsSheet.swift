//
//  SettingsSheet.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 20.05.26.
//

import SpriteKit

// MARK: - Delegate

protocol SettingsSheetDelegate: AnyObject {
    func settingsSheet(_ sheet: SettingsSheet, didSelect difficulty: Difficulty)
    func settingsSheet(_ sheet: SettingsSheet, didSetSoundEnabled isEnabled: Bool)
    func settingsSheetDidRequestHowToPlay(_ sheet: SettingsSheet)
    func settingsSheetDidDismiss(_ sheet: SettingsSheet)
}

// MARK: - SettingsSheet

final class SettingsSheet: SKNode {
    
    // MARK: - Public
    
    weak var delegate: SettingsSheetDelegate?
    
    // MARK: - Private
    
    private let sceneSize: CGSize
    private let sheetHeight: CGFloat = 450
    private var currentDifficulty: Difficulty
    private var isSoundEnabled: Bool
    
    private var backdrop      = SKShapeNode()
    private var panel         = SKShapeNode()
    private var diffButtons: [DifficultyButton] = []
    private let soundToggle = SoundToggleNode(size: CGSize(width: 210, height: 44))
    
    // MARK: - Init
    
    init(sceneSize: CGSize, current difficulty: Difficulty, isSoundEnabled: Bool) {
        self.sceneSize         = sceneSize
        self.currentDifficulty = difficulty
        self.isSoundEnabled    = isSoundEnabled
        super.init()
        zPosition = 100
        buildBackdrop()
        buildPanel()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    // MARK: - Build
    
    private func buildBackdrop() {
        let rect = CGRect(origin: .zero, size: sceneSize)
        backdrop = SKShapeNode(rect: rect)
        backdrop.fillColor   = SKColor.black.withAlphaComponent(0.45)
        backdrop.strokeColor = .clear
        backdrop.name        = "backdrop"
        backdrop.alpha       = 0
        addChild(backdrop)
        backdrop.run(.fadeAlpha(to: 1, duration: 0.22))
    }
    
    private func buildPanel() {
        let panelWidth  = min(sceneSize.width - 32, 420.0)
        let cornerRadius: CGFloat = 24
        
        let panelRect = CGRect(
            x: -panelWidth / 2,
            y: 0,
            width: panelWidth,
            height: sheetHeight
        )
        
        panel = SKShapeNode(rect: panelRect, cornerRadius: cornerRadius)
        panel.fillColor   = SKColor(white: 0.97, alpha: 1)
        panel.strokeColor = SKColor(white: 0.88, alpha: 1)
        panel.lineWidth   = 1
        panel.position    = CGPoint(x: sceneSize.width / 2, y: -sheetHeight) // starts off screen
        panel.name        = "panel"
        addChild(panel)
        
        // Slide up
        panel.run(.move(to: CGPoint(x: sceneSize.width / 2, y: 0), duration: 0.32))
        
        buildPanelContent(panelWidth: panelWidth)
    }
    
    private func buildPanelContent(panelWidth: CGFloat) {
        // Handle bar
        let handle = SKShapeNode(rectOf: CGSize(width: 40, height: 5), cornerRadius: 2.5)
        handle.fillColor   = SKColor(white: 0.75, alpha: 1)
        handle.strokeColor = .clear
        handle.position    = CGPoint(x: 0, y: sheetHeight - 18)
        panel.addChild(handle)
        
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text      = "Stack Settings"
        title.fontSize  = 22
        title.fontColor = SKColor(white: 0.15, alpha: 1)
        title.horizontalAlignmentMode = .center
        title.position  = CGPoint(x: 0, y: sheetHeight - 58)
        panel.addChild(title)
        
        // Difficulty label
        let diffLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        diffLabel.text      = "BLOCK SPEED"
        diffLabel.fontSize  = 11
        diffLabel.fontColor = SKColor(white: 0.55, alpha: 1)
        diffLabel.horizontalAlignmentMode = .center
        diffLabel.position  = CGPoint(x: 0, y: sheetHeight - 100)
        panel.addChild(diffLabel)
        
        // Difficulty buttons
        let difficulties: [Difficulty] = [.easy, .medium, .hard, .extreme]
        let buttonWidth: CGFloat  = (panelWidth - 56) / 4
        let buttonHeight: CGFloat = 70
        let startX = -panelWidth / 2 + 16 + buttonWidth / 2
        
        for (i, diff) in difficulties.enumerated() {
            let btn = DifficultyButton(
                difficulty: diff,
                size: CGSize(width: buttonWidth - 8, height: buttonHeight),
                isSelected: diff == currentDifficulty
            )
            btn.position = CGPoint(
                x: startX + CGFloat(i) * (buttonWidth + 8),
                y: sheetHeight - 175
            )
            btn.name = "diff_\(diff.rawValue)"
            panel.addChild(btn)
            diffButtons.append(btn)
        }
        
        // Info label
        let infoLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        infoLabel.text      = updateInfoText(for: currentDifficulty)
        infoLabel.fontSize  = 13
        infoLabel.fontColor = SKColor(white: 0.45, alpha: 1)
        infoLabel.horizontalAlignmentMode = .center
        infoLabel.position  = CGPoint(x: 0, y: sheetHeight - 230)
        infoLabel.name      = "infoLabel"
        panel.addChild(infoLabel)
        
        // Sound toggle
        soundToggle.position = CGPoint(x: 0, y: sheetHeight - 282)
        soundToggle.setEnabled(isSoundEnabled, animated: false)
        panel.addChild(soundToggle)

        // How to play
        let howToPlayBtn = buildSecondaryButton(title: "How to Play", name: "howToPlayBtn")
        howToPlayBtn.position = CGPoint(x: 0, y: sheetHeight - 340)
        panel.addChild(howToPlayBtn)
        
        // Close button
        let closeBtn = buildCloseButton()
        closeBtn.position = CGPoint(x: 0, y: sheetHeight - 400)
        panel.addChild(closeBtn)
    }

    private func buildSecondaryButton(title: String, name: String) -> SKNode {
        let container = SKNode()
        container.name = name

        let bg = SKShapeNode(rectOf: CGSize(width: 160, height: 42), cornerRadius: 21)
        bg.fillColor = SKColor(white: 0.91, alpha: 1)
        bg.strokeColor = SKColor(white: 0.82, alpha: 1)
        bg.lineWidth = 1
        bg.name = name
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = title
        label.fontSize = 15
        label.fontColor = SKColor(white: 0.22, alpha: 1)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = name
        container.addChild(label)

        return container
    }
    
    private func buildCloseButton() -> SKNode {
        let container = SKNode()
        container.name = "closeBtn"
        
        let bg = SKShapeNode(rectOf: CGSize(width: 160, height: 44), cornerRadius: 22)
        bg.fillColor   = SKColor(white: 0.15, alpha: 1)
        bg.strokeColor = .clear
        bg.name        = "closeBtn"
        container.addChild(bg)
        
        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text                    = "Close"
        label.fontSize                = 16
        label.fontColor               = .white
        label.verticalAlignmentMode   = .center
        label.horizontalAlignmentMode = .center
        label.name                    = "closeBtn"
        container.addChild(label)
        
        return container
    }
    
    // MARK: - Touch
    
    func handleTouch(at locationInScene: CGPoint) {
        let panelPoint = panel.convert(locationInScene, from: parent ?? self)
        
        for btn in diffButtons {
            let btnPoint = btn.convert(panelPoint, from: panel)
            if btn.contains(btnPoint) {
                select(difficulty: btn.difficulty)
                return
            }
        }
        
        let soundPoint = soundToggle.convert(panelPoint, from: panel)
        if soundToggle.contains(soundPoint) {
            toggleSound()
            return
        }

        let howToPlayRect = CGRect(
            x: -80, y: sheetHeight - 340 - 21,
            width: 160, height: 42
        )
        if howToPlayRect.contains(panelPoint) {
            delegate?.settingsSheetDidRequestHowToPlay(self)
            dismiss()
            return
        }
        
        if let closeNodes = panel.children.filter({ $0.name == "closeBtn" }) as [SKNode]?,
           !closeNodes.isEmpty
        {
            let closeBtnPos = CGPoint(x: 0, y: sheetHeight - 400)
            let closeBtnRect = CGRect(
                x: closeBtnPos.x - 80, y: closeBtnPos.y - 22,
                width: 160, height: 44
            )
            if closeBtnRect.contains(panelPoint) {
                dismiss()
                return
            }
        }
        
        let panelWorldRect = CGRect(
            x: panel.position.x - panel.frame.width / 2,
            y: panel.position.y,
            width: panel.frame.width,
            height: sheetHeight
        )
        if !panelWorldRect.contains(locationInScene) {
            dismiss()
        }
    }
    
    // MARK: - Actions
    
    private func select(difficulty: Difficulty) {
        guard difficulty != currentDifficulty else { return }
        currentDifficulty = difficulty
        
        diffButtons.forEach { $0.setSelected($0.difficulty == difficulty) }
        
        if let info = panel.childNode(withName: "infoLabel") as? SKLabelNode {
            info.text = updateInfoText(for: difficulty)
            info.run(.sequence([
                .scale(to: 1.08, duration: 0.08),
                .scale(to: 1.0,  duration: 0.06)
            ]))
        }
        
        delegate?.settingsSheet(self, didSelect: difficulty)
    }
    
    private func toggleSound() {
        isSoundEnabled.toggle()
        soundToggle.setEnabled(isSoundEnabled, animated: true)
        delegate?.settingsSheet(self, didSetSoundEnabled: isSoundEnabled)
    }
    
    func dismiss() {
        let slideDown = SKAction.move(
            to: CGPoint(x: sceneSize.width / 2, y: -sheetHeight),
            duration: 0.28
        )
        let fadeOut   = SKAction.fadeAlpha(to: 0, duration: 0.22)
        
        panel.run(slideDown)
        backdrop.run(.sequence([fadeOut, .run { [weak self] in
            guard let self else { return }
            self.removeFromParent()
            self.delegate?.settingsSheetDidDismiss(self)
        }]))
    }
    
    // MARK: - Helpers
    
    private func updateInfoText(for difficulty: Difficulty) -> String {
        "Block movement: \(difficulty.speedText)"
    }
}

// MARK: - DifficultyButton

private final class DifficultyButton: SKNode {
    
    let difficulty: Difficulty
    private let bg    = SKShapeNode()
    private let emoji = SKLabelNode(fontNamed: "Arial")
    private let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let sub   = SKLabelNode(fontNamed: "AvenirNext-Regular")
    private let size_: CGSize
    
    init(difficulty: Difficulty, size: CGSize, isSelected: Bool) {
        self.difficulty = difficulty
        self.size_      = size
        super.init()
        buildUI(isSelected: isSelected)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func buildUI(isSelected: Bool) {
        let rect = CGRect(
            x: -size_.width / 2, y: -size_.height / 2,
            width: size_.width, height: size_.height
        )
        let node = SKShapeNode(rect: rect, cornerRadius: 14)
        node.lineWidth = 2
        bg.addChild(node)    // we reuse bg directly
        addChild(bg)
        
        emoji.fontSize                = 22
        emoji.verticalAlignmentMode   = .center
        emoji.horizontalAlignmentMode = .center
        emoji.position                = CGPoint(x: 0, y: 14)
        addChild(emoji)
        
        label.fontSize                = 13
        label.verticalAlignmentMode   = .center
        label.horizontalAlignmentMode = .center
        label.position                = CGPoint(x: 0, y: -8)
        addChild(label)
        
        sub.fontSize                = 10
        sub.verticalAlignmentMode   = .center
        sub.horizontalAlignmentMode = .center
        sub.position                = CGPoint(x: 0, y: -24)
        addChild(sub)
        
        switch difficulty {
        case .easy:
            emoji.text = "🐢"
            label.text = "Easy"
            sub.text   = difficulty.speedText
        case .medium:
            emoji.text = "🦊"
            label.text = "Medium"
            sub.text   = difficulty.speedText
        case .hard:
            emoji.text = "🔥"
            label.text = "Hard"
            sub.text   = difficulty.speedText
        case .extreme:
            emoji.text = "⚡️"
            label.text = "Extreme"
            sub.text = difficulty.speedText
        }
        
        applyStyle(isSelected: isSelected, animated: false)
    }
    
    func setSelected(_ selected: Bool) {
        applyStyle(isSelected: selected, animated: true)
    }
    
    override func contains(_ point: CGPoint) -> Bool {
        let half = CGPoint(x: size_.width / 2, y: size_.height / 2)
        return abs(point.x) <= half.x && abs(point.y) <= half.y
    }
    
    private func applyStyle(isSelected: Bool, animated: Bool) {
        let bgColor: SKColor
        let strokeColor: SKColor
        let textColor: SKColor
        
        if isSelected {
            switch difficulty {
            case .easy:
                bgColor = SKColor.systemGreen.withAlphaComponent(0.15)
                strokeColor = .systemGreen
            case .medium:
                bgColor = SKColor.systemOrange.withAlphaComponent(0.15)
                strokeColor = .systemOrange
            case .hard:   bgColor = SKColor.systemRed.withAlphaComponent(0.15)
                strokeColor = .systemRed
            case .extreme:
                bgColor = SKColor.systemPurple.withAlphaComponent(0.15)
                strokeColor = .systemPurple
            }
            textColor = SKColor(white: 0.1, alpha: 1)
        } else {
            bgColor     = SKColor(white: 0.93, alpha: 1)
            strokeColor = .clear
            textColor   = SKColor(white: 0.5, alpha: 1)
        }
        
        if let shape = bg.children.first as? SKShapeNode {
            shape.fillColor   = bgColor
            shape.strokeColor = strokeColor
        }
        label.fontColor = textColor
        sub.fontColor   = textColor.withAlphaComponent(0.7)
        
        if animated {
            run(.sequence([
                .scale(to: 0.93, duration: 0.07),
                .scale(to: 1.0,  duration: 0.1)
            ]))
        }
    }
}

// MARK: - SoundToggleNode

private final class SoundToggleNode: SKNode {
    
    private let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let switchTrack = SKShapeNode()
    private let knob = SKShapeNode(circleOfRadius: 15)
    private let size_: CGSize
    
    init(size: CGSize) {
        self.size_ = size
        super.init()
        buildUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func contains(_ point: CGPoint) -> Bool {
        let half = CGPoint(x: size_.width / 2, y: size_.height / 2)
        return abs(point.x) <= half.x && abs(point.y) <= half.y
    }
    
    func setEnabled(_ isEnabled: Bool, animated: Bool) {
        switchTrack.fillColor = isEnabled
            ? SKColor.systemGreen.withAlphaComponent(0.9)
            : SKColor(white: 0.82, alpha: 1)
        
        switchTrack.strokeColor = .clear
        knob.fillColor = .white
        knob.strokeColor = SKColor.black.withAlphaComponent(0.08)
        knob.lineWidth = 1
        
        let targetX: CGFloat = isEnabled ? 80 : 48
        
        let move = SKAction.moveTo(x: targetX, duration: animated ? 0.16 : 0)
        let pop = SKAction.sequence([
            .scale(to: 1.08, duration: 0.08),
            .scale(to: 1.0, duration: 0.08)
        ])
        
        knob.run(.group([move, pop]))
    }
    
    private func buildUI() {
        label.text = "Sound"
        label.fontSize = 17
        label.fontColor = SKColor(white: 0.13, alpha: 1)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .left
        label.position = CGPoint(x: -size_.width / 2 + 8, y: 0)
        addChild(label)
        
        switchTrack.path = CGPath(
            roundedRect: CGRect(
                x: 32,
                y: -17,
                width: 64,
                height: 34
            ),
            cornerWidth: 17,
            cornerHeight: 17,
            transform: nil
        )
        switchTrack.strokeColor = .clear
        addChild(switchTrack)
        
        knob.position = CGPoint(x: 80, y: 0)
        addChild(knob)
    }
}
