//
//  RecipeTitleLabel.swift
//  Project: munchies
//  Eid: ln8223
//  Course: CS371L
//  Created by Nhem, Logan on 7/24/26.
//

import UIKit

class RecipeTitleLabel: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        textColor = .white

        clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topRight, .bottomRight],
            cornerRadii: CGSize(width: 12, height: 12)
        )

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    override func drawText(in rect: CGRect) {
        let padding = UIEdgeInsets(
            top: 6,
            left: 12,
            bottom: 6,
            right: 12
        )

        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize

        return CGSize(
            width: size.width + 24,
            height: size.height + 12
        )
    }
}
