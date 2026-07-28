//
//  RecipeDetailViewController.swift
//  munchies
//
//  Created by Nhem, Logan on 7/24/26.
//
//  coded by Sean

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class RecipeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var prepTime: UILabel!
    @IBOutlet weak var cookTime: UILabel!
    @IBOutlet weak var servings: UILabel!
    @IBOutlet weak var calories: UILabel!
    
    
    @IBOutlet weak var ingredients: UILabel!
    @IBOutlet weak var ingredientTable: UITableView!
    let ingredientTableCellIdentitfier = "ingredientCell"
    
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var instructions: UITextView!
    
    
    let db = Firestore.firestore()
    var recipe: Recipe?
    var isFavorited:Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientTable.delegate = self
        ingredientTable.dataSource = self
        instructions.isEditable = false
        instructions.isSelectable = false
        instructions.isScrollEnabled = true
        addUI()
        addFields()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        updateFavoriteButtonState()
    }
    
    // this is for adding in nice looking uis to the screen
    func addUI() {
        // borders
        // UIImage
        recipeImage.contentMode = .scaleAspectFill
        recipeImage.clipsToBounds = true
        // label
        styleLabel(recipeName)
        styleLabel(authorName)
        styleLabel(ingredients)
        styleLabel(instructionsLabel)
    }
    
    // for styling the labels
    func styleLabel(_ label: UILabel) {
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.textColor = .white
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        
        // Labels have no built-in padding, so give the background room to breathe
        label.numberOfLines = 1
    }
    
    func addFields(){
        guard let recipe = recipe else { return }
        recipeName.text = " \(recipe.name) "
        authorName.text = " by \(recipe.author ?? " Unknown ") "
        servings.text = "\(String(recipe.servings ?? 0))"
        calories.text = recipe.calories != nil ? "\(recipe.calories!) cal" : "N/A"
        let prep = recipe.getTime(for: .prep)
        prepTime.text = formatTime(hours: prep.hours, minutes: prep.minutes)
        let cook = recipe.getTime(for: .cook)
        cookTime.text = formatTime(hours: cook.hours, minutes: cook.minutes)
        loadImage(named: recipe.image ?? "munchiesLogoColor") { [weak self] image in
            self?.recipeImage.image = image ?? UIImage(named: "munchiesLogoColor")
        }
        
        instructions.text = recipe.instructions
        ingredientTable.reloadData()
    }
    
    // Turns an (hours, minutes) tuple into something like "1h 15m" or "45m"
    func formatTime(hours: Int, minutes: Int) -> String {
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    @IBAction func favoritePressed(_ sender: UIBarButtonItem) {
        
        guard let recipeID = recipe?.id else {
            print("No recipe ID available")
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            createAlert(title: "Not Logged In", "Please log in to favorite recipes.")
            return
        }
        let databaseFunc = isFavorited ? FieldValue.arrayRemove : FieldValue.arrayUnion
        
        db.collection(recipeCollectionID).document(recipeID).updateData([
            recipeFavoritedByFieldID: databaseFunc([uid])
        ]) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.createAlert(title: "Error", "Could not update favorite: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    if !self.isFavorited
                    {
                        self.recipe?.favoritedBy?.append(uid) // keep local copy in sync
                        sender.image = UIImage(systemName: "heart.fill") // optional: flip icon state
                    } else
                    {
                        let uidIndex = self.recipe?.favoritedBy?.firstIndex(of: uid)
                        self.recipe?.favoritedBy?.remove(at: uidIndex!)
                        sender.image = UIImage(systemName: "heart")
                    }
                    self.isFavorited = !self.isFavorited
                }
            }
        }
    }
    // Sets the button's icon based on whether the current user already favorited this recipe
    func updateFavoriteButtonState() {
        if let uid = Auth.auth().currentUser?.uid,
           let favoritedBy = recipe?.favoritedBy,
           favoritedBy.contains(uid),
           let button = navigationItem.rightBarButtonItem
        {
            
            button.image = UIImage(systemName: "heart.fill")
            isFavorited = true
        } else {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
            isFavorited = false
        }
    }
    
    private func createAlert(title: String, _ message: String) {   // ← was missing
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "okay", style: .default))
        present(alert, animated: true)
    }
    
    
    
    func loadImage(named nameOrURL: String, completion: @escaping (UIImage?) -> Void) {
        // Case 1: it's a local asset name (e.g. "placeholder", "default_recipe")
        if let assetImage = UIImage(named: nameOrURL) {
            completion(assetImage)
            return
        }
        // Case 2: treat it as a Firebase Storage URL
        // (gs://,https://...firebasestorage...)
        guard nameOrURL.hasPrefix("gs://") || nameOrURL.hasPrefix("http") else {
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference(forURL: nameOrURL)
        
        storageRef.getData(maxSize: maxImageSize) { data, error in
            if let error = error {
                print("Failed to fetch image: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe?.ingredients.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ingredientTableCellIdentitfier, for: indexPath)
        cell.textLabel?.text = "\(recipe?.ingredients[indexPath.row] ?? "")"
        return cell
    }
}
