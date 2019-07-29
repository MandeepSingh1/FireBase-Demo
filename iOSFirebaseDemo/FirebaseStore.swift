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

struct FireBaseTable {
    enum Name : String {
        case userList = "UsersList"
    }
}

struct Handlers {
    
    typealias response = (_ data :AnyObject?, _ err: Error?) -> ()
}

class FireBaseSingelton {
    
    private init() {}
    
    static let sharedInstance = FireBaseSingelton()
    
    let db = Firestore.firestore()

    //MARK:- Insert objects into the table.
    func insertData(dict: Dictionary<String, AnyObject>, tableName:FireBaseTable.Name, onResponse: @escaping Handlers.response) {
        
        var ref: DocumentReference? = nil
        ref = db.collection(tableName.rawValue).addDocument(data: [
            "email": dict["email"] as AnyObject,
            "name": dict["name"] as AnyObject,
            "password": dict["password"] as AnyObject,
            "phoneNumber": dict["phoneNumber"] as AnyObject,
            "dob": dict["dob"] as AnyObject
        ]) { err in
            if let err = err {
                onResponse(nil, err)
            } else {
                onResponse(ref!.documentID as AnyObject, nil)
            }
        }
    }
    
    //MARK:- Fetch all the values from the table
    func fetchObjectsFrom(tableName:FireBaseTable.Name) {

        db.collection(tableName.rawValue).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    func fetchSingleObject(tableName:FireBaseTable.Name, referenceID: String, onResponse: @escaping Handlers.response) {
        
        db.collection(tableName.rawValue).document(referenceID).getDocument { (object, error) in
            if let err = error {
                onResponse(nil, err)
            } else {
                onResponse(object!.data() as AnyObject?, nil)
            }
        }
    }
    
    func deleteObject(tableName:FireBaseTable.Name, referenceID: String) {
        
        db.collection(tableName.rawValue).document(referenceID).delete { (error) in
            print(error?.localizedDescription ?? "manu")
        }
    }
    
    //MARK:- Login into FireBase
    func loginToFireBase(dict: Dictionary<String, AnyObject>, onResponse: @escaping Handlers.response) {
        
        Auth.auth().signIn(withEmail: dict["email"] as? String ?? "", password: dict["password"] as? String ?? "") { (snapShot, error) in
            if error != nil  {
                onResponse(nil, error)
            } else {
                
                if let referID = snapShot?.user.uid {
                    self.fetchSingleObject(tableName: .userList, referenceID: referID, onResponse: { (userModel, err) in
                        if error != nil {
                            onResponse(nil, error)
                        } else {
                            onResponse(userModel, nil)
                        }
                    })
                }
            }
        }
    }
    
    
    //MARK:- Register on Firebase
    func createUseronFirebase(dict: Dictionary<String, AnyObject>, onResponse: @escaping Handlers.response) {
        
        Auth.auth().createUser(withEmail: dict["email"] as? String ?? "", password: dict["password"] as? String ?? "") { (snapShot, error) in
            
            guard error == nil else {
                onResponse(nil, error)
                return
            }
            
            var oldParameters = dict
            oldParameters["dob"] = "08/11/1992" as AnyObject
            
            self.createUserOnFireStore(userID: snapShot?.user.uid ?? "", dict: oldParameters, onResponse: { (responseObject, error) in
                if error != nil  {
                    onResponse(nil, error)
                } else {
                    onResponse(responseObject, nil)
                }
            })
        }
    }
    
    //MARK:- Register on FireStore
    private func createUserOnFireStore(userID: String, dict: Dictionary<String, AnyObject>, onResponse: @escaping Handlers.response) {
        //Stored Objects in the Cloud Store FireBase
        let newUserReference = db.collection(FireBaseTable.Name.userList.rawValue).document(userID)
        newUserReference.setData(dict) { (err) in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                self.fetchSingleObject(tableName: .userList, referenceID: userID, onResponse: onResponse)
            }
        }
    }
}
