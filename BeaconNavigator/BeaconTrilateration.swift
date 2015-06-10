//
//  BeaconTrilateration.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 10.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

let BeaconErrorDomain = "BeaconNavigator.f1re.de"

class BeaconTrilateration {
    
    func trilaterateUsingBeacons(beacons : [CLBeacon], map mapName : String, completionBlock : ((error : NSError?, coordinates : CGPoint?) -> Void)) {
        var error : NSError?
        
        // remove beacons with negative accuracy
        var usableBeacons = beacons.filter() { return $0.accuracy > 0 }
        
        if usableBeacons.count < 3 {
            error = NSError(domain: BeaconErrorDomain, code: 1, userInfo: ["description":"Less then 3 Beacons have a positive Accuracy"])
            completionBlock(error: error, coordinates: nil)
            return
        }
        
        let beacon1 = usableBeacons[0]
        let beacon2 = usableBeacons[1]
        let beacon3 = usableBeacons[2]
        
        // TODO: if there are more than 2 beacons, check if the first 3 beacons share the same minor or major id. if so take the 4th or 5th, ... beacon instead
        
        
        // Trilateration
        var beaconMap = BeaconMap(fileName: mapName)
        
        let beaconCoordinates = beaconMap.beaconCoordinatesForBeacons(usableBeacons)
        
        if beaconCoordinates.count > 2 {
            
        }
        else {
            error = NSError(domain: BeaconErrorDomain, code: 2, userInfo: ["description":"Could not map at Least 3 Beacons to the Map"])
            completionBlock(error: error, coordinates: nil)
            return
        }
    }
    
    func trilaterate(beaconCoordinates : [CLBeacon : CGPoint]) -> CGPoint {
        
    }
    
}