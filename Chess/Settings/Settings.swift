//
//  Settings.swift
//  Chess
//
//  Created by Marvellinus Vincent on 5/27/24.
//

import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    private let defaults = UserDefaults.standard

    func set<T>(_ value: T?, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func synchronize() {
        defaults.synchronize()
    }

    func value<T>(forKey key: String) -> T? {
        return defaults.value(forKey: key) as? T
    }
}

class AppSettings {
    static let shared = AppSettings()
    private let settingsManager = SettingsManager.shared

    var boardTheme: String? {
        get {
            return settingsManager.value(forKey: "boardTheme")
        }
        set {
            settingsManager.set(newValue, forKey: "boardTheme")
            settingsManager.synchronize()
        }
    }

    var soundEnabled: Bool? {
        get {
            return settingsManager.value(forKey: "soundEnabled")
        }
        set {
            settingsManager.set(newValue, forKey: "soundEnabled")
            settingsManager.synchronize()
        }
    }
    
    var showLegalMoves: Bool? {
        get {
            return settingsManager.value(forKey: "showLegalMoves")
        }
        set {
            settingsManager.set(newValue, forKey: "showLegalMoves")
            settingsManager.synchronize()
        }
    }
    
    var highlightMoves: Bool? {
        get {
            return settingsManager.value(forKey: "highlightMoves")
        }
        set {
            settingsManager.set(newValue, forKey: "highlightMoves")
            settingsManager.synchronize()
        }
    }
        
    var undo: Bool? {
        get {
            return settingsManager.value(forKey: "undo")
        }
        set {
            settingsManager.set(newValue, forKey: "undo")
            settingsManager.synchronize()
        }
    }
    
    func synchronize() {
        settingsManager.synchronize()
    }
}
