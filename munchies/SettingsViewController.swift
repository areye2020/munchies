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
    let settingsKey = "Settings"
    let switchCellIdentifier:String = "switchCell"
    let segueCellIdentifier:String = "segueCell"
    let defaultSettings:[Setting] = [Setting("Dark mode", false), Setting("Privacy"),
        Setting("Restrictions")]
    var settings:[Setting] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        if let data:Data = defaults.object(forKey: settingsKey) as? Data,
           let storedSettings:[Setting] = try? JSONDecoder().decode([Setting].self, from: data)
        {
            for Setting in storedSettings
            {
                settings.append(Setting)
            }
        } else
        {
            for Setting in defaultSettings
            {
                settings.append(Setting)
            }
            if let encodedSettings = try? JSONEncoder().encode(settings)
            {
                defaults.set(encodedSettings, forKey: settingsKey)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return settings.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell
    {
        let Setting:Setting = settings[indexPath.row]
        let cellType = Setting.switchState != nil ? switchCellIdentifier : segueCellIdentifier
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellType,
            for: indexPath)
        if cellType == switchCellIdentifier
        {
            let uiSwitch:UISwitch = UISwitch(frame: CGRect.zero)
            uiSwitch.tag = indexPath.row
            uiSwitch.addTarget(self, action: #selector(self.onSwitchChanged), for: UIControl.Event.valueChanged)
            uiSwitch.isOn = Setting.switchState!
            cell.accessoryView = uiSwitch
        }
        var content:UIListContentConfiguration = cell.defaultContentConfiguration()
        content.text = Setting.title
        cell.contentConfiguration = content
        
        return cell
    }
    
    @objc func onSwitchChanged(sender:UISwitch)
    {
        settings[sender.tag].switchState = sender.isOn
        if let encodedSettings = try? JSONEncoder().encode(settings)
        {
            defaults.set(encodedSettings, forKey: settingsKey)
        }
    }
}
