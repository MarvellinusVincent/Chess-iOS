//
//  SinglePlayerController.swift
//  Chess
//
//  Created by Marvellinus Vincent on 6/1/24.
//

import Foundation
import UIKit

class SinglePlayerController: UIViewController {
    
    var playerColor: String?
    var difficultyLevel: String?
    
    @IBOutlet weak var playWithWhiteButton: UIButton!
    @IBOutlet weak var playWithBlackButton: UIButton!
    @IBOutlet weak var easyModeButton: UIButton!
    @IBOutlet weak var mediumModeButton: UIButton!
    @IBOutlet weak var hardModeButton: UIButton!
    
    let whiteColor = "white"
    let blackColor = "black"
    let easyLevel = "easy"
    let mediumLevel = "medium"
    let hardLevel = "hard"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playWithWhiteButton.addTarget(self, action: #selector(playWithWhiteTapped(_:)), for: .touchUpInside)
        playWithBlackButton.addTarget(self, action: #selector(playWithBlackTapped(_:)), for: .touchUpInside)
        easyModeButton.addTarget(self, action: #selector(easyModeTapped(_:)), for: .touchUpInside)
        mediumModeButton.addTarget(self, action: #selector(mediumModeTapped(_:)), for: .touchUpInside)
        hardModeButton.addTarget(self, action: #selector(hardModeTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func playWithWhiteTapped(_ sender: UIButton) {
        playerColor = whiteColor
        updatePlayerColorButtons(selectedButton: sender)
    }
    
    @objc private func playWithBlackTapped(_ sender: UIButton) {
        playerColor = blackColor
        updatePlayerColorButtons(selectedButton: sender)
    }
    
    @objc private func easyModeTapped(_ sender: UIButton) {
        difficultyLevel = easyLevel
        updateDifficultyButtons(selectedButton: sender)
    }
    
    @objc private func mediumModeTapped(_ sender: UIButton) {
        difficultyLevel = mediumLevel
        updateDifficultyButtons(selectedButton: sender)
    }
    
    @objc private func hardModeTapped(_ sender: UIButton) {
        difficultyLevel = hardLevel
        updateDifficultyButtons(selectedButton: sender)
    }
    
    private func updatePlayerColorButtons(selectedButton: UIButton) {
        playWithWhiteButton.isSelected = (selectedButton == playWithWhiteButton)
        playWithBlackButton.isSelected = (selectedButton == playWithBlackButton)
        updateButtonAppearance(button: playWithWhiteButton)
        updateButtonAppearance(button: playWithBlackButton)
    }
    
    private func updateDifficultyButtons(selectedButton: UIButton) {
        easyModeButton.isSelected = (selectedButton == easyModeButton)
        mediumModeButton.isSelected = (selectedButton == mediumModeButton)
        hardModeButton.isSelected = (selectedButton == hardModeButton)
        updateButtonAppearance(button: easyModeButton)
        updateButtonAppearance(button: mediumModeButton)
        updateButtonAppearance(button: hardModeButton)
    }
    
    private func updateButtonAppearance(button: UIButton) {
        button.backgroundColor = button.isSelected ? UIColor.systemBlue : UIColor.systemGray
        button.setTitleColor(button.isSelected ? UIColor.white : UIColor.black, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playSinglePlayer" {
            if let destinationVC = segue.destination as? ViewController {
                destinationVC.singlePlayer = true
                if let playerColor = self.playerColor {
                    destinationVC.againstAIColor = (playerColor == whiteColor) ? blackColor : whiteColor
                } else {
                    destinationVC.againstAIColor = blackColor
                }
                destinationVC.difficultyLevel = self.difficultyLevel ?? easyLevel
            }
        }
    }
}
