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
        // Default image first
        recipeImage.image = UIImage(named: "munchiesLogoColor")
        
        titleLabel.text = recipe.name
        authorLabel.text = recipe.author
        
        let time = recipe.getTime(for: .total)
        timeLabel.text = "\(time.hours)h \(time.minutes)m"
        
        // Try to use the uploaded image
        guard recipe.image != nil && !recipe.image!.isEmpty,
              let url = URL(string: recipe.image!) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.recipeImage.image = image
            }
            
        }.resume()
    }
}
