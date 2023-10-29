//
//  KeyboardViewController.swift
//  keyboard
//

import UIKit

// MARK: - KeyboardViewController

final class KeyboardViewController: UIInputViewController {
  
    private var customInputViewController: InputViewController!
    private var constraintsHaveBeenAdded = false
    private var switchButton: UIButton?
    private var switchKeyView: UIView?
  
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        UniversalLogger.debug("textDidChange")
        customInputViewController?.textDidChange(textDocumentProxy)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        ColorManager.shared.keyboardAppearance = traitCollection.userInterfaceStyle
        KeysImages.shared.refreshImages()
        guard customInputViewController == nil else {
            return
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        initKeyboardViewConstraints()
        guard let inputView = inputView else { return }
        customInputViewController = InputViewController()
        customInputViewController.delegate = self
        customInputViewController.switchDelegate = self
        add(customInputViewController, with: [
          customInputViewController.view.topAnchor.constraint(equalTo: inputView.topAnchor),
          customInputViewController.view.rightAnchor.constraint(equalTo: inputView.rightAnchor),
          customInputViewController.view.bottomAnchor.constraint(equalTo: inputView.bottomAnchor),
          customInputViewController.view.leftAnchor.constraint(equalTo: inputView.leftAnchor)
        ])
        
        customInputViewController.view.backgroundColor = .clear
        customInputViewController.renderPopupView()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        ColorManager.shared.keyboardAppearance = traitCollection.userInterfaceStyle
        KeysImages.shared.refreshImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initSettings()
    }
  
    // MARK: Configuration
    
    private func initSettings() {
        KeyboardSettings.shared.update(self.textDocumentProxy)
        KeyboardSettings.shared.inputModeSwitchKey = needsInputModeSwitchKey ? .needs : .not
        UniversalLogger.debug("needsInputModeSwitchKey set to \(needsInputModeSwitchKey)")
    }
  
    private func initKeyboardViewConstraints() {
        guard !constraintsHaveBeenAdded else {
            return
        }
        
        guard let superview = view.superview else {
            return UniversalLogger.error("Keyboard has no superview.")
        }
        
        view.leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        constraintsHaveBeenAdded = true
        
        guard switchButton != nil else {
            return
        }
        
        // Hack to update frame after transition animations.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.updateSwitchButtonFrame()
        }
    }
}

// MARK: - KeyboardActionProtocol

extension KeyboardViewController: KeyboardActionProtocol {

    func insert(text: String) {
        textDocumentProxy.insertText(text)
    }
  
    func deleteBackward() {
        textDocumentProxy.deleteBackward()
    }
  
    func deleteBackward(amount: Int) {
        if amount <= 0 { return }
        
        (1...amount).forEach({ _ in
            deleteBackward()
        })
    }

    func nextKeyboard() {
        // This function is only a fallback if the switch button is not present.
        UniversalLogger.error("nextKeyboard should not be called.")
        advanceToNextInputMode()
    }
  
    func moveCursor(by offset: Int) {
        textDocumentProxy.adjustTextPosition(byCharacterOffset: offset)
    }
}

// MARK: - KeyboardSwitchProtocol

extension KeyboardViewController: KeyboardSwitchProtocol {
    func renderKeys(state: Key.State) {
        
    }

    func switchKeyAdded(_ switchKeyView: UIView) {
        self.switchKeyView = switchKeyView
        if switchButton?.superview == nil {
            UniversalLogger.debug("Adding switch button overlay")
            switchButton = UIButton()
            switchButton!.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            view.addSubview(switchButton!)
        }
        updateSwitchButtonFrame()
    }

    private func updateSwitchButtonFrame() {
        guard let switchButton = self.switchButton else { return }
        view.bringSubviewToFront(switchButton)
        guard let keyFrame = switchKeyView?.frame else { return }
        let newFrame = CGRect(x: keyFrame.minX, y: view.frame.maxY - keyFrame.height, width: keyFrame.width, height: keyFrame.height)
        switchButton.frame = newFrame
    }
}
