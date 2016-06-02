//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 5/28/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        API.sharedInstance().udacityLogin(emailTextField.text!, password: passwordTextField.text!) { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), { 
                if success {
                    self.completeLogin()
                } else {
                    print("Unable to login")
                }
            })
        }
    }
    
    func completeLogin() {
        let masterTabController = storyboard!.instantiateViewControllerWithIdentifier("MasterTabController") as! UITabBarController
        presentViewController(masterTabController, animated: true, completion: nil)
    }
    
}
