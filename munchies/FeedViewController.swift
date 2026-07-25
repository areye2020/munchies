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

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let db = Firestore.firestore()
    var recipes: [Recipe] = []
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    @IBOutlet weak var emptyStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeCollectionView.dataSource = self
        recipeCollectionView.delegate = self
        fetchRecipes()
        emptyStatusLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        recipes.count
    }
    
    func fetchRecipes() {
        db.collection("recipes").getDocuments { snapshot, error in
            
            if let error = error {
                print("Error getting recipes: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                return
            }
            
            self.recipes = documents.compactMap { document in
                try? document.data(as: Recipe.self)
            }
            
            DispatchQueue.main.async {
                self.emptyStatusLabel.isHidden = !self.recipes.isEmpty
                self.recipeCollectionView.reloadData()
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
    
}
