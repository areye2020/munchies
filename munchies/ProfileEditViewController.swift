//
//  ProfileEditViewController.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/17/26.
//

import UIKit
import PhotosUI
import FirebaseFirestore
import FirebaseAuth

class ProfileEditViewController: UIViewController, PHPickerViewControllerDelegate, UITextFieldDelegate
{
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var usernameTextField:RoundedTextField!
    @IBOutlet weak var statusLabel:UILabel!
    let maxUsernameLength:Int = 16
    let accessMessage:String = "Access to your photo library is required to add or change your "
        + "profile image"
    let database:Firestore = Firestore.firestore()
    var pickerConfig:PHPickerConfiguration!
    var picker:PHPickerViewController!
    var currentUser:User!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.layer.masksToBounds = true
        pickerConfig = PHPickerConfiguration()
        pickerConfig.filter = PHPickerFilter.images
        pickerConfig.selectionLimit = 1
        picker = PHPickerViewController(configuration: pickerConfig)
        picker.delegate = self
        usernameTextField.delegate = self
        usernameTextField.font = UIFont.systemFont(ofSize: 22)
        statusLabel.text = ""
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        updateCurrentUser()
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches:Set<UITouch>, with event:UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func updateCurrentUser()
    {
        if let user:FirebaseAuth.User = Auth.auth().currentUser
        {
            currentUser = User(UID: user.uid)
            {(newUser) in
                if newUser != nil
                {
                    self.usernameTextField.text = newUser!.username
                } else
                {
                    self.statusLabel.text = "error: could not retrieve user data"
                }
            }
        } else
        {
            statusLabel.text = "error: could not get current user"
        }
    }
    
    func textField(_ textField:UITextField, shouldChangeCharactersIn range:NSRange, replacementString string:String) -> Bool
    {
        let newString:String = (textField.text as? NSString)!.replacingCharacters(in: range, with: string)
        return newString.count <= maxUsernameLength
    }

    func picker(_ picker:PHPickerViewController, didFinishPicking results:[PHPickerResult])
    {
        picker.dismiss(animated: true)
        if !results.isEmpty
        {
            let result:PHPickerResult = results[0]
            if result.itemProvider.canLoadObject(ofClass: UIImage.self)
            {
                result.itemProvider.loadObject(ofClass: UIImage.self)
                {(itemProviderReading, error) in
                    if let error
                    {
                        print(error)
                    } else if let image:UIImage = itemProviderReading as? UIImage
                    {
                        DispatchQueue.main.sync
                        {
                            self.profileImageView.image = image
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onEditImage(_ sender:Any)
    {
        switch PHPhotoLibrary.authorizationStatus(for: PHAccessLevel.readWrite)
        {
            case PHAuthorizationStatus.authorized:
                present(picker, animated: true)
            case PHAuthorizationStatus.notDetermined:
                PHPhotoLibrary.requestAuthorization(for: PHAccessLevel.readWrite)
                {authStatus in
                    if authStatus == PHAuthorizationStatus.authorized
                        || authStatus == PHAuthorizationStatus.limited
                    {
                        self.present(self.picker, animated: true)
                    }
                }
            case PHAuthorizationStatus.denied:
                let alert:UIAlertController = UIAlertController(title: "Photo Access",
                    message: accessMessage,
                    preferredStyle: UIAlertController.Style.alert)
                let cancelAction:UIAlertAction = UIAlertAction(title: "no thanks",
                    style: UIAlertAction.Style.cancel)
                let settingsAction:UIAlertAction = UIAlertAction(title: "open settings?",
                    style: UIAlertAction.Style.default)
                {alert in
                    if let url:URL = URL(string: UIApplication.openSettingsURLString)
                    {
                        UIApplication.shared.open(url)
                    }
                }
                alert.addAction(cancelAction)
                alert.addAction(settingsAction)
                present(alert, animated: true)
            case PHAuthorizationStatus.restricted:
                createAlert(title: "Photo Access", accessMessage)
            case PHAuthorizationStatus.limited:
                present(picker, animated: true)
            default:
                break
        }
    }
    
    func createAlert(title:String, _ message:String)
    {
        let alert:UIAlertController = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert)
        let okayAction:UIAlertAction = UIAlertAction(title: "okay",
            style: UIAlertAction.Style.default)
        alert.addAction(okayAction)
        present(alert, animated: true)
    }
    
    @IBAction func onSaveChangePress(_ sender:Any)
    {
        if let newUsername:String = usernameTextField.text,
           newUsername != ""
        {
            if newUsername != currentUser.username
            {
                let database:Firestore = Firestore.firestore()
                database.collection(userCollectionID).whereField("username", isEqualTo: newUsername).getDocuments()
                {(querySnapshot, error) in
                    if let error
                    {
                        self.statusLabel.text = error.localizedDescription
                    } else
                    {
                        if let querySnapshot,
                           querySnapshot.documents.count > 0
                        {
                            self.statusLabel.text = "username already taken"
                        } else
                        {
                            database.collection(userCollectionID).document(self.currentUser.uid!).updateData(["username": newUsername])
                            {(error) in
                                if let error
                                {
                                    self.statusLabel.text = error.localizedDescription
                                } else
                                {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
