//
//  BeaconMapManager.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 11.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import Foundation

class BeaconMapManager : NSObject {
    
    let mapNames = ["SimpleQuad","Wohnung","Medicare 3 Beacons","Medicare 4 Beacons","Medicare 5 Beacons","SeefeldWohnzimmerSquare"]
    
    static let sharedInstance = BeaconMapManager()
    
    var maps : [BeaconMap] = []
    
    override init() {
        super.init()
        for mapName in mapNames {
            let beaconMap = BeaconMap(fileName: mapName)
            maps.append(beaconMap)
        }
    }
    
    
}