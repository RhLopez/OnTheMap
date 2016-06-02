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
        setUpTextField(emailTextField)
        setUpTextField(passwordTextField)
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        activityIndicator.startAnimating()
        API.sharedInstance().udacityLogin(emailTextField.text!, password: passwordTextField.text!) { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), { 
                if success {
                    self.activityIndicator.stopAnimating()
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
    
    func setUpTextField(textField: UITextField) {
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
}
