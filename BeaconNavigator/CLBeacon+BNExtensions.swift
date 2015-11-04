//
//  CLBeacon+BNExtensions.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 16.07.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import Foundation
import CoreLocation

let ENVVARNKEY = "EnvVarN"
let ENVVARNKEY0 = "EnvVarN0"
let ENVVARNKEY1 = "EnvVarN1"
let ENVVARNKEY2 = "EnvVarN2"
let RSSIVALUES = "RSSIVALUES"

let ReferenceDistance : Float = 1
let RSSIAtReferenceDistance : Int = -55

var rssiValuesForBeacon: [CLBeacon: [Int]] = [:]

extension CLBeacon {
    
    func getDistance() -> CGFloat {
        let distanceType = NSUserDefaults.standardUserDefaults().integerForKey(BeaconSettingsDistanceType)
        switch distanceType {
        case 0:
            return CGFloat(accuracy)
        case 1:
            return getAccuracyCalculatedByUsingLogNormal()
        case 1:
            return getAccuracyCalculatedByRSSIFittingCurve()
        case 3:
            return getAccuracyCalculatedByThirdParty()
        default:
            return 0.0
        }
    }
    
    func getAccuracyCalculatedByUsingLogNormal() -> CGFloat {
        if rssi == 0 {
            return -1.0; // if we cannot determine accuracy, return -1.
        }
        let storedN = NSUserDefaults.standardUserDefaults().floatForKey(keyForEnvVar(ENVVARNKEY))
        let n : Float = storedN > 0 ? storedN : 1.4
        
        let distance = ReferenceDistance * exp((Float(RSSIAtReferenceDistance) - Float(self.rssi) - 4) / (10 * n))
        return CGFloat(distance)
    }
    
    func getAccuracyCalculatedByRSSIFittingCurve() -> CGFloat {
        if rssi == 0 {
            return -1.0; // if we cannot determine accuracy, return -1.
        }
        let a0 = NSUserDefaults.standardUserDefaults().floatForKey(ENVVARNKEY0)
        let a1 = NSUserDefaults.standardUserDefaults().floatForKey(ENVVARNKEY1)
        let a2 = NSUserDefaults.standardUserDefaults().floatForKey(ENVVARNKEY2)
        
        let distance = a2 * Float(rssi * rssi) + a1 * Float(rssi) + a0
        return CGFloat(distance)
    }
    
    func getAccuracyCalculatedByThirdParty() -> CGFloat {
        
        //formula adapted from David Young's Radius Networks Android iBeacon Code
        
        if rssi == 0 {
            return -1.0; // if we cannot determine accuracy, return -1.
        }
        
        // Value is RSSI ~1M from a beacon
        let ratio : CGFloat = CGFloat(rssi) * 1.0 / CGFloat(RSSIAtReferenceDistance)
        if (ratio < 1.0) {
            return pow(ratio,10);
        }
        else {
            let accuracy : CGFloat =  (0.89976) * pow(ratio,7.7095) + 0.111;
            return accuracy
        }
    }
    
    func averageRSSI() -> Int {
        if rssiValuesForBeacon[self] == nil {
            rssiValuesForBeacon[self] = [Int]()
        }
        rssiValuesForBeacon[self]?.append(rssi)
        if rssiValuesForBeacon[self]?.count > 20 {
            rssiValuesForBeacon[self]?.removeFirst()
        }
        
        var middleValue = 0
        for rssiValue in rssiValuesForBeacon[self]! {
            middleValue += rssiValue
        }
        
        return middleValue / rssiValuesForBeacon[self]!.count
    }
    
    func keyForEnvVar(envVar : String) -> String {
        return ("\(envVar)\(self.major)\(self.minor)")
    }
}