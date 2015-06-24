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
let π = CGFloat(M_PI)

class BeaconTrilaterationController {
    
    static let sharedInstance = BeaconTrilaterationController()
    
    func trilaterateUsingBeacons(beacons : [CLBeacon], usingBeaconMap beaconMap : BeaconMap, completionBlock : ((error : NSError?, coordinates : CGPoint?, usedBeacons : [CLBeacon]) -> Void)) {
        var error : NSError?
        
        // Only use beacons which are on the map
        var usableBeacons = beacons.filter() { return beaconMap.beaconIsOnMap($0) }
        // remove beacons with negative accuracy
        usableBeacons = usableBeacons.filter() { return $0.accuracy > 0 }
        
        if usableBeacons.count < 3 {
            error = NSError(domain: BeaconErrorDomain, code: 1, userInfo: ["description":"Less then 3 Beacons have a positive Accuracy"])
            completionBlock(error: error, coordinates: nil, usedBeacons : usableBeacons)
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
            completionBlock(error: error, coordinates: nil, usedBeacons : usableBeacons)
            return
        }
        else {
            if let position = trilaterate2D(beacon1, beacon2: beacon2, beacon3: beacon3, inMap: beaconMap) {
                NSLog("calculated position \(position)")
                completionBlock(error: nil, coordinates: position, usedBeacons : [beacon1,beacon2,beacon3])
            }
            else {
                error = NSError(domain: BeaconErrorDomain, code: 2, userInfo: ["trilaterion Error":"unknown Trilateration Error"])
                completionBlock(error: nil, coordinates: nil, usedBeacons : [beacon1,beacon2,beacon3])
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
            
            // Translation Vector (if P1 is not (0,0))
            let translationVector = CGPointMake( -beaconP1.x, -beaconP1.y)
            
            // Translation Angle (if P2.x != 0)
            // Case differention
            
            var translationAngle : CGFloat = 0
            if beaconP2.y != 0 {
                
                translationAngle = abs(atan(beaconP2.y / beaconP2.x))
                // x > 0, y >0, nothing to do on additional calculation
                
                if beaconP2.x > 0 && beaconP2.y < 0 {
                    translationAngle = π - translationAngle
                }
                else if beaconP2.x < 0 && beaconP2.y < 0 {
                    translationAngle += π
                }
                else if beaconP2.x < 0 && beaconP2.y > 0 {
                    translationAngle = π - translationAngle
                }
            }
            
            let angleInDegree = RadiansToDegrees(translationAngle)
            
            var beaconP2T = transformPointToNewCoordinateSystem2D(beaconP2, translationVector: translationVector, translationAngle: Double(translationAngle))
            
            var beaconP3T = transformPointToNewCoordinateSystem2D(beaconP3, translationVector: translationVector, translationAngle: Double(translationAngle))
            
            var distance1T = CGFloat(beacon1.accuracy)
            var distance2T = CGFloat(beacon2.accuracy)
            var distance3T = CGFloat(beacon3.accuracy)
            
            // Switch Points for calculation if beaconP2T.x == 0, because otherwise divition through zero
            if beaconP2T.x == 0 {
                var tempBeacon = beaconP3T
                beaconP3T = beaconP2T
                beaconP2T = tempBeacon
                
                var tempDistance = distance2T
                distance2T = distance3T
                distance3T = tempDistance
            }
            
            let xPositionT1 = (pow(beaconP2T.x) + pow(distance1T) - pow(distance2T)) / (2 * beaconP2T.x)
            let yPositionT1 = sqrt(pow(distance1T) - pow(xPositionT1))
            let yPositionT2 = sqrt(pow(xPositionT1) - 2 * xPositionT1 * beaconP2T.x + pow(beaconP2T.x) - pow(distance2T))
            // Tests only
            let yPositionT3 = (pow(distance1T) - pow(distance2T) + pow(beaconP3T.x) + pow(beaconP3T.y)) / (2 * beaconP3T.y) - (beaconP3T.x / beaconP3T.y) * xPositionT1
            
            let positionT = CGPointMake(xPositionT1, (yPositionT2 > 0) ? yPositionT2 : yPositionT1)
            var position = transformPointToOriginCoordinateSystem2D(positionT, translationVector: translationVector, translationAngle: Double(translationAngle))
            
            position = adjustPointToBeInsideMap(position, map: map)
            
            return position
        }
        return nil
    }
    
    /*
    *
    - Param point : the point to be adjusted
    - Param map : the map the point should be adjusted in
    - return the new point which is guranteed within the map edges
    */
    func adjustPointToBeInsideMap(point : CGPoint, map : BeaconMap) -> CGPoint {
        // Adjust Position so it will always be inside the Map
        var adjustedPoint = point
        adjustedPoint.x = max(0, adjustedPoint.x)
        adjustedPoint.x = min(adjustedPoint.x, map.maxPoint.x)
        adjustedPoint.y = max(0, adjustedPoint.y)
        adjustedPoint.y = min(adjustedPoint.y, map.maxPoint.y)
        return adjustedPoint
    }
    
    /* Calculates Distance between 2 Points
    *
    @param pointA the first point
    @param pointB the second point
    @return distance between given points
    *
    */
    private func distanceBetweenPoints(pointA : CGPoint, pointB : CGPoint) -> CGFloat {
        let value = pow(pointB.x - pointA.x) + pow(pointB.y - pointA.y)
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
    
    private func transformPointToNewCoordinateSystem2D(point : CGPoint, translationVector vector : CGPoint, translationAngle angle : Double) -> CGPoint {
        let pointX = point.x + vector.x
        let pointY = point.y + vector.y
        let x = pointX * CGFloat(cos(angle)) + pointY * CGFloat(sin(angle))
        let y = (-pointX) * CGFloat(sin(angle)) + pointY * CGFloat(cos(angle))
        return CGPointMake(x, y)
    }
    
    private func transformPointToOriginCoordinateSystem2D(point : CGPoint, translationVector vector : CGPoint, translationAngle angle : Double) -> CGPoint {
        let x = point.x * CGFloat(cos(angle)) - point.y * CGFloat(sin(angle)) - vector.x
        let y = point.x * CGFloat(sin(angle)) + point.y * CGFloat(cos(angle)) - vector.y
        return CGPointMake(x, y)
    }
    // Radian / Degree conversion helpers
    
    func DegreesToRadians (value:CGFloat) -> CGFloat {
        return value * π / 180.0
    }
    
    func RadiansToDegrees (value:CGFloat) -> CGFloat {
        return value * 180.0 / π
    }
    
    func pow(value : CGFloat) -> CGFloat {
        return value * value
    }
    
}