//
//  FeedViewController.swift
//  Project: munchies
//  Eid:
//  Course: CS371L
//  Created by Adriana Monica Reyes on 7/11/26.
//  Logan Nhem working on Feed starting 7/20/26.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let db = Firestore.firestore()
    let detailSegueID = "DetailSegue"
    
    var currentUser:User!
    var recipes: [Recipe] = []
    var selectedRecipe: Recipe?
    
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    @IBOutlet weak var emptyStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeCollectionView.dataSource = self
        recipeCollectionView.delegate = self
        emptyStatusLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let uid = Auth.auth().currentUser?.uid
        {
            currentUser = User(UID:uid, onCompletion: fetchRecipes)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        recipes.count
    }
    
    func fetchRecipes(user:User?) {
        db.collection("recipes").getDocuments { snapshot, error in
            
            if let error = error {
                print("Error getting recipes: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                return
            }
            
            let allRecipes = documents.compactMap { document in
                try? document.data(as: Recipe.self)
            }
            
            if let user {
                self.addNonRestrictedRecipes(user: user, allRecipes: allRecipes)
            } else
            {
                self.recipes = allRecipes
            }
            
            DispatchQueue.main.async {
                self.emptyStatusLabel.isHidden = !self.recipes.isEmpty
                self.recipeCollectionView.reloadData()
            }
        }
    }
    
    func addNonRestrictedRecipes(user: User, allRecipes: [Recipe]) {
        user.fetchRestrictions() { userRestrictions, error in
            if let error {
                print(error.localizedDescription)
            } else {
                for recipe in allRecipes {
                    var violatesRestriction = false
                    var i = 0
                    while !violatesRestriction && i < recipe.ingredients.count
                    {
                        let currentIngredient = recipe.ingredients[i]
                        var j = 0
                        while !violatesRestriction && j < userRestrictions!.count {
                            let restrictionIngredients = userRestrictions![j].ingredients
                            if restrictionIngredients.firstIndex(of: currentIngredient) != nil
                            {
                                violatesRestriction = true
                            }
                            j += 1
                        }
                        if !violatesRestriction && user.customRestrictions.firstIndex(of: currentIngredient) != nil
                        {
                            violatesRestriction = true
                        }
                        i += 1
                    }
                    if !violatesRestriction
                    {
                        self.recipes.append(recipe)
                    }
                }
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "RecipeFeedCell",
            for: indexPath
        ) as! RecipeCollectionViewCell
        
        let recipe = recipes[indexPath.item]
        cell.configure(with: recipe)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let spacing: CGFloat = 12
        let width = (collectionView.frame.width - (spacing * 3)) / 2
        
        return CGSize(
            width: width,
            height: width * 1.1
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 12
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 12
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 12,
            left: 12,
            bottom: 12,
            right: 12
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        selectedRecipe = recipes[indexPath.item]
        performSegue(withIdentifier: detailSegueID, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRecipeDetail" {
            let destination = segue.destination as! RecipeDetailViewController
            destination.recipe = selectedRecipe
        }
    }
    
}
