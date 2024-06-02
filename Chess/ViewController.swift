//
//  ViewController.swift
//  Chess
//
//  Created by Marvellinus Vincent on 5/25/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var moveHistoryView: MoveHistory!
    @IBOutlet var boardView: BoardView?
    var currentGame = Game()
    var singlePlayer : Bool!
    var undo: Bool!
    var highlightMoves: Bool!
    var showLegalMoves: Bool!
    var sound: Bool!
    var regularMove: AVAudioPlayer!
    var captureMove: AVAudioPlayer!
    var againstAIColor: String!
    var difficultyLevel: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boardView?.delegate = self
        handleGameSettings()
        loadAudioFiles()
        currentGame.moveHistoryView = moveHistoryView
        print(againstAIColor)
        print(difficultyLevel)
    }
    
    private func handleGameSettings() {
        undo = AppSettings.shared.undo
        highlightMoves = AppSettings.shared.highlightMoves
        showLegalMoves = AppSettings.shared.showLegalMoves
        sound = AppSettings.shared.soundEnabled
    }
    
    private func loadAudioFiles() {
        DispatchQueue.global().async {
            if let regularUrl = Bundle.main.url(forResource: "RegularMove", withExtension: "mp3"),
               let captureUrl = Bundle.main.url(forResource: "Capture", withExtension: "mp3") {
                do {
                    self.regularMove = try AVAudioPlayer(contentsOf: regularUrl)
                    self.captureMove = try AVAudioPlayer(contentsOf: captureUrl)
                    self.regularMove.prepareToPlay()
                    self.captureMove.prepareToPlay()
                } catch {
                    print("Error loading audio files: \(error)")
                }
            }
        }
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
        if sound {
            let isCapture = currentGame.chessBoard.indexOfPiece(atPosition: move.destination) != nil
            if isCapture {
                captureMove.play()
            } else {
                regularMove.play()
            }
        }
        
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
            boardView.availableLegalMoves = []
        }, completion: { [weak self] _ in
            guard let self = self, board2 == self.currentGame.chessBoard else { return }
            if wasInCheck {
                boardView.chessBoard = board2
                return
            }
            if wasPromoted {
                showPromotionAlert(at: move.destination, playerColor: self.currentGame.player == .white ? "black" : "white")
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
    
    private func handlePieceSelection(_ position: ChessPiecePosition?) {
        let moves = position.map(currentGame.movesForPiece(at:)) ?? []
        UIView.animate(withDuration: 0, animations: {
            self.boardView?.pieceSelected = position
            self.boardView?.availableLegalMoves = moves
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
                let alert = UIAlertController(title: "Game Over",message: "Stalemate: Nobody wins", preferredStyle: .alert)
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
        }
    }
    
    private func showPromotionAlert(at position: ChessPiecePosition, playerColor: String) {
        let alert = UIAlertController(title: "Promote Pawn", message: nil, preferredStyle: .alert)

        let pieceImages: [Piece: String] = [
            .queen: "Queen-\(playerColor)",
            .rook: "Rook-\(playerColor)",
            .bishop: "Bishop-\(playerColor)",
            .knight: "Knight-\(playerColor)"
        ]

        var column = 0
        var row = 0
        let maxColumns = 2
        let imageWidth = 50
        let imageHeight = 50

        for piece in [Piece.queen, .rook, .bishop, .knight] {
            guard let imageName = pieceImages[piece], let pieceImage = UIImage(named: imageName) else {
                continue
            }

            let resizedImage = pieceImage.resized(to: CGSize(width: imageWidth, height: imageHeight))
            let action = UIAlertAction(title: piece.rawValue.capitalized, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.currentGame.promote(atPosition: position, chosenPromotedPiece: piece)
                self.boardView?.chessBoard = self.currentGame.chessBoard
                self.handleGameStatusChange()
            }
            action.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
            alert.addAction(action)
            column += 1
            if column == maxColumns {
                column = 0
                row += 1
            }
        }

        present(alert, animated: true)
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
