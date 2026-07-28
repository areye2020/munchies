//
//  EditRecipieViewController.swift
//  munchies
//
//  Created by Adriana Monica Reyes on 7/25/26.
//

import UIKit
import FirebaseFirestore

class EditRecipieViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var recipieImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var servingsLabel: UILabel!
    
    @IBOutlet weak var prepHoursTextField: UITextField!
    @IBOutlet weak var prepMinsTextField: UITextField!
    
    @IBOutlet weak var cookHoursTextField: UITextField!
    
    @IBOutlet weak var cookMinsTextField: UITextField!
    
    @IBOutlet weak var instructionsTextView: UITextView!
    
    @IBOutlet weak var ingredientsStackView: UIStackView!
    
    
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
        // ingredientsTextView.layer.borderColor = borderColor
        // ingredientsTextView.layer.borderWidth = borderWidth
        // ingredientsTextView.layer.cornerRadius = cornerRadius
        
        // 3. Apply styling to Instructions Text View
        instructionsTextView.layer.borderColor = borderColor
        instructionsTextView.layer.borderWidth = borderWidth
        instructionsTextView.layer.cornerRadius = cornerRadius
        
        // Slight inset so the text doesn't touch the border walls
        //ingredientsTextView.textContainerInset = UIEdgeInsets(top: 8, left: 25, bottom: 8, right: 5)
        instructionsTextView.textContainerInset = UIEdgeInsets(top: 8, left: 25, bottom: 8, right: 5)
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
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
        if let imageData = Data(base64Encoded: imageString), let decodedImage = UIImage(data: imageData) {
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
        
        // Clear out any placeholder rows in the stack view first
        ingredientsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Loop through the existing ingredients array and create a row for each
        if !recipe.ingredients.isEmpty {
            // FIX: Change 'existingIngredients' to 'recipe.ingredients'
            for ingredient in recipe.ingredients {
                addIngredientRow(with: ingredient)
            }
        } else {
            // If there are no ingredients, just add one empty row so the user can start typing
            addIngredientRow()
        }
    }
    
    // Creates a new dynamic row for an ingredient
    func addIngredientRow(with text: String = "") {
        // 1. Create a Horizontal Stack View to hold the text field and button
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 8
        rowStack.alignment = .fill
        rowStack.distribution = .fill
        
        // 2. Create and style the Text Field
        let textField = UITextField()
        textField.text = text
        textField.placeholder = "e.g. 2 cups of flour"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(named: "TextField") ?? .systemGray6
        // Allow it to stretch to fill most of the row
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        // 3. Create the Trash Can Button
        // We use a modern UIAction so we don't need Objective-C selectors
        let deleteAction = UIAction { _ in
            // Animate the deletion for a smooth UI experience
            UIView.animate(withDuration: 0.2, animations: {
                rowStack.isHidden = true
            }) { _ in
                rowStack.removeFromSuperview() // Actually remove it from the screen
            }
        }
        
        let deleteButton = UIButton(type: .system, primaryAction: deleteAction)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        // Prevent the button from stretching so it stays an icon shape
        deleteButton.setContentHuggingPriority(.required, for: .horizontal)
        
        // 4. Add the field and button to the row
        rowStack.addArrangedSubview(textField)
        rowStack.addArrangedSubview(deleteButton)
        
        // 5. Add the completed row to our main vertical stack view
        ingredientsStackView.addArrangedSubview(rowStack)
    }
    
    
    @IBAction func saveTapped(_ sender: Any) {
        
        // Ensure we know which document in Firestore we are updating
        guard let recipeID = recipe?.id else {
            print("Error: No recipe ID found.")
            return
        }
        
        // Extract text from our dynamic stack view rows
        var updatedIngredientsArray: [String] = []

        for view in ingredientsStackView.arrangedSubviews {
            if let rowStack = view as? UIStackView,
               let textField = rowStack.arrangedSubviews.first(where: { $0 is UITextField }) as? UITextField,
               let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
                
                // Add the text to our array if it's not blank
                updatedIngredientsArray.append(text)
            }
        }
        
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
            recipeIngredientsFieldID: updatedIngredientsArray,
            recipeInstructionsFieldID: instructionsTextView.text ?? ""
        ]
        
        // 5. Send the Update to Firestore
        let db = Firestore.firestore()
        db.collection(recipeCollectionID).document(recipeID).updateData(updatedData) { [weak self] error in
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
    
    @IBAction func addIngredientTapped(_ sender: Any) {
        //  add a new blank row to the bottom of the list
        addIngredientRow()
    }
    
    
    @IBAction func deleteRecipieTapped(_ sender: UIButton) {
        guard let recipeID = recipe?.id else { return } // Ensure we have an ID to delete
            
            // 1. Create a confirmation popup
            let alert = UIAlertController(title: "Delete Recipe",
                                          message: "Are you sure you want to delete this recipe? This cannot be undone.",
                                          preferredStyle: .alert)
            
            // 2. The Cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            // 3. The Destructive Delete action
            let confirmDelete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                
                let db = Firestore.firestore()
                // Replace "recipes" with your actual collection ID variable if it differs
                db.collection("recipes").document(recipeID).delete() { error in
                    if let error = error {
                        print("Error deleting document: \(error)")
                    } else {
                        print("Document successfully deleted!")
                        // Send the user back to the previous screen
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            
            alert.addAction(confirmDelete)
            
            // 4. Show the popup
            present(alert, animated: true, completion: nil)
    }
    
    
}
