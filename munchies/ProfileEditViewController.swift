//
//  ProfileEditViewController.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/17/26.
//

import UIKit

class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var profileImageView:UIImageView!
    let picker:UIImagePickerController = UIImagePickerController()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.layer.masksToBounds = true
        picker.delegate = self
    }

    @IBAction func onEditImage(_ sender:Any)
    {
    }
}
