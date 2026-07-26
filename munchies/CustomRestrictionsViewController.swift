//
//  CustomRestrictionsViewController.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/17/26.
//

import UIKit
import FirebaseAuth

class CustomRestrictionsViewController: UIViewController, UITableViewDelegate,
    UITableViewDataSource
{
    @IBOutlet weak var tableView:UITableView!
    let restrictionCellIdentifier:String = "customRestriction"
    let addTitle:String = "Add Custom Restriction"
    let addMessage:String = ""
    let editTitle:String = "Edit Entry"
    let editMessage:String = ""
    var alertTextField:UITextField!
    var editIndex:Int = -1
    var currentUser:User!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        currentUser = User(UID: Auth.auth().currentUser!.uid)
        {(user) in
            if user == nil
            {
                self.createErrorAlert(message: "could not retrieve user data")
            } else
            {
                self.currentUser.customRestrictions = self.currentUser.customRestrictions.sorted()
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return currentUser.customRestrictions.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: restrictionCellIdentifier, for: indexPath)
        var content:UIListContentConfiguration = cell.defaultContentConfiguration()
        content.text = currentUser.customRestrictions[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath)
    {
        editIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        let cancelAction:UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel)
        let submitAction:UIAlertAction = UIAlertAction(title: "submit", style: UIAlertAction.Style.default, handler: editRestriction)
        
        let alert:UIAlertController = UIAlertController(title: editTitle, message: editMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {(textField) in self.alertTextField = textField})
        alert.addAction(cancelAction)
        alert.addAction(submitAction)
        present(alert, animated: true)
    }
    
    func tableView(_ tableView:UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath:IndexPath)
    {
        if editingStyle == UITableViewCell.EditingStyle.delete
        {
            currentUser.customRestrictions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        }
    }
    
    func addRestriction(alert:UIAlertAction)
    {
        do
        {
            var newRestriction:String = try removeExtraWhitespace(string: alertTextField.text ?? "")
            if newRestriction != ""
            {
                newRestriction = newRestriction.lowercased()
                if !currentUser.customRestrictions.contains(newRestriction)
                {
                    currentUser.customRestrictions.append(newRestriction)
                    currentUser.customRestrictions = currentUser.customRestrictions.sorted()
                    tableView.reloadData()
                }
            }
        } catch
        {
            createErrorAlert(message: "Something went wrong; could not add entry")
        }
    }
    
    func editRestriction(alert:UIAlertAction)
    {
        do
        {
            var newRestriction:String = try removeExtraWhitespace(string: alertTextField.text ?? "")
            if newRestriction != "" && editIndex >= 0
            {
                newRestriction = newRestriction.lowercased()
                currentUser.customRestrictions[editIndex] = newRestriction
                currentUser.customRestrictions = currentUser.customRestrictions.sorted()
                tableView.reloadData()
                editIndex = -1
            } else
            {
                createErrorAlert(message: "Something went wrong; could not edit entry")
            }
        } catch
        {
            createErrorAlert(message: "Something went wrong; could not edit entry")
        }
    }
    
    func createErrorAlert(message:String)
    {
        let cancelAction:UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel)
        let alert:UIAlertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func removeExtraWhitespace(string:String) throws -> String
    {
        var newString:String = ""
        try newString = string.replacing(Regex("^\\s+"), with: "")
        try newString.replace(Regex("\\s+$"), with: "")
        try newString.replace(Regex("\\s+"), with: " ")
        return newString
    }
    
    @IBAction func onPressAdd(_ sender:UIBarButtonItem)
    {
        let cancelAction:UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel)
        let submitAction:UIAlertAction = UIAlertAction(title: "submit", style: UIAlertAction.Style.default, handler: addRestriction)
        
        let alert:UIAlertController = UIAlertController(title: addTitle, message: addMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {(textField) in self.alertTextField = textField})
        alert.addAction(cancelAction)
        alert.addAction(submitAction)
        present(alert, animated: true)
    }
}
