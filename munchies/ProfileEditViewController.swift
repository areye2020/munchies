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

class ProfileEditViewController: UIViewController, PHPickerViewControllerDelegate,
    UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var usernameTextField:RoundedTextField!
    @IBOutlet weak var bioTextView:UITextView!
    @IBOutlet weak var statusLabel:UILabel!
    let storage:Storage = Storage.storage()
    let accessMessage:String = "Access to your photo library is required to add or change your "
        + "profile image"
    let usernameTextFieldFontSize:CGFloat = 22
    let database:Firestore = Firestore.firestore()
    var pickerConfig:PHPickerConfiguration!
    var picker:PHPickerViewController!
    var newImageRef:StorageReference!
    var currentUser:User!
    
    var usernameSaved:Bool = true
    var bioSaved:Bool = true
    var avatarSaved:Bool = false
    
    override func viewDidLoad() {
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
    
    override func viewWillAppear(_ animated:Bool) {
        self.tabBarController?.setTabBarHidden(true, animated: true)
        updateCurrentUser()
    }
    
    override func viewWillDisappear(_ animated:Bool) {
        self.tabBarController?.setTabBarHidden(false, animated: true)
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
    
    // retrieve the current user so that their data can be set correctly
    func updateCurrentUser() {
        if let user:FirebaseAuth.User = Auth.auth().currentUser {
            currentUser = User(UID: user.uid) { (newUser) in
                if let newUser {
                    if newUser.imageURL != "" {
                        let profilePicRef:StorageReference = self.storage
                            .reference(forURL: newUser.imageURL)
                        profilePicRef.getData(maxSize: maxImageSize) { (data, error) in
                            if let error {
                                self.statusLabel.text = error.localizedDescription
                            } else {
                                self.profileImageView.image = UIImage(data: data!)
                            }
                        }
                    }
                    self.usernameTextField.text = newUser.username
                    self.bioTextView.text = newUser.bio
                } else {
                    self.statusLabel.text = "error: could not retrieve user data"
                }
            }
        } else {
            statusLabel.text = "error: could not get current user"
        }
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

    // update the user's avatar
    func picker(_ picker:PHPickerViewController, didFinishPicking results:[PHPickerResult]) {
        picker.dismiss(animated: true)
        if !results.isEmpty {
            let result:PHPickerResult = results[0]
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider
                    .loadObject(ofClass: UIImage.self) { (itemProviderReading, error) in
                    if let error {
                        print(error)
                    } else if let image:UIImage = itemProviderReading as? UIImage {
                        DispatchQueue.main.sync
                        {
                            self.profileImageView.image = image
                            self.avatarSaved = false
                        }
                    }
                }
            }
        }
    }
    
    // attempt to open the user's photo library
    // prompt the user to change their settings if they have denied access
    // displays an appropriate error message otherwise
    @IBAction func onEditImage(_ sender:Any) {
        switch PHPhotoLibrary.authorizationStatus(for: PHAccessLevel.readWrite) {
            case PHAuthorizationStatus.authorized:
                present(picker, animated: true)
            case PHAuthorizationStatus.notDetermined:
                PHPhotoLibrary.requestAuthorization(for: PHAccessLevel.readWrite) { authStatus in
                    if authStatus == PHAuthorizationStatus.authorized
                        || authStatus == PHAuthorizationStatus.limited {
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
                    style: UIAlertAction.Style.default) { alert in
                        if let url:URL = URL(string: UIApplication.openSettingsURLString) {
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
    // suitible for simple alerts
    func createAlert(title:String, _ message:String) {
        let alert:UIAlertController = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert)
        let okayAction:UIAlertAction = UIAlertAction(title: "okay",
            style: UIAlertAction.Style.default)
        alert.addAction(okayAction)
        present(alert, animated: true)
    }
    
    // attempt to save the changes made to the user's profile
    @IBAction func onSaveChangePress(_ sender:Any) {
        statusLabel.text = ""
        usernameSaved = false
        bioSaved = false
        
        if !avatarSaved {
            if currentUser.imageURL != "" {
                let oldImageRef:StorageReference = storage.reference(forURL: currentUser.imageURL)
                oldImageRef.delete() { (error) in
                    if let error {
                        self.addToStatus(error.localizedDescription)
                    } else {
                        self.uploadImage()
                    }
                }
            } else {
                uploadImage()
            }
        }
        
        if let newUsername:String = usernameTextField.text,
           newUsername != "" {
            if newUsername != currentUser.username {
                currentUser.updateUsernameAndBio(newName: newUsername,
                    newBio: bioTextView.text) { (error) in
                    if error != nil {
                        self.addToStatus(error!.localizedDescription)
                    } else {
                        self.usernameSaved = true
                        self.addToStatus("username saved!")
                    }
                }
            } else {
                usernameSaved = true
            }
        }
        
        if let newBio:String = bioTextView.text,
           newBio != "" {
            if newBio != currentUser.bio {
                currentUser.bio = newBio
                bioSaved = true
                addToStatus("bio saved!")
            } else {
                bioSaved = true
            }
        }
    }
    
    // attempt to upload the user's new avatar
    func uploadImage() {
        if let newImage:UIImage = profileImageView.image {
            if let newImageData:Data = newImage.jpegData(compressionQuality: jpgCompression) {
                newImageRef = storage.reference()
                    .child("\(profileImagesPath)\(currentUser.uid!).jpg")
                newImageRef.putData(newImageData, completion: onUpload)
            } else {
                addToStatus("error: could not compress image")
            }
        } else {
            addToStatus("error: could not upload new image")
        }
    }
    
    // helper function for uploadImage
    // relays to the user whether their new avatar was uploaded successfully or not
    func onUpload(metadata:StorageMetadata?, error:(any Error)?) {
        if let error {
            addToStatus(error.localizedDescription)
        } else {
            newImageRef.downloadURL() { (url, error) in
                if let error {
                    self.addToStatus(error.localizedDescription)
                } else {
                    self.avatarSaved = true
                    self.currentUser.imageURL = url!.absoluteString
                    self.addToStatus("avatar saved!")
                }
            }
        }
    }
    
    // add a message to the status label on a new line
    // if the label is blank, the message is added on the first line instead
    func addToStatus(_ message:String) {
        if statusLabel.text == "" {
            statusLabel.text = message
        } else {
            statusLabel.text! += "\n" + message
        }
    }
    
    // confirm the user wants to log out with an alert
    @IBAction func onLogOut(_ sender:Any) {
        let hasUnsavedChanges:Bool = !(usernameSaved && bioSaved && avatarSaved)
        let alert:UIAlertController = UIAlertController(title: "Logging Out",
            message: "\(hasUnsavedChanges ? "You haved unsaved changes. " : "")"
                + "Are you sure you want to log out?",
            preferredStyle: UIAlertController.Style.alert)
        let cancelAction:UIAlertAction = UIAlertAction(title: "cancel",
            style: UIAlertAction.Style.cancel)
        let imSureAction:UIAlertAction = UIAlertAction(title: "I'm sure",
            style: UIAlertAction.Style.destructive, handler: logoutHandler)
        alert.addAction(cancelAction)
        alert.addAction(imSureAction)
        present(alert, animated: true)
    }
    
    // attempt to log the user out and return them to the login screen
    func logoutHandler(alertAction:UIAlertAction) {
        do {
            try Auth.auth().signOut()
            let initialViewController = self.storyboard!
                .instantiateViewController(withIdentifier: "login")
            let navController = UINavigationController
                .init(rootViewController: initialViewController)

            self.view.window?.rootViewController = navController
            self.view.window?.makeKeyAndVisible()
        } catch {
            createAlert(title: "Error", "could not log out")
        }
    }
}
