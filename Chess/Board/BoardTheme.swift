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
    case grayscale = "Grayscale"
    case blackWhite = "Black & White"
    
    var squareColor: (odd: String, even: String) {
        switch self {
        case .original:
            return ("original_white", "original_black")
        case .chesscom:
            return ("chess.com_white", "chess.com_black")
        case .grayscale:
            return ("grayscale_white", "grayscale_black")
        case .blackWhite:
            return ("blackWhite_white", "blackWhite_black")
        }
    }
}

enum HighlightTheme {
    case original
    case chesscom
    case grayscale
    case blackWhite
    
    var highlightColor: UIColor {
        switch self {
        case .original:
            return UIColor(red: 128/255, green: 165/255, blue: 196/255, alpha: 1.0)
        case .chesscom:
            return UIColor(red: 220/255, green: 195/255, blue: 81/255, alpha: 1.0)
        case .grayscale:
            return UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1.0)
        case .blackWhite:
            return UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0)
        }
    }
}
