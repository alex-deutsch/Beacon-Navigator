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
    case trilateration = 0
    case lsq = 1
    case nlsq = 2
}

class BeaconLocationController {
    
    static let sharedInstance = BeaconLocationController()
    
    func locateUsingBeacons(_ beacons : [CLBeacon], usingBeaconMap beaconMap : BeaconMap, locationMethod : LocationMethod, completionBlock : ((_ error : NSError?, _ coordinates : Location?, _ usedBeacons : [CLBeacon]) -> Void)) {
        var error : NSError?
        
        // Only use beacons which are on the map
        var usableBeacons = beacons.filter() { return beaconMap.beaconIsOnMap($0) }
        
        // remove beacons with negative accuracy
        usableBeacons = usableBeacons.filter() { return $0.getDistance() > 0 }
        
        // If there are no more than 3 Beacons available, no calculations are possible
        if usableBeacons.count < 3 {
            error = NSError(domain: BeaconErrorDomain, code: 1, userInfo: ["description":"Less then 3 Beacons have a positive Accuracy"])
            completionBlock(error, nil, usableBeacons)
            return
        }
        
        // Apply Beacon Filters from User Settings
        let beaconNumberfilterSettings = UserDefaults.standard.integer(forKey: BeaconSettingsBeaconNumber)
        
        switch beaconNumberfilterSettings {
        case 0:
            break
        default:
            if usableBeacons.count > beaconNumberfilterSettings + 1 {
                var beaconArray : [CLBeacon] = []
                for i in 0..<beaconNumberfilterSettings+1 {
                    beaconArray.append(usableBeacons[i])
                }
                usableBeacons = beaconArray
            }

        }
        
        let beaconDistanceFilterSettings = UserDefaults.standard.integer(forKey: BeaconSettingsBeaconDistance)
        
        switch beaconDistanceFilterSettings {
        case 1:
            usableBeacons = usableBeacons.filter() { return $0.getDistance() < 3 }
        default:
            break
        }
        
        let beaconCoordinates = beaconMap.beaconCoordinatesForBeacons(usableBeacons)
        
        if beaconCoordinates.count < 2 {
            error = NSError(domain: BeaconErrorDomain, code: 2, userInfo: ["description":"Could not map at Least 3 Beacons to the Map"])
            completionBlock(error, nil, usableBeacons)
            return
        }
        else {
            guard let threeClosestBeacons : [CLBeacon] = [usableBeacons[0],usableBeacons[1],usableBeacons[2]] else { return }
            
            // Multilateration
            
            let locationLSQ = multilaterate(usableBeacons, map: beaconMap, method: .lsq)
            let locationNLSQ = multilaterate(usableBeacons, map: beaconMap, method: .nlsq)
            let positionTrilaterate = trilaterate2D(threeClosestBeacons, inMap: beaconMap)
            
            NSLog("locationLSQ   : \(locationLSQ.x), \(locationLSQ.y), \(locationLSQ.z)")
            NSLog("locationNLSQ  : \(locationNLSQ.x), \(locationNLSQ.y), \(locationNLSQ.z)")
            NSLog("Trilateration : \(positionTrilaterate.x), \(positionTrilaterate.y), \(positionTrilaterate.z)")
            NSLog("\n")
            
            if locationMethod == .nlsq {
                completionBlock(nil, locationNLSQ, usableBeacons)
            }
            else if locationMethod == .lsq {
                completionBlock(nil, locationLSQ, usableBeacons)
            }
            else if locationMethod == .trilateration {
                completionBlock(nil, positionTrilaterate, threeClosestBeacons)
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
    fileprivate func trilaterate2D(_ beacons : [CLBeacon], inMap map : BeaconMap) -> Location {
        
        if let beaconP1 = map.coordinateForBeacon(beacons[0]),
        let beaconP2 = map.coordinateForBeacon(beacons[1]),
        let beaconP3 = map.coordinateForBeacon(beacons[2])
        {
            // Translation Vector (if P1 is not (0,0))
            let translationVector = CGPoint( x: -beaconP1.x, y: -beaconP1.y)
            
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
            
            //let angleInDegree = RadiansToDegrees(translationAngle)
            
            //var beaconP1T = transformPointToNewCoordinateSystem2D(beaconP1, translationVector: translationVector, translationAngle: Double(translationAngle))
            
            let beaconP2T = transformPointToNewCoordinateSystem2D(beaconP2, translationVector: translationVector, translationAngle: Double(translationAngle))
            
            let beaconP3T = transformPointToNewCoordinateSystem2D(beaconP3, translationVector: translationVector, translationAngle: Double(translationAngle))
            
            let distance1T = CGFloat(beacons[0].getDistance())
            let distance2T = CGFloat(beacons[1].getDistance())
            let distance3T = CGFloat(beacons[2].getDistance())

            // alternative algorithm from https://en.wikipedia.org/wiki/Trilateration
            let xPositionT2 = (pow(distance1T) - pow(distance2T) + pow(beaconP2T.x)) / (2 * beaconP2T.x)
            let yPositionT2 = (pow(distance2T) - pow(distance3T) + pow(beaconP3T.x) + pow(beaconP3T.y)) / (2 * beaconP3T.y) - beaconP3T.x / beaconP3T.y * xPositionT2
            let positionT2 = CGPoint(x: xPositionT2, y: yPositionT2)
            var position2 = transformPointToOriginCoordinateSystem2D(positionT2, translationVector: translationVector, translationAngle: Double(translationAngle))
            position2 = adjustPointToBeInsideMap(position2, map: map)
            
            
            return Location(x: position2.x , y: position2.y, z: 0)
            
        }
        return Location(x: 0,y: 0,z: 0)
    }
    
    func multilaterate(_ beacons : [CLBeacon], map : BeaconMap, method: LocationMethod) -> Location {
        var transmissions : [NSDictionary] = []
        for beacon in beacons {
            if let beaconCoordinate = map.coordinateForBeacon(beacon) {
                let transmission = ["x":beaconCoordinate.x,"y":beaconCoordinate.y,"accuracy":beacon.getDistance()]
                transmissions.append(transmission as NSDictionary)
            }

        }
        
        guard let pointArray = (method == .lsq) ? BeaconCalculus.determinePosition(usingLeastSquare: transmissions) : BeaconCalculus.determinePosition(usingNonLinearLeastSquare: transmissions) else { return Location(x: 0, y: 0, z: 0) }

        var location = Location(x: CGFloat((pointArray[0] as AnyObject).floatValue), y: CGFloat((pointArray[1] as AnyObject).floatValue), z: CGFloat((pointArray[2] as AnyObject).floatValue))
        // adjust location to be inside map
        location = adjustLocationToBeInsideMap(location, map: map)
        return location
    }
    
    func trilaterate3D(_ beacons : [CLBeacon], map : BeaconMap) -> Location? {
        var transmissions : [NSDictionary] = []
        
        let threeClosestBeacons : [CLBeacon] = [beacons[0],beacons[1],beacons[2]]
        for beacon in threeClosestBeacons {
            if let beaconCoordinate = map.coordinateForBeacon(beacon) {
                let transmission = ["x":beaconCoordinate.x,"y":beaconCoordinate.y,"accuracy":beacon.getDistance()]
                transmissions.append(transmission as NSDictionary)
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
    
    // helpers
    
    /*
    *
    - Param point : the point to be adjusted
    - Param map : the map the point should be adjusted in
    - return the new point which is guranteed within the map edges
    */
    func adjustPointToBeInsideMap(_ point : CGPoint, map : BeaconMap) -> CGPoint {
        // Adjust Position so it will always be inside the Map
        var adjustedPoint = point
        adjustedPoint.x = max(0, adjustedPoint.x)
        adjustedPoint.x = min(adjustedPoint.x, map.maxPoint.x)
        adjustedPoint.y = max(0, adjustedPoint.y)
        adjustedPoint.y = min(adjustedPoint.y, map.maxPoint.y)
        return adjustedPoint
    }
    
    func adjustLocationToBeInsideMap(_ location : Location, map : BeaconMap) -> Location {
        // Adjust Position so it will always be inside the Map
        let adjustedPoint = location
        adjustedPoint.x = max(0, adjustedPoint.x)
        adjustedPoint.x = min(adjustedPoint.x, map.maxPoint.x)
        adjustedPoint.y = max(0, adjustedPoint.y)
        adjustedPoint.y = min(adjustedPoint.y, map.maxPoint.y)
        return adjustedPoint
    }
    
    
    /* Transforms a point to a new Coordinate System
    @param point the point to be transleted
    @param translationVector the translation vector
    @param the translation angle
    @return the point coordinates in the translated coordinate system
    */
    
    fileprivate func transformPointToNewCoordinateSystem2D(_ point : CGPoint, translationVector vector : CGPoint, translationAngle angle : Double) -> CGPoint {
        let pointX = point.x + vector.x
        let pointY = point.y + vector.y
        let x = pointX * CGFloat(cos(angle)) + pointY * CGFloat(sin(angle))
        let y = pointY * CGFloat(cos(angle)) - pointX * CGFloat(sin(angle))
        return CGPoint(x: x, y: y)
    }
    
    fileprivate func transformPointToOriginCoordinateSystem2D(_ point : CGPoint, translationVector vector : CGPoint, translationAngle angle : Double) -> CGPoint {
        let x = point.x * CGFloat(cos(angle)) - point.y * CGFloat(sin(angle)) - vector.x
        let y = point.x * CGFloat(sin(angle)) + point.y * CGFloat(cos(angle)) - vector.y
        return CGPoint(x: x, y: y)
    }
    // Radian / Degree conversion helpers
    
    func DegreesToRadians (_ value:CGFloat) -> CGFloat {
        return value * π / 180.0
    }
    
    func RadiansToDegrees (_ value:CGFloat) -> CGFloat {
        return value * 180.0 / π
    }
    
    func pow(_ value : CGFloat) -> CGFloat {
        return value * value
    }
    
    func DistanceBetweenPoints(_ pointA : CGPoint, pointB : CGPoint) -> CGFloat {
        return sqrt(pow(pointA.x - pointB.x) + pow(pointA.y - pointB.y))
    }
}
