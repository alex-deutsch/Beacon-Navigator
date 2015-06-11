//
//  BeaconMapChooserTableViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 11.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit

class BeaconMapChooserTableViewController: UITableViewController {
    
    let CellIdentifier = "BeaconMapRow"
    
    
    var maps : [BeaconMap] {
        get {
            return BeaconMapManager.sharedInstance.maps
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
        
        let map = maps[indexPath.row]
        
        cell.textLabel?.text = map.name
        cell.detailTextLabel?.text = ""
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maps.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapChoose2Map" {
            if let viewController = segue.destinationViewController as? BeaconMapViewController {
                let map = maps[tableView.indexPathForSelectedRow()!.row]
                viewController.beaconMap = map
            }
        }
    }
}
