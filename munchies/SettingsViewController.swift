//
//  SettingsViewController.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/13/26.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView:UITableView!
    let switchCellIdentifier:String = "switchCell"
    let segueCellIdentifier:String = "segueCell"
    let settings:[String] = ["Dark Mode", "Privacy", "Restrictions"]
    let settingSwitches:[String] = ["Dark Mode"]
    let settingSegues:[String] = ["Privacy", "Restrictions"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        print("huh?")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return settings.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell
    {
        var cellType:String
        let cellTitle = settings[indexPath.row]
        if settingSwitches.firstIndex(of: cellTitle) != nil
        {
            cellType = switchCellIdentifier
        } else
        {
            cellType = segueCellIdentifier
        }
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellType,
            for: indexPath)
        if cellType == switchCellIdentifier
        {
            let uiSwitch:UISwitch = UISwitch(frame: CGRect.zero)
            uiSwitch.tag = indexPath.row
            cell.accessoryView = uiSwitch
        }
        var content:UIListContentConfiguration = cell.defaultContentConfiguration()
        content.text = settings[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
    
    func onSwitchChanged()
    {
        
    }
}
