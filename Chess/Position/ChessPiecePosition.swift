//
//  ChessPiecePosition.swift
//  Chess
//
//  Created by Marvellinus Vincent on 5/23/24.
//

import Foundation

struct ChessPiecePosition: Hashable {
    var x, y: Int
    
    static func - (origin: ChessPiecePosition, destination: ChessPiecePosition) -> Offset {
        Offset(x: origin.x - destination.x, y: origin.y - destination.y)
    }

    static func += (origin: inout ChessPiecePosition, by: Offset) {
        origin.x += by.x
        origin.y += by.y
    }
}

struct Move: Equatable {
    var origin, destination: ChessPiecePosition
}
