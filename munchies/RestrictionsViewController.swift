//
//  RestrictionsViewController.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/15/26.
//

import UIKit

class RestrictionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    let screenTitle:String = "Restrictions"
    let switchCellIdentifier:String = "switchCell"
    let segueCellIdentifier:String = "segueCell"
    var restrictions:[String: [String]] =
       ["Gluten-free": ["gluten"],
        "Halal": ["pork"/*TODO*/],
        "Kosher": ["pork"/*TODO*/],
        "Lactose-free": ["lactose"],
        "Peanut-free": ["peanuts"],
        "Vegan": ["meat", "dairy milk"/*TODO*/],
        "Vegetarian": ["meat"]]
    var restrictionCells:[Setting] =
       [Setting("Gluten-free", false),
        Setting("Halal", false),
        Setting("Kosher", false),
        Setting("Lactose-free", false),
        Setting("Peanut-free", false),
        Setting("Vegan", false),
        Setting("Vegetarian", false)]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = screenTitle
        self.navigationItem.backButtonTitle = screenTitle
        tableView.delegate = self
        tableView.dataSource = self
        restrictionCells.sort()
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return restrictionCells.count + 1
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell
    {
        if indexPath.row == restrictionCells.count
        {
            let cell:UITableViewCell =
                tableView.dequeueReusableCell(withIdentifier: segueCellIdentifier,
                for: indexPath)
            var content:UIListContentConfiguration = cell.defaultContentConfiguration()
            content.text = "custom"
            cell.contentConfiguration = content
            return cell
        }
        
        let setting:Setting = restrictionCells[indexPath.row]
        let cellType:String = setting.switchState != nil ? switchCellIdentifier : segueCellIdentifier
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellType,
            for: indexPath)
        if cellType == switchCellIdentifier
        {
            let uiSwitch:UISwitch = UISwitch(frame: CGRect.zero)
            uiSwitch.tag = indexPath.row
            // TODO
//            uiSwitch.addTarget(self, action: #selector(self.onSwitchChanged), for: UIControl.Event.valueChanged)
            uiSwitch.isOn = setting.switchState!
            cell.accessoryView = uiSwitch
        }
        var content:UIListContentConfiguration = cell.defaultContentConfiguration()
        content.text = setting.title
        cell.contentConfiguration = content
        
        return cell
    }
}
