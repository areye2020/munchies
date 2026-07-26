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
import FirebaseStorage

class ProfileEditViewController: UIViewController, PHPickerViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate
{
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var usernameTextField:RoundedTextField!
    @IBOutlet weak var bioTextView:UITextView!
    @IBOutlet weak var statusLabel:UILabel!
    let storageRef:StorageReference = Storage.storage().reference()
    let accessMessage:String = "Access to your photo library is required to add or change your "
        + "profile image"
    let usernameTextFieldFontSize:CGFloat = 22
    let database:Firestore = Firestore.firestore()
    var pickerConfig:PHPickerConfiguration!
    var picker:PHPickerViewController!
    var currentUser:User!
    var hasChangedImage:Bool = false
    
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
        bioTextView.delegate = self
        usernameTextField.font = UIFont.systemFont(ofSize: usernameTextFieldFontSize)
        statusLabel.text = ""
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        self.tabBarController?.setTabBarHidden(true, animated: true)
        updateCurrentUser()
    }
    
    override func viewWillDisappear(_ animated:Bool)
    {
        self.tabBarController?.setTabBarHidden(false, animated: true)
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
    
    // retrieve the current user so that their data can be set correctly
    func updateCurrentUser()
    {
        if let user:FirebaseAuth.User = Auth.auth().currentUser
        {
            currentUser = User(UID: user.uid)
            {(newUser) in
                if newUser != nil
                {
                    self.usernameTextField.text = newUser!.username
                    self.bioTextView.text = newUser!.bio
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
    
    // only allow usernames up to maxUsernameLength in length
    func textField(_ textField:UITextField, shouldChangeCharactersIn range:NSRange,
        replacementString string:String) -> Bool
    {
        let newString:String = (textField.text as? NSString)!.replacingCharacters(in: range,
            with: string)
        return newString.count <= maxUsernameLength
    }
    
    func textView(_ textView:UITextView, shouldChangeTextIn range:NSRange, replacementText text:String) -> Bool
    {
        let newString:String = (textView.text as? NSString)!.replacingCharacters(in: range,
            with: text)
        return newString.count <= maxBioLength
    }

    // update the user's avatar
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
                            self.hasChangedImage = true
                        }
                    }
                }
            }
        }
    }
    
    // attempt to open the user's photo library
    // prompt the user to change their settings if they have denied access
    // displays an appropriate error message otherwise
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
    
    // create an alert with the given title and message
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
    
    // attempt to save the changes made to the user's profile
    // TODO only username changes are saved
    @IBAction func onSaveChangePress(_ sender:Any)
    {
        if let newUsername:String = usernameTextField.text,
           newUsername != ""
        {
            if newUsername != currentUser.username
            {
                currentUser.updateUsernameAndBio(newName: newUsername, newBio: bioTextView.text)
                {(error) in
                    if error != nil
                    {
                        self.statusLabel.text = error?.localizedDescription
                    } else if !self.hasChangedImage
                    {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            if hasChangedImage
            {
                let oldImage:StorageReference = storageRef.child("\(profileImagesPath)\(currentUser.uid!).jpg")
                oldImage.delete()
                {(error) in
                    if let error
                    {
                        self.statusLabel.text = error.localizedDescription
                    } else
                    {
                        if let newImage:UIImage = self.profileImageView.image
                        {
                            if let newImageData = newImage.jpegData(compressionQuality: jpgCompression)
                            {
                                // TODO
                            }
                        }
                    }
                }
            }
        }
        
        if let newBio:String = bioTextView.text,
           newBio != ""
        {
            currentUser.bio = newBio
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onLogOut(_ sender:Any)
    {
        var hasUnsavedChanges:Bool = false
        if usernameTextField.text != currentUser.username! // add bio stuff
        {
            hasUnsavedChanges = true
        }
        let alert:UIAlertController = UIAlertController(title: "Logging Out",
            message: "\(hasUnsavedChanges ? "You haved unsaved changes. " : "")"
                + "Are you sure you want to log out?",
            preferredStyle: UIAlertController.Style.alert)
        let cancelAction:UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel)
        let imSureAction:UIAlertAction = UIAlertAction(title: "I'm sure", style: UIAlertAction.Style.destructive, handler: logoutHandler)
        alert.addAction(cancelAction)
        alert.addAction(imSureAction)
        present(alert, animated: true)
    }
    
    func logoutHandler(alertAction:UIAlertAction)
    {
        do
        {
            try Auth.auth().signOut()
            let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "login")
            let navController = UINavigationController.init(rootViewController: initialViewController)

            self.view.window?.rootViewController = navController
            self.view.window?.makeKeyAndVisible()
        } catch
        {
            
        }
    }
}
