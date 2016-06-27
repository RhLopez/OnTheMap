//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 6/22/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import Foundation

class Parse {
    
    static let sharedInstance = Parse()
    
    let session = NSURLSession.sharedSession()
    
    func taskForGetMethod(pathExtension: String?, parameters: [String:AnyObject], completionHandlerForGetMethod: (results: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: parseUrl(parameters, pathExtension: pathExtension))
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: Constants.ApplicationHeader)
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: Constants.RestHeader)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func reportError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGetMethod(results: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
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
            
            self.serializeData(data, completionHandlerForSerialization: completionHandlerForGetMethod)
        }
        
        task.resume()
    }
    
    func taskForPostMethod(pathExtension: String?, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPostMethod: (results: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: parseUrl(parameters, pathExtension: pathExtension))
        request.HTTPMethod = "POST"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: Constants.ApplicationHeader)
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: Constants.RestHeader)
        request.addValue(Request.ApplicatonJson, forHTTPHeaderField: Request.ContentType)
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func reportError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPostMethod(results: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
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
            
            self.serializeData(data, completionHandlerForSerialization: completionHandlerForPostMethod)
        }
        
        task.resume()
    }
    
    func taskForPutMethod(pathExtension: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPutMethod: (results: AnyObject!, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: parseUrl(parameters, pathExtension: pathExtension))
        request.HTTPMethod = "PUT"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: Constants.ApplicationHeader)
        request.addValue(Constants.RestAPIKey, forHTTPHeaderField: Constants.RestHeader)
        request.addValue(Request.ApplicatonJson, forHTTPHeaderField: Request.ContentType)
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)

        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func reportError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPutMethod(results: nil, error: NSError(domain: "taskForPutMethod", code: 1, userInfo: userInfo))
                return
            }
            
            guard (error == nil) else {
                reportError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                reportError("The request did not return a status code 2xx: \(response!)")
                return
            }
            
            guard let data = data else {
                reportError("There was no data returned in request")
                return
            }
            
            self.serializeData(data, completionHandlerForSerialization: completionHandlerForPutMethod)
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
    
    func parseUrl(parameters: [String:AnyObject], pathExtension: String?) -> NSURL {
        let components = NSURLComponents()
        
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + Methods.Classes + Methods.StudentLocation + (pathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
}