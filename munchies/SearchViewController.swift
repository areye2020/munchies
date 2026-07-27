//
//  SearchViewController.swift
//  Project: munchies
//  Eid:
//  Course: CS371L
//  Created by Adriana Monica Reyes on 7/11/26.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let detailScreenSegueIdentifier = "showDetail"
    let db = Firestore.firestore()
    var selectedRecipe:Recipe!
    
    // currently logged in user
    var currentUser:User!
        
    // allRecipes holds everything from the database
    var allRecipes: [Recipe] = []
        
    // filteredRecipes is what the TableView actually displays
    var filteredRecipes: [Recipe] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Connect the UI to the code
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
                
        // make the table view look a bit cleaner without empty rows
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchEverythingFromFirestore()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailScreenSegueIdentifier {
            if let detailVC = segue.destination as? RecipeDetailViewController
            {
                detailVC.recipe = selectedRecipe
            }
        }
    }
    
    // MARK: - Firestore Fetch
    func fetchEverythingFromFirestore() {
        db.collection("recipes").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
                
            // Map the raw Firestore documents into your Swift Recipe objects
            self?.allRecipes = documents.compactMap { doc in
                try? doc.data(as: Recipe.self)
            }
            
            // Filter out recipes that violate the current user's restriction settings
            if let uid = Auth.auth().currentUser?.uid {
                self?.currentUser = User(UID: uid) { user in
                    if let user {
                        user.withoutRestrictedRecipes(recipes: self?.allRecipes ?? []) { allowedRecipes, error in
                            if let error {
                                print(error.localizedDescription)
                            } else
                            {
                                self?.allRecipes = allowedRecipes!
                                self?.filteredRecipes = self?.allRecipes ?? []
                                DispatchQueue.main.async {
                                    if let sBar = self?.searchBar {
                                        // Filtering the results immediately ensures the user's
                                        // search will still apply if they leave the screen and
                                        // return
                                        self?.filterWithSearchBar(sBar, textDidChange: self?.searchBar.text ?? "")
                                    } else {
                                        self?.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // Initially, the search bar is empty, so show everything
                self?.filteredRecipes = self?.allRecipes ?? []
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
        
    // Search Bar Logic
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterWithSearchBar(searchBar, textDidChange: searchText)
    }
    
    func filterWithSearchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText.isEmpty {
            // If the user clears the search bar, show all recipes
            filteredRecipes = allRecipes
        } else {
            // Filter character-by-character.
            // .lowercased() ensures "Tom" matches "tomato"
            filteredRecipes = allRecipes.filter { recipe in
                return recipe.name.lowercased().contains(searchText.lowercased())
            }
        }
            
        // Refresh the table with the new filtered results
        tableView.reloadData()
    }
        
    // Dismiss the keyboard when the user taps "Search" on the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCardCell", for: indexPath) as? RecipeCardCell else {
                    return UITableViewCell()
        }
                
        // Always use filteredRecipes for the table!
        let recipe = filteredRecipes[indexPath.row]
                
        // Reuse the configure method you already built for Favorites
        cell.configure(with: recipe, isEditable: false)
        
        // If you don't want the pencil icon showing up on the search page at all,
        // you can explicitly hide it here:
        // cell.editButton?.isHidden = true
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedRecipe = filteredRecipes[indexPath.row]
        performSegue(withIdentifier: detailScreenSegueIdentifier, sender: self)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }

}
