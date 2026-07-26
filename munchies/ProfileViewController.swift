//
//  ProfileViewController.swift
//  Project: munchies
//  Eid:
//  Course: CS371L
//  Created by Adriana Monica Reyes on 7/11/26.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class ProfileViewController: UIViewController
{
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var usernameBackground:UIView!
    @IBOutlet weak var usernameLabel:UILabel!
    @IBOutlet weak var bioLabel:UILabel!
    var currentUser:User!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.layer.masksToBounds = true
        usernameBackground.layer.cornerRadius = usernameBackground.bounds.height / 2
        usernameLabel.layer.masksToBounds = true
        usernameLabel.text = ""
        bioLabel.text = ""
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        updateCurrentUser()
    }
    
    func updateCurrentUser()
    {
        if let user:FirebaseAuth.User = Auth.auth().currentUser
        {
            currentUser = User(UID: user.uid)
            {(newUser) in
                if newUser != nil
                {
                    if newUser!.imageURL != ""
                    {
                        let storageRef:Storage = Storage.storage()
                        let profilePicRef:StorageReference = storageRef.reference(forURL: newUser!.imageURL)
                        profilePicRef.getData(maxSize: maxImageSize)
                        {(data, error) in
                            if let error
                            {
                                print(error.localizedDescription)
                            } else
                            {
                                self.profileImageView.image = UIImage(data: data!)
                            }
                        }
                    }
                    self.usernameLabel.text = newUser!.username
                    self.bioLabel.text = newUser!.bio
                }
            }
        }
    }
}
