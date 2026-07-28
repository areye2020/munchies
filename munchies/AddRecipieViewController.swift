//
//  AddRecipieViewController.swift
//  Project: munchies
//  Eid:
//  Course: CS371L
//  Created by Adriana Monica Reyes on 7/11/26.
//
// Auth.auth().currentUser?.uid
import UIKit
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


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
    
    let db = Firestore.firestore()
    // for later use in stroing
    var currentUser:User!
    
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
        // nagivation title
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(named: "ThemeColor") ?? UIColor.orange,
            .font: UIFont.systemFont(ofSize: 20)
        ]
        recipeImage.image = UIImage(named: "munchiesLogoColor")
        
        IngredientsTableView.delegate = self
        IngredientsTableView.dataSource = self
        // Ensure a default cell is available for ingredient rows
        IngredientsTableView.register(UITableViewCell.self, forCellReuseIdentifier: ingredientCellIdentifier)
        // Register a basic cell for the input row as well
        IngredientsTableView.register(UITableViewCell.self, forCellReuseIdentifier: addIngredientCellIdentifier)
        
        // Enable tapping the image view to edit/select a recipe image
        let tap = UITapGestureRecognizer(target: self, action: #selector(onEditImage))
        recipeImage.isUserInteractionEnabled = true
        recipeImage.addGestureRecognizer(tap)
        if let uid  = Auth.auth().currentUser?.uid
        {
            currentUser = User(UID: uid, onCompletion: nil)
        }
        
        updateUI()
    }
    
    func updateUI(){
        // borders
        // UITextView

        // UIImage
        recipeImage.contentMode = .scaleAspectFill
        recipeImage.clipsToBounds = true
    }
    
    //  for styling labels
    func styleLabel(_ label: UILabel) {
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.textColor = .white
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        
        // Labels have no built-in padding, so give the background room to breathe
        label.numberOfLines = 1
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
        var final = ""
        do {
            let trimmed = try removeExtraWhitespace(string: raw)
            final = trimmed.lowercased()
        } catch {
            print("error: could not add ingredient")
        }
        
        guard !final.isEmpty else {
            textField.resignFirstResponder()
            return true
        }
        ingredients.append(final)
        IngredientsTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        textField.text = ""
        return true
    }
    
    func removeExtraWhitespace(string:String) throws -> String
    {
        var newString:String = ""
        try newString = string.replacing(Regex("^\\s+"), with: "")
        try newString.replace(Regex("\\s+$"), with: "")
        try newString.replace(Regex("\\s+"), with: " ")
        return newString
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
    
    
    @IBAction func AddButton(_ sender: UIBarButtonItem) {
        createtRecipe()
        // seque to the favorites screen
    }
    
    
    func createtRecipe() {
        // Gather and validate basic fields
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let instructions = (instructionField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        // Parse numeric fields with safe defaults
        let servings = Int(servingField.text ?? "") ?? 0
        let prepHours = Int(prepHourField.text ?? "") ?? 0
        let prepMins = Int(prepMinField.text ?? "") ?? 0
        let cookHours = Int(cookHourField.text ?? "") ?? 0
        let cookMins = Int(cookMinField.text ?? "") ?? 0
        let prepTime = max(0, prepHours) * 60 + max(0, prepMins)
        let cookTime = max(0, cookHours) * 60 + max(0, cookMins)
        let calories = Int(calorieField.text ?? "")
        let favoritedBy:[String] = []
        // currruent user info is already done
        // Create the Firestore doc reference up front so we have an ID to use
        // for both the storage path and the document itself.
        let recipeRef = db.collection(recipeCollectionID).document()
        let recipeID = recipeRef.documentID
        
        // Minimal validation
        guard !name.isEmpty else {
            createAlert(title: "Missing Name", "Please enter a recipe name.")
            return
        }
        let saveRecipe: (String) -> Void = { imageURL in
            var data: [String: Any] = [
                recipeNameFieldID: name,
                recipeAuthorFieldID: self.currentUser.username!,
                recipeServingsFieldID: servings,
                recipePrepTimeFieldID: prepTime,
                recipeCookTimeFieldID: cookTime,
                recipeIngredientsFieldID: self.ingredients,
                recipeInstructionsFieldID: instructions,
                recipeAuthorIDFieldID: self.currentUser.uid! as Any,
                recipeFavoritedByFieldID: favoritedBy,
                recipeCreatedAtFieldID: FieldValue.serverTimestamp()
            ]
            if let calories = calories { data[recipeCaloriesFieldID] = calories }
            if !imageURL.isEmpty { data[recipeImageFieldID] = imageURL }
            
            recipeRef.setData(data) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.createAlert(title: "Save Failed", "Could not save recipe: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        // empthy all firelds before segue
                        self.nameField.text = ""
                        self.servingField.text = ""
                        self.calorieField.text = ""
                        self.prepHourField.text = ""
                        self.prepMinField.text = ""
                        self.cookHourField.text = ""
                        self.cookMinField.text = ""
                        self.ingredients = []
                        self.IngredientsTableView.reloadData()
                        self.recipeImage.image = UIImage(named: "munchiesLogoColor")
                        self.instructionField.text = ""
                        self.performSegue(withIdentifier: "favoriteSegue", sender: self)
                    }
                }
            }
        }
        // Only upload if the user actually picked an image
        if let image = recipeImage.image {
            uploadRecipeImage(recipeID: recipeID, image: image) { imageURL in
                saveRecipe(imageURL ?? "")
            }
        } else {
            saveRecipe("")
        }
    }
    
    
    func uploadRecipeImage(recipeID: String, image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        let storageRef = Storage.storage()
            .reference()
            .child("\(recipeImagesPath)\(recipeID).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Could not get URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
            }
        }
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
