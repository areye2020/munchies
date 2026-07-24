//
//  AddRecipieViewController.swift
//  munchies
//
//  Created by Adriana Monica Reyes on 7/11/26.
//

import UIKit

class AddRecipieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var servingField: UILabel!
    @IBOutlet weak var calorieField: UITextField!
    
    @IBOutlet weak var prepHourField: UITextField!
    @IBOutlet weak var prepMinField: UITextField!
    
    @IBOutlet weak var cookHourField: UITextField!
    @IBOutlet weak var cookMinField: UITextField!
    
    @IBOutlet weak var IngredientsTableView: UITableView!
    var ingredientCellIdentifier: String = "ingredientsTableCell"
    
    @IBOutlet weak var instructionField: UITextView!
    
    var recipeList:[Recipe] = []
    var ingredients:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ingredient = ingredients[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ingredientCellIdentifier, for: indexPath)
        cell.textLabel?.text = ingredient
        return cell
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
        let recipe = Recipe(
            name: nameField.text!,
            servings: Int(calorieField.text!) ?? 0,
            calories: Int(calorieField.text!) ?? 0,
            prepTime: Int(prepHourField.text!)!*60 + (Int(prepMinField.text!) ?? 0),
            cookTime: (Int(cookHourField.text!) ?? 0)*60 + (Int(cookMinField.text!) ?? 0),
            ingredients: ingredients, instructions: instructionField.text!)
        
    }
    
}
