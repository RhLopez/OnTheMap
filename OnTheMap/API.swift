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
        
        // TODO: Extract parsing code to own file
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
            
            self.udacitySessionID = sessionID
            
            completionHandlerForLogin(success: true, errorString: nil)
        }
        
        task.resume()
    }
    
    func loginToParse(completionHandlerForParse: (success: Bool, errorString: String?) -> Void) {
       
        // TODO: Extract request code to own file
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        // TODO: Extract parsing code to own file
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                print("There has been an error")
                return
            }
            
            guard let data = data else {
                print("There was no data returned")
                return
            }
            
            var parsedData: AnyObject!
            do {
                parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Unable to parse data from JSON")
                return
            }
            
            guard let results = parsedData["results"] as? [[String:AnyObject]] else {
                print("There is no key 'results' in \(data)")
                return
            }
            
            for item in results {
                guard let firstName = item["firstName"] as? String else {
                    print("No value for key 'firstName'")
                    return
                }
                
                guard let lastName = item["lastName"] as? String else {
                    print("No value for key 'lastName'")
                    return
                }
                
                guard let uniqueKey = item["uniqueKey"] as? String else {
                    print("No value for key 'uniqueKey")
                    return
                }
                
                guard let longitude = item["longitude"] as? Float else {
                    print("No value for key 'longitude'")
                    return
                }
                
                guard let latitude = item["latitude"] as? Float else {
                    print("No value for key 'latitude")
                    return
                }
                
                guard let mapString = item["mapString"] as? String else {
                    print("No value for key 'mapString'")
                    return
                }
                
                guard let mediaURL = item["mediaURL"] as? String else {
                    print("No value for key 'mediaURL")
                    return
                }
                
                guard let updatedAt = item["updatedAt"] as? String else {
                    print("No value for key 'updatedAt'")
                    return
                }
                
                let informationDictionary: [String:AnyObject] = [
                    "firstName": firstName,
                    "lastName": lastName,
                    "uniqueKey": uniqueKey,
                    "longitude": longitude,
                    "latitude": latitude,
                    "mapString": mapString,
                    "mediaURL": mediaURL,
                    "updatedAt": updatedAt
                ]
                
                Student.sharedInstance().students.append(StudentInformation(dictionary: informationDictionary))
            }
            completionHandlerForParse(success: true, errorString: nil)
        }
        
        task.resume()
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
        components.path = Parse.ApiPath
        components.query = Parse.classes + Parse.studentLocation
        
        return components.URL!
    }
    
    class func sharedInstance() -> API {
        struct Singleton {
            static var sharedInstance = API()
        }
        return Singleton.sharedInstance
    }
}