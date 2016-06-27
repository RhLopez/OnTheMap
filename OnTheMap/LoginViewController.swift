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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        textFieldConfig(emailTextField)
        textFieldConfig(passwordTextField)
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        // Check internet connection
        if Reachability.isConnectedToNetwork() == true {
            // Check if user has entered email and password
            if emailTextField.hasText() && passwordTextField.hasText() {
                activityIndicator.startAnimating()
                Udacity.sharedInstance.logIn(emailTextField.text!, password: passwordTextField.text!, completionHandlerForLogIn: { (success, errorString) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if success {
                            self.activityIndicator.stopAnimating()
                            self.completeLogin()
                        } else {
                            print(errorString!)
                            self.activityIndicator.stopAnimating()
                            AlerView.showAlert(self, title: "Login Failed", message: "\(errorString!)\nPlease try again.")
                        }
                    })
                })
            } else {
                AlerView.showAlert(self, title: "Attention", message: "Email/Password Field Empty")
            }
        } else {
            AlerView.showAlert(self, title: "No Internet Connection", message: "Make Sure your device is connected to the internet.")
        }
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Udacity.sharedInstance.signUpUrl())
    }
    
    
    func completeLogin() {
        let masterTabController = storyboard!.instantiateViewControllerWithIdentifier("MasterTabController") as! UITabBarController
        presentViewController(masterTabController, animated: true, completion: nil)
    }
    
    // Configure appearance of login textfields
    func textFieldConfig(textField: UITextField) {
        let padding = UIView(frame: CGRectMake(0,0,15,textField.frame.height))
        textField.leftView = padding
        textField.leftViewMode = UITextFieldViewMode.Always
        let placeholderString = textField.tag == 0 ? "Email" : "Password"
        textField.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        textField.delegate = self
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            textFieldConfig(textField)
        }
    }
}
