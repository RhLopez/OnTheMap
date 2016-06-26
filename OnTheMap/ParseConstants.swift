//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 6/22/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

extension Parse {
    
    struct Constants {
        
        //Mark: API Keys
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        //Mark: API Headers
        static let ApplicationHeader = "X-Parse-Application-Id"
        static let RestHeader = "X-Parse-REST-API-Key"
        
        //Mark: URL's
        static let ApiScheme = "https"
        static let ApiHost = "api.parse.com"
        static let ApiPath = "/1"
    }
    
    struct Methods {
        static let Classes = "/classes"
        static let StudentLocation = "/StudentLocation"
    }
    
    struct ParameterKeys {
        static let Limit = "limit"
        static let Order = "order"
        static let Where = "where"
        static let UniqueKey = "uniqueKey"
    }
    
    struct ParameterValue {
        static let LimitAmount = "100"
        static let OrderType = "-updatedAt"
    }
    
    struct JSONResponseKeys {
        static let Results = "results"
    }
    
    //Mark: 
    struct Request {
        static let ApplicatonJson = "application/json"
        static let ContentType = "Content-Type"
    }
    
}
