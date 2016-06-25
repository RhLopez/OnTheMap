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
                self.getSessionDictionary(data, completionHandlerForSessionDict: { (success, dictionary, errorString) in
                    if success {
                        self.getSessionId(dictionary!, completHandlerForSessiondId: { (success, errorString) in
                            if success {
                                completionHandlerForLogOut(success: true, errorString: nil)
                            } else {
                                completionHandlerForLogOut(success: false, errorString: errorString)
                            }
                        })
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
                self.getAccountDictionary(data, completionHandlerForAccountDict: { (success, dictionary, errorString) in
                    if success {
                        self.getAccountStatus(dictionary!, completionHandlerForAccount: { (success, errorString) in
                            if success {
                                self.getUserId(dictionary!, completionHandlerForUserId: { (success, errorString) in
                                    if success {
                                        self.getSessionDictionary(data, completionHandlerForSessionDict: { (success, dictionary, errorString) in
                                            if success {
                                                self.getSessionId(dictionary!, completHandlerForSessiondId: { (success, errorString) in
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
                                    } else {
                                        completionHandlerForAccountData(success: false, errorString: errorString)
                                    }
                                })
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
    
    func getAccountDictionary(data: AnyObject, completionHandlerForAccountDict: (success: Bool, dictionary: [String:AnyObject]?, errorString: String?) -> Void) {
        if let account = data["account"] as? [String:AnyObject] {
            completionHandlerForAccountDict(success: true, dictionary: account, errorString: nil)
        } else {
            completionHandlerForAccountDict(success: false, dictionary: nil, errorString: "Login Failed (No Account Data Returned)")
        }
    }
    
    func getAccountStatus(dictionary: [String:AnyObject], completionHandlerForAccount: (success: Bool, errorString: String?) -> Void) {
        if let registered = dictionary["registered"] as? Bool {
            if registered == true {
                completionHandlerForAccount(success: true, errorString: nil)
            } else {
                completionHandlerForAccount(success: false, errorString: "Account is not registered")
            }
        }
    }
    
    func getUserId(dictionary: [String:AnyObject], completionHandlerForUserId: (success: Bool, errorString: String?) -> Void) {
        if let studentId = dictionary["key"] as? String {
            
            Student.sharedInstance().userId = studentId
            completionHandlerForUserId(success: true, errorString: nil)
        } else {
            completionHandlerForUserId(success: false, errorString: "No Student Id returned")
        }
    }
    
    func getSessionDictionary(data: AnyObject, completionHandlerForSessionDict: (success: Bool, dictionary: [String:AnyObject]?, errorString: String?) -> Void) {
        if let session = data["session"] as? [String:AnyObject] {
            completionHandlerForSessionDict(success: true, dictionary: session, errorString: nil)
        } else {
            completionHandlerForSessionDict(success: false, dictionary: nil, errorString: "Login Failed (No Session Data Returned)")
        }
    }
    
    func getSessionId(dictionary: [String:AnyObject], completHandlerForSessiondId: (success: Bool, errorString: String?) -> Void) {
        if let sessionId = dictionary["id"] as? String {
            self.sessionId = sessionId
            completHandlerForSessiondId(success: true, errorString: nil)
        } else {
            completHandlerForSessiondId(success: false, errorString: "No Session Id returned")
        }
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
