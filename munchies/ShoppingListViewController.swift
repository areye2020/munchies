//
//  ShoppingListViewController.swift
//  Project: munchies
//  Eid:
//  Course: CS371L
//  Created by Adriana Monica Reyes on 7/11/26.
//

import UIKit
import CoreData

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // changed from [ShoppingListItem] to [Ingredient] to use the Core Data entity objects
    var ingredients: [Ingredient] = []
    
    // reference to the database context created in AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        
        // fetch the data from the phone's storage when the screen loads
        fetchIngredients()
    }
    
    // helper method to retrieve items from Core Data
    func fetchIngredients() {
        do {
            self.ingredients = try context.fetch(Ingredient.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Failed to fetch ingredients: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addVC = segue.destination as? AddIngredientViewController {
            addVC.onIngredientAdded = { [weak self] newIngredientName in
                guard let self = self else { return }
                
                // ADDED: Create a new Core Data Ingredient instead of a struct
                let newItem = Ingredient(context: self.context)
                newItem.name = newIngredientName
                newItem.isChecked = false
                // ADDED: Save it to the database, then re-fetch
                do {
                    try self.context.save()
                    self.fetchIngredients()
                } catch {
                    print("Error saving item: \(error)")
                }
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
        
        let itemName = item.name ?? "Unknown Item"
        
        // check if the text should be crossed out or regular
        if item.isChecked {
            // make the attributes for the crossed out text
            let attributes: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.secondaryLabel // Fades the text slightly out
            ]
                
            // name of ingredient
            cell.textLabel?.attributedText = NSAttributedString(string: itemName, attributes: attributes)
            cell.accessoryType = .checkmark
        } else {
                // if not then its normal text
            let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.label
            ]
                
            cell.textLabel?.attributedText = NSAttributedString(string: itemName, attributes: attributes)
            cell.accessoryType = .none
        }
        
        // color the checkmark to match burnt orange color
        cell.tintColor = UIColor(named: "BurntOrange")
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let itemToRemove = ingredients[indexPath.row]
            context.delete(itemToRemove)
            do {
                try context.save()
            } catch {
                print("Error deleting item: \(error)")
            }
            
            ingredients.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // toggle the checked stat and refresh the row
        ingredients[indexPath.row].isChecked.toggle()
        do {
            try context.save()
        } catch {
            print("Error saving checkmark toggle: \(error)")
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}
