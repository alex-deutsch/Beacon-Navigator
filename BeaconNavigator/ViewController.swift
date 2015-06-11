//
//  ViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 18.05.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BeaconManager.sharedInstance
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "main2beaconList" {
            if let viewController = segue.destinationViewController as? BeaconTableViewController {
            }
        }
    }

}

