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
    var timestamp : Date
    var distance : CGFloat
    
    required init(beacon : CLBeacon) {
        self.beacon = beacon
        self.timestamp = Date()
        self.distance = CGFloat(beacon.getDistance())
    }
}
