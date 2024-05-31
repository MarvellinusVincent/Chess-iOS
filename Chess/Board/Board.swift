//
//  Board.swift
//  Chess
//
//  Created by Marvellinus Vincent on 5/23/24.
//

import Foundation

struct ChessPiece: Equatable {
    var id: String
    var pieceType: Piece
    let color: PieceColor
    
    init(id: String, pieceType: Piece, color: PieceColor) {
        self.id = id
        self.pieceType = pieceType
        self.color = color
    }
    
    var imageName: String {
        "\(pieceType.rawValue.capitalized)-\(color.rawValue)"
    }
}

struct ChessBoard: Equatable {
    var pieces: [[ChessPiece?]]
}

extension ChessBoard {
    init() {
        pieces = [
            [ChessPiece(id: "Rook-black-1", pieceType: .rook, color: .black), ChessPiece(id: "Knight-black-1", pieceType: .knight, color: .black), ChessPiece(id: "Bishop-black-1", pieceType: .bishop, color: .black), ChessPiece(id: "Queen-black", pieceType: .queen, color: .black), ChessPiece(id: "King-black", pieceType: .king, color: .black), ChessPiece(id: "Bishop-black-2", pieceType: .bishop, color: .black), ChessPiece(id: "Knight-black-2", pieceType: .knight, color: .black), ChessPiece(id: "Rook-black-2", pieceType: .rook, color: .black)],
            [ChessPiece(id: "Pawn-black-1", pieceType: .pawn, color: .black), ChessPiece(id: "Pawn-black-2", pieceType: .pawn, color: .black), ChessPiece(id: "Pawn-black-3", pieceType: .pawn, color: .black), ChessPiece(id: "Pawn-black-4", pieceType: .pawn, color: .black), ChessPiece(id: "Pawn-black-5", pieceType: .pawn, color: .black), ChessPiece(id: "Pawn-black-6", pieceType: .pawn, color: .black), ChessPiece(id: "Pawn-black-7", pieceType: .pawn, color: .black), ChessPiece(id: "Pawn-black-8", pieceType: .pawn, color: .black)],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [ChessPiece(id: "Pawn-white-1", pieceType: .pawn, color: .white), ChessPiece(id: "Pawn-white-2", pieceType: .pawn, color: .white), ChessPiece(id: "Pawn-white-3", pieceType: .pawn, color: .white), ChessPiece(id: "Pawn-white-4", pieceType: .pawn, color: .white), ChessPiece(id: "Pawn-white-5", pieceType: .pawn, color: .white), ChessPiece(id: "Pawn-white-6", pieceType: .pawn, color: .white), ChessPiece(id: "Pawn-white-7", pieceType: .pawn, color: .white), ChessPiece(id: "Pawn-white-8", pieceType: .pawn, color: .white)],
            [ChessPiece(id: "Rook-white-1", pieceType: .rook, color: .white), ChessPiece(id: "Knight-white-1", pieceType: .knight, color: .white), ChessPiece(id: "Bishop-white-1", pieceType: .bishop, color: .white), ChessPiece(id: "Queen-white", pieceType: .queen, color: .white), ChessPiece(id: "King-white", pieceType: .king, color: .white), ChessPiece(id: "Bishop-white-2", pieceType: .bishop, color: .white), ChessPiece(id: "Knight-white-2", pieceType: .knight, color: .white), ChessPiece(id: "Rook-white-2", pieceType: .rook, color: .white)]
        ]
    }
    
    var allPositions: [ChessPiecePosition] { Self.allChessBoardPositions }
    
    static let allChessBoardPositions: [ChessPiecePosition] = {
        var positions: [ChessPiecePosition] = []
        for y in 0..<8 {
            for x in 0..<8 {
                positions.append(ChessPiecePosition(x: x, y: y))
            }
        }
        return positions
    }()
    
    var allChessBoardPieces: [(position: ChessPiecePosition, piece: ChessPiece)] {
        var allPieces: [(position: ChessPiecePosition, piece: ChessPiece)] = []
        for y in 0..<8 {
            for x in 0..<8 {
                if let piece = pieces[y][x] {
                    allPieces.append((ChessPiecePosition(x: x, y: y), piece))
                }
            }
        }
        return allPieces
    }
    
    mutating func movePiece(source: ChessPiecePosition, destination: ChessPiecePosition) {
        var pieces = self.pieces
        pieces[destination.y][destination.x] = indexOfPiece(atPosition: source)
        pieces[source.y][source.x] = nil
        self.pieces = pieces
    }
    
    mutating func removePiece(at position: ChessPiecePosition) {
        var pieces = self.pieces
        pieces[position.y][position.x] = nil
        self.pieces = pieces
    }

    mutating func promotePawn(atPosition position: ChessPiecePosition, chosenPromotedPiece pieceType: Piece) {
        var piece = self.indexOfPiece(atPosition: position)
        piece?.pieceType = pieceType
        pieces[position.y][position.x] = piece
    }
    
    func squareIsEmpty(between: ChessPiecePosition, and: ChessPiecePosition) -> Bool {
        let step = Offset(
            x: between.x > and.x ? -1 : (between.x < and.x ? 1 : 0),
            y: between.y > and.y ? -1 : (between.y < and.y ? 1 : 0)
        )
        var position = between
        position += step
        while position != and {
            if indexOfPiece(atPosition: position) != nil {
                return true
            }
            position += step
        }
        return false
    }
    
    func indexOfPiece(atPosition position: ChessPiecePosition) -> ChessPiece? {
        guard position.y >= 0, position.y < pieces.count, position.x >= 0, position.x < pieces[position.y].count else {
            return nil
        }
        return pieces[position.y][position.x]
    }
    
    func firstPosition(where condition: (ChessPiece) -> Bool) -> ChessPiecePosition? {
        for y in 0..<pieces.count {
            for x in 0..<pieces[y].count {
                if let piece = pieces[y][x], condition(piece) {
                    return ChessPiecePosition(x: x, y: y)
                }
            }
        }
        return nil
    }
}
