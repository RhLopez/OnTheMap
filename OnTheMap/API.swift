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
                API.sharedInstance().parseUdacityLoginData(data) { (success, error) in
                    if success {
                        completionHandlerForLogin(success: true, errorString: nil)
                    } else {
                        completionHandlerForLogin(success: false, errorString: error?.localizedDescription)
                    }
                }
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
                API.sharedInstance().parseUdacityLoginData(data, completionHandlerForLoginData: { (success, error) in
                    if success {
                        completionHandlerForLogout(success: true, errorString: nil)
                    } else {
                        completionHandlerForLogout(success: false, errorString: error?.localizedDescription)
                    }
                })
            }
        }
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