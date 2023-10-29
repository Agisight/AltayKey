//
//  KeypadViewController.swift

import UIKit

// MARK: - KeypadViewController

/// Key pad part of the input view.
final class KeypadViewController: UIViewController {
  
    weak var delegate: KeyboardActionProtocol?
    weak var switchDelegate: KeyboardSwitchProtocol?
  
    private let keyboardState = KeyboardState()
    private lazy var popupView: PopupView = {
        let newView = PopupView()
        newView.translatesAutoresizingMaskIntoConstraints = false
        let supView = view!
        supView.addSubview(newView)
        newView.topAnchor.constraint(equalTo: supView.topAnchor).isActive = true
        newView.rightAnchor.constraint(equalTo: supView.rightAnchor).isActive = true
        newView.bottomAnchor.constraint(equalTo: supView.bottomAnchor).isActive = true
        newView.leftAnchor.constraint(equalTo: supView.leftAnchor).isActive = true
        supView.bringSubviewToFront(newView)
        newView.hidePopup()
        return newView
    }()
  
    private var keySet: KeySet!
    private var pressedKeyView: KeyView?
    
    // MARK: Life cycle
  
    override func loadView() {
        view = KeypadView()
        (view as! KeypadView).switchDelegate = self
    }
  
    public func renderPopupView() {
        popupView.tag = 1
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
  
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
//        for key in self.keySet.keys {
//          key.view.updateAppearance()
//        }
        }
    }
  
    // MARK: Notifications
  
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppearanceDidChange), name: .keyboardAppearanceDidChange, object: nil)
    }
  
  @objc func keyboardAppearanceDidChange() {
      let view = self.view as! KeypadView
      view.updateAppearance()
      popupView.updateAppearance()
      self.loadKeySet()
  }
  
  // MARK: Update
  
    func textDocumentProxyWasUpdated() {
        keyboardState.textDocumentProxyWasUpdated()
    }
  
  // MARK: Loading
  
    private func loadKeySet() {
        let view = self.view as! KeypadView
        let factory = KeySetFactory()
        keySet = factory.generate()
        view.load(keySet: keySet)
        view.bringSubviewToFront(popupView)
    }
    
    private func reloadKeySet(newAltState: Key.State) {
        let view = self.view as! KeypadView
        view.reload3Rows(keySet: keySet, newAltState: newAltState)
        popupView.hidePopup()
        view.bringSubviewToFront(popupView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard keySet == nil else {
            return
        }
        
        view.frame = view.superview?.frame ?? .zero
        loadKeySet()
        keyboardState.configure(keySet: keySet, view: view as! KeypadView)
        keyboardState.actionDelegate = self
        keyboardState.displayDelegate = self
        addObservers()
    }
}

// MARK: - KeyboardActionProtocol

extension KeypadViewController: KeyboardActionProtocol {
  
    func insert(text: String) {
        delegate?.insert(text: text)
    }

    func deleteBackward() {
        delegate?.deleteBackward()
    }

    func deleteBackward(amount: Int) {
        delegate?.deleteBackward(amount: amount)
    }

    func nextKeyboard() {
        delegate?.nextKeyboard()
    }
}


// MARK: - KeyboardDisplayProtocol

extension KeypadViewController: KeyboardDisplayProtocol {
  
    func shiftStateChanged(newState: Key.State) {
        (view as? KeypadView)?.updateShiftState(newState)
        reloadKeySet(newAltState: KeyboardState.altState)
    }
  
    func altStateChanged(newState: Key.State) {
        keySet.keys.forEach({ $0.alt = newState })
        (view as? KeypadView)?.updateAltState(newState)
        reloadKeySet(newAltState: newState)
    }
  
  func keyIsPressed(kind: Key.Kind, at coordinate: KeyCoordinate?) {
    let keyViewToPress: KeyView?
    switch kind {
    case .letter:
      guard let _ = coordinate else {
        return UniversalLogger.error("The key should have a coordinate.")
      }
      
      keyViewToPress = nil // key.view
    default:
      guard let view = view as? KeypadView else {
        return UniversalLogger.error("The view should be a KeypadView.")
      }
      guard let keyView = view.view(for: kind) else {
        return UniversalLogger.error("Could not find key view")
      }
      keyViewToPress = keyView
    }
    if keyViewToPress != pressedKeyView || kind == .letter {
      pressedKeyView?.togglePression()
      keyViewToPress?.togglePression()
      if kind == .letter {
        guard let coordinate = coordinate else {
          return UniversalLogger.error("The key should have a coordinate.")
        }
        let key = keySet.key(at: coordinate)
        popupView.showPopup(for: key, at: coordinate)
      } else {
        popupView.hidePopup()
      }
    }
    pressedKeyView = keyViewToPress
  }
  
  func noKeyIsPressed() {
    pressedKeyView?.togglePression()
    pressedKeyView = nil
    popupView.hidePopup()
  }
  
  func launchSubLetterSelection(for key: Key, shiftState: Key.State, altState: Key.State) {
    popupView.showPopupWithSubLetters(for: key, shiftState: shiftState, altState: altState)
  }
  
  func select(subLetter: String) {
    popupView.select(subLetter: subLetter)
  }
  
}

// MARK: - KeyboardSwitchProtocol

extension KeypadViewController: KeyboardSwitchProtocol {
    func renderKeys(state: Key.State) {
        switchDelegate?.renderKeys(state: state)
        reloadKeySet(newAltState: state)
    }
    

  func switchKeyAdded(_ switchButton: UIView) {
    switchDelegate?.switchKeyAdded(switchButton)
  }

}
