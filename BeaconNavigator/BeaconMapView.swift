//
//  BeaconMapView.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 11.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit

class BeaconMapView : UIView {
    
    let beaconPointColor : UIColor = .blueColor()
    let roomBorderColor : UIColor = .grayColor()
    let positionPointColor : UIColor = .redColor()
    
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
    
    // Minor Distance
    var beaconDistances : [Int:CGFloat] = [:] {
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
        
        var adjustedMapSize = CGSizeMake(biggestX, biggestY)
        
        // Check which sides are the bigger ones 
        if (rect.width > rect.height && biggestY > biggestX) || (rect.height > rect.width && biggestY < biggestX) {
            // rotate map to fit view
            adjustedMapSize = CGSizeMake(biggestY, biggestX)
        }
        
        // Scale View according map size
        let rectWidthBigger = rect.width > rect.height
        let scaleFactor : CGFloat = rectWidthBigger ? rect.width / adjustedMapSize.width : rect.height / adjustedMapSize.height
        var rectForRoom = CGRectMake(0, 0, rectWidthBigger ? adjustedMapSize.width * scaleFactor : rect.width, rectWidthBigger ? adjustedMapSize.height * scaleFactor : rect.height)
        // Center the rect in container
        rectForRoom.origin = CGPointMake(rect.size.width / 2 - rectForRoom.size.width / 2 , rect.size.height / 2 - rectForRoom.size.height / 2)
        
        
        // Scale for Drawing in Coordinate System
        let scaleX = rectForRoom.width / adjustedMapSize.width
        let scaleY = rectForRoom.height / adjustedMapSize.height
        let scaleXY = min(scaleX,scaleY)
        
        // Draw Edges and lines  (Walls)
        if edgePoints?.count > 0 {
            var wallPath = UIBezierPath()
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
            wallPath.lineWidth = 10
            roomBorderColor.setStroke()
            wallPath.stroke()
            wallPath.closePath()
        }
        // Draw Beacon Points
        if let beaconPoints = beaconPoints {
            for (minor, beaconPoint) in beaconPoints {
                beaconPointColor.setFill()
                let drawingRect = CGRectMake(beaconPoint.x * scaleXY - 10, beaconPoint.y * scaleXY - 10, 20, 20)
                let pointPath = UIBezierPath(ovalInRect: drawingRect)
                pointPath.fill()
                pointPath.closePath()
                
                if let distance = beaconDistances[minor] {
                    let distanceRect = CGRectMake((beaconPoint.x - distance) * scaleX, (beaconPoint.y - distance) * scaleXY, distance * 2 * scaleXY, distance * 2 * scaleXY)
                    let distancePath = UIBezierPath(ovalInRect: distanceRect)
                    distancePath.lineWidth = 3
                    UIColor.redColor().setStroke()
                    distancePath.stroke()
                    distancePath.closePath()
                }
            }
        }
        
        // Draw current Position
        if let currentPosition = currentPosition {
            positionPointColor.setFill()
            let pointPath = UIBezierPath(ovalInRect: CGRectMake(currentPosition.x * scaleXY - 10, currentPosition.y * scaleXY - 10, 20, 20))
            pointPath.fill()
            
            // Draw dashed lines from every beacon to my position
            if let beaconPoints = beaconPoints {
                for (minor, beaconPoint) in beaconPoints {
                    beaconPointColor.setStroke()
                    let linePath = UIBezierPath()
                    linePath.moveToPoint(CGPointMake(beaconPoint.x * scaleXY, beaconPoint.y * scaleXY))
                    let drawingRect = CGRectMake(beaconPoint.x * scaleXY - 10, beaconPoint.y * scaleXY - 10, 20, 20)
                    let pointPath = UIBezierPath(ovalInRect: drawingRect)
                    linePath.stroke()
                    pointPath.closePath()
                }
            }
            
        }
        
        super.drawRect(rect)
    }
}
