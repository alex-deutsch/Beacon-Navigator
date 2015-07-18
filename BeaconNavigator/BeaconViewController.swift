//
//  BeaconViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 16.07.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconViewController : UIViewController {
    
    @IBOutlet var beaconNameLabel : UILabel!
    @IBOutlet var beaconAccuracyLabel : UILabel!
    var beacon : CLBeacon?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateBeacons:", name: BeaconManagerDidUpdateAvailableBeacons, object: nil)
        if let beacon = beacon {
            beaconNameLabel.text = "Beacon Minor \(beacon.minor), Major: \(beacon.major)"
        }
    }
    
    func didUpdateBeacons(notification : NSNotification) {
        
        if let beacons = notification.userInfo!["beacons"] as? [CLBeacon] {
            for currentBeacon in beacons {
                if currentBeacon.minor == beacon?.minor {
                    self.beacon = currentBeacon
                    beaconAccuracyLabel.text = "Distance: \(self.beacon!.getDistance()) m"
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}       