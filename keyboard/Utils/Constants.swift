//
//  Constants.swift
//

import UIKit

final class Constants {
  
    static let keySlotMultiplier: CGFloat = 1.0 / 11.0
    static let keyVerticalPadding: CGFloat = 5.0
    static let keyVerticalSizeCorrector: CGFloat = 6.0
    static let popupViewOffsetY: CGFloat = 8.0
    static let keyboardTopPadding: CGFloat = 3.0
    static let keyHorizontalPadding: CGFloat = 3.0
    static let keyShadowOffset: CGFloat = 0.75
    static let keyCornerRadius: CGFloat = 5.0
  
    static let longPressDelay: Double = 0.5
    static let subLettersSpacing: CGFloat = 2.0
    static let deletionLoopDelay: Double = 0.125
    static let doubleTapDelay: Double = 0.150
  
    static let popupHideDelay: Double = 0.050
    
    static let keyboardWideWidth: CGFloat = 528
    
    static var keyboardWidth: CGFloat {
        min(UIScreen.main.bounds.width, keyboardWideWidth)
    }
    
    static var keyboardLeftOffset: CGFloat {
        (UIScreen.main.bounds.width - keyboardWideWidth) / 2
    }
    
    static var keyboardRightOffset: CGFloat {
        (UIScreen.main.bounds.width - keyboardWideWidth) / 2
    }
    
    static var popupStackVerticalOffset: CGFloat {
        UIScreen.isPortrait ? keyVerticalPadding : 2
    }
}


enum ViewSize {
    static var suggestionsHeight: CGFloat {
        44
    }
    
    static var rowHeight: CGFloat {
      if UIDevice.isPhone {
        if UIScreen.isPortrait {
          return 54.0
        } else {
          return 40.0
        }
      } else {
        if UIScreen.isPortrait {
          return 70.0
        } else {
          return 70.0
        }
      }
    }
    
    static var bottomRowHeight: CGFloat {
        if UIDevice.isPhone {
            if UIScreen.isPortrait {
                return 52.0
            } else {
                return 40.0
            }
        } else {
            if UIScreen.isPortrait {
                return 70.0
            } else {
                return 70.0
            }
        }
    }
}
