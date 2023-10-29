//
//  KeySet.swift
//  keyboard
//
//  Created by Steve Gigou on 2020-05-04.
//  Copyright © 2020 Novesoft. All rights reserved.
//

import Foundation
import UIKit


// MARK: - typealias KeyCoordinate

typealias KeyCoordinate = (row: Int, col: Int)


// MARK: - typealias Row

typealias Row = [Key]

struct LetterInFrame {
    let letter: String
    let frame: CGRect
}

extension Row {
    /// TODO: do it if changes:
    /// – size
    /// – shift state
    /// – alt state
    /// – orientation
    fileprivate func allKeys(targetSize: CGSize, origin: CGPoint) -> [LetterInFrame] {
        let width = targetSize.width / CGFloat(count)
        let letters = enumerated().map({ item -> LetterInFrame in
            let letter = item.element.currentLabelText ?? ""
            let frame = CGRect(origin: .init(x: origin.x + CGFloat(item.offset) * width, y: origin.y), size: CGSize(width: width, height: targetSize.height))
            
            let letterInFrame = LetterInFrame(letter: letter, frame: frame)
            item.element.width = Int(width)
            return letterInFrame
        })

        return letters
    }
        
    fileprivate func allKeysFrames(targetSize: CGSize, origin: CGPoint) -> [CGRect] {
        let width = targetSize.width / CGFloat(count)
        let frames = enumerated().map { item -> CGRect in
            let frame = CGRect(origin: .init(x: origin.x + CGFloat(item.offset) * width, y: origin.y), size: CGSize(width: width, height: targetSize.height))
            return frame
        }
        
        return frames
    }
}

class KeysImages {
    
    static let shared = KeysImages()
    
    enum ImageKind: CaseIterable {
        static let darkPrefix = "dark"
        static let lightPrefix = "light"
        static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        case background
        case keysImage
        case lowercaseKeysImage
        case altKeysImage
        case altShiftKeysImage
        
        private var fileName: String {
            let storedBackgroundName = "KeyboardStoredShadow.png"
            let storedKeysName = "KeyboardStoredKeys.png"
            let storedLowercaseKeysName = "KeyboardStoredLowercaseKeys.png"
            let storedAltKeysName = "KeyboardStoredAltKeys.png"
            let storedAltShiftKeysName = "KeyboardStoredAltShiftKeys.png"
            
            switch self {
            case .background:
                return storedBackgroundName
            case .keysImage:
                return storedKeysName
            case .lowercaseKeysImage:
                return storedLowercaseKeysName
            case .altKeysImage:
                return storedAltKeysName
            case .altShiftKeysImage:
                return storedAltShiftKeysName
            }
        }
        
        private var saveURL: URL? {
            switch self {
            case .background:
                return Self.documentsDirectory?.appendingPathComponent(Self.lightPrefix + fileName)
            case .keysImage:
                return Self.documentsDirectory?.appendingPathComponent(Self.lightPrefix + fileName)
            case .lowercaseKeysImage:
                return Self.documentsDirectory?.appendingPathComponent(Self.lightPrefix + fileName)
            case .altKeysImage:
                return Self.documentsDirectory?.appendingPathComponent(Self.lightPrefix + fileName)
            case .altShiftKeysImage:
                return Self.documentsDirectory?.appendingPathComponent(Self.lightPrefix + fileName)
            }
        }
        
        private var saveDarkURL: URL? {
            switch self {
            case .background:
                return Self.documentsDirectory?.appendingPathComponent(Self.darkPrefix + fileName)
            case .keysImage:
                return Self.documentsDirectory?.appendingPathComponent(Self.darkPrefix + fileName)
            case .lowercaseKeysImage:
                return Self.documentsDirectory?.appendingPathComponent(Self.darkPrefix + fileName)
            case .altKeysImage:
                return Self.documentsDirectory?.appendingPathComponent(Self.darkPrefix + fileName)
            case .altShiftKeysImage:
                return Self.documentsDirectory?.appendingPathComponent(Self.darkPrefix + fileName)
            }
        }
        
        func url(style: UIUserInterfaceStyle) -> URL? {
            switch style {
            case .dark:
                return saveDarkURL
            case .light, .unspecified:
                return saveURL
            default:
                return saveURL
            }
        }
    }
    
    var background: UIImageView?
    var keysImage: UIImageView?
    var lowercaseKeysImage: UIImageView?
    var altKeysImage: UIImageView?
    var altShiftKeysImage: UIImageView?
    
    func imageFor(alt: Key.State, shift: Key.State) -> UIImageView? {
        switch alt {
        case .on, .locked:
            switch shift {
            case .off:
                return altKeysImage
            case .on, .locked:
                return altShiftKeysImage
            }
        case .off:
            switch shift {
            case .off:
                return lowercaseKeysImage
            case .on, .locked:
                return keysImage
            }
        }
    }
    
    var onlyKeys: UIImageView? {
        switch KeyboardState.shiftState {
        case .on:
            return KeyboardState.altState == .on ? altShiftKeysImage : keysImage
        case .locked:
            return KeyboardState.altState == .on ? altKeysImage : keysImage
        case .off:
            return KeyboardState.altState == .on ? altKeysImage : lowercaseKeysImage
        }
    }
    
    func moveOirignTo(_ origin: CGPoint) {
        keysImage?.frame.origin = origin
        lowercaseKeysImage?.frame.origin = origin
        altKeysImage?.frame.origin = origin
        altShiftKeysImage?.frame.origin = origin
        background?.frame.origin = origin
    }
    
    func removeKeysImage() {
        altKeysImage?.removeFromSuperview()
        keysImage?.removeFromSuperview()
        lowercaseKeysImage?.removeFromSuperview()
        altShiftKeysImage?.removeFromSuperview()
        background?.removeFromSuperview()
    }
    
    private init() {
        refreshImages()
    }
    
    func refreshImages() {
        background = Self.storedImageView(kind: .background)
        keysImage = Self.storedImageView(kind: .keysImage)
        lowercaseKeysImage = Self.storedImageView(kind: .lowercaseKeysImage)
        altKeysImage = Self.storedImageView(kind: .altKeysImage)
        altShiftKeysImage = Self.storedImageView(kind: .altShiftKeysImage)
        
        if let bkg = background?.image {
            debugPrint(bkg.size)
        }
        
        
    }
    
    static private func stored(kind: ImageKind) -> UIImage? {
        let style = ColorManager.shared.keyboardAppearance
        guard let saveURL = kind.url(style: style) else {
            return nil
        }
        
        guard let imageData = try? Data(contentsOf: saveURL) else {
            print("Couldn't get image for \(kind)")
            return nil
        }
        
        return UIImage(data: imageData, scale: UIScreen.main.scale)
    }
    
    static func storedImageView(kind: ImageKind) -> UIImageView? {
        guard let image = Self.stored(kind: kind) else {
            return nil
        }
        
        return UIImageView(image: image)
    }
    
    static func clearData() {
        ImageKind.allCases.forEach { kind in
            UIUserInterfaceStyle.allCases.forEach { appearance in
                guard let url = kind.url(style: appearance) else {
                    return
                }
            
                try? FileManager.default.removeItem(at: url)
            }
        }
    }
    
    func save(imageKind: ImageKind, img: UIImage?) {
        
        guard let imgData = img?.pngData() else {
            print("No png data for a \(imageKind)")
            return
        }
        
        guard let url = imageKind.url(style: ColorManager.shared.keyboardAppearance) else {
            debugPrint("No url for \(imageKind)")
            return
        }
        
        do {
            try imgData.write(to: url)
        } catch let error {
            debugPrint(error)
            print("Unable to Write an Image Data to Disk for \(imageKind). URL: \(url)")
        }
        
        guard let image = img else {
            return
        }
        
        switch imageKind {
        case .background:
            self.background = UIImageView(image: image)
        case .keysImage:
            self.keysImage = UIImageView(image: image)
        case .lowercaseKeysImage:
            self.lowercaseKeysImage = UIImageView(image: image)
        case .altKeysImage:
            self.altKeysImage = UIImageView(image: image)
        case .altShiftKeysImage:
            self.altShiftKeysImage = UIImageView(image: image)
        }
    }
}

// MARK: - struct KeySet

struct KeySet {
  
    let rows: [Row]
      
    var keys: [Key] {
        rows.reduce(into: [Key]()) { result, currentRow in
            result.append(contentsOf: currentRow)
        }
    }
  
  // MARK: Key finding
  
    func key(at coordinate: KeyCoordinate) -> Key {
        let row = rows[coordinate.row]
        let key = row[safe: coordinate.col] ?? row.last!
        return key
    }
  
    
    func keysImage(for size: CGSize, altState: Key.State) -> KeysImages {
        KeysImages.clearData()
        let currentImages = KeysImages.shared
        switch altState {
        case .on, .locked:
            switch KeyboardState.shiftState {
            case .on, .locked:
                if currentImages.altShiftKeysImage != nil {
                    return currentImages
                }
            case .off:
                if currentImages.altKeysImage != nil {
                    return currentImages
                }
            }
        case .off:
            switch KeyboardState.shiftState {
            case .on, .locked:
                if currentImages.keysImage != nil {
                    return currentImages
                }
            case .off:
                if currentImages.lowercaseKeysImage != nil {
                    return currentImages
                }
            }
        }
        
        let sz = size
        let lineSize = CGSize(width: size.width, height: size.height / 3)
        
        let shiftKeyWidth = sz.width * KeypadView.Const.keyWidthMultiplier
        let returnKeyWidth = sz.width * KeypadView.Const.keyWidthMultiplier
        
        let lastRowTargetSize: CGSize = .init(width: lineSize.width - shiftKeyWidth - returnKeyWidth, height: lineSize.height)
        let lastRowOrigin: CGPoint = .init(x: shiftKeyWidth, y: 2 * lineSize.height)
            
        
        var image = UIImage.initWithSize(size: sz, scale: UIScreen.main.scale)!
        autoreleasepool {
            var letterFrames = rows[0].allKeys(targetSize: lineSize, origin: .init(x: 0, y: 0))
            letterFrames += rows[1].allKeys(targetSize: lineSize, origin: .init(x: 0, y: lineSize.height))
            letterFrames += rows[2].allKeys(targetSize: lastRowTargetSize, origin: lastRowOrigin)
            
            if let drawnImage = image.lettersToImage(letterFrames) {
                image = drawnImage
            }
        }
        
        if altState != .on {
            var background = UIImage.initWithSize(size: sz, scale: UIScreen.main.scale)!
            autoreleasepool {
                var frames = rows[0].allKeysFrames(targetSize: lineSize, origin: .init(x: 0, y: 0))
                frames += rows[1].allKeysFrames(targetSize: lineSize, origin: .init(x: 0, y: lineSize.height))
                frames += rows[2].allKeysFrames(targetSize: lastRowTargetSize, origin: lastRowOrigin)
                if let drawnImage = background.imageBkgForText(from: frames) {
                    background = drawnImage
                }
            }
            
            autoreleasepool {
                currentImages.save(imageKind: .background, img: background)
                
                switch KeyboardState.shiftState {
                case .on, .locked:
                    currentImages.save(imageKind: .keysImage, img: image)
                case .off:
                    currentImages.save(imageKind: .lowercaseKeysImage, img: image)
                }
            }
            return currentImages
        }
        
        guard currentImages.imageFor(alt: KeyboardState.altState, shift: KeyboardState.shiftState) == nil else {
            return currentImages
        }
        
        autoreleasepool {
            switch KeyboardState.shiftState {
            case .off:
                currentImages.save(imageKind: .altKeysImage, img: image)
            case .on, .locked:
                currentImages.save(imageKind: .altShiftKeysImage, img: image)
            }
        }
        return currentImages
    }
}

public extension Array {
    subscript(safe index: Int) -> Element? {
        (0 ..< count).contains(index) ? self[index] : nil
    }

    subscript(safe range: Range<Index>) -> ArraySlice<Element> {
        let startIndex = Swift.min(range.startIndex, self.endIndex)
        let endIndex = Swift.min(range.endIndex, self.endIndex)
        return self[startIndex ..< endIndex]
    }

    subscript(safe range: ClosedRange<Index>) -> ArraySlice<Element> {
        let startIndex = Swift.min(range.lowerBound, self.endIndex)
        let endIndex = Swift.min(range.upperBound, self.endIndex)
        return self[startIndex ... endIndex]
    }
}
