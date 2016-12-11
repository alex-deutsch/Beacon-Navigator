//
//  BeaconMapView.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 11.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol BeaconMapViewDelegate {
    func toggleBeacon(_ beacon : Int)
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
            NotificationCenter.default.post(name: Notification.Name(rawValue: UserDefinedPositionSetNotification), object: self)
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
    
    override func draw(_ rect: CGRect) {
        
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
        
        let adjustedMapSize = CGSize(width: biggestX, height: biggestY)
        
        // Check which sides are the bigger ones
        if (rect.width > rect.height && biggestY > biggestX) || (rect.height > rect.width && biggestY < biggestX) {
            // rotate map to fit view
            // TODO: this is buggy
            //adjustedMapSize = CGSizeMake(biggestY, biggestX)
        }
        
        // Scale View according map size
        let rectWidthBigger = drawingRect.width > drawingRect.height
        let scaleFactor : CGFloat = rectWidthBigger ? drawingRect.width / adjustedMapSize.width : drawingRect.height / adjustedMapSize.height
        var rectForRoom = CGRect(x: 0, y: 0, width: rectWidthBigger ? adjustedMapSize.width * scaleFactor : drawingRect.width, height: rectWidthBigger ? adjustedMapSize.height * scaleFactor : drawingRect.height)
        // Center the rect in container
        rectForRoom.origin = CGPoint(x: rect.size.width / 2 - rectForRoom.size.width / 2 , y: rect.size.height / 2 - rectForRoom.size.height / 2)
        
        
        // Scale for Drawing in Coordinate System
        scaleX = rectForRoom.width / adjustedMapSize.width
        scaleY = rectForRoom.height / adjustedMapSize.height
        scaleXY = min(scaleX,scaleY)
        
        // Draw Edges and lines  (Walls)
        if edgePoints?.count > 0 {
            let wallPath = UIBezierPath()
            for i in 0 ..< edgePoints!.count {
                let edgePoint = edgePoints![i]
                let targetPoint = positionToPointinView(edgePoint)
                if i == 0 {
                    wallPath.move(to: targetPoint)
                }
                else {
                    wallPath.addLine(to: targetPoint)
                }
                
            }
            
            wallPath.addLine(to: positionToPointinView(edgePoints![0]))
            wallPath.lineWidth = lineWidthWall
            roomBorderColor.setStroke()
            roomFillColor.setFill()
            wallPath.stroke()
            wallPath.fill()
            wallPath.close()
        }
        // Draw Beacon Points
        if let beaconPoints = beaconPoints {
            for (beacon, beaconPoint) in beaconPoints {
                if  disabledBeacons.contains(beacon) {
                    //drawPointAtPosition(beaconPoint, color: beaconPointColorUsed)
                    
                    UIImage(named: "beacon_blue_disabled")?.draw(in: rectForPosition(beaconPoint, size: beaconPointSize))
                }
                else if usedBeacons.contains(beacon) {
                    UIImage(named: "beacon_blue_sending")?.draw(in: rectForPosition(beaconPoint, size: beaconPointSize))
                }
                else {
                    //drawPointAtPosition(beaconPoint, color: beaconPointColor)
                    UIImage(named: "beacon_blue")?.draw(in: rectForPosition(beaconPoint, size: beaconPointSize))
                }
                
                if let distance = beaconDistances[beacon] {
                    //NSLog("drawing distance for minor: \(minor) distance: \(distance)")
                    let distanceRect = CGRect(x: (beaconPoint.x - distance) * scaleXY + additionalDistance, y: (beaconPoint.y - distance) * scaleXY + additionalDistance, width: distance * 2 * scaleXY, height: distance * 2 * scaleXY)
                    let distancePath = UIBezierPath(ovalIn: distanceRect)
                    distancePath.lineWidth = lineWidthRadius
                    UIColor.lightGray.setStroke()
                    distancePath.stroke()
                    distancePath.close()
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
        super.draw(rect)
    }
    
    func drawPointAtPosition(_ position : CGPoint, color: UIColor) {
        color.setFill()
        let pointPath = UIBezierPath(ovalIn: rectForPosition(position, size: 10))
        pointPath.fill()
        pointPath.close()
    }
    
    func setUserDefinedPositionFromTouch(_ touch : UITouch?) {
        if let locationInView = touch?.location(in: self) {
            userdefinedPosition = pointInViewToPosition(locationInView)
        }
    }
    
    // Track Touches to set User Defined Position
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first as UITouch?, let beaconPoints = beaconPoints else { return }
        
        for (beacon, beaconPoint) in beaconPoints {
            let rect = rectForPosition(beaconPoint, size: beaconPointSize)
            let positionInView = touch.location(in: self)
            if rect.contains(positionInView) {
                delegate?.toggleBeacon(beacon)
                return
            }
        }
        setUserDefinedPositionFromTouch(touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first as UITouch? else { return }
        setUserDefinedPositionFromTouch(touch)
    }
    
    func positionToPointinView(_ position : CGPoint) -> CGPoint {
        return CGPoint(x: position.x * scaleXY + additionalDistance, y: position.y * scaleXY + additionalDistance)
    }
    
    func pointInViewToPosition(_ point : CGPoint) -> CGPoint {
        return CGPoint(x: (point.x - additionalDistance) / scaleXY, y: (point.y - additionalDistance) / scaleXY )
    }
    
    func rectForPosition(_ position : CGPoint, size : CGFloat) -> CGRect {
        let positionInView = positionToPointinView(position)
        return CGRect(x: positionInView.x - size / 2, y: positionInView.y - size / 2, width: size, height: size)
    }
}
