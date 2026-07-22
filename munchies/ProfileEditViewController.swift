//
//  ProfileEditViewController.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/17/26.
//

import UIKit
import PhotosUI

class ProfileEditViewController: UIViewController, PHPickerViewControllerDelegate
{
    @IBOutlet weak var profileImageView:UIImageView!
    var pickerConfig:PHPickerConfiguration!
    var picker:PHPickerViewController!
    
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
                    if authStatus == PHAuthorizationStatus.authorized || authStatus == PHAuthorizationStatus.limited
                    {
                        self.present(self.picker, animated: true)
                    }
                }
            case PHAuthorizationStatus.denied:
                let alert = UIAlertController(title: "Photo Access", message: "Access to your photo library is required to add or change your profile image", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "no thanks", style: UIAlertAction.Style.cancel)
                let settingsAction = UIAlertAction(title: "open settings?", style: UIAlertAction.Style.default)
                {alert in
                    if let url = URL(string: UIApplication.openSettingsURLString)
                    {
                        UIApplication.shared.open(url)
                    }
                }
                alert.addAction(cancelAction)
                alert.addAction(settingsAction)
                present(alert, animated: true)
            case PHAuthorizationStatus.restricted:
                break
            case PHAuthorizationStatus.limited:
                break
            default:
                break
        }
    }
    
    func createAlert(title:String, _ message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okayAction = UIAlertAction(title: "okay", style: UIAlertAction.Style.default)
        alert.addAction(okayAction)
        present(alert, animated: true)
    }
}
