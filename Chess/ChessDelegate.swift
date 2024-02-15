//
//  ChessDelegate.swift
//  Chess
//
//  Created by Marvellinus Vincent on 6/21/23.
//

import Foundation

protocol ChessDelegate {
    func movePiece(fromCol: Int, fromRow: Int, toCol: Int, toRow: Int)
    func pieceAt(col: Int, row:Int) -> ChessPiece?
}
