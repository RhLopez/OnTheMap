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
            let app = UIApplication.sharedApplication()
            if let url = view.annotation?.subtitle! {
                app.openURL(NSURL(string: url)!)
            }
        }
    }
}
