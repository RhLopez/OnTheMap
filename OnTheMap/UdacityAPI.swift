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
    
    static func udacityURL() -> NSURL {
        let components = NSURLComponents()
        components.scheme = Udacity.ApiScheme
        components.host = Udacity.ApiHhost
        components.path = Udacity.ApiPath + Udacity.Session
        
        return components.URL!
    }
}