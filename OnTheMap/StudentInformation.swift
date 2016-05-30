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
    var longitude: Float?
    var latitude: Float?
    var mapString: String?
    var mediaURL: String?
    var updatedAt: String?
    
    init(dictionary: [String:AnyObject]) {
        firstName = dictionary["fistName"] as? String
        lastName = dictionary["lastName"] as? String
        longitude = dictionary["longitude"] as? Float
        latitude = dictionary["latitude"] as? Float
        mapString = dictionary["mapString"] as? String
        mediaURL = dictionary["mediaURL"] as? String
        updatedAt = dictionary["updatedAt"] as? String
    }
}