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
    let defaults:UserDefaults = UserDefaults.standard
    let screenTitle:String = "General Settings"
    let backButtonTitle:String = "General"
    let settingsKey:String = "Settings"
    let switchCellIdentifier:String = "switchCell"
    let segueCellIdentifier:String = "segueCell"
    let restrictionSegueIdentifier = "restriction"

    let defaultSettings:[Setting] = [Setting("Dark mode", false), Setting("Privacy"),
        Setting("Restrictions")]
    var settings:[Setting] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = screenTitle
        self.navigationItem.backButtonTitle = backButtonTitle
        tableView.dataSource = self
        tableView.delegate = self
        if let data:Data = defaults.object(forKey: settingsKey) as? Data,
           let storedSettings:[Setting] = try? JSONDecoder().decode([Setting].self, from: data)
        {
            for setting in storedSettings
            {
                settings.append(setting)
            }
        } else
        {
            for setting in defaultSettings
            {
                settings.append(setting)
            }
            if let encodedSettings = try? JSONEncoder().encode(settings)
            {
                defaults.set(encodedSettings, forKey: settingsKey)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier:String, sender:Any?) -> Bool
    {
        return false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return settings.count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell
    {
        let setting:Setting = settings[indexPath.row]
        let cellType:String = setting.switchState != nil ? switchCellIdentifier : segueCellIdentifier
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellType,
            for: indexPath)
        if cellType == switchCellIdentifier
        {
            let uiSwitch:UISwitch = UISwitch(frame: CGRect.zero)
            uiSwitch.tag = indexPath.row
            uiSwitch.addTarget(self, action: #selector(self.onSwitchChanged), for: UIControl.Event.valueChanged)
            uiSwitch.isOn = setting.switchState!
            cell.accessoryView = uiSwitch
        }
        var content:UIListContentConfiguration = cell.defaultContentConfiguration()
        content.text = setting.title
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == settings.count - 1
        {
            performSegue(withIdentifier: restrictionSegueIdentifier, sender: self)
        }
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
