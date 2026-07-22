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
        
        // Theme Layout Configurations
            view.backgroundColor = UIColor(named: "SoftCream") ?? .systemBackground
            tableView.backgroundColor = .clear // Let the parent view background show through
            
            // Color the '+' bar button item and navigation header accent colors
            navigationController?.navigationBar.tintColor = UIColor(named: "BurntOrange")
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "SoftCream") ?? .systemBackground
            appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "BurntOrange") ?? .black]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
        
        // check if the text should be crossed out or regular
        if item.isChecked {
            // make the attributes for the crossed out text
            let attributes: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.secondaryLabel // Fades the text slightly out
            ]
                
            // name of ingredient
            cell.textLabel?.attributedText = NSAttributedString(string: item.name, attributes: attributes)
            cell.accessoryType = .checkmark
        } else {
                // if not then its normal text
            let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.label
            ]
                
            cell.textLabel?.attributedText = NSAttributedString(string: item.name, attributes: attributes)
            cell.accessoryType = .none
        }
        
        // color the checkmark to match burnt orange color
        cell.tintColor = UIColor(named: "BurntOrange")
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ingredients.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // toggle the checked stat and refresh the row
        ingredients[indexPath.row].isChecked.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}
