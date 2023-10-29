//
//  PopupView.swift
//  ibepo
//  Komikeyboard
//
//  Created by Steve Gigou on 2020-05-29.
//  Copyright © 2020 Novesoft. All rights reserved.
//

import UIKit

// MARK: - PopupView

/// Displays the key letter and its subletters.
final class PopupView: UIView {
  
    private let tailView = UIView()
    private let popupView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    private let letterStackView = UIStackView(arrangedSubviews: [])
    private var coord: KeyCoordinate?
  
    private var hideDelayTimer = Timer()
  
  // MARK: Life cycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
  }
  
    private lazy var lightBlurView: UIVisualEffectView = {
        let effect = Effect.commonEffect
        effect.backgroundColor = ColorManager.shared.popupBackground
        effect.layer.cornerRadius = Constants.keyCornerRadius
        return effect
    }()
    
  // MARK: Setup
  
  private func setupViews() {
    popupView.addSubview(lightBlurView)
    popupView.clipsToBounds = true
    NSLayoutConstraint.activate([
        lightBlurView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
        lightBlurView.centerYAnchor.constraint(equalTo: popupView.centerYAnchor),
        lightBlurView.widthAnchor.constraint(equalTo: popupView.widthAnchor),
        lightBlurView.heightAnchor.constraint(equalTo: popupView.heightAnchor),
    ])
    setupPopupView()
    setupTailView()
    setupLetterStackView()
    hidePopup()
    popupView.isHidden = true
  }
    
    // Create a CAShapeLayer
    private lazy var shapeLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.green.withAlphaComponent(0.6).cgColor // ColorManager.shared.popupBackground.withAlphaComponent(0.7).cgColor
        shape.shadowColor = UIColor.black.cgColor
        shape.shadowOffset = CGSize(width: 0, height: Constants.keyShadowOffset)
        shape.shadowRadius = 2 * Constants.keyShadowOffset
        shape.shadowOpacity = 0.25
        shape.lineWidth = 1.0
        shape.path = nil
        self.layer.addSublayer(shape)
        return shape
    }()
    
    func setup() {
//        shapeLayer.path = createBezierPath().cgPath
    }

  
    private func setupTailView() {
        tailView.backgroundColor = ColorManager.shared.popupBackground//.withAlphaComponent(0.5)
        popupView.backgroundColor = ColorManager.shared.popupBackground
        addSubview(tailView)
    }
  
  private func setupPopupView() {
    popupView.backgroundColor = .clear // ColorManager.shared.popupBackground
    popupView.layer.cornerRadius = Constants.keyCornerRadius
    popupView.layer.shadowColor = UIColor.black.cgColor
    popupView.layer.shadowOffset = CGSize(width: 0, height: Constants.keyShadowOffset)
    popupView.layer.shadowRadius = 2 * Constants.keyShadowOffset
    popupView.layer.shadowOpacity = 0.25
    popupView.layer.shadowPath = .none
    addSubview(popupView)
  }
  
  private func updatePopupViewShadowPath() {
    popupView.layer.shadowPath = UIBezierPath(roundedRect: popupView.bounds, cornerRadius: Constants.keyCornerRadius).cgPath
  }
  
  private func setupLetterStackView() {
    letterStackView.distribution = .fillEqually
    letterStackView.spacing = Constants.keyHorizontalPadding * 2
    letterStackView.translatesAutoresizingMaskIntoConstraints = false
    popupView.addSubview(letterStackView)
    letterStackView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: Constants.popupStackVerticalOffset).isActive = true
    letterStackView.rightAnchor.constraint(equalTo: popupView.rightAnchor, constant: -Constants.keyHorizontalPadding).isActive = true
    letterStackView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -Constants.popupStackVerticalOffset).isActive = true
    letterStackView.leftAnchor.constraint(equalTo: popupView.leftAnchor, constant: Constants.keyHorizontalPadding).isActive = true
  }
  
  func updateAppearance() {
    tailView.backgroundColor = ColorManager.shared.background
    popupView.backgroundColor = ColorManager.shared.background
  }
  
  // MARK: Actions
  
  func hidePopup() {
    hideDelayTimer.invalidate()
    hideDelayTimer = Timer(timeInterval: Constants.popupHideDelay, target: self, selector: #selector(hidePopupParts), userInfo: nil, repeats: false)
    hideDelayTimer.tolerance = Constants.popupHideDelay / 2
    RunLoop.current.add(hideDelayTimer, forMode: .common)
  }
  
  @objc func hidePopupParts() {
    DispatchQueue.main.async { [weak self] in
        self?.tailView.isHidden = true
        self?.popupView.isHidden = true
//        self?.shapeLayer.isHidden = true
    }
  }
  
    func showPopup(for key: Key, at coord: KeyCoordinate) {
        setup()
        self.coord = coord
        let offsetY = coord.row == 0 ? Constants.popupViewOffsetY : -Constants.popupViewOffsetY/2
        hideDelayTimer.invalidate()
        let rowY = frame.height / 4 * CGFloat(coord.row - 1)
        let offset: Int = coord.row == 2 ? 1 : 0
        let oX = frame.width * Constants.keySlotMultiplier * CGFloat(coord.col + offset)
        tailView.frame = CGRect(
            x: oX + Constants.keyHorizontalPadding + Constants.keyCornerRadius,
            y: rowY + frame.height / 4 + Constants.keyboardTopPadding,
            width: frame.width * Constants.keySlotMultiplier - 2 * Constants.keyHorizontalPadding - 2 * Constants.keyCornerRadius,
            height: Constants.keyVerticalPadding
        )
        
        let popupTopInset: CGFloat = (coord.row == 0 ? 4 : 0)
        
        popupView.frame = CGRect(
            x: oX,
            y: rowY + offsetY + popupTopInset + Constants.keyboardTopPadding,
            width: frame.width * Constants.keySlotMultiplier,
            height: ViewSize.rowHeight - offsetY - popupTopInset
        )
        updatePopupViewShadowPath()
        tailView.isHidden = false
        popupView.isHidden = false
        let currentLetter = key.currentLabelText ?? "�"
        generateLetterStackViewList(for: [currentLetter])
  }
  
  func showPopupWithSubLetters(for key: Key, shiftState: Key.State, altState: Key.State) {
    hideDelayTimer.invalidate()
    guard let coord = coord else {
        return UniversalLogger.error("PopupView should have a coord.")
    }
    let offsetY = coord.row == 0 ? Constants.popupViewOffsetY : -Constants.popupViewOffsetY/2
    let rowY = frame.height / 4 * CGFloat(coord.row - 1)
    let offset: Int = coord.row == 2 ? 1 : 0
    let oX = frame.width * Constants.keySlotMultiplier * CGFloat(coord.col + offset)
    
    tailView.frame = CGRect(
      x: oX + Constants.keyHorizontalPadding + Constants.keyCornerRadius,
        y: rowY + frame.height / 4 + Constants.keyboardTopPadding,
      width: frame.width * Constants.keySlotMultiplier - 2 * Constants.keyHorizontalPadding - 2 * Constants.keyCornerRadius,
      height: Constants.keyVerticalPadding
    )
    let keyLetter = key.set.letter(forShiftState: shiftState, andAltState: altState)
    let letters = key.set.subLetters(forShiftState: shiftState, andAltState: altState)
    var beforeLetters = 0
    var afterLetters = 0
    var keyLetterFound = false
    for letter in letters {
      if letter == keyLetter {
        keyLetterFound = true
        continue
      }
      if keyLetterFound {
        afterLetters += 1
      } else {
        beforeLetters += 1
      }
    }
    
    let popupTopInset: CGFloat = (coord.row == 0 ? 4 : 0)
    
    let commonWidth = frame.width * Constants.keySlotMultiplier
    popupView.frame = CGRect(
        x: oX - CGFloat(beforeLetters) * commonWidth,
      y: rowY + offsetY + popupTopInset + Constants.keyboardTopPadding,
      width: commonWidth * CGFloat(beforeLetters + 1 + afterLetters),
      height: ViewSize.rowHeight - offsetY - popupTopInset
    )
    updatePopupViewShadowPath()
    tailView.isHidden = false
    popupView.isHidden = false
    generateLetterStackViewList(for: letters)
    select(subLetter: keyLetter)
  }
  
  // MARK: Letter stack view
  
    func select(subLetter: String) {
        for case let label as UILabel in letterStackView.arrangedSubviews {
            label.updateLabel(subLetter: subLetter)
        }
    }
  
    private func generateLetterStackViewList(for letters: [String]) {
        letterStackView.removeAllArrangedSubviews()
        letters.forEach({
            letterStackView.addArrangedSubview(generateLetterView(for: $0))
        })
    }
  
    private func generateLetterView(for letter: String) -> UILabel {
        let label = UILabel()
        label.font = .subLetterFont
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = letter
        label.backgroundColor = UIColor {
            $0.userInterfaceStyle == .dark ? ColorManager.shared.popupBackground : .white
        }
        label.layer.cornerRadius = Constants.keyCornerRadius
        label.clipsToBounds = true
        return label
    }
}

private extension UIBezierPath {
    static func createBezierPath(size: CGSize, isShort: Bool = true, ls: Int = 1, rs: Int = 2) -> UIBezierPath {
        let left = CGFloat(ls)
        let right = CGFloat(rs + 1)
        let sHeight = 2 * ViewSize.rowHeight - 2 * Constants.keyVerticalPadding
        let sWidth = size.width * Constants.keySlotMultiplier
        let radius = Constants.keyCornerRadius
        let rad: CGFloat = 2
        // create a new path
        let path = UIBezierPath()

        // starting point for the path (bottom left)
        path.move(to: CGPoint(x: rad, y: sHeight - radius))

        // *********************
        // ***** Left side *****
        // *********************

        // segment 1: line
        var curY = sHeight / 2 + radius + radius
        path.addLine(to: CGPoint(x: rad, y: curY))

        if ls > 0 {
            let x = -sWidth * left + radius + rad
            // segment 2: curve
            path.addCurve(to: CGPoint(x:  -rad, y: curY - radius), // ending point
                controlPoint1: CGPoint(x: rad, y: curY),
                controlPoint2: CGPoint(x: rad, y: curY - radius))

            path.addLine(to: CGPoint(x: x - rad, y: curY - radius))
            
            // segment 2.5: arc
            path.addArc(
                withCenter: CGPoint(x: x - rad, y: curY - 2 * radius),
                radius: radius,
                startAngle: 3 * .pi / 2, // straight up
                endAngle: .pi, // 0 radians = straight right
                clockwise: true)
            
            curY = isShort ? radius + rad : 0
            
            // segment 3: line
            path.addLine(to: CGPoint(x: x - rad - radius, y: curY + radius))

            // *********************
            // ****** Top side *****
            // *********************

            // segment 4: arc
            path.addArc(withCenter: CGPoint(x: x - rad, y: curY + radius), // center point of circle
                radius: radius, // this will make it meet our path line
                startAngle: .pi, // π radians = 180 degrees = straight left
                endAngle: CGFloat(3) * .pi / 2, // 3π/2 radians = 270 degrees = straight up
                clockwise: true) // startAngle to endAngle goes in a clockwise direction
        } else {
            // segment 7: line
//            curY = sHeight / 2 + 2 * radius
//            path.addLine(to: CGPoint(x: sWidth + radius + rad, y: curY - 2 * radius))
//            // segment 8: curve
//            path.addCurve(to: CGPoint(x: sWidth - rad, y: curY + rad), // ending point
//                controlPoint1: CGPoint(x: sWidth + radius, y: curY - radius),
//                controlPoint2: CGPoint(x: sWidth - rad, y: curY - radius))
            
            // segment 2: curve
            path.addCurve(to: CGPoint(x: -radius - rad, y: curY - 2 * radius), // ending point aka top left point of curve
                controlPoint1: CGPoint(x: rad, y: curY - radius), // middle left curve
                controlPoint2: CGPoint(x: -radius - rad, y: curY - radius)) // middle left curve

            curY = isShort ? radius + rad : 0
            // segment 3: line
            path.addLine(to: CGPoint(x: -radius - rad, y: curY + radius))

            // *********************
            // ****** Top side *****
            // *********************

            // segment 4: arc
            path.addArc(withCenter: CGPoint(x: -rad, y: curY + radius), // center point of circle
                radius: radius, // this will make it meet our path line
                startAngle: .pi, // π radians = 180 degrees = straight left
                endAngle: CGFloat(3) * .pi / 2, // 3π/2 radians = 270 degrees = straight up
                clockwise: true) // startAngle to endAngle goes in a clockwise direction
        }
        
        if rs > 0 {
            let x = sWidth * right - radius - rad
            curY = isShort ? radius + rad : 0
            // segment 5: line
            path.addLine(to: CGPoint(x: x, y: curY))

            // segment 6: arc
            path.addArc(
                withCenter: CGPoint(x: x, y: curY + radius),
                radius: radius,
                startAngle: 3 * .pi / 2, // straight up
                endAngle: CGFloat(0), // 0 radians = straight right
                clockwise: true)

            // *********************
            // ***** Right side ****
            // *********************

            // segment 7: line
            curY = sHeight / 2 + 2 * radius
            path.addLine(to: CGPoint(x: x + radius, y: curY - 2 * radius))
            
            // segment 7.5: arc
            path.addArc(
                withCenter: CGPoint(x: x, y: curY - 2 * radius),
                radius: radius,
                startAngle: 0, // straight up
                endAngle: .pi/2, // 0 radians = straight right
                clockwise: true)

            // segment 8: curve
            path.addCurve(to: CGPoint(x: sWidth - rad, y: curY), // ending point
                controlPoint1: CGPoint(x: sWidth, y: curY - radius),
                controlPoint2: CGPoint(x: sWidth - rad, y: curY - radius))
            
        } else {
            curY = isShort ? radius + rad : 0
            path.addLine(to: CGPoint(x: sWidth + rad, y: curY))

            // segment 6: arc
            path.addArc(
                withCenter: CGPoint(x: sWidth + rad, y: curY + radius),
                radius: radius,
                startAngle: 3 * .pi / 2, // straight up
                endAngle: CGFloat(0), // 0 radians = straight right
                clockwise: true)

            // *********************
            // ***** Right side ****
            // *********************

            // segment 7: line
            curY = sHeight / 2 + 2 * radius
            path.addLine(to: CGPoint(x: sWidth + radius + rad, y: curY - 2 * radius))
            // segment 8: curve
            path.addCurve(to: CGPoint(x: sWidth - rad, y: curY + rad), // ending point
                controlPoint1: CGPoint(x: sWidth + radius, y: curY - radius),
                controlPoint2: CGPoint(x: sWidth - rad, y: curY - radius))
        }
        
        
        
        // segment 9: line
        path.addLine(to: CGPoint(x: sWidth - rad, y: sHeight - radius))
        
        // segment 10: arc
        path.addArc(withCenter: CGPoint(x: sWidth - radius - rad, y: sHeight - radius), // center point of circle
            radius: radius, // this will make it meet our path line
            startAngle: 0, // π radians = 180 degrees = straight left
            endAngle: .pi / 2, // 3π/2 radians = 270 degrees = straight up
            clockwise: true) // startAngle to endAngle goes in a clockwise direction

        // segment 11: line
        path.addLine(to: CGPoint(x: radius + rad, y: sHeight))
        
        // segment 12: arc
        path.addArc(
            withCenter: CGPoint(x: radius + rad, y: sHeight - radius),
            radius: radius,
            startAngle: 3 * .pi / 2, // straight up
            endAngle: .pi, // 0 radians = straight right
            clockwise: true
        )
        
        // *********************
        // **** Bottom side ****
        // *********************

        // segment 10: line
        path.close() // draws the final line to close the path

        path.apply(.init(translationX: 0, y: 2 * radius))
        return path
    }
}

extension UIFont {
    static var subLetterFont: UIFont {
        let fontSize: CGFloat
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            fontSize = UIScreen.isPortrait ? 50 : 50
        case .phone:
            fontSize = UIScreen.isPortrait ? 30 : 24
        default:
            fontSize = UIDevice.isPhone ? 30 : 24
        }
        
        return .systemFont(ofSize: fontSize, weight: .light)
    }
}

extension UILabel {
    func updateLabel(subLetter: String) {
        if self.text == subLetter {
            self.font = .subLetterFont
            self.textColor = UIColor {
                $0.userInterfaceStyle == .dark ? ColorManager.shared.label : .black
            }

            self.backgroundColor = ColorManager.shared.mainColor
            self.textColor = .white
        } else {
            self.font = .subLetterFont
            self.textColor = UIColor {
                $0.userInterfaceStyle == .dark ? ColorManager.shared.label : .black
            }
            
            self.backgroundColor = ColorManager.shared.popupBackground
        }
    }
}
