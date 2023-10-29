import UIKit

private enum LetterKeyViewConst {
    static let newButtonFrame = CGRect(origin: .zero, size: .init(width: 36, height: 42))
    static var shadowImage: UIImageView {
        let img = UIImage(named: "bottom-shadow")
        let view = UIImageView(image: img)
        return view
    }
}

private extension UIView {
    static func newV(frame: CGRect) -> UIView {
        /// background
        let newView = UIView(frame: frame)
        newView.backgroundColor = .clear
        newView.layer.cornerRadius = Constants.keyCornerRadius
        return newView
    }
}

extension UIImage {
    private var primaryFontSize: CGFloat {
        if UIDevice.isPhone {
            if UIScreen.isPortrait {
                return 25.5
            } else {
                return 16.0
            }
        } else {
            return 30.0
        }
    }
    
    private var secondaryFontSize: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if UIScreen.isPortrait {
                return 12.0
            } else {
                return 16.0
            }
        } else {
            return 16.0
        }
    }
    
    private var primaryWeight: UIFont.Weight {
        UIDevice.current.userInterfaceIdiom == .phone ? .light : .light
    }
    
    func lettersToImage(_ letters: [LetterInFrame]) -> UIImage? {
        let fontSize = primaryFontSize
        let textColor: UIColor = ColorManager.shared.label
        let textFont = UIFont.systemFont(ofSize: fontSize, weight: primaryWeight)
        let shadow = LetterKeyViewConst.shadowImage
        let scale: CGFloat = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        
        letters.forEach { letter in
            let oXY = letter.frame.origin
            let inSize = letter.frame.size
            shadow.frame.origin = letter.frame.origin

            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            let textFontAttributes = [
                NSAttributedString.Key.font: textFont,
                NSAttributedString.Key.foregroundColor: textColor,
                NSAttributedString.Key.paragraphStyle: style,
                ] as [NSAttributedString.Key: Any]
            let selfRect = CGRect(origin: .init(x: 0, y: 0), size: self.size)
            self.draw(in: selfRect)

            /// text
            let newPoint: CGPoint = .init(x: oXY.x + 0.5, y: oXY.y + inSize.height/2 - fontSize/2 - Constants.keyVerticalSizeCorrector)
            let rect = CGRect(origin: newPoint, size: inSize)
            let shadowY = rect.maxY - shadow.frame.height - 5
            let shadowRect = CGRect(origin: .init(x: newPoint.x + 2, y: shadowY), size: .init(width: inSize.width - 4, height: 8))
            letter.letter.draw(in: rect, withAttributes: textFontAttributes)
            shadow.drawHierarchy(in: shadowRect, afterScreenUpdates: true)
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func imageBkgForText(from frames: [CGRect]) -> UIImage? {
        let scale: CGFloat = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)

        let selfRect = CGRect(origin: .zero, size: self.size)
        self.draw(in: selfRect)
        
        let newView = UIView.newV(frame: LetterKeyViewConst.newButtonFrame)
        let popupBkgColor = ColorManager.shared.popupBackground
        newView.backgroundColor = popupBkgColor
        
        frames.forEach { rect in
            let oXY = rect.origin
            let inSize = rect.size
            let newRect = CGRect(origin: CGPoint(x: oXY.x + Constants.keyHorizontalPadding, y: oXY.y + Constants.keyVerticalPadding), size: .init(width: inSize.width - 2 * Constants.keyHorizontalPadding + 0.5, height: inSize.height - 2 * Constants.keyVerticalSizeCorrector))
            
            newView.frame = newRect
            newView.drawHierarchy(in: newRect, afterScreenUpdates: true)
        }
        
        /// background
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

extension UIImage {

    static func initWithPixelSize(size: CGSize, filledWithColor color: UIColor = UIColor.clear, opaque: Bool = false) -> UIImage? {
        return initWithSize(size: size, filledWithColor: color, scale: 1.0, opaque: opaque)
    }

    static func initWithSize(size: CGSize, filledWithColor color: UIColor = UIColor.clear, scale: CGFloat = 0.0, opaque: Bool = false) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        color.set()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
