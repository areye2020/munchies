//
//  RecipeDetailViewController.swift
//  munchies
//
//  Created by Nhem, Logan on 7/24/26.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class RecipeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var authorOutlet: UILabel!
    
    @IBOutlet weak var prepTimeOutlet: UILabel!
    @IBOutlet weak var cookTimeOutlet: UILabel!
    @IBOutlet weak var servingsOutlet: UILabel!
    @IBOutlet weak var caloriesOutlet: UILabel!
    
    @IBOutlet weak var ingredientsTable: UITableView!
    let ingredeintCellIdentitfier = "ingredientCell"
    
    @IBOutlet weak var instructionField: UITextField!
    
    
    var recipe: Recipe?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientsTable.delegate = self
        ingredientsTable.dataSource = self
        updateUI()
    }
    
    func updateUI(){
        if let urlString = recipe?.image, !urlString.isEmpty {
            loadImage(fromStorageURL: urlString) { [weak self] image in
                    self?.recipeImage.image = image ?? UIImage(named: "placeholder")
            }
        } else {
            recipeImage.image = UIImage(named: "placeholder")
        }
        nameOutlet.text = recipe?.name
        authorOutlet.text = "by \(recipe?.author ?? "")"
        prepTimeOutlet.text = "\((recipe?.getTime(for: .prep).hours), default: "0")h \((recipe?.getTime(for: .prep).hours), default: "0")m"
        cookTimeOutlet.text = "\((recipe?.getTime(for: .cook).hours), default: "0")h \((recipe?.getTime(for: .cook).hours), default: "0")m"
        servingsOutlet.text = "\(recipe?.servings, default: "0")"
        caloriesOutlet.text = "\(recipe?.calories, default: "0")"
        instructionField.text = "\(recipe?.instructions ?? "")"
        
    }
    
    
    func loadImage(fromStorageURL urlString: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = Storage.storage().reference(forURL: urlString)

        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in // 5MB max
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
    
    @IBAction func favoriteButton(_ sender: UIBarButtonItem) {
        recipe?.favoritedBy?.append(Auth.auth().currentUser!.uid)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (recipe?.ingredients.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ingredeintCellIdentitfier, for: indexPath)
        cell.textLabel?.text = recipe?.ingredients[indexPath.row]
        return cell
    }
    

}

