//
//  Difficulty.swift
//  StackTower Shared
//
//  Created by Elmar Ibrahimli on 01.06.26.
//

import CoreGraphics

enum Difficulty: String {
    case easy, medium, hard, extreme

    var blockSpeed: CGFloat {
        switch self {
        case .easy: return 3.1
        case .medium: return 4.4
        case .hard: return 5.8
        case .extreme: return 7.2
        }
    }

    var gameTime: Int {
        0
    }

    var speedText: String {
        switch self {
        case .easy: return "Slow"
        case .medium: return "Normal"
        case .hard: return "Fast"
        case .extreme: return "Wild"
        }
    }

    var title: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .extreme: return "Extreme"
        }
    }
}
