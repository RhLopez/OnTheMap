//
//  ParseConvinience.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 6/22/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import Foundation

extension Parse {
    
    func getStudentLocations(completionHandlerForGetLocations: (success: Bool, errorString: String?) -> Void) {
        let parameters = [
            ParameterKeys.Limit: ParameterValue.LimitAmount,
            ParameterKeys.Order: ParameterValue.OrderType
        ]
        
        taskForGetMethod(nil, parameters: parameters) { (results, error) in
            if let error = error {
                print(error)
                completionHandlerForGetLocations(success: false, errorString: "Unable to get Student Locations")
            } else {
                if let results = results[JSONResponseKeys.Results] as? [[String:AnyObject]] {
                    Student.sharedInstance().students = StudentInformation.studentsFromResults(results)
                    completionHandlerForGetLocations(success: true, errorString: nil)
                } else {
                    completionHandlerForGetLocations(success: false, errorString: "No value for key 'results' in: \(results)")
                }
            }
        }
    }
    
    func queryStudentLocation(completionHandlerQuery: (success: Bool, locationPosted: Bool?, errorString: String?) -> Void) {
        let queryString = "{\"\(ParameterKeys.UniqueKey)\":\"\(Student.sharedInstance().userId!)\"}"
        let parameters = [ParameterKeys.Where: queryString]
        
        taskForGetMethod(nil, parameters: parameters) { (results, error) in
            if let error = error {
                print(error)
                completionHandlerQuery(success: false, locationPosted: nil, errorString: "Unable to Query Student Location")
            } else {
                if let results = results[JSONResponseKeys.Results] as? [[String:AnyObject]] {
                    if !results.isEmpty {
                        let dataDict = results.first!
                        self.getUniqueKey(dataDict, completionHandlerForUniqueKey: { (success, uniqueKey, errorString) in
                            if success {
                                if Student.sharedInstance().userId == uniqueKey {
                                    self.getObjectId(dataDict, completionHandlerForObjectId: { (success, errorString) in
                                        if success {
                                            self.getUpdatedTime(dataDict, fromQuery: true, completionHandlerForUpdatedTime: { (success, updatedTime, errorString) in
                                                if success {
                                                    completionHandlerQuery(success: true, locationPosted: true, errorString: nil)
                                                } else {
                                                    completionHandlerQuery(success: false, locationPosted: nil, errorString: errorString)
                                                }
                                            })
                                        } else {
                                            completionHandlerQuery(success: false, locationPosted: nil, errorString: errorString)
                                        }
                                    })
                                }
                            } else {
                                completionHandlerQuery(success: false, locationPosted: nil, errorString: errorString)
                            }
                        })
                    } else {
                        completionHandlerQuery(success: false, locationPosted: nil, errorString: "No data in 'result' dictionary.")
                    }
                } else {
                    completionHandlerQuery(success: false, locationPosted: nil, errorString: "No value for key 'results' in: \(results)")
                }
            }
        }
    }
    
    func postStudentLocation(completionHandlerForLocationPost: (success: Bool, errorString: String?) -> Void) {
        let student = Student.sharedInstance()
        let parameters = [String:AnyObject]()
        let jsonBody = "{\"uniqueKey\": \"\(student.userId!)\", \"firstName\": \"\(student.firstName!)\", \"lastName\": \"\(student.lastName!)\",\"mapString\": \"\(student.mapString!)\", \"mediaURL\": \"\(student.mediaURL!)\",\"latitude\": \(student.latitude!), \"longitude\": \(student.longitude!)}"
        
        taskForPostMethod(nil, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            if let error = error {
                print(error)
                completionHandlerForLocationPost(success: false, errorString: "Unable to post student location")
            } else {
                self.getObjectId(results!, completionHandlerForObjectId: { (success, errorString) in
                    if success {
                        completionHandlerForLocationPost(success: true, errorString: nil)
                    } else {
                        completionHandlerForLocationPost(success: false, errorString: errorString)
                    }
                })
            }
        }
    }
    
    func updateStudentLocation(completionHandlerForUpdateLocation: (success: Bool, errorString: String?) -> Void) {
        let parameters = [String:AnyObject]()
        let student = Student.sharedInstance()
        let pathExtension = "/\(student.objectID!)"
        let jsonBody = "{\"uniqueKey\": \"\(student.userId!)\", \"firstName\": \"\(student.firstName!)\", \"lastName\": \"\(student.lastName!)\",\"mapString\": \"\(student.mapString!)\", \"mediaURL\": \"\(student.mediaURL!)\",\"latitude\": \(student.latitude!), \"longitude\": \(student.longitude!)}"
        
        taskForPutMethod(pathExtension, parameters: parameters , jsonBody: jsonBody) { (results, error) in
            if let error = error {
                print(error)
                completionHandlerForUpdateLocation(success: false, errorString: "Unable to update Student Location.\nPlease try again.")
            } else {
                self.getUpdatedTime(results, fromQuery: false, completionHandlerForUpdatedTime: { (success, updatedTime, errorString) in
                    if success {
                        self.compareTime(updatedTime!, completionHandlerForCompareTime: { (updated, detailString) in
                            if updated {
                                completionHandlerForUpdateLocation(success: true, errorString: nil)
                            } else {
                                completionHandlerForUpdateLocation(success: false, errorString: detailString)
                            }
                        })
                    } else {
                        completionHandlerForUpdateLocation(success: false, errorString: errorString)
                    }
                })
            }
        }
    }
    
    func getUniqueKey(results: [String:AnyObject], completionHandlerForUniqueKey: (success: Bool, uniqueKey: String?, errorString: String?) -> Void) {
        if let uniqueKey = results["uniqueKey"] as? String {
            completionHandlerForUniqueKey(success: true, uniqueKey: uniqueKey, errorString: nil)
        } else {
            completionHandlerForUniqueKey(success: false, uniqueKey: nil, errorString: "No value for key 'uniqueKey' in: \(results)")
        }
    }
    
    func getObjectId(results: AnyObject, completionHandlerForObjectId: (success: Bool, errorString: String?) -> Void) {
        if let objectId = results["objectId"] as? String {
            Student.sharedInstance().objectID = objectId
            completionHandlerForObjectId(success: true, errorString: nil)
        } else {
            completionHandlerForObjectId(success: false, errorString: "No value for key 'objectId' in: \(results)")
        }
    }
    
    func getUpdatedTime(results: AnyObject, fromQuery: Bool, completionHandlerForUpdatedTime: (success: Bool, updatedTime: String?, errorString: String?) -> Void) {
        if let updatedAt = results["updatedAt"] as? String {
            if fromQuery {
                Student.sharedInstance().updatedAt = formatDate(updatedAt)
            }
            completionHandlerForUpdatedTime(success: true, updatedTime: updatedAt, errorString: nil)
        } else {
            completionHandlerForUpdatedTime(success: false, updatedTime: nil, errorString: "No value for key 'updatedAt' in: \(results)")
        }
    }
    
    func compareTime(updatedTime: String, completionHandlerForCompareTime: (updated: Bool, detailString: String?) -> Void) {
        if Student.sharedInstance().updatedAt!.compare(formatDate(updatedTime)) == NSComparisonResult.OrderedAscending {
            completionHandlerForCompareTime(updated: true, detailString: nil)
        } else {
            completionHandlerForCompareTime(updated: false, detailString: "Location update was not successful.")
        }
    }
    
    func formatDate(date: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.dateFromString(date)!
    }
}