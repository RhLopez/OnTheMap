//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 5/29/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    var firstName: String?
    var lastName: String?
    var uniqueKey: String?
    var longitude: Float?
    var latitude: Float?
    var mapString: String?
    var mediaURL: String?
    var updatedAt: String?
    
    init(dictionary: [String:AnyObject]) {
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        uniqueKey = dictionary["uniqueKey"] as? String
        longitude = dictionary["longitude"] as? Float
        latitude = dictionary["latitude"] as? Float
        mapString = dictionary["mapString"] as? String
        mediaURL = dictionary["mediaURL"] as? String
        updatedAt = dictionary["updatedAt"] as? String
    }
    
    static func studentsFromResults(results: [[String:AnyObject]]) -> [StudentInformation] {
        var students = [StudentInformation]()
        
        for student in results {
            students.append(StudentInformation(dictionary: student))
        }
        
        return students
    }
}