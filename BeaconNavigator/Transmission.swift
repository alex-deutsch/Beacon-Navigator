//
//  Transmition.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 14.07.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import CoreLocation

class Transmission : NSObject {
    
    var beacon : CLBeacon
    var timestamp : NSDate
    var accuracy : CGFloat
    
    required init(beacon : CLBeacon) {
        self.beacon = beacon
        self.timestamp = NSDate()
        self.accuracy = CGFloat(beacon.accuracy)
    }
}