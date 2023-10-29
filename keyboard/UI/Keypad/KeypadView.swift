//
//  KeypadView.swift

import UIKit

// MARK: - KeypadView

final class KeypadView: UIView {
    enum Const {
        static let keyWidthMultiplier: CGFloat = 1/11
        static let lastRowKeyWidthMultiplier: CGFloat = 1/11
        static let keyboardTitle = "Алтай танал"
    }

    weak var switchDelegate: KeyboardSwitchProtocol?
  
    private var shiftKeyView: SpecialKeyView?
    private var deleteKeyView: SpecialKeyView?
    private var altKeyView: SpecialKeyView?
    private var switchKeyView: SpecialKeyView?
    private var spaceKeyView: SpecialKeyView?
    private var returnKeyView: SpecialKeyView?
    private lazy var keysStack: UIView = {
        let stack = UIView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.widthAnchor.constraint(equalTo: widthAnchor),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
        ])
        return stack
    }()

    // MARK: Life cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        addObservers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Drawing

    func updateShiftState(_ status: Key.State) {
        shiftKeyView?.isHighlighted = false
        let altStateOff = KeyboardState.altState == .off
        updateShift(state: status, altOff: altStateOff)
        shiftKeyView?.updateAppearance()
        updateKeysRows()
    }
    
    private func updateShift(state: Key.State, altOff: Bool) {
        switch state {
        case .locked:
            if altOff {
                shiftKeyView?.configure(withImage: SymbolsManager.image(kind:  .shiftFill), level: .primary)
            } else {
                shiftKeyView?.configure(withText: "123", level: .primary)
            }
            shiftKeyView?.isHighlighted = true
        case .on:
            if altOff {
                shiftKeyView?.configure(withImage: SymbolsManager.image(kind:  .shiftFill), level: .primary)
            } else {
                shiftKeyView?.configure(withText: "123", level: .primary)
            }
        case .off:
            if altOff {
                shiftKeyView?.configure(withImage: SymbolsManager.image(kind:  .shift), level: .secondary)
            } else {
                shiftKeyView?.configure(withText: "#+=", level: .secondary)
            }
        }
    }
    
    private func updateKeysRows() {
        guard let keysImage = threelines?.onlyKeys else {
            return
        }
        
        clearStack()
        keysStack.addSubview(keysImage)
    }
  
    func updateAltState(_ state: Key.State) {
        altKeyView?.isHighlighted = false
        switch state {
        case .locked:
            altKeyView?.configure(withImage: SymbolsManager.image(kind: .option), level: .primary)
            altKeyView?.isHighlighted = true
        case .on:
            altKeyView?.configure(withImage: SymbolsManager.image(kind: .option), level: .primary)
        case .off:
            altKeyView?.configure(withImage: SymbolsManager.image(kind: .option), level: .secondary)
        }
        altKeyView?.updateAppearance()
        updateShift(state: KeyboardState.shiftState, altOff: state == .off)
    }
  
    func updateAppearance() {
        shiftKeyView?.updateAppearance()
        deleteKeyView?.updateAppearance()
        altKeyView?.updateAppearance()
        switchKeyView?.updateAppearance()
        spaceKeyView?.updateAppearance()
        returnKeyView?.updateAppearance()
    }
    
    private func updateReturnKey(type: UIReturnKeyType) {
        switch type {
        case .default:
            returnKeyView?.isHighlighted = false
        default:
            returnKeyView?.isHighlighted = true
        }
        returnKeyView?.updateAppearance()
    }
    
    // MARK: View finding
    
    func view(for kind: Key.Kind) -> SpecialKeyView? {
        switch kind {
        case .shift:
            return shiftKeyView
        case .alt:
            return altKeyView
        case .delete:
            return deleteKeyView
        case .space:
            return spaceKeyView
        case .enter:
            return returnKeyView
        case .next:
            return switchKeyView
        default:
            UniversalLogger.error("This function should not be called for \(kind).")
            return nil
        }
    }
  
    var threelines: KeysImages?
    private var keyboardWidth: CGFloat {
        Constants.keyboardWidth
    }
    
    // MARK: Loading
  
    func load(keySet: KeySet) {
        threelines?.background?.removeFromSuperview()

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: 160).isActive = true
        
        let ksz = CGSize(width: keyboardWidth, height: 3 * ViewSize.rowHeight)
        let keysLines = keySet.keysImage(for: ksz, altState: .off)
        
        load3Rows(keySet)
        if let shadows = keysLines.background {
            addSubview(shadows)
            addSubview(keysStack)
        }
        threelines = keysLines
        updateKeysRows()
        keysLines.moveOirignTo(.init(x: 0, y: Constants.keyboardTopPadding))
        loadRow4(keySet)
    }
    
    func reload3Rows(keySet: KeySet, newAltState: Key.State) {
        let ksz = CGSize(width: keyboardWidth, height: 3 * ViewSize.rowHeight)
        let keysLines = keySet.keysImage(for: ksz, altState: newAltState)
        
        clearStack()
        updateKeysRows()
        
        keysLines.moveOirignTo(.init(x: 0, y: Constants.keyboardTopPadding))
    }

    private func load3Rows(_ keySet: KeySet) {
        let shift = addShift()
        shiftKeyView = shift
        updateShiftState(.off)

        let delete = addDelete()
        delete.configure(withImage: SymbolsManager.image(kind: .delete), level: .secondary)
        deleteKeyView = delete
    }

    private func loadRow4(_ keySet: KeySet) {
        let rowView4 = add4thRowView()
        let multiplier = Const.lastRowKeyWidthMultiplier
        var spaceLeftAnchor: NSLayoutXAxisAnchor!
        switch KeyboardSettings.shared.inputModeSwitchKey {
        case .needs:
            altKeyView = addSpecial(in: rowView4, widthMultiplier: multiplier * 1.5, leftAnchor: rowView4.leftAnchor)
            updateAltState(.off)
            switchKeyView = addSpecial(in: rowView4, widthMultiplier: multiplier * 1.5, leftAnchor: altKeyView!.rightAnchor)
            switchKeyView?.configure(withImage: SymbolsManager.image(kind: .globe), level: .secondary)
            spaceLeftAnchor = switchKeyView!.rightAnchor
            switchDelegate?.switchKeyAdded(switchKeyView!)
        case .not:
            altKeyView = addSpecial(in: rowView4, widthMultiplier: multiplier * 3.0, leftAnchor: rowView4.leftAnchor)
            updateAltState(.off)
            spaceLeftAnchor = altKeyView!.rightAnchor
        }
        
        spaceKeyView = addSpecial(in: rowView4, widthMultiplier: multiplier * 5.01, leftAnchor: spaceLeftAnchor)
        spaceKeyView!.configure(withText: Const.keyboardTitle, level: .primary)
        returnKeyView = addSpecial(in: rowView4, widthMultiplier: multiplier * 3.0, leftAnchor: spaceKeyView!.rightAnchor)

        let right = returnKeyView!.rightAnchor.constraint(equalTo: rowView4.rightAnchor)
        right.priority = .defaultHigh
        right.isActive = true
        returnKeyView?.configure(withImage: SymbolsManager.image(kind: .returnImage), level: .secondary)
    }

    private func add4thRowView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: ViewSize.bottomRowHeight),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1)
        ])
        return view
    }
  
    private func addSpecial(in rowView: UIView, widthMultiplier: CGFloat, leftAnchor: NSLayoutXAxisAnchor) -> SpecialKeyView {
        let specialKeyView = SpecialKeyView()
        specialKeyView.translatesAutoresizingMaskIntoConstraints = false
        rowView.addSubview(specialKeyView)
        specialKeyView.widthAnchor.constraint(equalTo: rowView.widthAnchor, multiplier: widthMultiplier).isActive = true
        specialKeyView.topAnchor.constraint(equalTo: rowView.topAnchor).isActive = true
        specialKeyView.bottomAnchor.constraint(equalTo: rowView.bottomAnchor).isActive = true
        specialKeyView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        return specialKeyView
    }
    
    private func addShift() -> SpecialKeyView {
        let offset = ViewSize.rowHeight - 1
        let width = keyboardWidth * Const.keyWidthMultiplier
        let height: CGFloat = ViewSize.rowHeight - 2
        let size = CGSize(width: width, height: height)
        let specialKeyView = SpecialKeyView(frame: .init(origin: .zero, size: size))
        specialKeyView.fontSize = 14
        specialKeyView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(specialKeyView)
        NSLayoutConstraint.activate([
            specialKeyView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Const.keyWidthMultiplier),
            specialKeyView.heightAnchor.constraint(equalToConstant: height),
            specialKeyView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -offset),
            specialKeyView.leftAnchor.constraint(equalTo: leftAnchor)
        ])
        return specialKeyView
    }
    
    private func addDelete() -> SpecialKeyView {
        let offset = ViewSize.rowHeight - 1
        let width = keyboardWidth * Const.keyWidthMultiplier
        let height: CGFloat = ViewSize.rowHeight - 2
        let size = CGSize(width: width, height: height)
        let specialKeyView = SpecialKeyView(frame: .init(origin: .zero, size: size))
        specialKeyView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(specialKeyView)
        NSLayoutConstraint.activate([
            specialKeyView.widthAnchor.constraint(equalToConstant: width),
            specialKeyView.heightAnchor.constraint(equalToConstant: height),
            specialKeyView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -offset),
            specialKeyView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        return specialKeyView
    }
    
    private func clearStack() {
        keysStack.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    // MARK: Notifications
  
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(returnKeyTypeDidChange(_:)), name: .returnKeyTypeDidChange, object: nil)
    }

    @objc private func returnKeyTypeDidChange(_ notification: Notification) {
        updateReturnKey(type: KeyboardSettings.shared.returnKeyType)
    }
}
