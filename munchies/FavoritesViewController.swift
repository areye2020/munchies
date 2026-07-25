//
//  FavoritesViewController.swift
//  munchies
//
//  Created by Nhem, Logan on 7/20/26.
//

import UIKit
import FirebaseFirestore

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    let db = Firestore.firestore()
        
        // Change these from MockRecipe to Recipe
        var uploadedRecipes: [Recipe] = []
        var savedRecipes: [Recipe] = []
        
        var currentRecipes: [Recipe] {
            return segmentedControl.selectedSegmentIndex == 0 ? uploadedRecipes : savedRecipes
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none

            let themeColor = UIColor(named: "ThemeColor") ?? .orange
            segmentedControl.selectedSegmentTintColor = themeColor
            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            segmentedControl.setTitleTextAttributes([.foregroundColor: themeColor], for: .normal)
            
            fetchFavoritesAndUploads()
        }
        
        func fetchFavoritesAndUploads() {
            db.collection("recipes").getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                // 1. Map all documents to Recipe objects
                let allRecipes = documents.compactMap { try? $0.data(as: Recipe.self) }
                
                // 2. Filter into your two distinct arrays using "testUser"
                self?.uploadedRecipes = allRecipes.filter { $0.authorID == "testUser" }
                self?.savedRecipes = allRecipes.filter { recipe in
                    return recipe.favoritedBy?.contains("testUser") ?? false
                }
                
                // 3. Reload the UI on the main thread
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return currentRecipes.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCardCell", for: indexPath) as? RecipeCardCell else {
                return UITableViewCell()
            }
                    
            let recipe = currentRecipes[indexPath.row]
            cell.configure(with: recipe)
        
            return cell
        }
    
    
    @IBAction func segmentChanged(_ sender: Any) {
        // Whenever the user taps a different segment, we need to refresh the table view
        // so it loads the data from the other array.
        tableView.reloadData()
    }

}

