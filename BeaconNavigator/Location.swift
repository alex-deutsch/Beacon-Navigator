//
//  Location.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 14.07.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import Foundation

class Location : NSObject {
    var x : CGFloat
    var y : CGFloat
    var z : CGFloat
    
     required init(x : CGFloat, y : CGFloat, z : CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
}