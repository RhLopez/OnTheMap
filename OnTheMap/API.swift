//
//  API.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 5/30/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import Foundation

class API: NSObject {
    
    static func udacityLogin(email: String, password: String, completionHandlerForLogin: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: API.udacityURL())
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
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
            
            guard let sessionID = session["id"] as? String else {
                print("No key id found in session")
                return
            }
            
            completionHandlerForLogin(success: true, errorString: nil)
        }
        
        task.resume()
    }
    
    static func udacityURL() -> NSURL {
        let components = NSURLComponents()
        components.scheme = Udacity.ApiScheme
        components.host = Udacity.ApiHhost
        components.path = Udacity.ApiPath + Udacity.Session
        
        return components.URL!
    }
}