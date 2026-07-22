//
//  AddIngredientViewController.swift
//  munchies
//
//  Created by Adriana Monica Reyes on 7/20/26.
//

import UIKit

class AddIngredientViewController: UIViewController {

    @IBOutlet weak var ingredientTextField: UITextField!
    
    var onIngredientAdded: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup background color
            view.backgroundColor = UIColor(named: "SoftCream") ?? .systemBackground
        
        setupKeyboardDismissRecognizer()
        
        // Apply styling to the text field layout
            ingredientTextField.borderStyle = .roundedRect
            ingredientTextField.tintColor = UIColor(named: "BurntOrange") // Cursor color
            
            // Style the Add button programmatically
            if let button = view.subviews.compactMap({ $0 as? UIButton }).first {
                // Configure a modern iOS 15+ filled button style
                var config = UIButton.Configuration.filled()
                config.title = "Add to List"
                config.baseBackgroundColor = UIColor(named: "BurntOrange")
                config.baseForegroundColor = .white
                config.cornerStyle = .large
                
                button.configuration = config
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // force keyboard to slide up after the modal transition finishes
        ingredientTextField.becomeFirstResponder()
    }
    
    private func setupKeyboardDismissRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        // make sure its not just empty spaces
        if let text = ingredientTextField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            // hand off text string
            onIngredientAdded?(text)
            
            // dismiss modal so the shopping list to slide back down
            dismiss(animated: true, completion: nil)
        }
    }
    
}
