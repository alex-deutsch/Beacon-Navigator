//
//  BeaconMap.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 10.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class BeaconMap {
    
    var beaconCoordinates : [Int : CGPoint] = [:]
    
    required init(fileName : String) {
        if let dictionary = NSDictionary(contentsOfFile: "fileName") {
            for (key, value) in dictionary {
                if let value = value as? [NSNumber], key = key as? Int {
                    if value.count == 2 {
                        let coordinate = CGPoint(x: value[0].integerValue, y: value[1].integerValue)
                        beaconCoordinates[key] = coordinate
                    }
                }
                
            }
        }
    }
    
    func coordinateForBeacon(beacon : CLBeacon) -> CGPoint? {
        let minorValue = beacon.minor.integerValue
        let coordinate = beaconCoordinates[minorValue]
        return coordinate
    }
    
    func beaconCoordinatesForBeacons(beacons : [CLBeacon]) -> [CLBeacon:CGPoint] {
        var beaconCoordinates : [CLBeacon:CGPoint] = [:]
        for beacon in beacons {
            if let coordinate = coordinateForBeacon(beacon) {
                beaconCoordinates[beacon] = coordinate
            }
        }
        return beaconCoordinates
    }
}