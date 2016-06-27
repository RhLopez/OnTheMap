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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var newPosting: Bool?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentLocations()
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch student locations if transitioning from LocationFinderVC
        if ((presentedViewController?.isKindOfClass(LocationFinderViewController)) != nil) {
            getStudentLocations()
        }
    }
    
    func getStudentLocations() {
        Student.sharedInstance.students.removeAll()
        ActivityIndicatorOverlay.sharedInstance.showOverlay(mapView)
        Parse.sharedInstance.getStudentLocations { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), { 
                if success {
                    self.mapSetup()
                    ActivityIndicatorOverlay.sharedInstance.hideOverlayView()
                } else {
                    ActivityIndicatorOverlay.sharedInstance.hideOverlayView()
                    AlerView.showAlert(self, title: "Unable to get Student Locations", message: "\(errorString!)\nPlease try again.")
                }
            })
        }
    }
    
    func mapSetup() {
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        
        for dictionary in Student.sharedInstance.students {
            
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
        
        mapView.addAnnotations(annotations)
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        ActivityIndicatorOverlay.sharedInstance.showOverlay(mapView)
        Udacity.sharedInstance.logOut { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), { 
                if success {
                    Student.sharedInstance.students.removeAll()
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    AlerView.showAlert(self, title: "Unable to logout", message: "Unable to logout./nPlease try again.")
                }
            })
        }
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        getStudentLocations()
    }
    
    @IBAction func postLocationButtonPressed(sender: AnyObject) {
        Parse.sharedInstance.queryStudentLocation { (success, locationPosted, errorString) in
            dispatch_async(dispatch_get_main_queue(), { 
                if success {
                    if locationPosted == true {
                        self.studentLocationPostedAlert()
                    } else {
                        self.newPosting = true
                        self.performSegueWithIdentifier("postStudentLocation", sender: self)
                    }
                } else {
                AlerView.showAlert(self, title: "Unable to query Student Location", message: "\(errorString!)nPlease try again.")
                }
            })
        }
    }
    
    func studentLocationPostedAlert() {
        let message = "User \(Student.sharedInstance.firstName!) \(Student.sharedInstance.lastName!) has already\nPosted a Student Location. Do you\nwant to overwrite the location?"
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: { (alert: UIAlertAction!) in
            self.newPosting = false
            self.performSegueWithIdentifier("postStudentLocation", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postStudentLocation" {
            let controller = segue.destinationViewController as! LocationFinderViewController
            controller.newPosting = self.newPosting!
        }
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
                    AlerView.showAlert(self, title: "Alert", message: "Invalid URL")
                }
            }
        }
    }
}

