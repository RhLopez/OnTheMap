//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 5/30/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import Foundation

struct Udacity {
    
    // MARK: URL
    static let ApiScheme = "https"
    static let ApiHhost = "www.udacity.com"
    static let ApiPath = "/api"
    
    //MARK: Method
    static let Session = "/session"
    
    //MARK: JSON
    static let jsonBody = "{\"udacity\": {\"username\": \"{email}\", \"password\": \"{***}\"}}"
}