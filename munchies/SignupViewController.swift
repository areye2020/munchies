//
//  SignupViewController.swift
//  Project: munchies
//  Eid: ln8223
//  Course: CS371L
//  Created by Nhem, Logan on 7/17/26.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userField: RoundedTextField!
    @IBOutlet weak var pwField: RoundedTextField!
    @IBOutlet weak var confirmField: RoundedTextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var pwMatchImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userField.placeholder = "Email"
        userField.delegate = self
        pwField.placeholder = "Password"
        pwField.delegate = self
        confirmField.placeholder = "Confirm Password"
        confirmField.delegate = self
        pwField.isSecureTextEntry = true
        confirmField.isSecureTextEntry = true
        pwField.addTarget(self, action: #selector(passwordsChanged), for: .editingChanged)
        confirmField.addTarget(self, action: #selector(passwordsChanged), for: .editingChanged)
        pwMatchImage.isHidden = true
        statusLabel.text = nil
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
    
    @IBAction func createPressed(_ sender: Any) {
        let user = userField.text!
        let pass = pwField.text!
        let confirm = confirmField.text!
        // Check for errors
        if user.isEmpty || pass.isEmpty {
            statusLabel.text = "Please enter an email and password"
            return
        }
        // Have password requirements?
        if confirm != pass {
            statusLabel.text = "Passwords do not match"
            return
        }
        // Create User
        Auth.auth().createUser(withEmail: user, password: pass) { authResult, error in
            if let error = error as NSError? {
                self.statusLabel.text = error.localizedDescription
            } else if let newUID = authResult?.user.uid {
                let newUser = User(UID: newUID, username: user)
                if let userData = newUser.asDictionary() {
                    Firestore.firestore().collection(userCollectionID).document(newUID).setData(userData) { error in
                        if let error = error as? NSError {
                            self.statusLabel.text = error.localizedDescription
                        } else
                        {
                            self.statusLabel.text = nil
                            // User is signed in, create profile
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            
                            guard let createProfileVC = storyboard.instantiateViewController(
                                withIdentifier: "CreateProfileViewController"
                            ) as? CreateProfileViewController else {
                                print("Could not find create profile vc")
                                return
                            }
                            
                            self.view.window?.rootViewController = createProfileVC
                            self.view.window?.makeKeyAndVisible()
                        }
                    }
                }
            } else {
                self.statusLabel.text = "error: new user could not be generated"
            }
        }
    }
    
    @objc func passwordsChanged() {
        guard
            let pass = pwField.text,
            let confirm = confirmField.text
        else { return }
        
        if confirm.isEmpty {
            pwMatchImage.isHidden = true
            return
        }
        
        pwMatchImage.isHidden = false
        
        if pass == confirm {
            pwMatchImage.image = UIImage(systemName: "checkmark.circle.fill")
            pwMatchImage.tintColor = .systemGreen
        } else {
            pwMatchImage.image = UIImage(systemName: "xmark.circle.fill")
            pwMatchImage.tintColor = .systemRed
        }
    }
}
