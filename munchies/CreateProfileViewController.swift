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
import FirebaseStorage

// Adds the user to a profile in firestore
class CreateProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var selectedPFP = false
    let db = Firestore.firestore()
    var currentUser:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        bioTextView.delegate = self
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        profileImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(profileImageTapped))
        
        profileImageView.addGestureRecognizer(tapGesture)
        
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
    
    // only allow bios up to maxBioLength in length
    func textView(_ textView:UITextView, shouldChangeTextIn range:NSRange,
        replacementText text:String) -> Bool {
        let newString:String = (textView.text as? NSString)!.replacingCharacters(in: range,
            with: text)
        return newString.count <= maxBioLength
    }
    
    // Gesture function for selecting profile picture, choose options through action sheet
    @objc func profileImageTapped() {
        let alert = UIAlertController(title: "Profile Picture", message: "Choose a source",
            preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) {_ in
            self.openCamera()
        })
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) {_ in
            self.openPhotoLibrary()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert = UIAlertController(
                title: "Camera Unavailable",
                message: "The iOS Simulator doesn't have a camera. Please use a physical device "
                    + "to test this feature.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    // Receive image
    func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            profileImageView.image = image
            selectedPFP = true
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        guard let username = usernameField.text, !username.isEmpty else {
            statusLabel.text = "Please choose a username"
            return
        }
        
        // Get Firebase UID
        guard let uid = Auth.auth().currentUser?.uid else {
            statusLabel.text = "No logged in user"
            return
        }
        
        // Create local User object
        currentUser = User(UID: uid) { newUser in
            let saveProfile: (String) -> Void = { imageURL in
                guard let user = newUser else {
                    self.statusLabel.text = "Could not create user"
                    return
                }
                
                user.imageURL = imageURL
                
                user.updateUsernameAndBio(
                    newName: username,
                    newBio: self.bioTextView.text
                ) { error in
                    
                    if let error = error {
                        self.statusLabel.text = error.localizedDescription
                    } else {
                        self.goToMainApp()
                    }
                }
            }
            
            if self.selectedPFP {
                self.uploadProfileImage(uid: uid) { imageURL in
                    saveProfile(imageURL ?? "")
                }
            } else {
                saveProfile("")
            }
        }
    }
    
    func uploadProfileImage(uid: String, completion: @escaping (String?) -> Void) {
        guard let image = profileImageView.image else {
            completion(nil)
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: jpgCompression) else {
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage()
            .reference()
            .child("\(profileImagesPath)\(uid).jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload failed")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Could not get URL")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
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
}
