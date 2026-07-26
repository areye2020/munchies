//
//  AddRecipieViewController.swift
//  Project: munchies
//  Eid:
//  Course: CS371L
//  Created by Adriana Monica Reyes on 7/11/26.
//

// Auth.auth(0.currentUser.uid


import UIKit
import PhotosUI

class AddRecipieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var servingField: UILabel!
    @IBOutlet weak var calorieField: UITextField!
    
    @IBOutlet weak var prepHourField: UITextField!
    @IBOutlet weak var prepMinField: UITextField!
    
    @IBOutlet weak var cookHourField: UITextField!
    @IBOutlet weak var cookMinField: UITextField!
    
    @IBOutlet weak var IngredientsTableView: UITableView!
    var ingredientCellIdentifier: String = "ingredientsTableCell"
    private let addIngredientCellIdentifier = "AddIngredientInputCell"
    private weak var addIngredientTextField: UITextField?
    
    @IBOutlet weak var instructionField: UITextView!
    
    var recipeList:[Recipe] = []
    var ingredients:[String] = []
    
    @IBOutlet weak var recipeImage: UIImageView!
    private let accessMessage:String = "Access to your photo library is required to add a recipe image"
    private var pickerConfig: PHPickerConfiguration = PHPickerConfiguration()
    private lazy var picker: PHPickerViewController = {
        pickerConfig.filter = .images
        pickerConfig.selectionLimit = 1
        let p = PHPickerViewController(configuration: pickerConfig)
        p.delegate = self
        return p
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IngredientsTableView.delegate = self
        IngredientsTableView.dataSource = self
        // Ensure a default cell is available for ingredient rows
        IngredientsTableView.register(UITableViewCell.self, forCellReuseIdentifier: ingredientCellIdentifier)
        // Register a basic cell for the input row as well
        IngredientsTableView.register(UITableViewCell.self, forCellReuseIdentifier: addIngredientCellIdentifier)

        // Configure any text fields to use number pads where appropriate
        calorieField.keyboardType = .numberPad
        prepHourField.keyboardType = .numberPad
        prepMinField.keyboardType = .numberPad
        cookHourField.keyboardType = .numberPad
        cookMinField.keyboardType = .numberPad
        
        // Enable tapping the image view to edit/select a recipe image
        let tap = UITapGestureRecognizer(target: self, action: #selector(onEditImage))
        recipeImage.isUserInteractionEnabled = true
        recipeImage.addGestureRecognizer(tap)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 2 }

    // Remove section header titles and spacing
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return CGFloat.leastNormalMagnitude }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { return nil }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return ingredients.count } else { return 1 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let ingredient = ingredients[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: ingredientCellIdentifier, for: indexPath)
            cell.textLabel?.text = ingredient
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: addIngredientCellIdentifier, for: indexPath)
            cell.selectionStyle = .none
            // Remove any existing text field (in case of reused cell)
            for subview in cell.contentView.subviews { subview.removeFromSuperview() }
            let tf = UITextField(frame: .zero)
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.placeholder = "Add ingredient..."
            tf.returnKeyType = .done
            tf.clearButtonMode = .whileEditing
            tf.autocapitalizationType = .sentences
            tf.delegate = self
            cell.contentView.addSubview(tf)
            NSLayoutConstraint.activate([
                tf.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                tf.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                tf.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                tf.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
            ])
            self.addIngredientTextField = tf
            return cell
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let raw = textField.text ?? ""
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            textField.resignFirstResponder()
            return true
        }
        ingredients.append(trimmed)
        IngredientsTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        textField.text = ""
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return indexPath.section == 0 }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == 0 {
            ingredients.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    @IBAction func minusServing(_ sender: Any) {
        servingField.text = String(Int(servingField.text!)! - 1)
        if Int(servingField.text!)! < 0 {
            servingField.text = "0"
        }
    }
    
    @IBAction func plusServing(_ sender: Any) {
        servingField.text = String(Int(servingField.text!)! + 1)
    }
    
    func createtRecipe() {
        // placeholder
        //        let recipe = Recipe(
        //            name: nameField.text!,
        //            servings: Int(calorieField.text!) ?? 0,
        //            calories: Int(calorieField.text!) ?? 0,
        //            prepTime: Int(prepHourField.text!)!*60 + (Int(prepMinField.text!) ?? 0),
        //            cookTime: (Int(cookHourField.text!) ?? 0)*60 + (Int(cookMinField.text!) ?? 0),
        //            ingredients: ingredients, instructions: instructionField.text!)
        
    }
    
    // Attempt to open the user's photo library; prompt for settings if denied
    @objc @IBAction func onEditImage(_ sender: Any) {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized:
            present(picker, animated: true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { authStatus in
                if authStatus == .authorized || authStatus == .limited {
                    DispatchQueue.main.async { self.present(self.picker, animated: true) }
                }
            }
        case .denied:
            let alert = UIAlertController(title: "Photo Access", message: accessMessage, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "no thanks", style: .cancel)
            let settingsAction = UIAlertAction(title: "open settings?", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }
            alert.addAction(cancelAction)
            alert.addAction(settingsAction)
            present(alert, animated: true)
        case .restricted:
            createAlert(title: "Photo Access", accessMessage)
        case .limited:
            present(picker, animated: true)
        @unknown default:
            break
        }
    }
    
    private func createAlert(title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "okay", style: .default)
        alert.addAction(okayAction)
        present(alert, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            guard let self = self, let uiImage = image as? UIImage else { return }
            DispatchQueue.main.async { self.recipeImage.image = uiImage }
        }
    }
    
}
