//
//  BeaconMapViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 12.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit

class BeaconMapViewController : UIViewController {
    
    @IBOutlet var beaconMapView : BeaconMapView!
    
    var beaconMap : BeaconMap?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let beaconMap = beaconMap {
            beaconMapView.mapSize = beaconMap.size
            beaconMapView.beaconPoints = beaconMap.beaconCoordinatesForBeacons(BeaconManager.sharedInstance.currentAvailableBeacons).values.array
        }

    }
}
