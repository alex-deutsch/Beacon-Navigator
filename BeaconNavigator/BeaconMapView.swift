//
//  BeaconMapView.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 11.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit

protocol BeaconMapViewDelegate {
    func toggleBeacon(beacon : Int)
}

let UserDefinedPositionSetNotification = "UserDefinedPositionSetNotification"


class BeaconMapView : UIView {
    
    var delegate : BeaconMapViewDelegate?
    
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
    
    var disabledBeacons : [Int] = [] {
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
        
        var drawingRect = rect
        
        drawingRect.origin.x += additionalDistance
        drawingRect.origin.y += additionalDistance
        drawingRect.size.height -= additionalDistance * 2
        drawingRect.size.width -= additionalDistance * 2
        
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
        let rectWidthBigger = drawingRect.width > drawingRect.height
        let scaleFactor : CGFloat = rectWidthBigger ? drawingRect.width / adjustedMapSize.width : drawingRect.height / adjustedMapSize.height
        var rectForRoom = CGRectMake(0, 0, rectWidthBigger ? adjustedMapSize.width * scaleFactor : drawingRect.width, rectWidthBigger ? adjustedMapSize.height * scaleFactor : drawingRect.height)
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
                let targetPoint = positionToPointinView(edgePoint)
                if i == 0 {
                    wallPath.moveToPoint(targetPoint)
                }
                else {
                    wallPath.addLineToPoint(targetPoint)
                }
                
            }
            
            wallPath.addLineToPoint(positionToPointinView(edgePoints![0]))
            wallPath.lineWidth = lineWidthWall
            roomBorderColor.setStroke()
            roomFillColor.setFill()
            wallPath.stroke()
            wallPath.fill()
            wallPath.closePath()
        }
        // Draw Beacon Points
        if let beaconPoints = beaconPoints {
            for (beacon, beaconPoint) in beaconPoints {
                if  disabledBeacons.contains(beacon) {
                    //drawPointAtPosition(beaconPoint, color: beaconPointColorUsed)
                    
                    UIImage(named: "beacon_blue_disabled")?.drawInRect(rectForPosition(beaconPoint, size: beaconPointSize))
                }
                else if usedBeacons.contains(beacon) {
                    UIImage(named: "beacon_blue_sending")?.drawInRect(rectForPosition(beaconPoint, size: beaconPointSize))
                }
                else {
                    //drawPointAtPosition(beaconPoint, color: beaconPointColor)
                    UIImage(named: "beacon_blue")?.drawInRect(rectForPosition(beaconPoint, size: beaconPointSize))
                }
                
                if let distance = beaconDistances[beacon] {
                    //NSLog("drawing distance for minor: \(minor) distance: \(distance)")
                    let distanceRect = CGRectMake((beaconPoint.x - distance) * scaleXY + additionalDistance, (beaconPoint.y - distance) * scaleXY + additionalDistance, distance * 2 * scaleXY, distance * 2 * scaleXY)
                    let distancePath = UIBezierPath(ovalInRect: distanceRect)
                    distancePath.lineWidth = lineWidthRadius
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
        let pointPath = UIBezierPath(ovalInRect: rectForPosition(position, size: 10))
        pointPath.fill()
        pointPath.closePath()
    }
    
    func setUserDefinedPositionFromTouch(touch : UITouch?) {
        if let locationInView = touch?.locationInView(self) {
            userdefinedPosition = pointInViewToPosition(locationInView)
        }
    }
    
    // Track Touches to set User Defined Position
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        guard let touch = touches.first as UITouch?, let beaconPoints = beaconPoints else { return }
        
        for (beacon, beaconPoint) in beaconPoints {
            let rect = rectForPosition(beaconPoint, size: beaconPointSize)
            let positionInView = touch.locationInView(self)
            if rect.contains(positionInView) {
                delegate?.toggleBeacon(beacon)
                return
            }
        }
        setUserDefinedPositionFromTouch(touch)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        guard let touch = touches.first as UITouch? else { return }
        setUserDefinedPositionFromTouch(touch)
    }
    
    func positionToPointinView(position : CGPoint) -> CGPoint {
        return CGPointMake(position.x * scaleXY + additionalDistance, position.y * scaleXY + additionalDistance)
    }
    
    func pointInViewToPosition(point : CGPoint) -> CGPoint {
        return CGPointMake((point.x - additionalDistance) / scaleXY, (point.y - additionalDistance) / scaleXY )
    }
    
    func rectForPosition(position : CGPoint, size : CGFloat) -> CGRect {
        let positionInView = positionToPointinView(position)
        return CGRectMake(positionInView.x - size / 2, positionInView.y - size / 2, size, size)
    }
}
