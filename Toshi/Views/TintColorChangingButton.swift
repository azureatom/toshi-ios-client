//
//  TintColorChangingButton.swift
//  Toshi
//
//  Created by Ellen Shapiro (Work) on 3/23/18.
//  Copyright © 2018 Bakken&Baeck. All rights reserved.
//

import UIKit

class TintColorChangingButton: UIButton {

    let normalTintColor: UIColor
    let disabledTintColor: UIColor
    let selectedTintColor: UIColor
    let highlightedTintColor: UIColor

    init(normalTintColor: UIColor = Theme.tintColor,
         disabledTintColor: UIColor = Theme.greyTextColor,
         selectedTintColor: UIColor? = nil,
         highlightedTintColor: UIColor? = nil) {
        self.normalTintColor = normalTintColor
        self.disabledTintColor = disabledTintColor
        self.selectedTintColor = selectedTintColor ?? normalTintColor
        self.highlightedTintColor = highlightedTintColor ?? normalTintColor

        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isEnabled: Bool {
        didSet {
            updateTintColor()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            updateTintColor()
        }
    }

    override var isSelected: Bool {
        didSet {
            updateTintColor()
        }
    }

    private func updateTintColor() {
        switch state {
        case .normal:
            tintColor = normalTintColor
        case .disabled:
            tintColor = disabledTintColor
        case .selected:
            tintColor = selectedTintColor
        case .highlighted:
            tintColor = highlightedTintColor
        default:
            // some weird combo is happening, leave things where they are
            break
        }
    }
}
