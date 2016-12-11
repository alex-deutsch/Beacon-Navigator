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
    
    
    let name : String
    var edgeCoordinates : [CGPoint] = []
    var maxPoint = CGPoint.zero
    
    // Beacon Minor Value(Int) : Point(CGPoint)
    fileprivate var beaconCoordinates : [Int : CGPoint] = [:]
    
    required init(fileName : String) {
        if  let path = Bundle.main.path(forResource: fileName, ofType: "plist"),
            let dictionary = NSDictionary(contentsOfFile: path),
            let beacons = dictionary["beacons"] as? Dictionary<String,Dictionary<String,NSNumber>>,
            let edges = dictionary["edges"] as? Array<Dictionary<String,NSNumber>> {
            
                // Read Edges
                for edge in edges {
                    let edgePoint = CGPoint(x: CGFloat(edge["x"]!.floatValue), y: CGFloat(edge["y"]!.floatValue))
                    edgeCoordinates.append(edgePoint)
                    
                    // Set Max Point
                    if edgePoint.x > maxPoint.x {
                        maxPoint.x = edgePoint.x
                    }
                    else if edgePoint.y > maxPoint.y {
                        maxPoint.y = edgePoint.y
                    }
                }
                
                // Read Beacon Coordinates
                for (beaconMinor, coordinate) in beacons {
                    let coordinate = CGPoint(x: CGFloat(coordinate["x"]!.floatValue), y: CGFloat(coordinate["y"]!.floatValue))
                    beaconCoordinates[Int(beaconMinor)!] = coordinate
                    
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
    func coordinateForBeacon(_ beacon : CLBeacon) -> CGPoint? {
        let minorValue = beacon.minor.intValue
        let coordinate = beaconCoordinates[minorValue]
        return coordinate
    }
    
    /* Returns a dictionary of beacons and corresponding points
    @param beacons an array of beacons to map with points
    @return dictionary of beacons and corresponding points
    */
    func beaconCoordinatesForBeacons(_ beacons : [CLBeacon]) -> [CLBeacon:CGPoint] {
        var beaconCoordinates : [CLBeacon:CGPoint] = [:]
        for beacon in beacons {
            if let coordinate = coordinateForBeacon(beacon) {
                beaconCoordinates[beacon] = coordinate
            }
        }
        return beaconCoordinates
    }
    
    /* Check if that beacon is on that map 
    @return boolean value if the beacon positioned on in this map
    */
    func beaconIsOnMap(_ beacon : CLBeacon) -> Bool {
        return beaconCoordinates.keys.contains(beacon.minor.intValue)
    }
}
