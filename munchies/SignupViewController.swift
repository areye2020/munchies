//
//  SignupViewController.swift
//  Project: munchies
//  Eid: ln8223
//  Course: CS371L
//  Created by Nhem, Logan on 7/17/26.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var userField: RoundedTextField!
    @IBOutlet weak var pwField: RoundedTextField!
    @IBOutlet weak var confirmField: RoundedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userField.placeholder = "Username"
        pwField.placeholder = "Password"
        confirmField.placeholder = "Confirm Password"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func createPressed(_ sender: Any) {
    }
}
