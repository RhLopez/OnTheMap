//
//  APIConvinience.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 6/4/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import Foundation

extension API {
    
    func parseUdacityLoginData(data: AnyObject, completionHandlerForLoginData: (success: Bool, error: NSError?) -> Void ) {
        
        func sendError(error: String) {
            let userInfo = [NSLocalizedDescriptionKey: error]
            completionHandlerForLoginData(success: false, error: NSError(domain: "completionHandlerForLoginData", code: 1, userInfo: userInfo))
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
                "mediaURL": mediaURL,
                "updatedAt": updatedAt
            ]
            
            Student.sharedInstance().students.append(StudentInformation(dictionary: informationDictionary))
        }
        completionHandlerForParseData(success: true, error: nil)

    }
}