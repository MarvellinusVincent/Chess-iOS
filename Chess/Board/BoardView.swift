//
//  BoardView.swift
//  Chess
//
//  Created by Marvellinus Vincent on 5/23/24.
//

import Foundation
import UIKit

protocol BoardViewDelegate: AnyObject {
    func boardView(_ boardView: BoardView, tap position: ChessPiecePosition)
}

class BoardView: UIView {
    
    weak var delegate: BoardViewDelegate?
    
    private var squares: [UIView] = []
    private var legalMoves: [UIView] = []
    private var numberLabels: [UILabel] = []
    private var letterLabels: [UILabel] = []
    private var chessPieces: [String: UIImageView] = [:]
    
    var chessBoard = ChessBoard() {
        didSet { displayPiece() }
    }
    
    var pieceSelected: ChessPiecePosition? {
        didSet { highlightPiece() }
    }
    
//    Depends on the switch if its on
//    var availableLegalMoves: [ChessPiecePosition] = [] {
//        didSet { updateLegalMoves() }
//    }

    private func configureView() {
        for i in 0 ..< 8 {
            for j in 0 ..< 8 {
                let isWhiteSquare = (i + j) % 2 == 0
                let view = UIView()
                view.backgroundColor = UIColor(named: isWhiteSquare ? theme.squareColor.odd : theme.squareColor.even)
                squares.append(view)
                addSubview(view)
//    Depends on the switch if its on
//                let legalMoveView = UIView()
//                legalMoveView.backgroundColor = .white
//                legalMoveView.frame = boundingBox(x: j, y: i, boxSize: squareSize)
//                legalMoves.append(legalMoveView)
//                addSubview(legalMoveView)

                if j == 0 {
                    let label = UILabel()
                    label.text = "\(8 - i)"
                    label.font = UIFont.systemFont(ofSize: 11)
                    label.textColor = .black
                    label.sizeToFit()
                    numberLabels.append(label)
                    view.addSubview(label)
                }

                if i == 7 {
                    let label = UILabel()
                    label.text = "\(Character(UnicodeScalar(97 + j)!))"
                    label.font = UIFont.systemFont(ofSize: 11)
                    label.textColor = .black
                    label.sizeToFit()
                    letterLabels.append(label)
                    view.addSubview(label)
                }
            }
        }

        for row in chessBoard.pieces {
            for piece in row {
                guard let piece = piece else {
                    continue
                }
                let view = UIImageView()
                view.contentMode = .scaleAspectFit
                chessPieces[piece.id] = view
                addSubview(view)
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }
    
    private func displayPiece() {
        var visiblePieces = Set<String>()
        let size = squareSize
        for (i, row) in chessBoard.pieces.enumerated() {
            for (j, piece) in row.enumerated() {
                guard let piece = piece, let view = chessPieces[piece.id] else {
                    continue
                }
                visiblePieces.insert(piece.id)
                view.image = UIImage(named: piece.imageName)
                view.frame = boundingBox(x: j, y: i, boxSize: size)
            }
        }
        for (id, view) in chessPieces {
            if !visiblePieces.contains(id) {
                view.alpha = 0
            }
        }
        highlightPiece()
    }
    
    private func highlightPiece() {
        for (i, row) in chessBoard.pieces.enumerated() {
            for (j, piece) in row.enumerated() {
                guard let piece = piece, let view = chessPieces[piece.id] else {
                    continue
                }
                let isSelected = pieceSelected == ChessPiecePosition(x: j, y: i)

                if isSelected {
                    squares[i * 8 + j].backgroundColor = highlightColor
                } else {
                    squares[i * 8 + j].backgroundColor = UIColor(named: (i + j) % 2 == 0 ? theme.squareColor.odd : theme.squareColor.even)
                }
                view.alpha = pieceSelected == ChessPiecePosition(x: j, y: i) ? 1 : 1
            }
        }
    }
    
    var theme: BoardTheme = {
        if let storedTheme = AppSettings.shared.boardTheme, let theme = BoardTheme(rawValue: storedTheme) {
            return theme
        } else {
            return .original
        }
    }() {
        didSet { updateBoardTheme() }
    }
    
    private var highlightColor: UIColor {
        switch theme {
        case .original:
            return HighlightTheme.original.highlightColor
        case .chesscom:
            return HighlightTheme.chesscom.highlightColor
        case .grayscale:
            return HighlightTheme.grayscale.highlightColor
        case .blackWhite:
            return HighlightTheme.blackWhite.highlightColor
        }
    }
    
    private func labelColor(for theme: BoardTheme) -> UIColor {
        switch theme {
        case .original, .chesscom, .grayscale:
            return .black
        case .blackWhite:
            return .red
        }
    }
    
    private var squareSize: CGSize {
        let bounds = self.bounds.size
        return CGSize(width: bounds.width / 8, height: bounds.height / 8)
    }
    
    private func boundingBox(x: Int, y: Int, boxSize: CGSize) -> CGRect {
        let offset = CGPoint(x: CGFloat(x) * boxSize.width, y: CGFloat(y) * boxSize.height)
        return CGRect(origin: offset, size: boxSize)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = squareSize
        for i in 0 ..< 8 {
            for j in 0 ..< 8 {
                let squareFrame = boundingBox(x: j, y: i, boxSize: size)
                squares[i * 8 + j].frame = squareFrame

                if j == 0 {
                    let label = numberLabels[i]
                    label.frame.origin = CGPoint(x: 2, y: 2)
                }

                if i == 7 {
                    let label = letterLabels[j]
                    label.frame.origin = CGPoint(x: squareFrame.width - label.frame.width - 2, y: squareFrame.height - label.frame.height - 2)
                }
            }
        }
        displayPiece()
        //    Depends on the switch if its on
        //        updateLegalMoves()
    }
    
    private func updateBoardTheme() {
        for square in squares {
            square.removeFromSuperview()
        }
        squares.removeAll()
        for i in 0 ..< 8 {
            for j in 0 ..< 8 {
                let isWhiteSquare = i % 2 == j % 2
                let view = UIView()
                view.backgroundColor = UIColor(named: isWhiteSquare ? theme.squareColor.odd : theme.squareColor.even)
                squares.append(view)
                insertSubview(view, at: 0)
            }
        }
        let labelColor = self.labelColor(for: theme)
        for label in numberLabels {
            label.textColor = labelColor
        }
        for label in letterLabels {
            label.textColor = labelColor
        }
    }
    
//    Depends on the switch if its on
//    private func updateLegalMoves() {
//        let size = squareSize
//        for i in 0 ..< 8 {
//            for j in 0 ..< 8 {
//                let position = ChessPiecePosition(x: j, y: i)
//                let view = legalMoves[i * 8 + j]
//                view.frame = boundingBox(x: j, y: i, boxSize: size)
//                view.layer.cornerRadius = size.width / 2
//                view.layer.transform = CATransform3DMakeScale(0.25, 0.25, 0)
//                view.backgroundColor = // depends on the board theme
//                view.alpha = availableLegalMoves.contains(position) ? 1 : 0
//            }
//        }
//    }
    
    @objc private func didTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let size = squareSize
        let position = ChessPiecePosition(x: Int(location.x / size.width), y: Int(location.y / size.height))
        delegate?.boardView(self, tap: position)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
}
