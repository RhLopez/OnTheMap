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
    
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        ActivityIndicatorOverlay.shared.showOverlay(listTableView)
        Udacity.sharedInstance().logOut { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), { 
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                AlerView.showAler(self, message: "Unable to logout.\nPlease try again.")
            }
        }
    }
    
    @IBAction func postLocationButtonPressed(sender: AnyObject) {
        Parse.sharedInstance().queryStudentLocation { (success, locationPosted, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    if locationPosted == true {
                        self.studentLocationPostedAlert()
                    } else {
                        self.newPosting = true
                        self.performSegueWithIdentifier("postStudentLocation", sender: self)
                    }
                })
            } else {
                AlerView.showAler(self, message: "Unable to query Student Location.\nPlease try again.")
            }
        }
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        Student.sharedInstance().students.removeAll()
        ActivityIndicatorOverlay.shared.showOverlay(listTableView)
        Parse.sharedInstance().getStudentLocations { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), { 
                    self.listTableView.reloadData()
                    ActivityIndicatorOverlay.shared.hideOverlayView()
                })
            } else {
                AlerView.showAler(self, message: "Unable to load Student Locations.\nPlease try again.")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postStudentLocation" {
            let controller = segue.destinationViewController as! LocationFinderViewController
            controller.newPosting = self.newPosting!
        }
    }
    
    func studentLocationPostedAlert() {
        let message = "User \(Student.sharedInstance().firstName!) \(Student.sharedInstance().lastName!) has already\nPosted a Student Location. Do you\nwant to overwrite the location?"
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
       return Student.sharedInstance().students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itemCell") as! ListCustomCell
        let student = Student.sharedInstance().students[indexPath.row]
        
        cell.cellImage.image = UIImage(named: "pin")
        cell.nameLabel.text = student.firstName! + " " + student.lastName!
        cell.urlLabel.text = student.mediaURL!
        
        return cell
    }
}

extension ListTableViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = Student.sharedInstance().students[indexPath.row]
        if let urlString = student.mediaURL {
            if verifyURL(urlString) {
                UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
            } else {
                let alert = UIAlertController(title: "Alert", message: "Invalid URL", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}