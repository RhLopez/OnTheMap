//
//  API.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 5/30/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import Foundation

class API: NSObject {
    
    let session = NSURLSession.sharedSession()
    
    var udacitySessionID: String?
    
    func udacityLogin(email: String, password: String, completionHandlerForLogin: (success: Bool, errorString: String?) -> Void) {
        
        // TODO: Extract request code to own file
        let request = NSMutableURLRequest(URL: udacityURL())
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        taskForPostMethod(request, api: "Udacity") { (data, error) in
            
            if let error = error {
                completionHandlerForLogin(success: false, errorString: error.localizedDescription)
            } else {
                API.sharedInstance().parseUdacityLoginData(data, type: "login") { (success, error) in
                    if success {
                        self.getUserInfo({ (success, errorString) in
                            if success {
                                completionHandlerForLogin(success: true, errorString: nil)
                            } else {
                                completionHandlerForLogin(success: false, errorString: error?.localizedDescription)
                            }
                        })
                    } else {
                        completionHandlerForLogin(success: false, errorString: error?.localizedDescription)
                    }
                }
            }
        }
    }
    
    func getUserInfo(completionHandlerForUserInfo: (success: Bool, errorString: String?) -> Void) {

        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(Student.sharedInstance().accountKey!)")!)
        
        taskForGetMethod(request, api: "Udacity") { (data, error) in
            if let error = error {
                completionHandlerForUserInfo(success: false, errorString: error.localizedDescription)
            } else {
                API.sharedInstance().parseUdacityUserData(data, completionHandlerForUserData: { (success, error) in
                    if success {
                        completionHandlerForUserInfo(success: true, errorString: nil)
                    } else {
                        completionHandlerForUserInfo(success: false, errorString: error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    func loginToParse(completionHandlerForParse: (success: Bool, errorString: String?) -> Void) {
       
        // TODO: Extract request code to own file
        let request = NSMutableURLRequest(URL: parseURL())
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        taskForPostMethod(request, api: "Parse") { (data, error) in
            if let error = error {
                completionHandlerForParse(success: false, errorString: error.localizedDescription)
            } else {
                API.sharedInstance().parseParseData(data, completionHandlerForParseData: { (success, error) in
                    if success {
                        completionHandlerForParse(success: true, errorString: nil)
                    } else {
                        completionHandlerForParse(success: false, errorString: error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    func queryStudentLocation(completionHandlerForQuery: (success: Bool, errorString: String?) -> Void) {
        
        let parameter = "{\"uniqueKey\":\"\(Student.sharedInstance().accountKey!)\"}"
        let escapedParameter = parameter.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=" + escapedParameter!
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        request.addValue(Parse.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Parse.RestAPIKEy, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        taskForGetMethod(request, api: "Parse") { (data, error) in
            if let error = error {
                completionHandlerForQuery(success: false, errorString: error.localizedDescription)
            } else {
                if API.sharedInstance().parseQuery(data) {
                    completionHandlerForQuery(success: true, errorString: nil)
                } else {
                    completionHandlerForQuery(success: false, errorString: "User has location posted")
                }
            }
        }
    }
    
    func updateStudentLocation(completionHanderForUpdate: (success: Bool, errorString: String?) -> Void) {
        let student: Student = Student.sharedInstance()
        print(student.objectID!)
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(Student.sharedInstance().objectID!)"
        let url = NSURL(string: urlString)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(student.accountKey!)\", \"firstName\": \"\(student.firstName!)\", \"lastName\": \"\(student.lastName!)\",\"mapString\": \"\(student.mapString!)\", \"mediaURL\": \"\(student.mediaURL!)\",\"latitude\": \(student.latitude!), \"longitude\": \(student.longitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        taskForPostMethod(request, api: "Parse") { (data, error) in
            if let error = error {
                completionHanderForUpdate(success: false, errorString: error.localizedDescription)
            } else {
                API.sharedInstance().parseStudentLocationUpdate(data, completionHandlerForParseUpdate: { (success) in
                    if success {
                        completionHanderForUpdate(success: true, errorString: nil)
                    } else {
                        completionHanderForUpdate(success: false, errorString: nil)
                    }
                })
            }
        }
    }
    
    func postStudentLocation(completionHandlerForLocationPost: (success: Bool, errorString: String?) -> Void) {
        let student: Student = Student.sharedInstance()
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(student.accountKey!)\", \"firstName\": \"\(student.firstName!)\", \"lastName\": \"\(student.lastName!)\",\"mapString\": \"\(student.mapString!)\", \"mediaURL\": \"\(student.mediaURL!)\",\"latitude\": \(student.latitude!), \"longitude\": \(student.longitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        taskForPostMethod(request, api: "Parse") { (data, error) in
            if let error = error {
                completionHandlerForLocationPost(success: false, errorString: error.localizedDescription)
            } else {
                API.sharedInstance().parseStudentPostLocation(data, completionHandlerForPostLocation: { (success, error) in
                    if success {
                        completionHandlerForLocationPost(success: true, errorString: nil)
                    } else {
                        completionHandlerForLocationPost(success: false, errorString: error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    func logoutUdacity(completionHandlerForLogout: (success: Bool, errorString: String?) -> Void) {
        
        //TODO: Extraxt request
        let request = NSMutableURLRequest(URL: udacityURL())
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        taskForPostMethod(request, api: "Udacity") { (data, error) in
            if let error = error {
                completionHandlerForLogout(success: false, errorString: error.localizedDescription)
            } else {
                // Change function name
                API.sharedInstance().parseUdacityLoginData(data, type: "logout", completionHandlerForLoginData: { (success, error) in
                    if success {
                        completionHandlerForLogout(success: true, errorString: nil)
                    } else {
                        completionHandlerForLogout(success: false, errorString: error?.localizedDescription)
                    }
                })
            }
        }
    }
    
    func taskForGetMethod(request: NSURLRequest, api: String, completionHandlerForTask: (data: AnyObject!, error: NSError?) -> Void) {
       
        var newData: NSData?
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForTask(data: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
            
            guard (error == nil) else {
                sendError("There was an error with the request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("The request did not return a status code 2xx")
                return
            }
            
            guard let data = data else {
                sendError("There was no data returned in request")
                return
            }
            if api == "Udacity" {
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            } else {
                newData = data
            }
            
            self.serializeData(newData!, completionHandlerForParseData: completionHandlerForTask)
        }
        
        task.resume()
    }
    
    func taskForPostMethod(request: NSURLRequest, api: String, completionHandlerForTask: (data: AnyObject!, error: NSError?) -> Void) {
        
        var newData: NSData?
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForTask(data: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                return
            }
 
            guard (error == nil) else {
                sendError("There was an error with the request: \(error)")
                return
            }
         
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("The request did not return a status code 2xx")
                return
            }
        
            guard let data = data else {
                sendError("There was no data returned in request")
                return
            }
            
            if api == "Udacity" {
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            } else {
                newData = data
            }
            
            self.serializeData(newData!, completionHandlerForParseData: completionHandlerForTask)
        }
        
        task.resume()
    }
    
    func serializeData(data: NSData, completionHandlerForParseData: (parsedData: AnyObject!, error: NSError?) -> Void) {
        var parsedData: AnyObject!
        
        do {
            parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Unable to parse JSON in \(data)"]
            completionHandlerForParseData(parsedData: nil, error: NSError(domain: "parseData", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForParseData(parsedData: parsedData, error: nil)
    }
    
    
    // TODO: Combine url functions into one
    func udacityURL() -> NSURL {
        let components = NSURLComponents()
        components.scheme = Udacity.ApiScheme
        components.host = Udacity.ApiHhost
        components.path = Udacity.ApiPath + Udacity.Session
        
        return components.URL!
    }
    
    func parseURL() -> NSURL {
        let components = NSURLComponents()
        components.scheme = Parse.ApiScheme
        components.host = Parse.ApiHost
        components.path = Parse.ApiPath + Parse.classes + Parse.studentLocation
        
        return components.URL!
    }
    
    class func sharedInstance() -> API {
        struct Singleton {
            static var sharedInstance = API()
        }
        return Singleton.sharedInstance
    }
}