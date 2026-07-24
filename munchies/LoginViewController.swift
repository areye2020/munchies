//
//  LoginViewController.swift
//  Project: munchies
//  Eid: ln8223
//  Course: CS371L
//  Created by Nhem, Logan on 7/13/26.
//

import UIKit
import FirebaseCore
import FirebaseAuth

// remember to add keyboard
// we want this to segue to a profile screen for setup
class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var pwField: RoundedTextField!
    @IBOutlet weak var userField: RoundedTextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userField.placeholder = "Email"
        userField.delegate = self
        pwField.placeholder = "Password"
        pwField.delegate = self
        pwField.isSecureTextEntry = true
        statusLabel.text = nil
        // Do any additional setup after loading the view.
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
    

    @IBAction func loginPressed(_ sender: Any) {
        let user = userField.text!
        let pass = pwField.text!
        // Check for errors
        if user.isEmpty || pass.isEmpty {
            statusLabel.text = "Please enter an email and password"
            return
        }
        // Login User
        Auth.auth().signIn(withEmail: user, password: pass) { authResult, error in
            if let error = error as NSError? {
                self.statusLabel.text = error.localizedDescription
            } else {
                self.statusLabel.text = nil
                // Reset navigation stack
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                    guard let tabBarController = storyboard.instantiateViewController(
                        withIdentifier: "MainTabBarController"
                    ) as? UITabBarController else {
                        print("Could not find tab bar controller")
                        return
                    }

                    self.view.window?.rootViewController = tabBarController
                    self.view.window?.makeKeyAndVisible()
            }
        }
    }

}
