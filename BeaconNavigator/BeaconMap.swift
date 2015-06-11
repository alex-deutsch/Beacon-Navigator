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
    
    
    var name : String
    

    var size : CGSize = CGSizeZero
    // Beacon Minor Value(Int) : Point(CGPoint)
    private var beaconCoordinates : [Int : CGPoint] = [:]
    
    required init(fileName : String) {
        if  let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist"),
            let dictionary = NSDictionary(contentsOfFile: path),
            let sizeDictionary = dictionary["size"] as? Dictionary<String,NSNumber>,
            let beaconDictionary = dictionary["beacons"] as? Dictionary<String,AnyObject>,
            let height = sizeDictionary["height"],
            let width = sizeDictionary["width"] {
            
                // Read Map Size
                size = CGSizeMake(CGFloat(width.floatValue), CGFloat(height.floatValue))
                
                // Read Beacon Coordinates
                for (key, value) in beaconDictionary {
                    if value.count == 2 {
                        let coordinate = CGPoint(x: value[0].integerValue, y: value[1].integerValue)
                        beaconCoordinates[key.toInt()!] = coordinate
                    }
                    
                }
        }
        else {
            NSLog("Error Loading Map with name: \(fileName), either map file was not found or the map does not contain all required parameters")
        }
        name = fileName
    }
    

    /* maps a beacon to a point in the map
    @param beacon the beacon to be mapped
    @return the matching point in the map of the beacon, nil if the beacon was not found on the map
    */
    func coordinateForBeacon(beacon : CLBeacon) -> CGPoint? {
        let minorValue = beacon.minor.integerValue
        let coordinate = beaconCoordinates[minorValue]
        return coordinate
    }
    
    /* Returns a dictionary of beacons and corresponding points
    @param beacons an array of beacons to map with points
    @return dictionary of beacons and corresponding points
    */
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