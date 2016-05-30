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
        
        let request = NSMutableURLRequest(URL: Udacity.udacityURL())
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(emailTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                print("There has been an error")
                return
            }
            
            guard let data = data else {
                print("There was no data returned!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            var parsedData: AnyObject!
            do {
                parsedData = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Unable to parse data from JSON")
                return
            }
            
            guard let session = parsedData["session"] as? [String:AnyObject] else {
                print("No key 'session' found")
                return
            }
            
            guard let sessionId = session["id"] as? String else {
                print("No key id found in session")
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.completeLogin()
            })
        }
        
        task.resume()
    }
    
    func completeLogin() {
        let masterTabController = storyboard!.instantiateViewControllerWithIdentifier("MasterTabController") as! UITabBarController
        presentViewController(masterTabController, animated: true, completion: nil)
    }
    
}
