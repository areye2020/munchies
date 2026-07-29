//
//  EditRecipieViewController.swift
//  munchies
//
//  Created by Adriana Monica Reyes on 7/25/26.
//

import UIKit
import FirebaseFirestore

class EditRecipieViewController: UIViewController, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

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
        setupImageTap()
        styleUIElements()
    }
    
    func styleUIElements() {
        // 1. Create a border color (using system gray so it looks natural in light/dark mode)
        let borderColor = UIColor.systemGray4.cgColor
        let borderWidth: CGFloat = 1.0
        let cornerRadius: CGFloat = 8.0
        
        // 2. Apply styling to Ingredients Text View
        ingredientsTextView.layer.borderColor = borderColor
        ingredientsTextView.layer.borderWidth = borderWidth
        ingredientsTextView.layer.cornerRadius = cornerRadius
        
        // 3. Apply styling to Instructions Text View
        instructionsTextView.layer.borderColor = borderColor
        instructionsTextView.layer.borderWidth = borderWidth
        instructionsTextView.layer.cornerRadius = cornerRadius
        
        // Slight inset so the text doesn't touch the border walls
        ingredientsTextView.textContainerInset = UIEdgeInsets(top: 8, left: 25, bottom: 8,
            right: 5)
        instructionsTextView.textContainerInset = UIEdgeInsets(top: 8, left: 25, bottom: 8,
            right: 5)
    }
    
    // 1. Make the image view tappable
        func setupImageTap() {
            recipieImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            recipieImageView.addGestureRecognizer(tapGesture)
        }
        
        // 2. Open the Photo Library when tapped
        @objc func imageTapped() {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true // Lets the user crop the photo into a square
            present(imagePicker, animated: true, completion: nil)
        }
        
        // 3. Catch the selected image and put it in the ImageView
        func imagePickerController(_ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                recipieImageView.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                recipieImageView.image = originalImage
            }
            dismiss(animated: true, completion: nil)
        }
    
    
    
    func populateUI() {
        // Ensure we actually have a recipe passed in
        guard let recipe = recipe else { return }
        
        // 1. Populate basic text fields
        nameTextField.text = recipe.name
        instructionsTextView.text = recipe.instructions
        
        // NEW IMAGE LOADING LOGIC:
        let imageString = recipe.image ?? ""
        if let imageData = Data(base64Encoded: imageString),
           let decodedImage = UIImage(data: imageData) {
            // It's a user-uploaded base64 image
            recipieImageView.image = decodedImage
        } else {
            // It's an Xcode asset name or empty
            recipieImageView.image = UIImage(named: imageString) ?? UIImage(systemName: "photo")
        }
        
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
        ingredientsTextView.text = recipe.ingredients.joined(separator: "\n")
        
    }
    private func confirmDeleteRecipe() {
        // 1. Create the confirmation alert dialog wrapper
        let alert = UIAlertController(
            title: "Delete Recipe",
            message: "Are you sure you want to permanently delete this recipe? This action cannot "
                + "be undone.",
            preferredStyle: .alert
        )
        
        // 2. Build the destructive action option
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.executeFirestoreDeletion()
        }
        
        // 3. Build a cancel action option to safeguard against accidental touches
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // 4. Attach actions and present the interactive popover onto the viewport
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
        
    private func executeFirestoreDeletion() {
        // Safely extract your recipe's identifier or document reference key
        guard let recipeId = self.recipe?.id else {
            print("Error: Could not locate a valid document reference identifier for this recipe "
                + "object.")
            return
        }
        
        let db = Firestore.firestore()
        
        // Reference the exact target document inside the "recipes" collection path
        db.collection("recipes").document(recipeId).delete { [weak self] error in
            if let error = error {
                // Gracefully log database communication errors
                print("Error removing recipe document from Firestore: "
                      + error.localizedDescription)
                let errorAlert = UIAlertController(title: "Error", message: "Failed to delete the "
                    + "recipe. Please try again.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(errorAlert, animated: true)
            } else {
                print("Recipe document successfully deleted from Firestore.")
                
                // Pop the view controller off the navigation stack instantly to slide back
                // smoothly to the feed screen
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    
    
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
        
        // NEW: Convert the current image to a Base64 String
        var finalImageString = recipe?.image ?? ""
        if let currentImage = recipieImageView.image,
            let imageData = currentImage.jpegData(compressionQuality: 0.1) {
                    finalImageString = imageData.base64EncodedString()
        }
        
        // 4. Package the data for Firestore
        let updatedData: [String: Any] = [
            recipeNameFieldID: nameTextField.text ?? "",
            recipeServingsFieldID: currentServings, // Grabbed straight from our stepper variable
            recipePrepTimeFieldID: totalPrepTime,
            recipeCookTimeFieldID: totalCookTime,
            recipeIngredientsFieldID: ingredientsArray,
            recipeInstructionsFieldID: instructionsTextView.text ?? ""
        ]
        
        // 5. Send the Update to Firestore
        let db = Firestore.firestore()
        db.collection(recipeCollectionID).document(recipeID)
            .updateData(updatedData) { [weak self] error in
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
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        // This will trigger our safety alert popup and Firestore deletion
        confirmDeleteRecipe()
    }
}
