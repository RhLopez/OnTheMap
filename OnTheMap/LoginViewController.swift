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
        if emailTextField.hasText() && passwordTextField.hasText() {
            activityIndicator.startAnimating()
            Udacity.sharedInstance().logIn(emailTextField.text!, password: passwordTextField.text!, completionHandlerForLogIn: { (success, errorString) in
                dispatch_async(dispatch_get_main_queue(), { 
                    if success {
                        if success {
                            self.activityIndicator.stopAnimating()
                            self.completeLogin()
                        } else {
                            print(errorString!)
                            self.activityIndicator.stopAnimating()
                            AlerView.showAlert(self, message: "Unable To Retrieve User Information\nPlease Try Again.")
                        }
                    } else {
                        self.activityIndicator.stopAnimating()
                        AlerView.showAlert(self, message: "Invalid Email/Password")
                    }
                })
            })
        } else {
            AlerView.showAlert(self, message: "Email/Password Field Empty")
        }
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Udacity.sharedInstance().signUpUrl())
    }
    
    
    func completeLogin() {
        let masterTabController = storyboard!.instantiateViewControllerWithIdentifier("MasterTabController") as! UITabBarController
        presentViewController(masterTabController, animated: true, completion: nil)
    }
    
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
