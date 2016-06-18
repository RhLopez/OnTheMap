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
    
    var newStudent: Bool?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        processParseLogin()
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if ((presentedViewController?.isKindOfClass(LocationFinderViewController)) != nil) {
            Student.sharedInstance().students.removeAll()
            processParseLogin()
        }
    }
    
    func processParseLogin() {
        ActivityIndicatorOverlay.shared.showOverlay(mapView)
        API.sharedInstance().loginToParse { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.mapSetup()
                    ActivityIndicatorOverlay.shared.hideOverlayView()
                } else {
                    print(errorString)
                }
            })
        }
    }
    
    func mapSetup() {
        
        mapView.removeAnnotations(mapView.annotations)
        
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
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        ActivityIndicatorOverlay.shared.showOverlay(mapView)
        API.sharedInstance().logoutUdacity { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    Student.sharedInstance().students.removeAll()
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                print("Unable to logout")
            }
        }
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        Student.sharedInstance().students.removeAll()
        processParseLogin()
    }
    
    @IBAction func postLocationButtonPressed(sender: AnyObject) {
        API.sharedInstance().queryStudentLocation { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.studentLocationPostedAlert()
                } else {
                    self.newStudent = true
                    self.performSegueWithIdentifier("postStudentLocation", sender: self)
                }
            })
        }
    }
    
    func studentLocationPostedAlert() {
        let message = "User \(Student.sharedInstance().firstName!) \(Student.sharedInstance().lastName!) has already\nPosted a Student Location. Do you\nwant to overwrite the location?"
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: { (alert: UIAlertAction!) in
            self.newStudent = false
            self.performSegueWithIdentifier("postStudentLocation", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postStudentLocation" {
            let controller = segue.destinationViewController as! LocationFinderViewController
            controller.newStudent = self.newStudent!
        }
    }
    
    func loadingOverlay() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Please Wait...", preferredStyle: .Alert)
        alert.view.tintColor = UIColor.blackColor()
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        
        return alert
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

