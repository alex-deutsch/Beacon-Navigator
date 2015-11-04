//
//  ViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 18.05.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BeaconManager.sharedInstance
        self.title = "Beacon Navigator"
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        switch indexPath.section {
        case 0:
            cell.imageView?.image = UIImage(named: "icon_map")
            cell.textLabel?.text = "Indoor Navigation"
        case 1:
            cell.imageView?.image = UIImage(named: "beacon_blue")
            cell.textLabel?.text = "Beacon Liste"
        case 2:
            cell.imageView?.image = UIImage(named: "icon_settings")
            cell.textLabel?.text = "Einstellungen"
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            performSegueWithIdentifier("main2maps", sender: self)
        case 1:
            performSegueWithIdentifier("main2beaconlist", sender: self)
        case 2:
            performSegueWithIdentifier("main2settings", sender: self)
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

}

