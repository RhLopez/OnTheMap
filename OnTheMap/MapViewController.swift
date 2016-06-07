//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 5/29/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        processParseLogin()
        mapView.delegate = self
    }
    
    func processParseLogin() {
        API.sharedInstance().loginToParse { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.mapSetup()
                } else {
                    print("no success")
                }
            })
        }
    }
    
    func mapSetup() {
        var annotations = [MKPointAnnotation]()
        
        
        for dictionary in Student.sharedInstance().students {
            
            let latitude = CLLocationDegrees(Double(dictionary.latitude!))
            let longitutde = CLLocationDegrees(Double(dictionary.longitude!))
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitutde)
            
            let firstName = dictionary.firstName!
            let lastName = dictionary.lastName!
            let mediaURL = dictionary.mediaURL!
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    func showInvalidURLAlert() {
        let alert = UIAlertController(title: "Alert", message: "Invalid URL", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func verifyURL(urlString: String) -> Bool {
        if let url = NSURL(string: urlString) {
            return UIApplication.sharedApplication().canOpenURL(url)
        }
        return false
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            pinView!.pinTintColor = UIColor.redColor()
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let url = view.annotation?.subtitle! {
                if verifyURL(url) {
                    UIApplication.sharedApplication().openURL(NSURL(string: url)!)
                } else {
                    showInvalidURLAlert()
                }
            }
        }
    }
}
