//
//  PieceColor.swift
//  Chess
//
//  Created by Marvellinus Vincent on 5/23/24.
//

import Foundation

enum PieceColor: String {
    case white
    case black
    var opponentColor: PieceColor {
        self == .black ? .white : .black
    }
}
