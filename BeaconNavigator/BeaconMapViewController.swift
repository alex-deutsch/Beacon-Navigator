//
//  BeaconMapViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 12.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconMapViewController : UIViewController {
    
    @IBOutlet var beaconMapView : BeaconMapView!
    
    var beaconMap : BeaconMap?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register for Beacon updates
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateBeacons:", name: BeaconManagerDidUpdateAvailableBeacons, object: nil)
        
        // Set Beacon Map Size to draw it
        if let beaconMap = beaconMap {
            beaconMapView.edgePoints = beaconMap.edgeCoordinates
        }
    }
    
    
    func didUpdateBeacons(notification : NSNotification) {
        
        if let beacons = notification.userInfo!["beacons"] as? [CLBeacon] {
            
            
            
            // Update map with available Beacons
            if let beaconMap = beaconMap {
                
                var beaconMinorPosition : [Int:CGPoint] = [:]
                for beacon in beacons {
                    beaconMinorPosition[beacon.minor.integerValue] = beaconMap.coordinateForBeacon(beacon)
                    if beacon.accuracy > 0 {
                        beaconMapView.beaconDistances[beacon.minor.integerValue] = CGFloat(beacon.accuracy)
                    }
                }
                
                beaconMapView.beaconPoints = beaconMinorPosition
                
                // Calculate Position
                BeaconTrilaterationController.sharedInstance.trilaterateUsingBeacons(beacons,usingBeaconMap: beaconMap, completionBlock: { (error, coordinates) -> Void in
                    if let error = error {
                        NSLog("Error Trilaterating: \(error.localizedDescription)")
                    }
                    else if let coordinates = coordinates {
                        NSLog("received current position: \(coordinates)")
                        self.beaconMapView.currentPosition = coordinates
                    }
                })
            }
            
        }
    }
}
