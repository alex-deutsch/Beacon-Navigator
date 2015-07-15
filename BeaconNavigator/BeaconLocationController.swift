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

enum LocationMethod : Int {
    case Trilateration = 0
    case TrilaterationAlternative = 1
    case LeastSquares = 2
}

class BeaconLocationController {
    
    static let sharedInstance = BeaconLocationController()
    
    func locateUsingBeacons(beacons : [CLBeacon], usingBeaconMap beaconMap : BeaconMap, locationMethod : LocationMethod, completionBlock : ((error : NSError?, coordinates : Location?, usedBeacons : [CLBeacon]) -> Void)) {
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
        
        

        
        let beaconCoordinates = beaconMap.beaconCoordinatesForBeacons(usableBeacons)
        
        if beaconCoordinates.count < 2 {
            error = NSError(domain: BeaconErrorDomain, code: 2, userInfo: ["description":"Could not map at Least 3 Beacons to the Map"])
            completionBlock(error: error, coordinates: nil, usedBeacons : usableBeacons)
            return
        }
        else {
            
            //Trilateration #1
            if let position = trilaterate2D(beacon1, beacon2: beacon2, beacon3: beacon3, inMap: beaconMap) {
                NSLog("Trilateration Result \(position.x), \(position.y), 0")
                if locationMethod == .Trilateration {
                    completionBlock(error: nil, coordinates: Location(x: position.x, y: position.y, z: 0), usedBeacons : [beacon1,beacon2,beacon3])
                }
            }
            else {
                if locationMethod == .Trilateration {
                    error = NSError(domain: BeaconErrorDomain, code: 2, userInfo: ["trilaterion Error":"unknown Trilateration Error"])
                    completionBlock(error: nil, coordinates: nil, usedBeacons : [beacon1,beacon2,beacon3])
                }
            }
            
            // Trilateration #2
            
            if let trilateration2Location = trilaterate3D([beacon1,beacon2,beacon3], map: beaconMap) {
                NSLog("Trilateration #2  Result: \(trilateration2Location.x), \(trilateration2Location.y), \(trilateration2Location.z)")
                if locationMethod == .TrilaterationAlternative {
                completionBlock(error: nil, coordinates: trilateration2Location, usedBeacons: [beacon1,beacon2,beacon3])
                }
            }
            
            // Multilateration
            
            let location = multilaterate(usableBeacons, map: beaconMap)
            NSLog("Multilaterion Result: \(location.x), \(location.y), \(location.z)")
            if locationMethod == .LeastSquares {
                completionBlock(error: nil, coordinates: location, usedBeacons: usableBeacons)
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
            if beaconP2.y + translationVector.y != 0 {
                
                translationAngle = abs(atan((beaconP2.y + translationVector.y) / (beaconP2.x + translationVector.x)))
                // x > 0, y >0, nothing to do on additional calculation
                
                if beaconP2.x + translationVector.x > 0 && beaconP2.y + translationVector.y < 0 {
                    translationAngle = π - translationAngle
                }
                else if beaconP2.x + translationVector.x < 0 && beaconP2.y + translationVector.y < 0 {
                    translationAngle += π
                }
                else if beaconP2.x + translationVector.x < 0 && beaconP2.y + translationVector.y > 0 {
                    translationAngle = π - translationAngle
                }
            }
            
            let angleInDegree = RadiansToDegrees(translationAngle)
            
            var beaconP1T = transformPointToNewCoordinateSystem2D(beaconP1, translationVector: translationVector, translationAngle: Double(translationAngle))
            
            var beaconP2T = transformPointToNewCoordinateSystem2D(beaconP2, translationVector: translationVector, translationAngle: Double(translationAngle))
            
            var beaconP3T = transformPointToNewCoordinateSystem2D(beaconP3, translationVector: translationVector, translationAngle: Double(translationAngle))
            
            var distance1T = CGFloat(beacon1.accuracy)
            var distance2T = CGFloat(beacon2.accuracy)
            var distance3T = CGFloat(beacon3.accuracy)

            // Algorithm from http://stackoverflow.com/questions/16176656/trilateration-and-locating-the-point-x-y-z // This actually sucks
            let xPositionT1 = (pow(distance1T) - pow(distance2T) + pow(beaconP2T.x)) / (2 * beaconP2T.x)
            let yPositionT1 = (pow(distance1T) - pow(distance3T) + pow(beaconP3T.x) + pow(beaconP3T.y)) / (2 * beaconP3T.y - (beaconP3T.x / beaconP3T.y) * xPositionT1)
            var position = transformPointToOriginCoordinateSystem2D(CGPointMake(xPositionT1, yPositionT1), translationVector: translationVector, translationAngle: Double(translationAngle))
            position = adjustPointToBeInsideMap(position, map: map)
            
            // alternative algorithm from https://en.wikipedia.org/wiki/Trilateration
            let xPositionT2 = (pow(distance1T) - pow(distance2T) + pow(beaconP2T.x)) / (2 * beaconP2T.x)
            let yPositionT2 = (pow(distance2T) - pow(distance3T) + pow(beaconP3T.x) + pow(beaconP3T.y)) / (2 * beaconP3T.y) - beaconP3T.x / beaconP3T.y * xPositionT2
            let positionT2 = CGPointMake(xPositionT2, yPositionT2)
            var position2 = transformPointToOriginCoordinateSystem2D(positionT2, translationVector: translationVector, translationAngle: Double(translationAngle))
            position2 = adjustPointToBeInsideMap(position2, map: map)
            
            // mix algorithms
            let positionT23Mix = CGPointMake((xPositionT1 + xPositionT2) / 2, (yPositionT1 + yPositionT2) / 2)
            var position23Mix = transformPointToOriginCoordinateSystem2D(positionT23Mix, translationVector: translationVector, translationAngle: Double(translationAngle))
            position23Mix = adjustPointToBeInsideMap(position23Mix, map: map)
            
            return position2
            
        }
        return nil
    }
    
    func multilaterate(beacons : [CLBeacon], map : BeaconMap) -> Location {
        var transmissions : [NSDictionary] = []
        for beacon in beacons {
            if let beaconCoordinate = map.coordinateForBeacon(beacon) {
                var transmission = ["x":beaconCoordinate.x,"y":beaconCoordinate.y,"accuracy":beacon.accuracy]
                transmissions.append(transmission)
            }

        }
        
        let pointArray = NonLinear.determine(transmissions)
        var location = Location(x: CGFloat(pointArray[0].floatValue), y: CGFloat(pointArray[1].floatValue), z: CGFloat(pointArray[2].floatValue))
        // adjust location to be inside map
        location = adjustLocationToBeInsideMap(location, map: map)
        return location
    }
    
    func trilaterate3D(beacons : [CLBeacon], map : BeaconMap) -> Location? {
        var transmissions : [NSDictionary] = []
        for beacon in beacons {
            if let beaconCoordinate = map.coordinateForBeacon(beacon) {
                var transmission = ["x":beaconCoordinate.x,"y":beaconCoordinate.y,"accuracy":beacon.accuracy]
                transmissions.append(transmission)
            }
            
        }
        
        if let pointArray = Trilateration.trilaterate(transmissions) as? [NSNumber] {
            var location = Location(x: CGFloat(pointArray[0].floatValue), y: CGFloat(pointArray[1].floatValue), z: CGFloat(pointArray[2].floatValue))
            // adjust location to be inside map
            location = adjustLocationToBeInsideMap(location, map: map)
            return location
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
    
    func adjustLocationToBeInsideMap(location : Location, map : BeaconMap) -> Location {
        // Adjust Position so it will always be inside the Map
        var adjustedPoint = location
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
        let y = pointY * CGFloat(cos(angle)) - pointX * CGFloat(sin(angle))
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