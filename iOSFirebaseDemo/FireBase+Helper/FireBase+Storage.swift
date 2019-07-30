//
//  FireBase+Storage.swift
//  iOSFirebaseDemo
//
//  Created by Mandeep Singh on 30/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import Foundation
import FirebaseStorage

class BucketStorage {
    
    private init() {}
    
    static let shared = BucketStorage()
    
    private let bucketReference = Storage.storage(url: Constants.bucketURL).reference()
    
    private func createReference() -> StorageReference  {
        
        let imageID = Constants.generateID()
        let riversRef = bucketReference.child("\(Constants.mediaPath + imageID).jpg")
        return riversRef
    }
    
    func uploadMedia(data: Data, onResponse: @escaping Handlers.response) {
        
        let reference = self.createReference()
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = reference.putData(data, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                onResponse(nil, error)
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            print(size)
            // You can also access to download URL after upload.
            reference.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    onResponse(nil, error)
                    return
                }
                onResponse(downloadURL as AnyObject?, nil)
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            
            print(percentComplete)
        }

    }
    
    func uploadMedia(localPath: URL, onResponse: @escaping Handlers.response) {
        
        let reference = self.createReference()
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = reference.putFile(from: localPath, metadata: metadata) { metadata, error in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                onResponse(nil, error)
                return
            }
            let size = metadata.size
            print(size)

            reference.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    onResponse(nil, error)
                    return
                }
                onResponse(downloadURL as AnyObject?, nil)
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            
            print(percentComplete)
        }
    }
}

