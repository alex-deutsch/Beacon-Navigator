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
    @IBOutlet var beaconAccuracyLabel2 : UILabel!
    @IBOutlet var beaconRSSILabel : UILabel!
    var beacon : CLBeacon?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(BeaconViewController.didUpdateBeacons(_:)), name: NSNotification.Name(rawValue: BeaconManagerDidUpdateAvailableBeacons), object: nil)
        if let beacon = beacon {
            beaconNameLabel.text = "Beacon Minor \(beacon.minor), Major: \(beacon.major)"
        }
    }
    
    func didUpdateBeacons(_ notification : Notification) {
        
        if let beacons = notification.userInfo!["beacons"] as? [CLBeacon] {
            for currentBeacon in beacons {
                if currentBeacon.minor == beacon?.minor {
                    self.beacon = currentBeacon
                    beaconAccuracyLabel.text = "Distance CL: \(self.beacon!.accuracy) m"
                    beaconAccuracyLabel2.text = "Distance LN: \(self.beacon!.getAccuracyCalculatedByUsingLogNormal()) m"
                    beaconRSSILabel.text = "RSSI: \(self.beacon?.rssi) db"
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "beaconToRSSI" {
            if let viewController = segue.destination as? RSSICalibratorViewController {
                viewController.beacon = beacon
            }
        }
    }
}       
