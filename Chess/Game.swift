//
//  Game.swift
//  Chess
//
//  Created by Marvellinus Vincent on 5/25/24.
//

import Foundation

enum Status {
    case ongoing
    case check
    case checkMate
    case staleMate
}

struct Game {
    var chessBoard: ChessBoard
    var moveHistory: [Move]
    var moveHistoryView: MoveHistory?
    var previousStates: [GameState] = []
    
    init() {
        chessBoard = ChessBoard()
        moveHistory = []
    }
    
    var gameStatus: Status {
        let player = player
        var movable = false
        for move in possibleMoves(for: player) {
            var newBoard = self
            newBoard.chessBoard.movePiece(source: move.origin, destination: move.destination)
            if !newBoard.check(for: player) {
                movable = true
                break
            }
        }
        if check(for: player) {
            return movable ? .check : .checkMate
        }
        if additionalStalemateCheck() {
            return .staleMate
        }
        return movable ? .ongoing : .staleMate
    }
    
    mutating func saveCurrentState() {
        let state = GameState(chessBoard: chessBoard, moveHistory: moveHistory)
        previousStates.append(state)
    }
    
    func isValidMove(start: ChessPiecePosition, target: ChessPiecePosition) -> Bool {
        guard let this = chessBoard.indexOfPiece(atPosition: start) else {
            return false
        }
        let delta = target - start
        if let other = chessBoard.indexOfPiece(atPosition: target) {
            guard other.color != this.color else {
                return false
            }
            if this.pieceType == .pawn {
                return pawnCapturable(from: start, with: delta)
            }
        }
        switch this.pieceType {
        case .pawn:
            if enPassant(from: start, to: target) {
                return true
            }
            if delta.x != 0 {
                return false
            }
            switch this.color {
            case .white:
                if start.y == 6 {
                    if delta.y == -1 || delta.y == -2 {
                        return !chessBoard.squareIsEmpty(between: start, and: target)
                    }
                    return false
                }
                return delta.y == -1
            case .black:
                if start.y == 1 {
                    if delta.y == 1 || delta.y == 2 {
                        return !chessBoard.squareIsEmpty(between: start, and: target)
                    }
                    return false
                }
                return delta.y == 1
            }
        case .knight:
            for offset in [Offset(x: 1, y: 2), Offset(x: -1, y: 2), Offset(x: 2, y: 1), Offset(x: -2, y: 1), Offset(x: 1, y: -2), Offset(x: -1, y: -2), Offset(x: 2, y: -1), Offset(x: -2, y: -1),
            ] {
                if offset == delta {
                    return true
                }
            }
            return false
        case .bishop:
            return abs(delta.x) == abs(delta.y) && !chessBoard.squareIsEmpty(between: start, and: target)
        case .rook:
            return (delta.x == 0 || delta.y == 0) && !chessBoard.squareIsEmpty(between: start, and: target)
        case .queen:
            return (delta.x == 0 || delta.y == 0 || abs(delta.x) == abs(delta.y)) && !chessBoard.squareIsEmpty(between: start, and: target)
        case .king:
            if abs(delta.x) <= 1, abs(delta.y) <= 1 {
                return true
            }
            return canCastle(from: start, to: target)
        }
    }
    
    mutating func movePiece(source: ChessPiecePosition, destination: ChessPiecePosition) {
        saveCurrentState()
        guard isValidMove(start: source, target: destination) else { return }
        let originPieceType = chessBoard.indexOfPiece(atPosition: source)?.pieceType.rawValue ?? ""
        let destinationPieceType = chessBoard.indexOfPiece(atPosition: destination)?.pieceType.rawValue ?? ""
        if let piece = chessBoard.indexOfPiece(atPosition: source) {
            switch piece.pieceType {
            case .pawn:
                if enPassant(from: source, to: destination) {
                    chessBoard.removePiece(at: ChessPiecePosition(x: destination.x, y: destination.y - (destination.y - source.y)))
                }
            case .king:
                if abs(destination.x - source.x) > 1 {
                    let kingSide = destination.x == 6
                    let rookSource = ChessPiecePosition(x: kingSide ? 7 : 0, y: source.y)
                    let rookDestination = ChessPiecePosition(x: kingSide ? 5 : 3, y: source.y)
                    chessBoard.movePiece(source: rookSource, destination: rookDestination)
                }
            default:
                break
            }
        }
        chessBoard.movePiece(source: source, destination: destination)
        moveHistory.append(Move(origin: source, destination: destination))
        moveHistoryView?.update(with: Move(origin: source, destination: destination), originPiece: originPieceType, destinationPiece: destinationPieceType)
    }
    
    // AI Logic
    
    func AI(for color: PieceColor, difficulty: String) -> Move? {
        let deadline = Date().addingTimeInterval(5)
        var bestMove: Move?
        var bestScore = Int.min
        while Date() < deadline {
            for piecePosition in chessBoard.allPositions {
                guard let piece = chessBoard.indexOfPiece(atPosition: piecePosition), piece.color == color else {
                    continue
                }
                
                let possibleMoves = possibleMoves(for: piecePosition)
                
                for move in possibleMoves {
                    var newGame = self
                    newGame.movePiece(source: piecePosition, destination: move.destination)
                    
                    let score: Int
                    switch difficulty {
                    case "easy":
                        score = minimax(board: newGame, depth: 1, maximizingPlayer: false, color: color)
                    case "medium":
                        score = minimax(board: newGame, depth: 2, maximizingPlayer: false, color: color)
                    case "hard":
                        score = minimax(board: newGame, depth: 3, maximizingPlayer: false, color: color)
                    default:
                        score = minimax(board: newGame, depth: 1, maximizingPlayer: false, color: color)
                    }
                    
                    if score > bestScore {
                        bestMove = move
                        bestScore = score
                    }
                }
            }
        }
        
        return bestMove
    }

    func minimax(board: Game, depth: Int, maximizingPlayer: Bool, color: PieceColor) -> Int {
        if depth == 0 {
            return evaluatePosition(board: board, color: color)
        }
        
        if maximizingPlayer {
            var maxScore = Int.min
            let possibleMoves = board.possibleMoves(for: color)
            for move in possibleMoves {
                var newBoard = board
                newBoard.movePiece(source: move.origin, destination: move.destination)
                let score = minimax(board: newBoard, depth: depth - 1, maximizingPlayer: false, color: color)
                maxScore = max(maxScore, score)
            }
            return maxScore
        } else {
            var minScore = Int.max
            let possibleMoves = board.possibleMoves(for: color.opponentColor)
            for move in possibleMoves {
                var newBoard = board
                newBoard.movePiece(source: move.origin, destination: move.destination)
                let score = minimax(board: newBoard, depth: depth - 1, maximizingPlayer: true, color: color)
                minScore = min(minScore, score)
            }
            return minScore
        }
    }

    func evaluatePosition(board: Game, color: PieceColor) -> Int {
        let spaceControlScore = calculateSpaceControl(for: color)
        let pawnStructureScore = calculatePawnStructure(for: color)
        let pieceActivityScore = calculatePieceActivity(for: color, board: board)
        
        var pieceValues = 0
        for row in board.chessBoard.pieces {
            for piece in row {
                if let piece = piece {
                    let value = piece.pieceType.value
                    pieceValues += (piece.color == color ? value : -value)
                }
            }
        }
        
        let pieceValuesWeighted = Double(pieceValues) * 0.6
        let spaceControlWeighted = Double(spaceControlScore) * 0.05
        let pawnStructureWeighted = Double(pawnStructureScore) * 0.1
        let pieceActivityWeighted = Double(pieceActivityScore) * 0.25
        
        let totalScore = pieceValuesWeighted + spaceControlWeighted + pawnStructureWeighted + pieceActivityWeighted
        
        return Int(totalScore)
    }
    
    func calculatePieceActivity(for color: PieceColor, board: Game) -> Int {
        var activityScore = 0
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board.chessBoard.pieces[row][col], piece.color == color {
                    let position = ChessPiecePosition(x: col, y: row)
                    let legalMoves = board.availableMoves(for: position)
                    activityScore += legalMoves.count
                    for move in legalMoves {
                        if (move.x >= 2 && move.x <= 5) && (move.y >= 2 && move.y <= 5) {
                            activityScore += 1
                        }
                        if (color == .white && move.y <= 3) || (color == .black && move.y >= 4) {
                            activityScore += 1
                        }
                    }
                }
            }
        }
        return activityScore
    }
    
    func calculateSpaceControl(for color: PieceColor) -> Int {
        var spaceControlScore = 0
        let squareWeights: [[Int]] = [
            [1, 1, 1, 1, 1, 1, 1, 1],
            [1, 2, 2, 2, 2, 2, 2, 1],
            [1, 2, 3, 3, 3, 3, 2, 1],
            [1, 2, 3, 4, 4, 3, 2, 1],
            [1, 2, 3, 4, 4, 3, 2, 1],
            [1, 2, 3, 3, 3, 3, 2, 1],
            [1, 2, 2, 2, 2, 2, 2, 1],
            [1, 1, 1, 1, 1, 1, 1, 1]
        ]
        
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = chessBoard.pieces[row][col], piece.color == color {
                    spaceControlScore += squareWeights[row][col]
                }
            }
        }
        return spaceControlScore
    }
    
    func calculatePawnStructure(for color: PieceColor) -> Int {
        var pawnStructureScore = 0
        
        let pawns = chessBoard.allChessBoardPieces.filter { _, piece in
            piece.color == color && piece.pieceType == .pawn
        }
        
        for (position, _) in pawns {
            let adjacentPawns = countAdjacentPawns(at: position, for: color)
            pawnStructureScore += adjacentPawns
        }
        
        return pawnStructureScore
    }
    
    func countAdjacentPawns(at position: ChessPiecePosition, for color: PieceColor) -> Int {
        var adjacentPawns = 0
        
        for offset in [Offset(x: 1, y: 0), Offset(x: -1, y: 0)] {
            let adjacentPosition = position + offset
            if chessBoard.allPositions.contains(adjacentPosition),
               let piece = chessBoard.indexOfPiece(atPosition: adjacentPosition),
               piece.color == color && piece.pieceType == .pawn {
                adjacentPawns += 1
            }
        }
        
        return adjacentPawns
    }
    
    // Pawn helper functions
    
    func pawnCapturable(from: ChessPiecePosition, with delta: Offset ) -> Bool {
        guard abs(delta.x) == 1, let pawn = chessBoard.indexOfPiece(atPosition: from) else {
            return false
        }
        switch pawn.color {
            case .white:
            return delta.y == -1
            case .black:
            return delta.y == 1
            }
    }
    
    func enPassant(from: ChessPiecePosition, to: ChessPiecePosition) -> Bool {
        guard let piece = chessBoard.indexOfPiece(atPosition: from),
              pawnCapturable(from: from, with: to - from),
              let lastMove = moveHistory.last, lastMove.destination.x == to.x,
              let previousPiece = chessBoard.indexOfPiece(atPosition: lastMove.destination),
              piece.color != previousPiece.color
        else {
            return false
        }
        switch previousPiece.color {
        case .white:
            return lastMove.origin.y == to.y + 1 && lastMove.destination.y == to.y - 1
        default:
            return lastMove.origin.y == to.y - 1 && lastMove.destination.y == to.y + 1
        }
    }
    
    func canPromote(at position: ChessPiecePosition) -> Bool {
        if let piece = chessBoard.indexOfPiece(atPosition: position),
           piece.pieceType == .pawn,
           (piece.color == .white && position.y == 0) ||
           (piece.color == .black && position.y == 7)
        {
            return true
        }
        return false
    }
    
    mutating func promote(atPosition position: ChessPiecePosition, chosenPromotedPiece pieceType: Piece) {
        chessBoard.promotePawn(atPosition: position, chosenPromotedPiece: pieceType)
    }
    
    // King helper functions
    
    func king(for color: PieceColor) -> ChessPiecePosition {
        for y in 0..<8 {
            for x in 0..<8 {
                if let piece = chessBoard.pieces[y][x], piece.pieceType == .king, piece.color == color {
                    return ChessPiecePosition(x: x, y: y)
                }
            }
        }
        return ChessPiecePosition(x: -1, y: -1)
    }
    
    func check(for player: PieceColor) -> Bool {
        return pieceIsThreatened(at: king(for: player))
    }
    
    func canCastle(from: ChessPiecePosition, to: ChessPiecePosition) -> Bool {
        guard let piece = chessBoard.indexOfPiece(atPosition: from) else {
            return false
        }
        let homeRank = piece.color == .black ? 0 : 7
        guard from.y == homeRank, to.y == homeRank,
              from.x == 4, (to.x == 2 || to.x == 6)
        else {
            return false
        }
        let king = ChessPiecePosition(x: 4, y: homeRank)
        let isKingSideCastle = (to.x == 6)
        let rookHomePosition = ChessPiecePosition(x: isKingSideCastle ? 7 : 0, y: homeRank)
        if hasMadeFirstMove(at: king) {
            return false
        }
        if hasMadeFirstMove(at: rookHomePosition) {
            return false
        }
        for x in (isKingSideCastle ? 5...6 : 1...3) {
            if chessBoard.indexOfPiece(atPosition: ChessPiecePosition(x: x, y: homeRank)) != nil {
                return false
            }
        }
        for x in (isKingSideCastle ? 4...6 : 2...4) {
            if positionUnderAttack(ChessPiecePosition(x: x, y: homeRank), by: piece.color.opponentColor) {
                return false
            }
        }
        return true
    }
    
    // Move Checks
    
    var player: PieceColor {
        moveHistory.last.flatMap {
            chessBoard.indexOfPiece(atPosition: $0.destination)?.color.opponentColor
        } ?? .white
    }
    
    func playerTurn(at position: ChessPiecePosition) -> Bool {
        chessBoard.indexOfPiece(atPosition: position)?.color == player
    }
    
    func availableMoves(for position: ChessPiecePosition) -> [ChessPiecePosition] {
        chessBoard.allPositions.filter { isValidMove(start: position, target: $0) }
    }
    
    func hasMadeFirstMove(at position: ChessPiecePosition) -> Bool {
        for move in moveHistory {
            if move.origin == position {
                return true
            }
        }
        return false
    }
    
    func movesForPiece(at position: ChessPiecePosition) -> [ChessPiecePosition] {
        chessBoard.allPositions.filter { isValidMove(start: position, target: $0) }
    }
    
    func possibleMoves(for color: PieceColor) ->
        LazySequence<FlattenSequence<LazyMapSequence<[ChessPiecePosition], LazyFilterSequence<[Move]>>>>
    {
        chessBoard.allChessBoardPieces
            .compactMap { $1.color == color ? $0 : nil }
            .lazy.flatMap { self.possibleMoves(for: $0) }
    }

    func possibleMoves(for position: ChessPiecePosition) -> LazyFilterSequence<[Move]> {
        chessBoard.allPositions
            .map { Move(origin: position, destination: $0) }
            .lazy.filter { self.isValidMove(start: $0.origin, target: $0.destination) }
    }

    func possibleThreats(for color: PieceColor) -> LazyFilterSequence<[(position: ChessPiecePosition, piece: ChessPiece)]> {
        chessBoard.allChessBoardPieces.lazy.filter { position, piece in
            piece.color == color && self.pieceIsThreatened(at: position)
        }
    }
    
    func pieceIsThreatened(at position: ChessPiecePosition) -> Bool {
        for startPosition in chessBoard.allPositions {
            if isValidMove(start: startPosition, target: position) {
                return true
            }
        }
        return false
    }

    func positionUnderAttack(_ position: ChessPiecePosition, by color: PieceColor) -> Bool {
        for (from, piece) in chessBoard.allChessBoardPieces {
            if piece.color == color {
                if piece.pieceType == .pawn {
                    if pawnCapturable(from: from, with: position - from) {
                        return true
                    }
                } else {
                    if isValidMove(start: from, target: position) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    // Additional Game Logic
    
    func additionalStalemateCheck() -> Bool {
        let allPieces = chessBoard.allChessBoardPieces.map { $0.piece }
        let totalPiecesCount = allPieces.count
        if totalPiecesCount == 2 {
            return true
        }
        let whitePieces = allPieces.filter { $0.color == .white }
        let blackPieces = allPieces.filter { $0.color == .black }
        let whiteNonKingPieces = whitePieces.filter { $0.pieceType != .king }
        let blackNonKingPieces = blackPieces.filter { $0.pieceType != .king }
        let whiteMinorPieces = whiteNonKingPieces.count == 1 && (whiteNonKingPieces.first?.pieceType == .knight || whiteNonKingPieces.first?.pieceType == .bishop)
        let blackMinorPieces = blackNonKingPieces.count == 1 && (blackNonKingPieces.first?.pieceType == .knight || blackNonKingPieces.first?.pieceType == .bishop)
        return whiteMinorPieces && totalPiecesCount == 3 || blackMinorPieces && totalPiecesCount == 3
    }
}

extension Game {
    mutating func undoLastMove() {
        guard !previousStates.isEmpty else {
            return
        }
        let lastState = previousStates.removeLast()
        self.chessBoard = lastState.chessBoard
        self.moveHistory = lastState.moveHistory
        self.moveHistoryView?.removeLastMove()
    }
}

struct GameState {
    var chessBoard: ChessBoard
    var moveHistory: [Move]
}
