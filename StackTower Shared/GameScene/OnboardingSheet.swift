//
//  OnboardingSheet.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 09.06.26.
//

import SpriteKit

protocol OnboardingSheetDelegate: AnyObject {
    func onboardingSheetDidFinish(_ sheet: OnboardingSheet)
}

final class OnboardingSheet: SKNode {

    weak var delegate: OnboardingSheetDelegate?

    private let sceneSize: CGSize
    private let backdrop = SKShapeNode()
    private let panel = SKShapeNode()
    private let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let messageLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private let actionLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let skipLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let pageLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let previewNode = SKNode()
    private let dotsNode = SKNode()
    private let buttonNode = SKNode()
    private let buttonBackground = SKShapeNode()
    private var pageIndex = 0

    private let pages: [(title: String, message: String, action: String)] = [
        ("Time Your Tap", "Tap when the moving block lines up with the tower.", "Next"),
        ("Stay Centered", "Anything hanging over the edge gets cut away.", "Next"),
        ("Catch Gold", "Golden Repair Blocks restore width and keep your run alive.", "Done")
    ]

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        super.init()
        zPosition = 120
        buildUI()
        renderPage(animated: false)
    }

    required init?(coder: NSCoder) { fatalError() }

    func handleTouch(from start: CGPoint, to end: CGPoint) {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y

        if abs(deltaX) > 54, abs(deltaX) > abs(deltaY) * 1.35 {
            deltaX < 0 ? advance() : goBack()
            return
        }

        handleTap(at: end)
    }

    private func handleTap(at location: CGPoint) {
        let buttonPoint = buttonNode.convert(location, from: parent ?? self)
        if CGRect(x: -92, y: -26, width: 184, height: 52).contains(buttonPoint) {
            advance()
            return
        }

        let panelPoint = panel.convert(location, from: parent ?? self)
        if CGRect(x: 92, y: 206, width: 100, height: 44).contains(panelPoint) {
            dismiss()
        }
    }

    private func buildUI() {
        backdrop.path = CGPath(rect: CGRect(origin: .zero, size: sceneSize), transform: nil)
        backdrop.fillColor = SKColor.black.withAlphaComponent(0.48)
        backdrop.strokeColor = .clear
        backdrop.alpha = 0
        addChild(backdrop)

        let panelWidth = min(sceneSize.width - 32, 420)
        let panelHeight = min(sceneSize.height - 118, 540)
        panel.path = CGPath(
            roundedRect: CGRect(
                x: -panelWidth / 2,
                y: -panelHeight / 2,
                width: panelWidth,
                height: panelHeight
            ),
            cornerWidth: 30,
            cornerHeight: 30,
            transform: nil
        )
        panel.fillColor = SKColor(red: 0.98, green: 0.99, blue: 1.0, alpha: 1)
        panel.strokeColor = SKColor(white: 0.86, alpha: 1)
        panel.lineWidth = 1
        panel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        panel.setScale(0.92)
        panel.alpha = 0
        addChild(panel)

        let topY = panelHeight / 2
        let bottomY = -panelHeight / 2

        skipLabel.text = "Skip"
        skipLabel.fontSize = 15
        skipLabel.fontColor = SKColor(white: 0.45, alpha: 1)
        skipLabel.horizontalAlignmentMode = .right
        skipLabel.verticalAlignmentMode = .center
        skipLabel.position = CGPoint(x: panelWidth / 2 - 28, y: topY - 34)
        panel.addChild(skipLabel)

        pageLabel.fontSize = 12
        pageLabel.fontColor = SKColor(white: 0.48, alpha: 1)
        pageLabel.horizontalAlignmentMode = .left
        pageLabel.verticalAlignmentMode = .center
        pageLabel.position = CGPoint(x: -panelWidth / 2 + 28, y: topY - 34)
        panel.addChild(pageLabel)

        titleLabel.fontSize = 29
        titleLabel.fontColor = SKColor(white: 0.08, alpha: 1)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: topY - 86)
        panel.addChild(titleLabel)

        let previewBg = SKShapeNode(rectOf: CGSize(width: panelWidth - 54, height: 168), cornerRadius: 24)
        previewBg.fillColor = SKColor(red: 0.94, green: 0.97, blue: 1.0, alpha: 1)
        previewBg.strokeColor = SKColor(red: 0.83, green: 0.89, blue: 0.96, alpha: 1)
        previewBg.lineWidth = 1
        previewBg.position = CGPoint(x: 0, y: topY - 194)
        panel.addChild(previewBg)

        previewNode.position = previewBg.position
        panel.addChild(previewNode)

        messageLabel.fontSize = 16
        messageLabel.fontColor = SKColor(white: 0.38, alpha: 1)
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.verticalAlignmentMode = .center
        messageLabel.preferredMaxLayoutWidth = panelWidth - 58
        messageLabel.numberOfLines = 2
        messageLabel.position = CGPoint(x: 0, y: bottomY + 138)
        panel.addChild(messageLabel)

        dotsNode.position = CGPoint(x: 0, y: bottomY + 88)
        panel.addChild(dotsNode)

        buildButton(buttonY: bottomY + 42)

        backdrop.run(.fadeAlpha(to: 1, duration: 0.18))
        panel.run(.group([
            .fadeIn(withDuration: 0.22),
            .scale(to: 1, duration: 0.22)
        ]))
    }

    private func buildButton(buttonY: CGFloat) {
        buttonNode.name = "onboardingButton"
        buttonNode.position = CGPoint(x: 0, y: buttonY)
        panel.addChild(buttonNode)

        buttonBackground.path = CGPath(
            roundedRect: CGRect(x: -92, y: -26, width: 184, height: 52),
            cornerWidth: 26,
            cornerHeight: 26,
            transform: nil
        )
        buttonBackground.fillColor = SKColor(white: 0.1, alpha: 1)
        buttonBackground.strokeColor = .clear
        buttonNode.addChild(buttonBackground)

        actionLabel.fontSize = 17
        actionLabel.fontColor = .white
        actionLabel.horizontalAlignmentMode = .center
        actionLabel.verticalAlignmentMode = .center
        buttonNode.addChild(actionLabel)
    }

    private func renderPage(animated: Bool) {
        let page = pages[pageIndex]
        titleLabel.text = page.title
        messageLabel.text = page.message
        actionLabel.text = page.action
        pageLabel.text = "\(pageIndex + 1) of \(pages.count)"
        skipLabel.isHidden = pageIndex == pages.count - 1
        buttonBackground.fillColor = pageIndex == pages.count - 1 ? SKColor.systemGreen : SKColor(white: 0.1, alpha: 1)

        previewNode.removeAllChildren()
        dotsNode.removeAllChildren()
        buildPreview()
        buildDots()

        if animated {
            panel.run(.sequence([
                .scale(to: 0.98, duration: 0.06),
                .scale(to: 1.0, duration: 0.08)
            ]))
        }
    }

    private func buildPreview() {
        switch pageIndex {
        case 0:
            buildStackPreview(activeOffset: -74, cutSide: nil, golden: false)
            let tap = makePreviewLabel(text: "TAP", size: 24, color: SKColor.systemBlue)
            tap.position = CGPoint(x: 78, y: 38)
            previewNode.addChild(tap)
        case 1:
            buildStackPreview(activeOffset: 54, cutSide: 1, golden: false)
            let cut = makePreviewLabel(text: "CUT", size: 20, color: SKColor.systemRed)
            cut.position = CGPoint(x: 86, y: -34)
            previewNode.addChild(cut)
        default:
            buildStackPreview(activeOffset: 0, cutSide: nil, golden: true)
            let repair = makePreviewLabel(text: "+ REPAIR", size: 22, color: SKColor(red: 1.0, green: 0.68, blue: 0.08, alpha: 1))
            repair.position = CGPoint(x: 0, y: 54)
            previewNode.addChild(repair)
        }
    }

    private func buildStackPreview(activeOffset: CGFloat, cutSide: CGFloat?, golden: Bool) {
        let widths: [CGFloat] = [150, 126, 104]
        let colors = [
            SKColor.systemCyan,
            SKColor.systemBlue,
            SKColor.systemPurple
        ]

        for index in 0..<widths.count {
            let block = makeBlock(width: widths[index], color: colors[index])
            block.position = CGPoint(x: 0, y: -58 + CGFloat(index) * 24)
            previewNode.addChild(block)
        }

        let activeWidth: CGFloat = golden ? 112 : 118
        let activeColor = golden ? SKColor(red: 1.0, green: 0.76, blue: 0.16, alpha: 1) : SKColor.systemPink
        let active = makeBlock(width: activeWidth, color: activeColor)
        active.position = CGPoint(x: activeOffset, y: 18)
        previewNode.addChild(active)

        if let cutSide {
            let piece = makeBlock(width: 42, color: SKColor.systemRed.withAlphaComponent(0.85))
            piece.position = CGPoint(x: activeOffset + cutSide * 80, y: 18)
            piece.zRotation = cutSide * 0.22
            previewNode.addChild(piece)
        }

        active.run(.repeatForever(.sequence([
            .moveBy(x: activeOffset == 0 ? 0 : 28, y: 0, duration: 0.42),
            .moveBy(x: activeOffset == 0 ? 0 : -28, y: 0, duration: 0.42)
        ])))
    }

    private func makeBlock(width: CGFloat, color: SKColor) -> SKShapeNode {
        let block = SKShapeNode(rectOf: CGSize(width: width, height: 22), cornerRadius: 5)
        block.fillColor = color
        block.strokeColor = SKColor.white.withAlphaComponent(0.25)
        block.lineWidth = 1
        return block
    }

    private func makePreviewLabel(text: String, size: CGFloat, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }

    private func buildDots() {
        for index in 0..<pages.count {
            let dot = SKShapeNode(circleOfRadius: index == pageIndex ? 5 : 4)
            dot.fillColor = index == pageIndex ? SKColor(white: 0.12, alpha: 1) : SKColor(white: 0.78, alpha: 1)
            dot.strokeColor = .clear
            dot.position = CGPoint(x: CGFloat(index - 1) * 18, y: 0)
            dotsNode.addChild(dot)
        }
    }

    private func advance() {
        if pageIndex < pages.count - 1 {
            pageIndex += 1
            renderPage(animated: true)
        } else {
            dismiss()
        }
    }

    private func goBack() {
        guard pageIndex > 0 else { return }
        pageIndex -= 1
        renderPage(animated: true)
    }

    private func dismiss() {
        panel.run(.group([
            .fadeOut(withDuration: 0.18),
            .scale(to: 0.94, duration: 0.18)
        ]))
        backdrop.run(.sequence([
            .fadeOut(withDuration: 0.18),
            .run { [weak self] in
                guard let self else { return }
                self.removeFromParent()
                self.delegate?.onboardingSheetDidFinish(self)
            }
        ]))
    }
}
