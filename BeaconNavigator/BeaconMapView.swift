//
//  BeaconMapView.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 11.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit

class BeaconMapView : UIView {
    
    var mapSize : CGSize = CGSizeZero {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var beaconPoints : [CGPoint]? {
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
        
        var adjustedMapSize = mapSize
        
        // Check which sides are the bigger ones 
        if (rect.width > rect.height && mapSize.height > mapSize.width) || (rect.height > rect.width && mapSize.height > mapSize.width) {
            // rotate map to fit view
            adjustedMapSize = CGSizeMake(mapSize.height, mapSize.width)
        }
        
        // Scale View according map size
        let rectWidthBigger = rect.width > rect.height
        let scaleFactor : CGFloat = rectWidthBigger ? rect.width / mapSize.width : rect.height / mapSize.height
        var rectForRoom = CGRectMake(0, 0, rectWidthBigger ? adjustedMapSize.width * scaleFactor : rect.width, rectWidthBigger ? adjustedMapSize.height * scaleFactor : rect.height)
        // Center the rect in container
        rectForRoom.origin = CGPointMake(rect.size.width / 2 - rectForRoom.size.width / 2 , rect.size.height / 2 - rectForRoom.size.height / 2)
        
        // Create Path
        let path = UIBezierPath(rect: rectForRoom)
        UIColor.blueColor().setStroke()
        path.lineWidth = 10
        path.stroke()
        path.closePath()
        
        // TODO: Draw Beacon Points
        //let scaleX = rectForRoom
        
        // TODO: Draw current Position
        
        super.drawRect(rect)
    }
}
