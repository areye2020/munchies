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
                

                let imageString = recipe.image ?? ""

                // 1. Try Base64 Encoded String
                if let imageData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters),
                let decodedImage = UIImage(data: imageData) {
                self.recipeImageView.image = decodedImage
                }
                // 2. Try Firebase Storage URL
                else if imageString.hasPrefix("http") || imageString.hasPrefix("https") || imageString.hasPrefix("gs://"),
                let url = URL(string: imageString) {
            
                    URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let downloadedImage = UIImage(data: data), error == nil {
                    DispatchQueue.main.async {
                        self.recipeImageView.image = downloadedImage
                    }
                }
                    }.resume()
                }
                // 3. Try Local Asset Name
                else if let assetImage = UIImage(named: imageString) {
                    self.recipeImageView.image = assetImage
                }
                // 4. Fallback Placeholder
                else {
                    self.recipeImageView.image = UIImage(systemName: "photo.fill")
                    self.recipeImageView.tintColor = UIColor(named: "ThemeColor")
                }
        
            editButton?.isHidden = !isEditable
        }

}
