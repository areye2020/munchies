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
    let defaults = UserDefaults.standard
    let switchCellIdentifier:String = "switchCell"
    let segueCellIdentifier:String = "segueCell"

    enum Setting:Int
    {
        case darkMode
        case privacy
        case restrictions
    }
    let settings:[String] = ["Dark Mode", "Privacy", "Restrictions"]
    let settingSwitches:[Setting] = [Setting.darkMode]
    let settingSegues:[Setting] = [Setting.privacy, Setting.restrictions]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return settings.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell
    {
        var cellType:String
        let cellSetting:Setting = Setting(rawValue: indexPath.row)!
        if settingSwitches.firstIndex(of: cellSetting) != nil
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
            uiSwitch.addTarget(self, action: #selector(self.onSwitchChanged), for: UIControl.Event.valueChanged)
            cell.accessoryView = uiSwitch
        }
        var content:UIListContentConfiguration = cell.defaultContentConfiguration()
        content.text = settings[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
    
    @objc func onSwitchChanged(sender:UISwitch)
    {
        switch sender.tag
        {
            case Setting.darkMode.rawValue:
                defaults.set(sender.isOn, forKey: settings[Setting.darkMode.rawValue])
            default:
                break
        }
    }
}
