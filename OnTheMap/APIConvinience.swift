//
//  APIConvinience.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 6/4/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import Foundation

extension API {
    
    func parseUdacityLoginData(data: AnyObject, type: String, completionHandlerForLoginData: (success: Bool, error: NSError?) -> Void ) {
        
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey: error]
            completionHandlerForLoginData(success: false, error: NSError(domain: "completionHandlerForLoginData", code: 1, userInfo: userInfo))
        }
        
        if type == "login" {
            guard let account = data["account"] as? [String:AnyObject] else {
                sendError("No value for key 'account' in \(data)")
                return
            }
            
            guard let registered = account["registered"] as? Bool else {
                sendError("No value for key 'registered' in \(data)")
                return
            }
            
            guard let key = account["key"] as? String else {
                sendError("No value for key 'key' in \(data)")
                return
            }
            
            Student.sharedInstance().registeredAccount = registered
            Student.sharedInstance().accountKey = key
        }
        
        guard let session = data["session"] as? [String:AnyObject] else {
            sendError("No value for key 'session' in \(data)")
            return
        }
        
        guard let sessionId = session["id"] as? String else {
            sendError("No value for key 'id' in \(data)")
            return
        }
        
        API.sharedInstance().udacitySessionID = sessionId
        
        completionHandlerForLoginData(success: true, error: nil)
    }
    
    func parseUdacityUserData(data: AnyObject, completionHandlerForUserData: (success: Bool, error: NSError?) -> Void) {
        
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey: error]
            completionHandlerForUserData(success: false, error: NSError(domain: "completionHandlerForUserData", code: 1, userInfo: userInfo))
        }
        
        guard let user = data["user"] as? [String:AnyObject] else  {
            sendError("No value key 'user' in \(data)")
            return
        }
        
        guard let lastName = user["last_name"] as? String else {
            sendError("No value key 'last_name' in \(data)")
            return
        }
        
        guard let firsName = user["first_name"] as? String else {
            sendError("No value key 'first_name' in \(data)")
            return
        }
        
        Student.sharedInstance().firstName = firsName
        Student.sharedInstance().lastName = lastName
        
        completionHandlerForUserData(success: true, error: nil)
    }
    
    func parseParseData(data: AnyObject, completionHandlerForParseData: (success: Bool, error: NSError?) -> Void) {
        
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey: error]
            completionHandlerForParseData(success: false, error: NSError(domain: "parseParseData", code: 1, userInfo: userInfo))
        }
        
        guard let results = data["results"] as? [[String:AnyObject]] else {
            sendError("There is no key 'results' in \(data)")
            return
        }

        for item in results {
            guard let firstName = item["firstName"] as? String else {
                sendError("No value for key 'firstName' in \(data)")
                return
            }
            
            guard let lastName = item["lastName"] as? String else {
                sendError("No value for key 'lastName' in \(data)")
                return
            }
            
            guard let uniqueKey = item["uniqueKey"] as? String else {
                sendError("No value for key 'uniqueKey' in \(data)")
                return
            }
            
            guard let longitude = item["longitude"] as? Float else {
                sendError("No value for key 'longitude' in \(data)")
                return
            }
            
            guard let latitude = item["latitude"] as? Float else {
                sendError("No value for key 'latitude' in \(data)")
                return
            }
            
            guard let mapString = item["mapString"] as? String else {
                sendError("No value for key 'mapString' in \(data)")
                return
            }
            
            guard let objectID = item["objectId"] as? String else {
                sendError("No value for key 'objectId' in \(data)")
                return
            }
            
            guard let mediaURL = item["mediaURL"] as? String else {
                sendError("No value for key 'mediaURL' in \(data)")
                return
            }
            
            guard let updatedAt = item["updatedAt"] as? String else {
                sendError("No value for key 'updatedAt' in \(data)")
                return
            }
            
            let informationDictionary: [String:AnyObject] = [
                "firstName": firstName,
                "lastName": lastName,
                "uniqueKey": uniqueKey,
                "longitude": longitude,
                "latitude": latitude,
                "mapString": mapString,
                "objectID": objectID,
                "mediaURL": mediaURL,
                "updatedAt": updatedAt
            ]
            
            Student.sharedInstance().students.append(StudentInformation(dictionary: informationDictionary))
        }
        completionHandlerForParseData(success: true, error: nil)
    }
    
    func parseQuery(data: AnyObject) -> Bool {
        var student: [String:AnyObject]?

        // TODO: Handle error
        guard let results = data["results"] as? [[String:AnyObject]] else {
            print("There is no key 'results'")
            return false
        }
        
        if results.isEmpty {
            return false
        }
        
        student = results[0]
        
        guard let objectId = student!["objectId"] as? String else {
            print("There is no key 'objectId")
            return false
        }
        
        guard let updatedAt = student!["updatedAt"] as? String else {
            print("There is no key for 'updatedAt")
            return false
        }
        
        guard let uniqueKey = student!["uniqueKey"] as? String else {
            print("There is no key for 'uniqueKey'")
            return false
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        Student.sharedInstance().updatedAt = dateFormatter.dateFromString(updatedAt)
        Student.sharedInstance().objectID = objectId
        
        return Student.sharedInstance().accountKey! == uniqueKey
    }
    
    func parseStudentPostLocation(data: AnyObject, completionHandlerForPostLocation: (success: Bool, error: NSError?) -> Void) {
        
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey: error]
            completionHandlerForPostLocation(success: false, error: NSError(domain: "parseParseData", code: 1, userInfo: userInfo))
        }
        
        guard let objectId = data["objectId"] as? String else {
            sendError("No value for key 'objectId in \(data)")
            return
        }
        
        Student.sharedInstance().accountKey = objectId
        completionHandlerForPostLocation(success: true, error: nil)
    }
    
    func parseStudentLocationUpdate(data: AnyObject, completionHandlerForParseUpdate: (success: Bool) -> Void) {
        guard let updatedAt = data["updatedAt"] as? String else {
            print("No key for value 'updatedAt")
            return
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let formattedDate = dateFormatter.dateFromString(updatedAt)
        
        if Student.sharedInstance().updatedAt!.compare(formattedDate!) == NSComparisonResult.OrderedAscending {
            completionHandlerForParseUpdate(success: true)
        } else {
            completionHandlerForParseUpdate(success: false)
        }
    }
}