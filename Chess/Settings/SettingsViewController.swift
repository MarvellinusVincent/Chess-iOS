//
//  SettingsViewController.swift
//  Chess
//
//  Created by Marvellinus Vincent on 5/30/24.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func settingsDidChange(undo: Bool, highlightMoves: Bool, showLegalMoves: Bool, sound: Bool)
}

class SettingsViewController: UIViewController {
    
    weak var delegate: SettingsViewControllerDelegate?
    
    private var themeButtons: [UIButton] = []
    private var switches: [UISwitch] = []
    
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var showLegalMovesSwitch: UISwitch!
    @IBOutlet weak var highlightMovesSwitch: UISwitch!
    @IBOutlet weak var undoSwitch: UISwitch!
    
    @IBOutlet weak var originalBoardTheme: UIButton!
    @IBOutlet weak var chessComBoardTheme: UIButton!
    @IBOutlet weak var blackWhiteBoardTheme: UIButton!
    @IBOutlet weak var grayscaleBoardTheme: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        setupThemeButtons()
        setupSwitches()
    }
    
    private func loadSettings() {
        undoSwitch.isOn = AppSettings.shared.undo ?? false
        highlightMovesSwitch.isOn = AppSettings.shared.highlightMoves ?? false
        showLegalMovesSwitch.isOn = AppSettings.shared.showLegalMoves ?? false
        soundSwitch.isOn = AppSettings.shared.soundEnabled ?? false
    }
    
    private func setupThemeButtons() {
        themeButtons = [originalBoardTheme, chessComBoardTheme, grayscaleBoardTheme, blackWhiteBoardTheme]
        for button in themeButtons {
            button.addTarget(self, action: #selector(themeButtonTapped(_:)), for: .touchUpInside)
        }
        if let selectedTheme = AppSettings.shared.boardTheme {
            for button in themeButtons {
                button.isSelected = button.titleLabel?.text == selectedTheme
            }
        }
    }
    
    private func setupSwitches() {
        switches = [undoSwitch, highlightMovesSwitch, showLegalMovesSwitch, soundSwitch]
        for toggle in switches {
            toggle.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        }
    }
    
    @objc private func themeButtonTapped(_ sender: UIButton) {
        for button in themeButtons {
            button.isSelected = false
        }
        sender.isSelected = true
        if let selectedTheme = sender.titleLabel?.text {
            AppSettings.shared.boardTheme = selectedTheme
        }
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        switch sender {
        case undoSwitch:
            AppSettings.shared.undo = sender.isOn
        case highlightMovesSwitch:
            AppSettings.shared.highlightMoves = sender.isOn
        case showLegalMovesSwitch:
            AppSettings.shared.showLegalMoves = sender.isOn
        case soundSwitch:
            AppSettings.shared.soundEnabled = sender.isOn
        default:
            break
        }
        
        delegate?.settingsDidChange(
            undo: undoSwitch.isOn,
            highlightMoves: highlightMovesSwitch.isOn,
            showLegalMoves: showLegalMovesSwitch.isOn,
            sound: soundSwitch.isOn
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppSettings.shared.synchronize()
    }
}
