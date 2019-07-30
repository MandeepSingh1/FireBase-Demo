//
//  RegisterVC.swift
//  iOSFirebaseDemo
//
//  Created by Mandeep Singh on 29/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import UIKit
import FirebaseAuth
import MobileCoreServices

class RegisterVC: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var avatarImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func register(_ sender: UIButton) {
        
        guard let emailText = self.email.text, !emailText.isEmpty else {
            print("Empty Email text")
            return
        }
        
        guard let password = self.password.text, !password.isEmpty else {
            print("Empty password text")
            return
        }
        
        guard let name = self.name.text, !name.isEmpty else {
            print("Empty password text")
            return
        }
        
        guard let number = self.phoneNumber.text, !number.isEmpty else {
            print("Empty password text")
            return
        }
        
        if let image = self.avatarImage.image {
            
            guard let data = image.pngData() else {return}
            
            BucketStorage.shared.uploadMedia(data: data) { (url, error) in
                guard let bucketURL = url as? URL else {
                    print(error?.localizedDescription ?? "Not found")
                    return
                }
                
                var dict = Dictionary<String, AnyObject>()
                dict["name"] = name as AnyObject
                dict["email"] = emailText as AnyObject
                dict["password"] = password as AnyObject
                dict["phoneNumber"] = number as AnyObject
                dict["photo"] = bucketURL.absoluteString as AnyObject

                self.registerProcess(dict: dict)
            }
        } else {
            print("image not Selected")
        }
    }
    
    func registerProcess(dict:Dictionary<String, AnyObject>) {
        
        FireBaseSingelton.sharedInstance.createUseronFirebase(dict: dict) { (response, error) in
            
            if let err = error {
                print(err.localizedDescription)
            } else {
                print(response ?? "hureeey")
            }
        }
    }
    
    @IBAction func tapOnImage(_ sender: UIButton) {
        self.uploadProfilePicClick(sender: sender)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RegisterVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension RegisterVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:- Cell Delegates
    func uploadProfilePicClick(sender: UIButton) {
        
        let mediaTypeArray = [kUTTypeImage as String, kUTTypeMovie as String]
        
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Take Photo", style: .default)
        { _ in
            
            self.openImagePickerViewController(sourceType: .camera, mediaTypes: mediaTypeArray, callBack: { (isAllow) in
                if let allowed = isAllow as? Bool, allowed == true {
                    self.openImagePicker(sourceType: .camera, mediaTypes: mediaTypeArray)
                }
            })
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Choose Photo", style: .default)
        { _ in
            self.openImagePickerViewController(sourceType: .photoLibrary, mediaTypes: mediaTypeArray, callBack: { (isAllow) in
                if let allowed = isAllow as? Bool, allowed == true {
                    self.openImagePicker(sourceType: .photoLibrary, mediaTypes: mediaTypeArray)
                }
            })
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    func openImagePicker(sourceType: UIImagePickerController.SourceType, mediaTypes: [String]) {
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.mediaTypes = mediaTypes
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        DispatchQueue.main.async {
            self.avatarImage.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

