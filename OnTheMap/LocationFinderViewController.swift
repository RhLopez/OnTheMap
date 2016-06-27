//
//  LocationFinderViewController.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 6/10/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import UIKit
import MapKit

class LocationFinderViewController: UIViewController {
    
    
    @IBOutlet weak var promptTextView: UITextView!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet var enterLocationView: UIView!
    @IBOutlet weak var submitInformationView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var linkTextView: UITextView!
    
    var newPosting: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitInformationView.hidden = true
        locationTextView.delegate = self
        linkTextView.delegate = self
        setupPrompt()
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupPrompt() {
        let promptString = "Where are you\nstudying\ntoday?"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        
        let attributedString = NSMutableAttributedString(string: promptString, attributes: [NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 34)!,
            NSForegroundColorAttributeName: UIColor(red: 0.28, green: 0.49, blue: 0.67, alpha: 1.00)])
        
        attributedString.addAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size:  34)!], range: NSMakeRange(14, 8))
            
        promptTextView.attributedText = attributedString
    }
    
    @IBAction func informationPostingButtonPressed(sender: UIButton) {
        if sender.currentTitle == "Find on the Map" {
            findLocationOnMap()
        } else {
            submitStudentLocation()
        }
    }
    
    func findLocationOnMap() {
        if locationTextView.text.isEmpty || locationTextView.text == "Enter Your Location Here" {
            AlerView.showAlert(self, title: "Location Empty", message: "No location was entered.")
        } else {
            geoCodeLocation(locationTextView.text!)
        }
    }
    
    func submitStudentLocation() {
        if linkTextView.text.isEmpty || linkTextView.text == "Enter a Link to Share Here" {
            AlerView.showAlert(self, title: "Link Empty", message: "No link was entered.")
        } else {
            Student.sharedInstance.mapString = locationTextView.text!
            Student.sharedInstance.mediaURL = linkTextView.text!
            if newPosting == true {
                postStudentLocation()
            } else {
                updateStudentLocation()
            }
        }
    }
    
    func postStudentLocation() {
        Parse.sharedInstance.postStudentLocation({ (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    AlerView.showAlert(self, title: "Unable To Post Student Location", message: "\(errorString!)\nPlease try again.")
                }
            })
        })
    }
    
    func updateStudentLocation() {
        Parse.sharedInstance.updateStudentLocation({ (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    AlerView.showAlert(self, title: "Unable To Update Student Location", message: "\(errorString!)\nPlease try again.")
                }
            })
        })
    }
    
    func geoCodeLocation(address: String) {
        ActivityIndicatorOverlay.sharedInstance.showOverlay(self.mapView)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if (error != nil) {
                print(error)
                ActivityIndicatorOverlay.sharedInstance.hideOverlayView()
                AlerView.showAlert(self, title: "Unable To Find Location", message: "Please try again")
            } else {
                self.enterLocationView.hidden = true
                self.submitInformationView.hidden = false
                if let placemark = placemarks?.first {
                    let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinates
                    let region = MKCoordinateRegionMakeWithDistance(coordinates, 250, 250)
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.addAnnotation(annotation)
                    Student.sharedInstance.latitude = Float(coordinates.latitude)
                    Student.sharedInstance.longitude = Float(coordinates.longitude)
                    ActivityIndicatorOverlay.sharedInstance.hideOverlayView()
                }
            }
        }
    }
}

extension LocationFinderViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.text == "Enter Your Location Here" || textView.text == "Enter a Link to Share Here" {
            textView.text = ""
        }
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension LoginViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView.pinTintColor = UIColor.redColor()
        
        return pinView
    }
}