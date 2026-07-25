//
//  RecipeCollectionViewCell.swift
//  Project: munchies
//  Eid: ln8223
//  Course: CS371L
//  Created by Nhem, Logan on 7/24/26.
//

import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .systemGray6

        recipeImage.contentMode = .scaleAspectFill
        recipeImage.clipsToBounds = true
        
    }

    func configure(with recipe: Recipe) {
        // image needs to change to a url for firebase to load from its library
        recipeImage.image = UIImage(named: "munchiesLogoColor")
        titleLabel.text = recipe.name
        authorLabel.text = recipe.author
        let time = recipe.getTime(for: .total)
        timeLabel.text = "\(time.hours)h \(time.minutes)m"
    }
}
