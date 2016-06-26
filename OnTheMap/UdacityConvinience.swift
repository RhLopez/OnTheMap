//
//  UdacityConvinience.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 6/21/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import Foundation

extension Udacity {
    
    func signUpUrl() -> NSURL {
        return NSURL(string: Constants.signUpUrl)!
    }
    
    func logIn(email: String, password: String, completionHandlerForLogIn: (success: Bool, errorString: String?) -> Void) {
        let jsonBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        
        self.getAccountData(jsonBody) { (success, errorString) in
            if success {
                self.getUserData({ (success, errorString) in
                    if success {
                        completionHandlerForLogIn(success: true, errorString: nil)
                    } else {
                        completionHandlerForLogIn(success: false, errorString: errorString)
                    }
                })
            } else {
                completionHandlerForLogIn(success: false, errorString: errorString)
            }
        }
    }
    
    func logOut(completionHandlerForLogOut: (success: Bool, errorString: String?) -> Void) {
        taskForDeleteMethod { (data, error) in
            if let error = error {
                print(error)
                completionHandlerForLogOut(success: false, errorString: "Unable to Log Out (Error in Data)")
            } else {
                self.getSessionID(data, completionHandlerForSessionId: { (success, errorString) in
                    if success {
                        completionHandlerForLogOut(success: true, errorString: nil)
                    } else {
                        completionHandlerForLogOut(success: false, errorString: errorString)
                    }
                })
            }
        }
    }
    
    func getAccountData(jsonBody: String, completionHandlerForAccountData: (success: Bool, errorString: String?) -> Void) {
        taskForPostMethod(jsonBody) { (data, error) in
            if let error = error {
                print(error)
                completionHandlerForAccountData(success: false, errorString: "Unable to Log In (Error in Data)")
            } else {
                self.getAccountDetails(data, completionHanderForAccountDetails: { (success, errorString) in
                    if success {
                        self.getSessionID(data, completionHandlerForSessionId: { (success, errorString) in
                            if success {
                                completionHandlerForAccountData(success: true, errorString: nil)
                            } else {
                                completionHandlerForAccountData(success: false, errorString: errorString)
                            }
                        })
                    } else {
                        completionHandlerForAccountData(success: false, errorString: errorString)
                    }
                })
            }
        }
    }
    
    func getUserData(completionHandlerForUserData: (success: Bool, errorString: String?) -> Void) {
        taskForGetMethod { (data, error) in
            if let error = error {
                print(error)
                completionHandlerForUserData(success: false, errorString: "Unable to get User Data (Error in Data)")
            } else {
                self.processUserData(data, completionHandlerForProcessUser: { (success, errorString) in
                    if success {
                        completionHandlerForUserData(success: true, errorString: nil)
                    } else {
                        completionHandlerForUserData(success: false, errorString: errorString)
                    }
                })
            }
        }
    }

    func getAccountDetails(data: AnyObject, completionHanderForAccountDetails: (success: Bool, errorString: String?) -> Void) {
        func reportError(error: String) {
            completionHanderForAccountDetails(success: false, errorString: error)
        }
        
        guard let account = data["account"] as? [String:AnyObject] else {
            reportError("No account data returned in: \(data)")
            return
        }
        
        guard let registered = account["registered"] as? Bool where registered == true else {
            reportError("Account is not registered")
            return
        }
        
        guard let userId = account["key"] as? String else {
            reportError("No Student Id returned")
            return
        }
        
        Student.sharedInstance().registeredAccount = registered
        Student.sharedInstance().userId = userId
        
        completionHanderForAccountDetails(success: true, errorString: nil)
    }
    
    func getSessionID(data: AnyObject, completionHandlerForSessionId: (success: Bool, errorString: String?) -> Void) {
        func reportError(error: String) {
            completionHandlerForSessionId(success: false, errorString: error)
        }
        
        guard let session = data["session"] as? [String:AnyObject] else {
            reportError("No session data returned in: \(data)")
            return
        }
        
        guard let sessionId = session["id"] as? String else {
            reportError("No session id returned in: \(data)")
            return
        }
        
        self.sessionId = sessionId
        
        completionHandlerForSessionId(success: true, errorString: nil)
    }
    
    func processUserData(data: AnyObject, completionHandlerForProcessUser: (success: Bool, errorString: String?) -> Void) {
        func reportError(error: String) {
            completionHandlerForProcessUser(success: false, errorString: error)
        }
        
        guard let user = data["user"] as? [String:AnyObject] else {
            reportError("No value for key 'user' in: \(data)")
            return
        }
        
        guard let firstName = user["first_name"] as? String else {
            reportError("No value for key 'first_name' in: \(data)")
            return
        }
        
        guard let lastName = user["last_name"] as? String else {
            reportError("No value for key 'last_name' in: \(data)")
            return
        }
        
        Student.sharedInstance().firstName = firstName
        Student.sharedInstance().lastName = lastName
        
        completionHandlerForProcessUser(success: true, errorString: nil)
    }
}
