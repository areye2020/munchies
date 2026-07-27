//
//  RecipeProfileCell.swift
//  Project: munchies
//  Eid: ln8223
//  Course: CS371L
//  Created by Nhem, Logan on 7/27/26.
//

import UIKit

class RecipeProfileCell: UICollectionViewCell {
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var titleLabel: RecipeTitleLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor(named: "BackgroundColor")
        
        recipeImage.contentMode = .scaleAspectFill
        recipeImage.layer.cornerRadius = 8
        recipeImage.layer.masksToBounds = true
    }
    
    func configure(with recipe: Recipe) {
        // Default image first
        recipeImage.image = UIImage(named: "munchiesLogoColor")
        
        titleLabel.text = recipe.name
        
        // Try to use the uploaded image
        let imageString = recipe.image ?? ""
        
        // 1. Try Base64 Encoded String
        if let imageData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters),
           let decodedImage = UIImage(data: imageData) {
            self.recipeImage.image = decodedImage
        }
        // 2. Try Firebase Storage URL
        else if imageString.hasPrefix("http") || imageString.hasPrefix("https") || imageString.hasPrefix("gs://"),
                let url = URL(string: imageString) {
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let downloadedImage = UIImage(data: data), error == nil {
                    DispatchQueue.main.async {
                        self.recipeImage.image = downloadedImage
                    }
                }
            }.resume()
        }
        // 3. Try Local Asset Name
        else if let assetImage = UIImage(named: imageString) {
            self.recipeImage.image = assetImage
        }
        // 4. Fallback
        else {
            self.recipeImage.image = UIImage(named: "munchiesLogoColor")
        }
    }
}
