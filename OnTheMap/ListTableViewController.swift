//
//  ListTableViewController.swift
//  OnTheMap
//
//  Created by Ramiro H. Lopez on 6/3/16.
//  Copyright © 2016 Ramiro H. Lopez. All rights reserved.
//

import UIKit

class ListTableViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    
    var newPosting: Bool?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        listTableView.reloadData()
        navigationController?.hidesBarsOnSwipe = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch student locations if transitioning from LocationFinderVC
        if ((presentedViewController?.isKindOfClass(LocationFinderViewController)) != nil) {
            getStudentLocations()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        ActivityIndicatorOverlay.sharedInstance.showOverlay(listTableView)
        Udacity.sharedInstance.logOut { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    AlerView.showAlert(self, title: "Unable To Logout", message: "\(errorString!)\nPlease try again.")
                }
            })
        }
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
                    AlerView.showAlert(self, title: "Unable To Query Location", message: "\(errorString!)\nPlease try again.")
                }
            })
        }
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        getStudentLocations()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postStudentLocation" {
            let controller = segue.destinationViewController as! LocationFinderViewController
            controller.newPosting = self.newPosting!
        }
    }
    
    func getStudentLocations() {
        Student.sharedInstance.students.removeAll()
        ActivityIndicatorOverlay.sharedInstance.showOverlay(listTableView)
        Parse.sharedInstance.getStudentLocations { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.listTableView.reloadData()
                    ActivityIndicatorOverlay.sharedInstance.hideOverlayView()
                } else {
                    AlerView.showAlert(self, title: "Unable To Load Student Locations", message: "\(errorString!)\nPlease try again.")
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
    
    func verifyURL(urlString: String) -> Bool {
        if let url = NSURL(string: urlString) {
            return UIApplication.sharedApplication().canOpenURL(url)
        }
        return false
    }
    
}

extension ListTableViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return Student.sharedInstance.students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell") as! ListCustomCell
        let student = Student.sharedInstance.students[indexPath.row]
        
        cell.cellImage.image = UIImage(named: "pin")
        cell.nameLabel.text = student.firstName! + " " + student.lastName!
        cell.urlLabel.text = student.mediaURL!
        
        return cell
    }
}

extension ListTableViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = Student.sharedInstance.students[indexPath.row]
        if let urlString = student.mediaURL {
            if verifyURL(urlString) {
                UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
            } else {
                AlerView.showAlert(self, title: "Alert", message: "Invalid URL")
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}