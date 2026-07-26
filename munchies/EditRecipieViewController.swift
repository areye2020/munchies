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

    @IBOutlet weak var servingsLabel: UILabel!
    
    @IBOutlet weak var prepHoursTextField: UITextField!
    @IBOutlet weak var prepMinsTextField: UITextField!
    
    @IBOutlet weak var cookHoursTextField: UITextField!
    
    @IBOutlet weak var cookMinsTextField: UITextField!
    
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    
    // This catches the data passed from the previous screen
    var recipe: Recipe?
    
    // Tracks the stepper value for servings
    var currentServings: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateUI()
    }
    
    func populateUI() {
        // Ensure we actually have a recipe passed in
        guard let recipe = recipe else { return }
        
        // 1. Populate basic text fields
        nameTextField.text = recipe.name
        instructionsTextView.text = recipe.instructions
        
        recipieImageView.image = UIImage(named: recipe.image) ?? UIImage(systemName: "photo")
        
        // 2. Set up the Servings Stepper
        currentServings = recipe.servings ?? 1
        servingsLabel.text = "\(currentServings)"
                
        // 3. Split Prep Time into Hours and Minutes
        let prepTime = recipe.getTime(for: .prep)
        prepHoursTextField.text = "\(prepTime.hours)"
        prepMinsTextField.text = "\(prepTime.minutes)"
                
        // 4. Split Cook Time into Hours and Minutes
        let cookTime = recipe.getTime(for: .cook)
        cookHoursTextField.text = "\(cookTime.hours)"
        cookMinsTextField.text = "\(cookTime.minutes)"
                        
        // 5. Convert [String] array into a single string for the text view
        ingredientsTextView.text = recipe.ingredients.joined(separator: "\n")}
    
    
    @IBAction func saveTapped(_ sender: Any) {
        
        // Ensure we know which document in Firestore we are updating
        guard let recipeID = recipe?.id else {
            print("Error: No recipe ID found.")
            return
        }
        
        // 1. Recreate the Ingredients Array
        // Split by new line and remove any empty blank lines
        let ingredientsArray = ingredientsTextView.text
            .components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        // 2. Calculate Total Prep Time (Hours to Mins + Mins)
        let prepHours = Int(prepHoursTextField.text ?? "0") ?? 0
        let prepMins = Int(prepMinsTextField.text ?? "0") ?? 0
        let totalPrepTime = (prepHours * 60) + prepMins
        
        // 3. Calculate Total Cook Time (Hours to Mins + Mins)
        let cookHours = Int(cookHoursTextField.text ?? "0") ?? 0
        let cookMins = Int(cookMinsTextField.text ?? "0") ?? 0
        let totalCookTime = (cookHours * 60) + cookMins
        
        // 4. Package the data for Firestore
        let updatedData: [String: Any] = [
            "name": nameTextField.text ?? "",
            "servings": currentServings, // Grabbed straight from our stepper variable
            "prepTime": totalPrepTime,
            "cookTime": totalCookTime,
            "ingredients": ingredientsArray,
            "instructions": instructionsTextView.text ?? ""
        ]
        
        // 5. Send the Update to Firestore
        let db = Firestore.firestore()
        db.collection("recipes").document(recipeID).updateData(updatedData) { [weak self] error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")
                // Pop the view controller to go back to the Favorites screen
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
    @IBAction func minusServingsTapped(_ sender: UIButton) {
        if currentServings > 1 {
            currentServings -= 1
            servingsLabel.text = "\(currentServings)"
        }
    }
    
    @IBAction func plusServingsTapped(_ sender: Any) {
        currentServings += 1
        servingsLabel.text = "\(currentServings)"
    }
}
