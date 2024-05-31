//
//  ViewController.swift
//  Chess
//
//  Created by Marvellinus Vincent on 5/25/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var boardView: BoardView?
    private var currentGame = Game()
    var singlePlayer : Bool!
    var undo: Bool!
    var highlightMoves: Bool!
    var showLegalMoves: Bool!
    var sound: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boardView?.delegate = self
        handleGameStatusChange()
        undo = {
            return AppSettings.shared.undo
        }()
        highlightMoves = {
            return AppSettings.shared.highlightMoves
        }()
        showLegalMoves = {
            return AppSettings.shared.showLegalMoves
        }()
        sound = {
            return AppSettings.shared.soundEnabled
        }()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
}

extension ViewController: BoardViewDelegate {
    func boardView(_ boardView: BoardView, tap position: ChessPiecePosition) {
        guard let selection = boardView.pieceSelected else {
            if currentGame.playerTurn(at: position) {
                handlePieceSelection(position)
            }
            return
        }
        guard currentGame.isValidMove(start: selection, target: position) else {
            if selection == position {
                handlePieceSelection(nil)
            } else if currentGame.playerTurn(at: position) {
                handlePieceSelection(position)
            }
            return
        }
        makeMove(Move(origin: selection, destination: position))
    }
    
    private func makeMove(_ move: Move) {
        guard let boardView = boardView else {
            return
        }
        let oldGame = currentGame
        currentGame.movePiece(source: move.origin, destination: move.destination)
        let board1 = currentGame.chessBoard
        let kingPosition = currentGame.king(for: oldGame.player)
        let wasInCheck = currentGame.pieceIsThreatened(at: kingPosition)
        let wasPromoted = !wasInCheck && currentGame.canPromote(at: move.destination)
        if wasInCheck {
            currentGame = oldGame
            return
        }
        let board2 = currentGame.chessBoard
        UIView.animate(withDuration: 0.25, animations: {
            boardView.pieceSelected = nil
            boardView.chessBoard = board1
            // Depends on the switch if legal moves is on
//            boardView.availableLegalMoves = []
        }, completion: { [weak self] _ in
            guard let self = self, board2 == self.currentGame.chessBoard else { return }
            if wasInCheck {
                boardView.chessBoard = board2
                return
            }
            if wasPromoted {
                let alert = UIAlertController(
                    title: "Promote Pawn",
                    message: nil,
                    preferredStyle: .alert
                )
                let playerColor = currentGame.player == .white ? "black" : "white"
                let pieceImages: [Piece: String] = [
                    .queen: "Queen-\(playerColor)",
                    .rook: "Rook-\(playerColor)",
                    .bishop: "Bishop-\(playerColor)",
                    .knight: "Knight-\(playerColor)"
                ]
                
                for piece in [Piece.queen, .rook, .bishop, .knight] {
                    guard let imageName = pieceImages[piece],
                          let pieceImage = UIImage(named: imageName) else {
                        continue
                    }
                    let action = UIAlertAction(
                        title: "",
                        style: .default,
                        handler: { [weak self] _ in
                            guard let self = self else { return }
                            self.currentGame.promote(atPosition: move.destination, chosenPromotedPiece: piece)
                            boardView.chessBoard = self.currentGame.chessBoard
                            self.handleGameStatusChange()
                        }
                    )
                    action.setValue(pieceImage.withRenderingMode(.alwaysOriginal), forKey: "image")
                    action.accessibilityLabel = "\(piece.rawValue.capitalized)"
                    alert.addAction(action)
                }
                
                self.present(alert, animated: true)
                return
            }
            self.handleGameStatusChange()
        })
    }
    
    private func AIMove() {
        if singlePlayer {
            guard let move = currentGame.AI(for: currentGame.player) else { return }
            makeMove(move)
        }
    }
    
//      Depends on the switch if legal moves is on
    private func handlePieceSelection(_ position: ChessPiecePosition?) {
//        let moves = position.map(currentGame.movesForPiece(at:)) ?? []
        UIView.animate(withDuration: 0, animations: {
            self.boardView?.pieceSelected = position
//            self.boardView?.availableLegalMoves = moves
        })
    }
    
    private func handleGameStatusChange() {
        let gameState = currentGame.gameStatus
        switch gameState {
            case .ongoing, .check:
                AIMove()
            case .checkMate:
                let alert = UIAlertController(title: "Game Over",message: "Checkmate: \(currentGame.player.opponentColor) wins", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Look At Final Position", style: .default))
                alert.addAction(UIAlertAction(title: "Back to Home Screen", style: UIAlertAction.Style.default, handler: {
                    action in self.performSegue(withIdentifier: "GameBackButton", sender: self)
                }))
                alert.addAction(UIAlertAction(title: "Rematch", style: UIAlertAction.Style.default, handler: {
                    action in
                    self.currentGame = Game()
                    UIView.animate(withDuration: 0.3, animations: {
                        self.boardView?.chessBoard = self.currentGame.chessBoard
                    }, completion: { [weak self] _ in
                        self?.handleGameStatusChange()
                    })
                    self.handlePieceSelection(nil)
                }))
                present(alert, animated: true)
            case .staleMate:
                let alert = UIAlertController(
                    title: "Game Over",
                    message: "Stalemate: Nobody wins",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
        }
    }
}
