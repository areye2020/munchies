//
//  ProfileViewController.swift
//  Project: munchies
//  Eid:
//  Course: CS371L
//  Created by Adriana Monica Reyes on 7/11/26.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileViewController: UIViewController, UICollectionViewDataSource,
    UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var ownedRecipes: [Recipe] = []
    var selectedRecipe: Recipe?
    let db:Firestore = Firestore.firestore()
    let detailSegueID = "profileRecipeDetailSegue"
    
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var usernameBackground:UIView!
    @IBOutlet weak var usernameLabel:UILabel!
    @IBOutlet weak var bioLabel:UILabel!
    var currentUser:User!
    
    @IBOutlet weak var emptyStatusLabel: UILabel!
    @IBOutlet weak var profileBackground: UIView!
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeCollectionView.dataSource = self
        recipeCollectionView.delegate = self
        
        usernameLabel.layer.masksToBounds = true
        usernameLabel.text = ""
        bioLabel.text = ""
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.layer.masksToBounds = true
        
        usernameBackground.layer.cornerRadius = usernameBackground.bounds.height / 2
        profileBackground.layer.cornerRadius = 12
        profileBackground.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        updateCurrentUser()
    }
    
    
    // update the current user and populate their username, avatar, bio, and owened recipes with
    // the relevant data
    func updateCurrentUser() {
        if let user:FirebaseAuth.User = Auth.auth().currentUser {
            currentUser = User(UID: user.uid) { (newUser) in
                if newUser != nil {
                    if newUser!.imageURL != "" {
                        let storageRef:Storage = Storage.storage()
                        let profilePicRef:StorageReference = storageRef.reference(forURL: newUser!.imageURL)
                        profilePicRef.getData(maxSize: maxImageSize) { (data, error) in
                            if let error {
                                print(error.localizedDescription)
                            } else {
                                self.profileImageView.image = UIImage(data: data!)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.usernameLabel.text = newUser!.username
                        self.bioLabel.text = newUser!.bio
                    }
                    // Grab recipes once user is finalized
                    self.fetchOwnedRecipes(user: newUser!)
                }
            }
        }
    }
    
    // added by Logan
    func fetchOwnedRecipes(user: User) {
        db.collection(recipeCollectionID)
            .whereField(recipeAuthorIDFieldID, isEqualTo: user.uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let documents = snapshot?.documents else {
                    return
                }
                self.ownedRecipes = documents.compactMap { document in
                    try? document.data(as: Recipe.self)
                }
                DispatchQueue.main.async {
                    self.emptyStatusLabel.isHidden = !self.ownedRecipes.isEmpty
                    self.recipeCollectionView.reloadData()
                }
            }
    }
    
    func collectionView(_ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        return ownedRecipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeProfileCell",
            for: indexPath) as! RecipeProfileCell
        let recipe = ownedRecipes[indexPath.item]
        cell.configure(with: recipe)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 3
        let spacing: CGFloat = 12
        let totalSpacing = spacing * (columns + 1)
        let width = (collectionView.frame.width - totalSpacing) / columns
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int ) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    // Selection for detail page
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRecipe = ownedRecipes[indexPath.item]
        performSegue(withIdentifier: detailSegueID, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailSegueID {
            let destination = segue.destination as! RecipeDetailViewController
            destination.recipe = selectedRecipe
        }
    }
}
