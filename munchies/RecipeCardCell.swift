//
//  RecipeCardCell.swift
//  munchies
//
//  Created by Adriana Monica Reyes on 7/23/26.
//

import UIKit

class RecipeCardCell: UITableViewCell {

    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cookTimeLabel: UILabel!

    @IBOutlet weak var editButton: UIButton!
    
    // This closure will notify the ViewController when tapped
    var editAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        editAction?()
    }
    
    
    // gonna call this function from FavoritesViewController to populate the cell
    func configure(with recipe: Recipe, isEditable: Bool) {
            titleLabel.text = recipe.name
            
                let time = recipe.getTime(for: .cook)
                if time.hours > 0 {
                    cookTimeLabel.text = "\(time.hours) hr \(time.minutes) mins"
                } else {
                    cookTimeLabel.text = "\(time.minutes) mins"
                }
                
                // Images work exactly the same!
            if let image = UIImage(named: recipe.image!) {
                    recipeImageView.image = image
                } else {
                    recipeImageView.image = UIImage(systemName: "photo.fill")
                    recipeImageView.tintColor = UIColor(named: "ThemeColor")
                }
        
            editButton?.isHidden = !isEditable
        }

}
