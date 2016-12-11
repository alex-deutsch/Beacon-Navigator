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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as UITableViewCell!
        
        let beacon = beacons![indexPath.row]
        
        cell?.imageView?.image = UIImage(named: "beacon_blue")
        cell?.textLabel?.text = "Major: \(beacon.major) Minor: \(beacon.minor)"
        cell?.detailTextLabel?.text = "Accuracy: \(beacon.accuracy) CAccuracy: \(beacon.getAccuracyCalculatedByUsingLogNormal()), RSSI: \(beacon.rssi)"
        
        return cell!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(BeaconTableViewController.didUpdateBeacons(_:)), name: NSNotification.Name(rawValue: BeaconManagerDidUpdateAvailableBeacons), object: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let beacons = beacons {
            return beacons.count
        }
        return 0
    }
    
    func didUpdateBeacons(_ notification : Notification) {
        let updatedBeacons = notification.userInfo!["beacons"] as! [CLBeacon]
        self.beacons = updatedBeacons
        self.beacons!.sort { (beacon1, beacon2) in return beacon1.minor.intValue > beacon2.minor.intValue }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beacon = self.beacons?[indexPath.row]
        let beaconViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BeaconViewController") as! BeaconViewController
        beaconViewController.beacon = beacon
        self.navigationController?.pushViewController(beaconViewController, animated: true)
    }
}
