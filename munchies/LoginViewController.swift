//
//  LoginViewController.swift
//  Project: munchies
//  Eid: ln8223
//  Course: CS371L
//  Created by Nhem, Logan on 7/13/26.
//

import UIKit

// remember to add keyboard
// we want this to segue to a profile screen for setup
class LoginViewController: UIViewController {

    @IBOutlet weak var pwField: RoundedTextField!
    @IBOutlet weak var userField: RoundedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userField.placeholder = "Username"
        pwField.placeholder = "Password"
        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginPressed(_ sender: Any) {
    }
    
    @IBAction func signupPressed(_ sender: Any) {
    }
    

}
