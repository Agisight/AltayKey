//
//  KeySetFactory.swift
//  ibepo
//  KomiKeyboard
//
//  Created by Steve Gigou on 2020-05-04.
//  Edited by Aleksei Ivanov on 2020-10-17
//  Copyright © 2020 Novesoft. All rights reserved.
//  Copyright © 2020 majbyr.com. All rights reserved.
//

import UIKit
import AudioToolbox

/// Represents a tap on the keyboard. It has two times more columns than the KeySet.
typealias KeypadCoordinate = (row: Int, col: Int)


// MARK: - KeyGestureRecognizerDelegate

protocol KeyGestureRecognizerDelegate: AnyObject {
    func touchDown(at keypadCoordinate: KeypadCoordinate, with touch: UITouch)
    func touchMoved(to keypadCoordinate: KeypadCoordinate, with touch: UITouch)
    func touchUp(at keypadCoordinate: KeypadCoordinate, with touch: UITouch)
    func toEndTouch()
  
}


// MARK: - KeyGestureRecognizer

final class KeyGestureRecognizer: UIGestureRecognizer {
  
  private weak var customDelegate: KeyGestureRecognizerDelegate?
  
  private let defaultCoordinate = KeyCoordinate(row: 0, col: 1)
  
  // MARK: Life cycle
  
  convenience init(delegate: KeyGestureRecognizerDelegate) {
    self.init()
    customDelegate = delegate
  }
  
  // MARK: Touches
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesBegan(touches, with: event)
    for touch in touches {
      if let coordinates = findCoordinates(for: touch) {
        customDelegate?.touchDown(at: coordinates, with: touch)
      }
    }
    AudioServicesPlaySystemSound(1104)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesMoved(touches, with: event)
    
    guard let view = self.view, let touched = touches.first else {
        return
    }
    
    let loc = touched.location(in: view)
    guard view.bounds.contains(loc) else {
        customDelegate?.toEndTouch()
        return
    }
    
    for touch in touches {
      if let coordinates = findCoordinates(for: touch) {
        customDelegate?.touchMoved(to: coordinates, with: touch)
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesEnded(touches, with: event)
    for touch in touches {
      if let coordinates = findCoordinates(for: touch) {
        customDelegate?.touchUp(at: coordinates, with: touch)
      }
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesCancelled(touches, with: event)
    for touch in touches {
      if let coordinates = findCoordinates(for: touch) {
        customDelegate?.touchUp(at: coordinates, with: touch)
      }
    }
  }
  
  // MARK: Calculations
  
  private func findCoordinates(for touch: UITouch) -> KeypadCoordinate? {
    let location = touch.location(in: view)
    if !(view?.bounds.contains(location) ?? true) {
        return nil
    }
    let row = findRow(for: touch)
    let col = findCol(for: touch, in: row)
    return KeypadCoordinate(row: row, col: col)
  }
  
  private func findRow(for touch: UITouch) -> Int {
    guard let view = self.view else {
      UniversalLogger.debug("Touch view not found.")
      return 3
    }
    let location = touch.location(in: view)
    return findPosition(location: location.y, size: view.frame.height, chunkAmount: 4)
  }
  
  private func findCol(for touch: UITouch, in row: Int) -> Int {
    guard let view = self.view else {
      UniversalLogger.debug("Touch view not found.")
      return 0
    }
    let location = touch.location(in: view)
    return findPosition(location: location.x, size: view.frame.width, chunkAmount: 22)
  }
  
  private func findPosition(location: CGFloat, size: CGFloat, chunkAmount: Int) -> Int {
    let chunkSize = size / CGFloat(chunkAmount)
    let chunk = Int(location / chunkSize)
    return min (chunk, chunkAmount - 1)
  }
  
}
