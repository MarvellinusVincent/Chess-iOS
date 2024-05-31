//
//  BoardTheme.swift
//  Chess
//
//  Created by Marvellinus Vincent on 5/23/24.
//

import Foundation
import UIKit

enum BoardTheme: String, CaseIterable {
    case original = "Original"
    case chesscom = "Chess.com"
    case glass = "Glass"
    case light = "Light"
    
    var squareColor: (odd: String, even: String) {
        switch self {
        case .original:
            return ("original_white", "original_black")
        case .chesscom:
            return ("chess.com_white", "chess.com_black")
        case .glass:
            return ("glass_white", "glass_black")
        case .light:
            return ("light_white", "light_black")
        }
    }
}

enum HighlightTheme {
    case original
    case chesscom
    case glass
    case light
    
    var highlightColor: (even: UIColor, odd: UIColor) {
        switch self {
        case .original:
            return (UIColor(red: 246/255.0, green: 234/255.0, blue: 122/255.0, alpha: 1.0), UIColor(red: 220/255.0, green: 195/255.0, blue: 81/255.0, alpha: 1.0))
        case .chesscom:
            return (UIColor(red: 245/255.0, green: 246/255.0, blue: 140/255.0, alpha: 1.0), UIColor(red: 186/255.0, green: 201/255.0, blue: 73/255.0, alpha: 1.0))
        case .glass:
            return (UIColor(red: 97/255.0, green: 129/255.0, blue: 155/255.0, alpha: 1.0), UIColor(red: 67/255.0, green: 97/255.0, blue: 119/255.0, alpha: 1.0))
        case .light:
            return (UIColor(red: 175/255.0, green: 229/255.0, blue: 244/255.0, alpha: 1.0), UIColor(red: 152/255.0, green: 217/255.0, blue: 237/255.0, alpha: 1.0))
        }
    }
}

enum labelTheme {
    case original
    case chesscom
    case glass
    case light
    
    var labelColor: (even: UIColor, odd: UIColor) {
        switch self {
        case .original:
            return (UIColor(red: 183/255.0, green: 135/255.0, blue: 96/255.0, alpha: 1.0), UIColor(red: 237/255.0, green: 214/255.0, blue: 176/255.0, alpha: 1.0))
        case .chesscom:
            return (UIColor(red: 119/255.0, green: 149/255.0, blue: 86/255.0, alpha: 1.0), UIColor(red: 235/255.0, green: 236/255.0, blue: 208/255.0, alpha: 1.0))
        case .glass:
            return (UIColor(red: 44/255.0, green: 50/255.0, blue: 64/255.0, alpha: 1.0), UIColor(red: 100/255.0, green: 109/255.0, blue: 125/255.0, alpha: 1.0))
        case .light:
            return (UIColor(red: 196/255.0, green: 216/255.0, blue: 227/255.0, alpha: 1.0), UIColor(red: 240/255.0, green: 241/255.0, blue: 240/255.0, alpha: 1.0))
        }
    }
}
