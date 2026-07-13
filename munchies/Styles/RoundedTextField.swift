//
//  RoundedTextField.swift
//  Project: munchies
//  Eid: ln8223
//  Course: CS371L
//  Created by Nhem, Logan on 7/13/26.
//

import Foundation
import UIKit

class RoundedTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    private func setupStyle() {
        borderStyle = .none

        backgroundColor = UIColor(named: "TextField")

        // Moves text from edge
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: 16, height: 0)
        leftView = paddingView
        leftViewMode = .always

        font = UIFont.systemFont(ofSize: 16)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Makes it pill-shaped based on the height
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true

        // Keep padding height synced with the text field height
        if let paddingView = leftView {
            paddingView.frame.size.height = bounds.height
        }
    }
}
