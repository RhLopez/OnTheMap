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
        activityIndicator.startAnimating()
        API.sharedInstance().udacityLogin(emailTextField.text!, password: passwordTextField.text!) { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), { 
                if success {
                    self.activityIndicator.stopAnimating()
                    self.completeLogin()
                } else {
                    self.activityIndicator.stopAnimating()
                    self.showNotification()
                    print(errorString)
                }
            })
        }
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
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
    
    func showNotification() {
        //TODO: Specify if login failed because of connection or incorrect email/password
        let alert = UIAlertController(title: "Alert", message: "Invalid Login, Please try again.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            let textString = textField.tag == 0 ? "Email" : "Password"
            textField.placeholder = textString
        }
    }
}
