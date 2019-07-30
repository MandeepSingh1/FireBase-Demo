//
//  FirebaseStore.swift
//  iOSFirebaseDemo
//
//  Created by Mandeep Singh on 29/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth



class FireBaseSingelton {
    
    private init() {}
    
    static let sharedInstance = FireBaseSingelton()
    
    let db = Firestore.firestore()

    //MARK:- Insert objects into the table.
    func insertData(dict: Dictionary<String, AnyObject>, name:Table.Name, onResponse: @escaping Handlers.response) {
        
        var ref: DocumentReference? = nil
        ref = db.collection(name.rawValue).addDocument(data: dict) { err in
            if let err = err {
                onResponse(nil, err)
            } else {
                onResponse(ref!.documentID as AnyObject, nil)
            }
        }
    }
    
    //MARK:- Fetch all the values from the table
    func fetchObjectsFrom(name:Table.Name) {

        db.collection(name.rawValue).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    //MARK:- Fetch Particular Document from a table
    func fetchSingleObject(name:Table.Name, referenceID: String, onResponse: @escaping Handlers.response) {
        
        db.collection(name.rawValue).document(referenceID).getDocument { (object, error) in
            if let err = error {
                onResponse(nil, err)
            } else {
                onResponse(object!.data() as AnyObject?, nil)
            }
        }
    }
    
    //MARK:- Delete Particular Document from a table
    func deleteObject(name:Table.Name, referenceID: String) {
        
        db.collection(name.rawValue).document(referenceID).delete { (error) in
            print(error?.localizedDescription ?? "manu")
        }
    }
}

