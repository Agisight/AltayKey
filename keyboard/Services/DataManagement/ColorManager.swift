//
//  ColorManager.swift
//  keyboard
//

import UIKit

extension UIUserInterfaceStyle: CaseIterable {
    public static var allCases: [UIUserInterfaceStyle] = [unspecified, .light, .dark]
}

final class ColorManager {

    static let shared = ColorManager()

    private init() {}
    
    var keyboardAppearance: UIUserInterfaceStyle = .unspecified {
        didSet {
            colorAppearance = keyboardAppearance
            if oldValue == keyboardAppearance { return }
            NotificationCenter.default.post(name: .keyboardAppearanceDidChange, object: nil)
        }
    }
  
    var systemAppearance: UIUserInterfaceStyle = .unspecified {
        didSet {
            colorAppearance = systemAppearance
            if oldValue == systemAppearance { return }
            NotificationCenter.default.post(name: .keyboardAppearanceDidChange, object: nil)
        }
    }
  
    private var colorAppearance: UIUserInterfaceStyle = .unspecified
  
    var mainColor: UIColor {
        .systemBlue
    }
  
    var label: UIColor {
        colorAppearance == .dark ? .white : .black
    }
  
    var testColor: UIColor {
        if colorAppearance == .dark {
            return .red
        } else {
            return .green
        }
    }
    
    var shadowColor: UIColor {
        if colorAppearance == .dark {
            return .black
        } else {
            return .black.withAlphaComponent(1)
        }
    }
    
    var popupBackground: UIColor {
        if colorAppearance == .dark {
            return UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1)
        } else {
            return .white
        }
    }
    
    var background: UIColor {
        if colorAppearance == .dark {
            return UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1)
        } else {
            return .white
        }
    }
    
    var specialBackground: UIColor {
        if colorAppearance == .dark {
            return UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.22)
        } else {
            return UIColor(red: 180.0/255, green: 183.0/255, blue: 191.0/255, alpha: 1)
        }
    }
}

extension UIColor {

    func newWithoutAlpha(overlaped: UIColor) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        var oRed: CGFloat = 0
        var oGreen: CGFloat = 0
        var oBlue: CGFloat = 0
        var oAlpha: CGFloat = 0

        getRed(&oRed, green: &oGreen, blue: &oBlue, alpha: &oAlpha)
        
        let opacity = oAlpha

        let flattenedColor = UIColor(
            red: opacity * red + (1 - opacity) * oRed,
            green: opacity * green + (1 - opacity) * oGreen,
            blue: opacity * blue + (1 - opacity) * oBlue,
            alpha: 1)
        
        return flattenedColor
    }
    
    
    func solidColorWhenOverlayed(by overlayColor: UIColor) -> UIColor {
        // Helper function to clamp values to range (0.0 ... 1.0)
        func clampValue(_ v: CGFloat) -> CGFloat {
            guard v > 0 else { return  0 }
            guard v < 1 else { return  1 }
            return v
        }

        var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))

        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        overlayColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        // Make sure the input colors are well behaved
        // Components should be in the range (0.0 ... 1.0)
        // This to compensate for any "bad" colors = colors which have component values out of range
        r1 = clampValue(r1)
        g1 = clampValue(g1)
        b1 = clampValue(b1)

        r2 = clampValue(r2)
        g2 = clampValue(g2)
        b2 = clampValue(b2)
        a2 = clampValue(a2)

        return UIColor(  red  : r1 * (1 - a2) + r2 * a2,
                         green: g1 * (1 - a2) + g2 * a2,
                         blue : b1 * (1 - a2) + b2 * a2,
                         alpha: 1)
    }

}
