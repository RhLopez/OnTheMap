//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 6/21/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

extension Udacity {
    
    struct Constants {
        
        //Mark: URLs
        static let signUpUrl: String = "https://udacity.com/account/auth#!/signup"
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApidPath = "/api"
        
        //Mark: Cookie
        static let Cookie = "XSRF-TOKEN"
        
        //Mark: Header
        static let CookeHeader = "X-XSRF-TOKEN"
        static let ApplicationJson = "json/application"
    }
    
    struct Methods {
        
        //Mark: Account
        static let Account = "/account"
        
        //Mark: Methods
        static let Session = "/session"
        
        //Mark: Users
        static let Users = "/users"
    }
}
