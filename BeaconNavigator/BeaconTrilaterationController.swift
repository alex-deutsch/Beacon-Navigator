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
    
    static let sharedInstance = BeaconTrilaterationController()
    
    func trilaterateUsingBeacons(beacons : [CLBeacon], usingBeaconMap beaconMap : BeaconMap, completionBlock : ((error : NSError?, coordinates : CGPoint?) -> Void)) {
        var error : NSError?
        
        // Only use beacons which are on the map
        var usableBeacons = beacons.filter() { return beaconMap.beaconIsOnMap($0) }
        // remove beacons with negative accuracy
        usableBeacons = usableBeacons.filter() { return $0.accuracy > 0 }
        
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
        
        let beaconCoordinates = beaconMap.beaconCoordinatesForBeacons(usableBeacons)
        
        if beaconCoordinates.count < 2 {
            error = NSError(domain: BeaconErrorDomain, code: 2, userInfo: ["description":"Could not map at Least 3 Beacons to the Map"])
            completionBlock(error: error, coordinates: nil)
            return
        }
        else {
            if let position = trilaterate2D(beacon1, beacon2: beacon2, beacon3: beacon3, inMap: beaconMap) {
                completionBlock(error: nil, coordinates: position)
            }
            else {
                error = NSError(domain: BeaconErrorDomain, code: 2, userInfo: ["trilaterion Error":"unknown Trilateration Error"])
                completionBlock(error: nil, coordinates: nil)
            }
        }
        
    }
    
    
    // MARK: Helper functions
    
    /* Trilateration Method for 2D Calculation, requires the beacons to be placed in the same height as the cellphone will be held, accepts only 3 Beacons
    @param beaconP1
    @param beaconP2
    @param beaconP3
    @param the map the beacons are located in
    */
    private func trilaterate2D(beacon1 : CLBeacon, beacon2 : CLBeacon, beacon3 : CLBeacon, inMap map : BeaconMap) -> CGPoint? {
        
        if let beaconP1 = map.coordinateForBeacon(beacon1),
        beaconP2 = map.coordinateForBeacon(beacon2),
        beaconP3 = map.coordinateForBeacon(beacon3)
        {
            // TODO: Implement
            
            // First Implementation without
        }
        return nil
    }
    
    /* Calculates Distance between 2 Points
    *
    @param pointA the first point
    @param pointB the second point
    @return distance between given points
    *
    */
    private func distanceBetweenPoints(pointA : CGPoint, pointB : CGPoint) -> CGFloat {
        let value = pow(pointB.x - pointA.x,2) + pow(pointB.y - pointA.y,2)
        let value2 = fabsf(Float(value))
        let value3 = sqrt(value2)
        return CGFloat(value3)
    }
    
    /* Transforms a point to a new Coordinate System
    @param point the point to be transleted
    @param translationVector the translation vector
    @param the translation angle
    @return the point coordinates in the translated coordinate system
    */
    
    private func transformPointToCoordinateSystem(point : CGPoint, translationVector vector : CGPoint, translationAngle angle : Double) -> CGPoint {
        let x = point.x * CGFloat(cos(angle)) - point.y * CGFloat(sin(angle)) + vector.x
        let y = point.x * CGFloat(sin(angle)) - point.y * CGFloat(cos(angle)) + vector.y
        return CGPointMake(x, y)
    }
    
    // Radian / Degree conversion helpers
    
    private func DegreesToRadians (value:Double) -> Double {
        return value * M_PI / 180.0
    }
    
    private func RadiansToDegrees (value:Double) -> Double {
        return value * 180.0 / M_PI
    }
    
}