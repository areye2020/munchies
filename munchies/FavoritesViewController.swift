//
//  FavoritesViewController.swift
//  munchies
//
//  Created by Nhem, Logan on 7/20/26.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // This is the data that will populate the cards.
    var uploadedRecipes: [MockRecipe] = [
        MockRecipe(title: "Spicy Orange Chicken", cookTime: "30 mins", ingredients: "Chicken, Orange, Soy Sauce...", imageName: "orangeChicken"),
        MockRecipe(title: "Enchiladas", cookTime: "15 mins", ingredients: "Tortillas, Beef, Jalapeno...", imageName: "enchiladas")
    ]
        
    var savedRecipes: [MockRecipe] = [
        MockRecipe(title: "Creamy Tomato Soup", cookTime: "45 mins", ingredients: "Tomatoes, Cream, Basil...", imageName: "tomatoSoup"),
        MockRecipe(title: "Avocado Toast", cookTime: "5 mins", ingredients: "Bread, Avocado, Salt...", imageName: "avacadoToast"),
        MockRecipe(title: "Tamales", cookTime: "25 mins", ingredients: "Masa, Pork, Onions...", imageName: "tamales")
    ]
    
    // We use this computed property to figure out which array to show based on the segmented control
    var currentRecipes: [MockRecipe] {
        return segmentedControl.selectedSegmentIndex == 0 ? uploadedRecipes : savedRecipes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // tell table view this view controller will provide its data
        tableView.dataSource = self
        tableView.delegate = self
        
        // Match the segmented control styling to your orange theme
        let themeColor = UIColor(named: "ThemeColor") ?? .orange
        segmentedControl.selectedSegmentTintColor = themeColor
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: themeColor], for: .normal)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the count of whichever array is currently active
        return currentRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue using the exact identifier from your storyboard
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCardCell", for: indexPath) as? RecipeCardCell else {
            return UITableViewCell()
        }
                
        // Grab the correct recipe based on the row index
        let recipe = currentRecipes[indexPath.row]
                
        // Pass the data to the cell so it can update its labels/images
        cell.configure(with: recipe)
    
        return cell
    }
    
    
    @IBAction func segmentChanged(_ sender: Any) {
        // Whenever the user taps a different segment, we need to refresh the table view
        // so it loads the data from the other array.
        tableView.reloadData()
    }

}

struct MockRecipe {
    let title: String
    let cookTime: String
    let ingredients: String
    let imageName: String
}
