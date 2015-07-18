//
//  CLBeacon+BNExtensions.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 16.07.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import Foundation
import CoreLocation

extension CLBeacon {
    
    func getDistance() -> CGFloat {
        let distanceType = NSUserDefaults.standardUserDefaults().integerForKey("DistanceType")
        switch distanceType {
        case 0:
            return CGFloat(accuracy)
        case 1:
            return getAccuracyCalculatedByRSSI()
        default:
            return 0.0
        }
    }
    
    func getAccuracyCalculatedByRSSI() -> CGFloat {
        
        //formula adapted from David Young's Radius Networks Android iBeacon Code
        
        if rssi == 0 {
            return -1.0; // if we cannot determine accuracy, return -1.
        }
        
        // Value is RSSI ~1M from a beacon
        let txPower : CGFloat = -60
        let ratio : CGFloat = CGFloat(rssi) * 1.0 / txPower
        if (ratio < 1.0) {
            NSLog("ration < 1 for beacon: \(minor)")
            return pow(ratio,10);
        }
        else {
            let accuracy : CGFloat =  (0.89976) * pow(ratio,7.7095) + 0.111;
            return accuracy
        }
    }
}