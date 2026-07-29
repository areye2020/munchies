//
//  RestrictionsViewController.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/15/26.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RestrictionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let database:Firestore = Firestore.firestore()
    let screenTitle:String = "Restrictions"
    let switchCellIdentifier:String = "switchCell"
    let segueCellIdentifier:String = "segueCell"
    var currentUser:User!
    var restrictionCells:[Setting] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = screenTitle
        self.navigationItem.backButtonTitle = screenTitle
        tableView.delegate = self
        tableView.dataSource = self
        self.tabBarController?.setTabBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated:Bool) {
        updateCurrentUser()
    }
    
    // update the current user and refresh their restrictions appropriately
    func updateCurrentUser() {
        if let user:FirebaseAuth.User = Auth.auth().currentUser {
            currentUser = User(UID: user.uid) { (newUser) in
                self.database.collection(restrictionCollectionID)
                    .getDocuments() { (querySnapshot, error) in
                    if let error {
                        print(error.localizedDescription)
                    } else {
                        if let documents:[QueryDocumentSnapshot] = querySnapshot?.documents {
                            self.restrictionCells = []
                            for document in documents {
                                let docFields:[String:Any] = document.data()
                                let name:String = docFields[restrictionNameFieldID] as! String
                                var switchState:Bool = false
                                if let newUser {
                                    switchState = newUser.restrictions.contains(name)
                                }
                                self.restrictionCells.append(Setting(name, switchState))
                            }
                        }
                    }
                    self.restrictionCells.sort()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        // there is an extra cell for the custom restrictions cell
        return restrictionCells.count + 1
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        if indexPath.row == restrictionCells.count {
            let cell:UITableViewCell =
                tableView.dequeueReusableCell(withIdentifier: segueCellIdentifier,
                for: indexPath)
            var content:UIListContentConfiguration = cell.defaultContentConfiguration()
            content.text = "custom"
            cell.contentConfiguration = content
            return cell
        }
        
        let setting:Setting = restrictionCells[indexPath.row]
        let cellType:String = setting.switchState != nil ?
            switchCellIdentifier : segueCellIdentifier
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellType,
            for: indexPath)
        if cellType == switchCellIdentifier {
            let uiSwitch:UISwitch = UISwitch(frame: CGRect.zero)
            uiSwitch.tag = indexPath.row
            uiSwitch.addTarget(self, action: #selector(self.handleSwitchChange),
                for: UIControl.Event.valueChanged)
            uiSwitch.isOn = setting.switchState!
            cell.accessoryView = uiSwitch
        }
        var content:UIListContentConfiguration = cell.defaultContentConfiguration()
        content.text = setting.title
        cell.contentConfiguration = content
        
        return cell
    }
    
    @objc func handleSwitchChange(sender:UISwitch) {
        let restriction:String = restrictionCells[sender.tag].title
        if sender.isOn {
            currentUser.restrictions.append(restriction)
        } else {
            if let restrictionIndex:Int = currentUser.restrictions.firstIndex(of: restriction)
            {
                currentUser.restrictions.remove(at: restrictionIndex)
            }
        }
    }
}
