//
//  HapticsManager.swift
//  Spotify
//
//  Created by Anthony Kim on 3/15/21.
//

import Foundation
import UIKit

// when you declare a class as being final, no other class can inherit from it
// this means they can't override your methods in order to change your behavior.
// They need to use your class the way its was wrtitten.

final class HapticsManager {
    static let shared = HapticsManager()
    
    private init() {}
    
    public func vibrateForSelection() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type) //so the caller can specify what the type is
        }
    }
}
