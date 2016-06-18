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
        API.sharedInstance().logoutUdacity { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                print("Unable to logout")
            }
        }
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        Student.sharedInstance().students.removeAll()
        ActivityIndicatorOverlay.shared.showOverlay(listTableView)
        API.sharedInstance().loginToParse { (success, errorString) in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                   self.listTableView.reloadData()
                    ActivityIndicatorOverlay.shared.hideOverlayView()
                } else {
                    print("no success")
                }
            })
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
                showInvalidURLAlert()
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}