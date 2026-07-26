//
//  FavoritesViewController.swift
//  munchies
//
//  Created by Nhem, Logan on 7/20/26.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

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
            
            //fetchFavoritesAndUploads()
        }
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // This forces the app to re-fetch the data from Firestore
            // every single time you navigate back to this screen.
            fetchFavoritesAndUploads()
        }
        
        func fetchFavoritesAndUploads() {
            // 1. Safely grab the current logged-in user's UID
            guard let currentUserID = Auth.auth().currentUser?.uid else {
                print("No user is currently logged in. Cannot fetch specific recipes.")
                return
            }
        
            db.collection("recipes").getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
            
                // 2. Map all documents to Recipe objects
                let allRecipes = documents.compactMap { try? $0.data(as: Recipe.self) }
            
                // 3. Filter into your two distinct arrays using the real currentUserID
                self?.uploadedRecipes = allRecipes.filter { $0.authorID == currentUserID }
                self?.savedRecipes = allRecipes.filter { recipe in
                    return recipe.favoritedBy?.contains(currentUserID) ?? false
                }
            
                // 4. Reload the UI on the main thread
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
            
            // Determine editability: true if we are on the Uploaded segment (index 0), false otherwise
            let isCurrentSegmentEditable = (segmentedControl.selectedSegmentIndex == 0)
            
            // Pass both the recipe and the editability status to the cell
            cell.configure(with: recipe, isEditable: isCurrentSegmentEditable)
            
            cell.editAction = { [weak self] in
                // This triggers the segue and passes the specific recipe as the sender
                self?.performSegue(withIdentifier: "toEditRecipe", sender: recipe)
            }
            return cell
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditRecipe",
           let destinationVC = segue.destination as? EditRecipieViewController,
           let selectedRecipe = sender as? Recipe {
            
            // Pass the recipe object to the edit screen
            destinationVC.recipe = selectedRecipe
        }
    }
    
    
    @IBAction func segmentChanged(_ sender: Any) {
        // Whenever the user taps a different segment, we need to refresh the table view
        // so it loads the data from the other array.
        tableView.reloadData()
    }
    
    

}

