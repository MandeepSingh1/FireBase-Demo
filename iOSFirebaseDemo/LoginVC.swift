//
//  LoginVC.swift
//  iOSFirebaseDemo
//
//  Created by Mandeep Singh on 29/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        guard let emailText = self.email.text, !emailText.isEmpty else {
            print("Empty Email text")
            return
        }
        
        guard let password = self.password.text, !password.isEmpty else {
            print("Empty password text")
            return
        }
        
        var dict = Dictionary<String, AnyObject>()
        dict["email"] = emailText as AnyObject
        dict["password"] = password as AnyObject
        
        FireBaseSingelton.sharedInstance.loginToFireBase(dict: dict) { (response, error) in
            
            if let err = error {
                print(err.localizedDescription)
            } else {
                print(response ?? "hureeey")
            }
        }
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

extension LoginVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
