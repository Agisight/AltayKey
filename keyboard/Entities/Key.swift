//
//  Key.swift
//  keyboard
//
//  Created by Steve Gigou on 2020-05-04.
//  Copyright © 2020 Novesoft. All rights reserved.
//

import UIKit


/// A key set and its representing view.
class Key {
    
    enum Kind {
        case letter, shift, delete, alt, next, space, enter
            
        var isModifier: Bool {
            self == .shift || self == .alt || self == .next
        }
    }
  
    enum State {
        case off, on, locked
    
        var isActive: Bool {
            self != .off
        }
    
        mutating func toggle() {
            switch self {
            case .on, .locked:
                self = .off
            case .off:
                self = .on
            }
        }
    }
  
    /// List of characters the view should display.
    let set: KeyCharacterSet
  
    /// View that will display the characters of the set.
    var alt: State
    
    var width: Int = 0
    
    init(set: KeyCharacterSet, alt: State, width: Int = 0) {
        self.set = set
        self.alt = alt
        self.width = width
    }
    
    var currentLabelText: String? {
        return set.letter(forShiftState: KeyboardState.shiftState, andAltState: alt)
    }
}
