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

class BeaconTrilaterationController {
    
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
        
        let position = trilaterate(beaconCoordinates[beacon1]!, beaconP2: beaconCoordinates[beacon2]!, beaconP3: beaconCoordinates[beacon3]!)
        completionBlock(error: nil, coordinates: position)
    }
    
    
    // MARK: Helper functions
    
    /* Trilateration Method, accepts only 3 Beacons
    @param beaconP1
    @param beaconP2
    @param beaconP3
    */
    private func trilaterate(beaconP1 : CGPoint, beaconP2 : CGPoint, beaconP3 : CGPoint) -> CGPoint {
        
        var W, Z, x, y, y2 : CGFloat
        
        let distanceA = distanceBetweenPoints(beaconP1, pointB: beaconP2)
        let distanceB = distanceBetweenPoints(beaconP2, pointB: beaconP3)
        let distanceC = distanceBetweenPoints(beaconP3, pointB: beaconP1)
        
        W = distanceA * distanceA - distanceB * distanceB - beaconP1.x * beaconP1.x - beaconP1.y * beaconP1.y + beaconP2.x * beaconP2.x + beaconP2.y * beaconP2.y
        Z = distanceB * distanceB - distanceC * distanceC - beaconP2.x * beaconP2.x - beaconP2.y * beaconP2.y + beaconP3.x * beaconP3.x + beaconP3.y * beaconP3.y
        
        x = (W * (beaconP3.y - beaconP2.y) - Z*(beaconP2.y - beaconP1.y)) / ( 2 * ((beaconP2.x - beaconP1.x) * (beaconP3.y - beaconP2.y) - (beaconP3.x - beaconP2.x) * (beaconP2.y - beaconP1.y)))
        y = (W - 2 * x * (beaconP2.x - beaconP1.x)) / (2 * (beaconP2.y - beaconP1.y))
        
        y2 = (Z - 2 * x * (beaconP3.x - beaconP2.x)) / (2 * (beaconP3.y - beaconP2.y))
        
        y = (y + y2) / 2
        
        return CGPointMake(x, y)
    }

    /* Calculates Distance between 2 Points
    *
    @param pointA the first point
    @param pointB the second point
    @return distance between given points
    *
    */
    private func distanceBetweenPoints(pointA : CGPoint, pointB : CGPoint) -> CGFloat {
        return sqrt(pow(pointB.x - pointA.x,2) - pow(pointB.y - pointA.y,2))
    }
    
}