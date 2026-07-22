//
//  ProfileViewController.swift
//  munchies
//
//  Created by Adriana Monica Reyes on 7/11/26.
//

import UIKit

class ProfileViewController: UIViewController
{
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.layer.masksToBounds = true
        usernameLabel.layer.cornerRadius = usernameLabel.bounds.height / 2
        usernameLabel.layer.masksToBounds = true // sigh
    }
}
