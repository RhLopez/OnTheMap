//
//  Student.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 5/30/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import Foundation

class Student: NSObject {
    
    static let sharedInstance = Student()
    
    var firstName: String?
    var lastName: String?
    var mediaURL: String?
    var mapString: String?
    var latitude: Float?
    var longitude: Float?
    var registeredAccount: Bool?
    var objectID: String?
    var updatedAt: NSDate?
    var userId: String?
    var uniqueKey: String?
    
    var students = [StudentInformation]()
}