//
//  SymbolsManager.swift
//  keyboard
//
//  Created by Steve Gigou on 2020-05-06.
//  Copyright © 2020 Novesoft. All rights reserved.
//

import UIKit

final class SymbolsManager {
  
  static private func getImage(named name: String) -> UIImage {
    if #available(iOS 13, *) {
      return UIImage(systemName: name) ?? UIImage()
    } else {
      return UIImage(named: name) ?? UIImage()
    }
  }
  
    enum ImageKind {
        case returnImage
        case globe
        case delete
        case shift
        case shiftFill
        case shiftAlt
        case shiftAltFill
        case option
    }
    
    static func image(kind: ImageKind) -> UIImage {
        let imageName: String
        switch kind {
        case .returnImage:
            imageName = "return"
        case .globe:
            imageName = "globe"
        case .delete:
            imageName = "delete.left"
        case .shift:
            imageName = "shift"
        case .shiftFill:
            imageName = "shift.fill"
        case .shiftAlt, .shiftAltFill:
            imageName = "#+="
        case .option:
            imageName = "option"
        }
        
        return SymbolsManager.getImage(named: imageName)
    }
}
