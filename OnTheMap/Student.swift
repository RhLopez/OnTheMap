//
//  Student.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 5/30/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import Foundation

class Student: NSObject {
    
    var firstName: String?
    var lastName: String?
    var mediaURL: String?
    var mapString: String?
    var latitude: Float?
    var longitude: Float?
    var accountKey: String?
    var registeredAccount: Bool?
    var objectID: String?
    var updatedAt: NSDate?
    
    var students = [StudentInformation]()
    
    class func sharedInstance() -> Student {
        struct Singleton {
            static var sharedInstance = Student()
        }
        return Singleton.sharedInstance
    }
}