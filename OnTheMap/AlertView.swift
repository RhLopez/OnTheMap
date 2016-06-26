//
//  AlertView.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 6/18/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import UIKit

class AlerView: NSObject {
    
    class func showAlert(view: UIViewController, message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        dispatch_async(dispatch_get_main_queue()) { 
            view.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
