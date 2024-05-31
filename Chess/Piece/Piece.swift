//
//  Piece.swift
//  Chess
//
//  Created by Marvellinus Vincent on 5/23/24.
//

import Foundation

enum Piece: String {
    case pawn
    case rook
    case knight
    case bishop
    case queen
    case king

    var value: Int {
        switch self {
            case .king:
                return 0
            case .pawn:
                return 1
            case .knight, .bishop:
                return 3
            case .rook:
                return 5
            case .queen:
                return 9
        }
    }
}
