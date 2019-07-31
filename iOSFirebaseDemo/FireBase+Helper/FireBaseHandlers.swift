//
//  FireBaseHandlers.swift
//  iOSFirebaseDemo
//
//  Created by Mandeep Singh on 30/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Photos
import MobileCoreServices

struct Table {
    enum Name : String {
        case userList = "UsersList"
    }
}

struct Handlers {
    typealias response = (_ data :AnyObject?, _ err: Error?) -> ()
    typealias callBack = (_ success:AnyObject) -> () // for success case
}


struct Constants {
    static let bucketURL = "gs://iosdemo-579ca.appspot.com/"
    static let folderName = "Bucket/"
    
    static func generateID() -> String {
        let timeStamp = Int(Date().toMillis())
        return "\(timeStamp)"
    }
}

extension Date {
    func toMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension UIViewController {
    
    func openImagePickerViewController(sourceType: UIImagePickerController.SourceType, mediaTypes: [String], callBack: Handlers.callBack?) {
        
        if sourceType == .camera {
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            switch cameraAuthorizationStatus {
                
            case .denied:
                self.alertPromptToAllowCameraAccessViaSetting(accessType: "Camera")
                callBack?(false as AnyObject)
            case .authorized:
                callBack?(true as AnyObject)
            case .restricted:
                self.alertPromptToAllowCameraAccessViaSetting(accessType: "Camera")
                callBack?(false as AnyObject)
            case .notDetermined:
                self.openAccessCameraPop(mediaTypes: mediaTypes, callBack: callBack)
            @unknown default:
                break
            }
        } else {
            let photsAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            
            switch photsAuthorizationStatus {
                
            case .denied:
                self.alertPromptToAllowCameraAccessViaSetting(accessType: "Library")
                callBack?(false as AnyObject)
            case .authorized:
                callBack?(true as AnyObject)
            case .restricted:
                self.alertPromptToAllowCameraAccessViaSetting(accessType: "Library")
                callBack?(false as AnyObject)
            case .notDetermined:
                self.openAccessPhotoLibraryPop(mediaTypes: mediaTypes, callBack: callBack)
            @unknown default:
                break
            }
        }
    }
    
    func openAccessCameraPop(mediaTypes: [String], callBack: Handlers.callBack?) {
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
            
            if granted {
                callBack?(true as AnyObject)
            } else {
                self.alertPromptToAllowCameraAccessViaSetting(accessType: "Camera")
            }
        }
    }
    
    func openAccessPhotoLibraryPop(mediaTypes: [String], callBack: Handlers.callBack?) {
        
        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus)in
            
            switch status {
                
            case .denied:
                self.alertPromptToAllowCameraAccessViaSetting(accessType: "Library")
                break
            case .authorized:
                callBack?(true as AnyObject)
                break
            case .restricted:
                self.alertPromptToAllowCameraAccessViaSetting(accessType: "Library")
                break
            case .notDetermined:
                self.alertPromptToAllowCameraAccessViaSetting(accessType: "Library")
                break
            @unknown default:
                break
            }
        })
    }
    
    func alertPromptToAllowCameraAccessViaSetting(accessType: String) {
        
        let alert = UIAlertController(title: "Access to \(accessType) is restricted", message: "You need to enable access to \(accessType). Apple Settings > Privacy > \(accessType).", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Settings", style: .cancel) { (alert) -> Void in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        })
        
        self.present(alert, animated: true)
    }
    
}



