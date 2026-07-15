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
    var restrictions:[Setting] = [Setting("Gluten-free", false), Setting("Halal", false),
        Setting("Kosher", false), Setting("Lactose-free", false),
        Setting("Peanut-free", false), Setting("Vegan", false),
        Setting("Vegetarian", false)]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = screenTitle
        tableView.delegate = self
        tableView.dataSource = self
        restrictions.sort()
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return restrictions.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell
    {
        let setting:Setting = restrictions[indexPath.row]
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
