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
    let megaByte:Int64 = 1024 * 1024
    var maxImageSize:Int64!
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
        maxImageSize = 2 * megaByte
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
                    let storageRef:Storage = Storage.storage()
                    let profilePicRef:StorageReference = storageRef.reference().child("profileImages/\(newUser!.uid!).jpg")
                    profilePicRef.getData(maxSize: self.maxImageSize)
                    {(data, error) in
                        if let error
                        {
                            print(error.localizedDescription)
                        } else
                        {
                            self.profileImageView.image = UIImage(data: data!)
                        }
                    }
                    self.usernameLabel.text = newUser!.username
                    self.bioLabel.text = newUser!.bio
                }
            }
        }
    }
}
