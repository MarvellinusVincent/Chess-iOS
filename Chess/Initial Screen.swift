//
//  Initial Screen.swift
//  Chess
//
//  Created by Marvellinus Vincent on 5/24/24.
//

import Foundation
import UIKit

class InitialScreen: UIViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ViewController {
            if segue.identifier == "SinglePlayer" {
                destinationVC.singlePlayer = true
            } else if segue.identifier == "Pass&Play" {
                destinationVC.singlePlayer = false
            }
        }
    }
    @IBAction func unwind(segue: UIStoryboardSegue) {
    }
}
