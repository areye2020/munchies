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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // force keyboard to slide up after the modal transition finishes
        ingredientTextField.becomeFirstResponder()
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
