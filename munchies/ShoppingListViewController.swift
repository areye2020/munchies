//
//  ShoppingListViewController.swift
//  Project: munchies
//  Eid:
//  Course: CS371L
//  Created by Adriana Monica Reyes on 7/11/26.
//

import UIKit

// starting out just gonna have this struct hold the ingredient data
// later will move to using core data to store on phone
struct ShoppingListItem {
    var name: String
    // to track and make them crossed out
    var isChecked: Bool = false
}

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // to get it working first time hold our list of ingredients here
    // use emojis in placeholder maybe look nicer
        var ingredients: [ShoppingListItem] = [
            ShoppingListItem(name: "🍎 Apples"),
            ShoppingListItem(name: "🥛 Milk"),
            ShoppingListItem(name: "🍞 Bread")
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Shopping List"
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addVC = segue.destination as? AddIngredientViewController {
            addVC.onIngredientAdded = { [weak self] newIngredientName in
                guard let self = self else { return }
                
                let newItem = ShoppingListItem(name: newIngredientName, isChecked: false)
                self.ingredients.append(newItem)
                self.tableView.reloadData()
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // total number of items in the array
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // dequeue prototype cell using "IngredientCell" indetifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        let item = ingredients[indexPath.row]
        
        // set text tabel to item name
        cell.textLabel?.text = item.name
        
        // to handle the check mark
        cell.accessoryType = item.isChecked ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // toggle the checked stat and refresh the row
        ingredients[indexPath.row].isChecked.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}
