//
//  Board_View.swift
//  Chess
//
//  Created by Marvellinus Vincent on 3/12/23.
//

import UIKit

class Board_View: UIView {
    
    let ratio: CGFloat = 1.0
    var originX: CGFloat = -10
    var originY: CGFloat = -10
    var CellSide: CGFloat = -10
    var ShadowPiece: Set<ChessPiece> = Set<ChessPiece>()
    var chessDelegate: ChessDelegate? = nil
    var fromCol: Int? = nil
    var fromRow: Int? = nil
    var movingImage: UIImage? = nil
    var movingPieceX: CGFloat = -1
    var movingPieceY: CGFloat = -1

    override func draw(_ rect: CGRect) {
        CellSide = bounds.width * ratio / 8
        originX = bounds.width * (1 - ratio) / 2
        originY = bounds.height * (1 - ratio) / 2
        drawBoard()
        drawPieces()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let first = touches.first!
        let fingerLocation = first.location(in: self)
        fromCol = Int((fingerLocation.x - originX) / CellSide)
        fromRow = Int((fingerLocation.y - originY) / CellSide)
        if let fromCol = fromCol, let fromRow = fromRow, let movingPiece = chessDelegate?.pieceAt(col: fromCol, row: fromRow){
            movingImage = UIImage(named: movingPiece.imageName)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let first = touches.first!
        let fingerLocation = first.location(in: self)
        movingPieceX = fingerLocation.x
        movingPieceY = fingerLocation.y
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let first = touches.first!
        let fingerLocation = first.location(in: self)
        let toCol: Int = Int((fingerLocation.x - originX) / CellSide)
        let toRow: Int = Int((fingerLocation.y - originY) / CellSide)
        if let fromCol = fromCol, let fromRow = fromRow, fromCol != toCol || fromRow != toRow{
            chessDelegate?.movePiece(fromCol: fromCol, fromRow: fromRow, toCol: toCol, toRow: toRow)
        }
        movingImage = nil
        fromCol = nil
        fromRow = nil
        setNeedsDisplay()
    }
    func drawBoard() {
        for row in 0..<4 {
            for col in 0..<4 {
                drawSquare(col: col * 2, row: row * 2, color: UIColor.white)
                drawSquare(col: 1 + col * 2, row: row * 2, color: UIColor.lightGray)
                drawSquare(col: col * 2, row: 1 + row * 2, color: UIColor.lightGray)
                drawSquare(col: 1 + col * 2, row: 1 + row * 2, color: UIColor.white)
            }
        }
    }
    func drawPieces() {
        for piece in ShadowPiece where fromCol != piece.col || fromRow != piece.row {
            let pieceImage = UIImage(named: piece.imageName)
            pieceImage?.draw(in: CGRect(x: originX + CGFloat(piece.col) * CellSide, y: originY + CGFloat(piece.row) * CellSide, width: CellSide, height: CellSide))
        }
        movingImage?.draw(in: CGRect(x: movingPieceX - CellSide / 2, y: movingPieceY - CellSide / 2, width: CellSide, height: CellSide))
    }
    
    func drawSquare(col: Int, row: Int, color: UIColor) {
        let path = UIBezierPath(rect: CGRect(x: originX + CGFloat(col) * CellSide, y: originY + CGFloat(row) * CellSide, width: CellSide, height: CellSide))
        color.setFill()
        path.fill()
    }

}
