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
        super.viewDidAppear(true)
        listTableView.reloadData()
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
        
        return cell
    }
}