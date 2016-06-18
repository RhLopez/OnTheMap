//
//  ActivityIndicatorOverlay.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 6/18/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import UIKit

class ActivityIndicatorOverlay {
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class var shared: ActivityIndicatorOverlay {
        struct Static {
            static let instance: ActivityIndicatorOverlay = ActivityIndicatorOverlay()
        }
        return Static.instance
    }
    
    func showOverlay(view: UIView!) {
        overlayView = UIView(frame: UIScreen.mainScreen().bounds)
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.center = overlayView.center
        overlayView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        view.addSubview(overlayView)
    }
    
    func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
    
}
