//
//  MoveHistory.swift
//  Chess
//
//  Created by Marvellinus Vincent on 6/1/24.
//

import Foundation
import UIKit

class MoveHistory: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var moveHistory: [(Int, String)] = []
    var originPieceType: String = ""
    var destinationPieceType: String = ""
    var turnNumber: Int = 1
    
    private let cellIdentifier = "MoveCell"
    
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        dataSource = self
        register(MoveCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionViewLayout = layout
        layout.itemSize = CGSize(width: 70, height: frame.height)
        
        showsHorizontalScrollIndicator = true
        showsVerticalScrollIndicator = false
        alwaysBounceHorizontal = false
        alwaysBounceVertical = false
        isScrollEnabled = true
    }
    
    func update(with move: Move, originPiece: String, destinationPiece: String) {
        originPieceType = originPiece
        destinationPieceType = destinationPiece
        
        let notation = convertToChessNotation(move, originPiece, destinationPiece)
        moveHistory.append((turnNumber, notation))
        
        if moveHistory.count % 2 == 0 {
            turnNumber += 1
        }
        
        reloadData()
        
        let lastIndexPath = IndexPath(item: moveHistory.count - 1, section: 0)
        scrollToItem(at: lastIndexPath, at: .right, animated: true)
    }
    
    private func convertToChessNotation(_ move: Move, _ originPiece: String, _ destinationPiece: String) -> String {
        let destination = chessPositionToChessNotation(move.destination)
        let isCapture = !destinationPiece.isEmpty
        let captureSymbol = isCapture ? "x" : ""
        
        if originPiece == "pawn" {
            if isCapture {
                let originFile = chessPositionToChessNotation(move.origin).prefix(1)
                return "\(originFile)\(captureSymbol)\(destination)"
            }
            return "\(destination)"
        } else {
            var pieceSymbol = String(originPiece.first!).uppercased()
            if originPiece == "knight" {
                pieceSymbol = "N"
            }
            if isCapture {
                return "\(pieceSymbol)\(captureSymbol)\(destination)"
            }
            return "\(pieceSymbol)\(destination)"
        }
    }
    
    private func chessPositionToChessNotation(_ position: ChessPiecePosition) -> String {
        let file = String(UnicodeScalar(97 + position.x)!)
        let rank = 8 - position.y
        return "\(file)\(rank)"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moveHistory.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MoveCollectionViewCell
        
        let turn = (indexPath.item / 2) + 1
        let moveIndex = indexPath.item % 2
        
        let moveTuple = moveHistory[indexPath.item]
        let moveText = "\(moveTuple.1)"
        
        if moveIndex == 0 {
            cell.moveLabel.text = "\(turn). \(moveText)"
        } else {
            cell.moveLabel.text = moveText
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let moveTuple = moveHistory[indexPath.item]
            let moveText = "\(moveTuple.1)"

            let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.height)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedRect = NSString(string: moveText).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
            let width = estimatedRect.width

            return CGSize(width: width, height: frame.height)
        }
    
    func removeLastMove() {
        guard !moveHistory.isEmpty else { return }
        moveHistory.removeLast()
        
        if moveHistory.count % 2 == 1 {
            turnNumber -= 1
        }
        
        reloadData()
        
        if !moveHistory.isEmpty {
            let lastIndexPath = IndexPath(item: moveHistory.count - 1, section: 0)
            scrollToItem(at: lastIndexPath, at: .right, animated: true)
        }
    }
}


class MoveCollectionViewCell: UICollectionViewCell {
    let moveLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(moveLabel)
        
        moveLabel.numberOfLines = 1
        
        NSLayoutConstraint.activate([
            moveLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            moveLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            moveLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            moveLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
        
        moveLabel.textAlignment = .center
        moveLabel.textColor = .black
        moveLabel.font = UIFont.systemFont(ofSize: 16)
    }
}
