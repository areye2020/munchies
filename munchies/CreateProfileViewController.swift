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
class CreateProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
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
        
        statusLabel.text = nil
        statusLabel.isHidden = true
    }
    
    
    @IBAction func donePressed(_ sender: Any) {
        if usernameField.text == "" {
            statusLabel.text = "Please choose a username"
            statusLabel.isHidden = false
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
                print("No logged in user")
                return
            }

            let profileData: [String: Any] = [
                "username": usernameField.text ?? "",
                "bio": bioTextView.text ?? "",
                "profileImageURL": "",
            ]

            db.collection("users")
                .document(uid)
                .setData(profileData) { error in
                    
                    if let error = error {
                        print("Error saving profile: \(error.localizedDescription)")
                        return
                    }

                    print("Profile saved!")
                    self.statusLabel.isHidden = true
                    self.goToMainApp()
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
