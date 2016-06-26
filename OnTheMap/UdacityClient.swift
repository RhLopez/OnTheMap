//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 6/21/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import Foundation

class Udacity: NSObject {
    
    var sessionId: String?
    
    let session = NSURLSession.sharedSession()
    
    func taskForPostMethod(jsonBody: String, completionHandlerForPost: (data: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: udacityUrl(Methods.Session))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func reportError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPost(data: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                return
            }
            
            guard (error == nil) else {
                reportError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                reportError("The request did not return a status code 2xx")
                return
            }
            
            guard let data = data else {
                reportError("There was no data returned in request")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            self.serializeData(newData, completionHandlerForSerialization: completionHandlerForPost)
        }
        
        task.resume()
    }
    
    func taskForGetMethod(completionHandlerForGet: (data: AnyObject!, error: NSError?) -> Void) {
        
        let pathExtension = Methods.Users + "/\(Student.sharedInstance().userId!)"
        let request = NSMutableURLRequest(URL: udacityUrl(pathExtension))
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func reportError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGet(data: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                return
            }
            
            guard (error == nil) else {
                reportError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                reportError("The request did not return a status code 2xx")
                return
            }
            
            guard let data = data else {
                reportError("There was no data returned in request")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            self.serializeData(newData, completionHandlerForSerialization: completionHandlerForGet)
        }
        
        task.resume()
    }
    
    func taskForDeleteMethod(completionHandlerForDelete: (data: AnyObject!, error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(URL: udacityUrl(Methods.Session))
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == Constants.Cookie { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: Constants.CookeHeader)
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func reportError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForDelete(data: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                return
            }
            
            guard (error == nil) else {
                reportError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                reportError("The request did not return a status code 2xx")
                return
            }
            
            guard let data = data else {
                reportError("There was no data returned in request")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            self.serializeData(newData, completionHandlerForSerialization: completionHandlerForDelete)
        }
        
        task.resume()
        
    }
    
    func serializeData(data: NSData, completionHandlerForSerialization: (parsedData: AnyObject!, error: NSError?) -> Void) {
        
        var parsedData: AnyObject!
        
        do {
            parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Unable to parse JSON in \(data)"]
            completionHandlerForSerialization(parsedData: nil, error: NSError(domain: "parseData", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForSerialization(parsedData: parsedData, error: nil)
    }
    
    func udacityUrl(pathExtension: String?) -> NSURL {
        let components = NSURLComponents()
        
        components.scheme = Udacity.Constants.ApiScheme
        components.host = Udacity.Constants.ApiHost
        components.path = Udacity.Constants.ApidPath + (pathExtension ?? "")
        
        return components.URL!
    }
    
    class func sharedInstance() -> Udacity {
        struct Singleton {
            static var sharedInstance = Udacity()
        }
        return Singleton.sharedInstance
    }
}
