//: Playground - noun: a place where people can play

import UIKit
import Foundation

let π = CGFloat(M_PI)

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
    return pow(value, 2)
}

let distance1 : CGFloat = 2
let distance2 : CGFloat = 2
let distance3 : CGFloat = 1.9

let beaconP1 : CGPoint = CGPointMake(1.5, 0)
let beaconP2 : CGPoint = CGPointMake(0, 3)
let beaconP3 : CGPoint = CGPointMake(3, 3)


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

var distance1T = distance1
var distance2T = distance2
var distance3T = distance3

// Switch Points for calculation if beaconP2T.x == 0, because otherwise divition through zero
if beaconP2T.x == 0 {
    var tempBeacon = beaconP3T
    beaconP3T = beaconP2T
    beaconP2T = tempBeacon
    
    var tempDistance = distance2T
    distance2T = distance3T
    distance3T = tempDistance
}

let xPositionT1 = (pow(beaconP2T.x, 2) + pow(distance1, 2) - pow(distance2T, 2)) / (2 * beaconP2T.x)

let yPositionT1 = sqrt(pow(distance1, 2) - pow(xPositionT1, 2))
let yPositionT2 = sqrt(pow(xPositionT1, 2) - 2 * xPositionT1 * beaconP2T.x + pow(beaconP2T.x, 2) - pow(distance2T, 2))

let yPositionT = (yPositionT2 > 0) ? yPositionT2 : yPositionT1

// Tests only
let yPositionT3 = (pow(distance1T) - pow(distance2T) + pow(beaconP3T.x) + pow(beaconP3T.y)) / (2 * beaconP3T.y) - (beaconP3T.x / beaconP3T.y) * xPositionT1

//



let positionT = CGPointMake(xPositionT1, yPositionT3)

let position = transformPointToOriginCoordinateSystem2D(positionT, translationVector: translationVector, translationAngle: Double(translationAngle))

