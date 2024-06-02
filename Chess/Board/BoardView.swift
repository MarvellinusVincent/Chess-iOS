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
    
    var availableLegalMoves: [ChessPiecePosition] = [] {
        didSet { updateLegalMoves() }
    }

    private func configureView() {
        for i in 0 ..< 8 {
            for j in 0 ..< 8 {
                let isWhiteSquare = (i + j) % 2 == 0
                let view = UIView()
                view.backgroundColor = UIColor(named: isWhiteSquare ? theme.squareColor.odd : theme.squareColor.even)
                squares.append(view)
                addSubview(view)

                if j == 0 {
                    let label = UILabel()
                    label.text = "\(8 - i)"
                    label.font = UIFont.systemFont(ofSize: 11)
                    label.textColor = labelColor(for: theme, isEvenSquare: (i + j) % 2 == 0)
                    label.sizeToFit()
                    numberLabels.append(label)
                    view.addSubview(label)
                }

                if i == 7 {
                    let label = UILabel()
                    label.text = "\(Character(UnicodeScalar(97 + j)!))"
                    label.font = UIFont.systemFont(ofSize: 11)
                    label.textColor = labelColor(for: theme, isEvenSquare: (i + j) % 2 == 0)
                    label.sizeToFit()
                    letterLabels.append(label)
                    view.addSubview(label)
                }
                
                if AppSettings.shared.showLegalMoves == false {
                    continue
                }
                
                let legalMoveView = UIView()
                legalMoveView.backgroundColor = .white
                legalMoveView.frame = boundingBox(x: j, y: i, boxSize: squareSize)
                legalMoves.append(legalMoveView)
                addSubview(legalMoveView)
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
        guard let delegate = delegate as? ViewController, delegate.highlightMoves else {
            return
        }
        let highlightColors: (even: UIColor, odd: UIColor)
        switch theme {
        case .original:
            highlightColors = HighlightTheme.original.highlightColor
        case .chesscom:
            highlightColors = HighlightTheme.chesscom.highlightColor
        case .glass:
            highlightColors = HighlightTheme.glass.highlightColor
        case .light:
            highlightColors = HighlightTheme.light.highlightColor
        }
        for (i, row) in chessBoard.pieces.enumerated() {
            for (j, piece) in row.enumerated() {
                guard let piece = piece, let view = chessPieces[piece.id] else {
                    continue
                }
                let isSelected = pieceSelected == ChessPiecePosition(x: j, y: i)
                let isEvenSquare = (i + j) % 2 == 0

                if isSelected {
                    squares[i * 8 + j].backgroundColor = isEvenSquare ? highlightColors.even : highlightColors.odd
                } else {
                    squares[i * 8 + j].backgroundColor = UIColor(named: isEvenSquare ? theme.squareColor.odd : theme.squareColor.even)
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
    
    
    private func labelColor(for theme: BoardTheme, isEvenSquare: Bool) -> UIColor {
        let labelColors: (even: UIColor, odd: UIColor)
        switch theme {
        case .original:
            labelColors = labelTheme.original.labelColor
        case .chesscom:
            labelColors = labelTheme.chesscom.labelColor
        case .glass:
            labelColors = labelTheme.glass.labelColor
        case .light:
            labelColors = labelTheme.light.labelColor
        }
        return isEvenSquare ? labelColors.even : labelColors.odd
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
        updateLegalMoves()
    }
    
    private func updateBoardTheme() {
        for square in squares {
            square.removeFromSuperview()
        }
        squares.removeAll()
        for i in 0 ..< 8 {
            for j in 0 ..< 8 {
                let isEvenSquare = (i + j) % 2 == 0
                let view = UIView()
                view.backgroundColor = UIColor(named: isEvenSquare ? theme.squareColor.even : theme.squareColor.odd)
                squares.append(view)
                insertSubview(view, at: 0)
            }
        }
        for (index, label) in numberLabels.enumerated() {
            label.textColor = labelColor(for: theme, isEvenSquare: index % 2 == 0)
        }
        for (index, label) in letterLabels.enumerated() {
            label.textColor = labelColor(for: theme, isEvenSquare: index % 2 == 0)
        }
    }
    
    private func updateLegalMoves() {
        if AppSettings.shared.showLegalMoves == false {
            return
        }
        let size = squareSize
        for i in 0 ..< 8 {
            for j in 0 ..< 8 {
                let position = ChessPiecePosition(x: j, y: i)
                guard let view = legalMoves[safe: i * 8 + j] else {
                    continue
                }
                view.frame = boundingBox(x: j, y: i, boxSize: size)
                view.layer.cornerRadius = size.width / 2
                view.layer.transform = CATransform3DMakeScale(0.3, 0.3, 0)
//                view.backgroundColor = // depends on the board theme
                view.alpha = availableLegalMoves.contains(position) ? 1 : 0
                let hasPiece = chessBoard.pieces[i][j] != nil
                if hasPiece {
                    bringSubviewToFront(view)
                } else {
                    bringSubviewToFront(view)
                }
            }
        }
    }
    
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

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

