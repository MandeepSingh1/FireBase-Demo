//
//  AuthFireBase.swift
//  iOSFirebaseDemo
//
//  Created by Mandeep Singh on 30/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import Foundation
import FirebaseAuth

extension FireBaseSingelton {
    
    //MARK:- Login into FireBase with email and password
    func loginToFireBase(dict: Dictionary<String, AnyObject>, onResponse: @escaping Handlers.response) {
        
        Auth.auth().signIn(withEmail: dict["email"] as? String ?? "", password: dict["password"] as? String ?? "") { (snapShot, error) in
            if error != nil  {
                onResponse(nil, error)
            } else {
                
                if let referID = snapShot?.user.uid {
                    self.fetchSingleObject(name: .userList, referenceID: referID, onResponse: { (userModel, err) in
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
    
    
    //MARK:- Register on Firebase with email and firebase
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
    
    //MARK:- Register on FireStore with Avatar Model
    private func createUserOnFireStore(userID: String, dict: Dictionary<String, AnyObject>, onResponse: @escaping Handlers.response) {
        //Stored Objects in the Cloud Store FireBase
        let newUserReference = db.collection(Table.Name.userList.rawValue).document(userID)
        newUserReference.setData(dict) { (err) in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                self.fetchSingleObject(name: .userList, referenceID: userID, onResponse: onResponse)
            }
        }
    }
}
