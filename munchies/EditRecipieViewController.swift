//
//  EditRecipieViewController.swift
//  munchies
//
//  Created by Adriana Monica Reyes on 7/25/26.
//

import UIKit
import FirebaseFirestore

class EditRecipieViewController: UIViewController {

    @IBOutlet weak var recipieImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var servingsTextField: UITextField!
    @IBOutlet weak var prepTimeTextField: UITextField!
    @IBOutlet weak var cookTimeTextField: UITextField!
    
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    
    // This catches the data passed from the previous screen
    var recipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateUI()
    }
    
    func populateUI() {
        // Ensure we actually have a recipe passed in
        guard let recipe = recipe else { return }
        
        // 1. Populate basic text fields
        nameTextField.text = recipe.name
        cookTimeTextField.text = "\(recipe.cookTime)"
            
        // Safely unwrap optionals
        if let servings = recipe.servings { servingsTextField.text = "\(servings)" }
        if let prepTime = recipe.prepTime { prepTimeTextField.text = "\(prepTime)" }
                
        // 2. THE ARRAY TRICK: Convert the [String] array into a single string, separated by new lines
        ingredientsTextView.text = recipe.ingredients.joined(separator: "\n")
                
        // 3. Populate instructions
                instructionsTextView.text = recipe.instructions
                
        // Populate Image - Assuming local assets for now
        recipieImageView.image = UIImage(named: recipe.image) ?? UIImage(systemName: "photo")
    }
    
    
    @IBAction func saveTapped(_ sender: Any) {
        
        // We need the Firestore document ID to know which recipe to update
                guard let recipeID = recipe?.id else {
                    print("Error: No recipe ID found.")
                    return
                }
                
                // THE ARRAY TRICK (Reverse): Split the text view string by new lines to recreate the [String] array.
                // We use .filter to remove any blank lines the user accidentally left in.
                let ingredientsArray = ingredientsTextView.text
                    .components(separatedBy: "\n")
                    .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                
                // Safely pull integers from the text fields
                let servings = Int(servingsTextField.text ?? "")
                let prepTime = Int(prepTimeTextField.text ?? "")
                let cookTime = Int(cookTimeTextField.text ?? "0") ?? 0
                
                // Package the updated data matching your Firestore schema exactly
                let updatedData: [String: Any] = [
                    "name": nameTextField.text ?? "",
                    "servings": servings as Any, // Using 'as Any' allows nil to be saved if left blank
                    "prepTime": prepTime as Any,
                    "cookTime": cookTime,
                    "ingredients": ingredientsArray,
                    "instructions": instructionsTextView.text ?? ""
                ]
                
                // Access Firestore and execute the update
                let db = Firestore.firestore()
                db.collection("recipes").document(recipeID).updateData(updatedData) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        print("Document successfully updated!")
                        // Automatically close this screen and return to the feed upon success
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
        
}
