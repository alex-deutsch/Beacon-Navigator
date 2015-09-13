//
//  BeaconMapView.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 11.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit

let UserDefinedPositionSetNotification = "UserDefinedPositionSetNotification"

class BeaconMapView : UIView {
    
    // Scale for Drawing in Coordinate System
    var scaleX : CGFloat = 1
    var scaleY : CGFloat = 1
    var scaleXY : CGFloat = 1
    
    
    // can set by touching the view
    var userdefinedPosition : CGPoint? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(UserDefinedPositionSetNotification, object: self)
            self.setNeedsDisplay()
        }
    }
    
    var trackedPositions : [CGPoint]? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var edgePoints : [CGPoint]? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // Minor : Position
    var beaconPoints : [Int:CGPoint]? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // Minor : Distance
    var beaconDistances : [Int:CGFloat] = [:] {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // Used Beacons for position calc
    var usedBeacons : [Int] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var currentPosition : CGPoint? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        var biggestX : CGFloat = 0
        var biggestY : CGFloat = 0
        
        if let edgePoints = edgePoints {
            for edgePoint in edgePoints {
                if edgePoint.x > biggestX { biggestX = edgePoint.x }
                if edgePoint.y > biggestY { biggestY = edgePoint.y }
            }
        }
        
        let adjustedMapSize = CGSizeMake(biggestX, biggestY)
        
        // Check which sides are the bigger ones
        if (rect.width > rect.height && biggestY > biggestX) || (rect.height > rect.width && biggestY < biggestX) {
            // rotate map to fit view
            // TODO: this is buggy
            //adjustedMapSize = CGSizeMake(biggestY, biggestX)
        }
        
        // Scale View according map size
        let rectWidthBigger = rect.width > rect.height
        let scaleFactor : CGFloat = rectWidthBigger ? rect.width / adjustedMapSize.width : rect.height / adjustedMapSize.height
        var rectForRoom = CGRectMake(0, 0, rectWidthBigger ? adjustedMapSize.width * scaleFactor : rect.width, rectWidthBigger ? adjustedMapSize.height * scaleFactor : rect.height)
        // Center the rect in container
        rectForRoom.origin = CGPointMake(rect.size.width / 2 - rectForRoom.size.width / 2 , rect.size.height / 2 - rectForRoom.size.height / 2)
        
        
        // Scale for Drawing in Coordinate System
        scaleX = rectForRoom.width / adjustedMapSize.width
        scaleY = rectForRoom.height / adjustedMapSize.height
        scaleXY = min(scaleX,scaleY)
        
        // Draw Edges and lines  (Walls)
        if edgePoints?.count > 0 {
            let wallPath = UIBezierPath()
            for var i = 0; i < edgePoints!.count; i++ {
                let edgePoint = edgePoints![i]
                let targetPoint = CGPointMake(edgePoint.x * scaleXY, edgePoint.y * scaleXY)
                if i == 0 {
                    wallPath.moveToPoint(targetPoint)
                }
                else {
                    wallPath.addLineToPoint(targetPoint)
                }
                
            }
            
            wallPath.addLineToPoint(CGPointMake(edgePoints![0].x * scaleXY, edgePoints![0].y * scaleXY))
            wallPath.lineWidth = 5
            roomBorderColor.setStroke()
            wallPath.stroke()
            wallPath.closePath()
        }
        // Draw Beacon Points
        if let beaconPoints = beaconPoints {
            for (minor, beaconPoint) in beaconPoints {
                if usedBeacons.contains(minor) {
                    drawPointAtPosition(beaconPoint, color: beaconPointColorUsed)
                }
                else {
                    drawPointAtPosition(beaconPoint, color: beaconPointColor)
                }
                
                if let distance = beaconDistances[minor] {
                    NSLog("drawing distance for minor: \(minor) distance: \(distance)")
                    let distanceRect = CGRectMake((beaconPoint.x - distance) * scaleXY, (beaconPoint.y - distance) * scaleXY, distance * 2 * scaleXY, distance * 2 * scaleXY)
                    let distancePath = UIBezierPath(ovalInRect: distanceRect)
                    distancePath.lineWidth = 3
                    UIColor.lightGrayColor().setStroke()
                    distancePath.stroke()
                    distancePath.closePath()
                }
            }
        }
        
        // Draw User defined position
        if let userdefinedPosition = userdefinedPosition {
            drawPointAtPosition(userdefinedPosition, color: userDefpositionPointColor)
        }
        
        // Draw tracked position
        if let trackedPositions = trackedPositions {
            for position in trackedPositions {
                drawPointAtPosition(position, color: usertrackingPositionPointColor)
            }
        }
        
        // Draw current Position
        if let currentPosition = currentPosition {
            drawPointAtPosition(currentPosition, color: positionPointColor)
        }
        
        // Draw User Defined Position
        super.drawRect(rect)
    }
    
    func drawPointAtPosition(position : CGPoint, color: UIColor) {
        color.setFill()
        let pointPath = UIBezierPath(ovalInRect: CGRectMake(position.x * scaleXY - 5, position.y * scaleXY - 5, 10, 10))
        pointPath.fill()
        pointPath.closePath()
    }
    
    func setUserDefinedPositionFromTouch(touch : UITouch?) {
        if let locationInView = touch?.locationInView(self) {
            userdefinedPosition = CGPointMake(locationInView.x / scaleXY, locationInView.y / scaleXY)
        }
    }
    
    // Track Touches to set User Defined Position
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        guard let touch = touches.first as UITouch? else { return }
        setUserDefinedPositionFromTouch(touch)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        guard let touch = touches.first as UITouch? else { return }
        setUserDefinedPositionFromTouch(touch)
    }
}
