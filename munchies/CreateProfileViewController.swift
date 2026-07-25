//
//  CreateProfileViewController.swift
//  Project: munchies
//  Eid: ln8223
//  Course: CS371L
//  Created by Nhem, Logan on 7/24/26.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

// Adds the user to a profile in firestore
class CreateProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    
    let maxUsernameLength:Int = 16
    let db = Firestore.firestore()
    var currentUser:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        bioTextView.delegate = self
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        bioTextView.layer.cornerRadius = 12
        bioTextView.clipsToBounds = true
        bioTextView.textContainerInset = UIEdgeInsets(
            top: 12,
            left: 12,
            bottom: 12,
            right: 12
        )
        bioTextView.textContainer.lineFragmentPadding = 0
        bioTextView.text = ""
        
        statusLabel.text = ""
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches:Set<UITouch>, with event:UIEvent?) {
        self.view.endEditing(true)
    }
    
    // only allow usernames up to maxUsernameLength in length
    func textField(_ textField:UITextField, shouldChangeCharactersIn range:NSRange,
        replacementString string:String) -> Bool {
        let newString:String = (textField.text as? NSString)!.replacingCharacters(in: range,
            with: string)
        return newString.count <= maxUsernameLength
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if usernameField.text == "" {
            statusLabel.text = "Please choose a username"
        } else {
            guard let uid = Auth.auth().currentUser?.uid else {
                statusLabel.text = "No logged in user"
                return
            }
            currentUser = User(UID: uid) { (user) in
                if user != nil {
                    let newName = self.usernameField.text!
                    let newBio = self.bioTextView.text!
                    user!.updateUsernameAndBio(newName: newName, newBio: newBio) { (error) in
                        if error != nil {
                            self.statusLabel.text = error!.localizedDescription
                        } else {
                            print("New name saved successfully")
                            self.statusLabel.text = ""
                            self.goToMainApp()
                        }
                    }
                } else
                {
                    self.statusLabel.text = "Could not retrieve current user"
                }
            }
        }
    }
    
    func goToMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let tabBarController = storyboard.instantiateViewController(
            withIdentifier: "MainTabBarController"
        ) as? UITabBarController else {
            return
        }

        self.view.window?.rootViewController = tabBarController
        self.view.window?.makeKeyAndVisible()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
