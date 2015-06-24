//
//  BeaconTableViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 10.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

class BeaconTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let CellIdentifier = "BeaconRow"
    
    var locationManager : CLLocationManager?
    
    var beacons : [CLBeacon]?

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
        
        let beacon = beacons![indexPath.row]
        
        cell.textLabel?.text = "Major: \(beacon.major) Minor: \(beacon.minor)"
        cell.detailTextLabel?.text = "Accuracy: \(beacon.accuracy), RSSI: \(beacon.rssi)"
        
        return cell
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateBeacons:", name: BeaconManagerDidUpdateAvailableBeacons, object: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let beacons = beacons {
            return beacons.count
        }
        return 0
    }
    
    func didUpdateBeacons(notification : NSNotification) {
        var updatedBeacons : [CLBeacon] = notification.userInfo!["beacons"] as! [CLBeacon]
        beacons = updatedBeacons
        tableView.reloadData()
    }
}
