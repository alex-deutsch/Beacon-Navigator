//
//  BeaconMapViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 12.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconMapViewController : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var mapScrollView : UIScrollView!
    @IBOutlet var beaconMapView : BeaconMapView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var userdefinedPositionLabel: UILabel!
    @IBOutlet weak var varianzLabel :UILabel!
    @IBOutlet var rightBarButtonItem : UIBarButtonItem!
    
    var trackPositions = false {
        didSet {
            if trackPositions == false {
                trackedPositions.removeAll(keepCapacity: false)
            }
        }
    }
    
    var trackedPositions : [CGPoint] = [] {
        didSet {
            //self.logTextView.text = "\(trackedPositions.map { $0.formatedString() })"
            self.beaconMapView.trackedPositions = trackedPositions
        }
    }
    var beaconMap : BeaconMap?
    
    // logged beaconPosition
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userdefinedPositionLabel.textColor = userDefpositionPointColor
        positionLabel.textColor = positionPointColor
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = beaconMap?.name
        
        // Register for Beacon updates
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdateBeacons:", name: BeaconManagerDidUpdateAvailableBeacons, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mapViewDidUpdateUserDefinedPosition:", name: UserDefinedPositionSetNotification, object: beaconMapView)
        
        // Set Beacon Map Size to draw it
        if let beaconMap = beaconMap {
            beaconMapView.edgePoints = beaconMap.edgeCoordinates
        }
        mapScrollView.minimumZoomScale = 1.0
        mapScrollView.maximumZoomScale = 5.0
        
        
    }
    
    
    func didUpdateBeacons(notification : NSNotification) {
        
        if let beacons = notification.userInfo!["beacons"] as? [CLBeacon] {
            
            
            
            // Update map with available Beacons
            if let beaconMap = beaconMap {
                
                // Try to map all Beacons to the map
                var beaconMinorPosition : [Int:CGPoint] = [:]
                for beacon in beacons {
                    beaconMinorPosition[beacon.minor.integerValue] = beaconMap.coordinateForBeacon(beacon)
                    
                    // Apply a distance for the beacon if there is a useful one
                    if beacon.getDistance() > 0 {
                        beaconMapView.beaconDistances[beacon.minor.integerValue] = CGFloat(beacon.getDistance())
                    }
                }
                
                // All beacons which are on the map
                beaconMapView.beaconPoints = beaconMinorPosition
                
                // Calculate Position
                let locationMethod : LocationMethod = LocationMethod(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("LocationMethod"))!
                BeaconLocationController.sharedInstance.locateUsingBeacons(beacons,usingBeaconMap: beaconMap, locationMethod : locationMethod, completionBlock: { (error, coordinates, usedBeacons) -> Void in
                    if let error = error {
                        NSLog("Error Trilaterating: \(error.localizedDescription)")
                    }
                    else if let coordinates = coordinates {
                        let positionPoint = CGPointMake(coordinates.x, coordinates.y)
                        //NSLog("received current position: \(positionPoint)")
                        self.beaconMapView.currentPosition = positionPoint
                        self.beaconMapView.usedBeacons = usedBeacons.map { $0.minor.integerValue }
                        
                        // update label
                        self.positionLabel.text = String.localizedStringWithFormat("calc Pos: \(positionPoint.formatedString())")
                        
                        // Track Point if on
                        if self.trackPositions {
                            self.trackedPositions.append(positionPoint)
                        }
                    }
                })
            }
            
        }
    }
    
    // Mark: UIScrollViewDelegate
    
    // TODO: Adjust beaconMapView to be sharper after zoom
    func scrollViewDidZoom(scrollView: UIScrollView) {
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return beaconMapView
    }
    
    // Notifications
    func mapViewDidUpdateUserDefinedPosition(notification : NSNotification) {
        if let position = beaconMapView.userdefinedPosition {
            userdefinedPositionLabel.text = String.localizedStringWithFormat("userDef P: \(position.formatedString())")
        }
        
        // Reset tracked Points
        trackedPositions.removeAll(keepCapacity: false)
    }
    
    @IBAction func rightBarButtonItemClicked() {
        trackPositions = !trackPositions
        rightBarButtonItem.title = trackPositions ? "untrack" : "track"
    }
    
    @IBAction func generatePDFClicked() {
        if let beaconName = beaconMap?.name {
            let pdfManager = BeaconMapPDFCreator(name: beaconName)
            pdfManager.generatePDF(beaconMapView, loggedPositionsString: varianzLabel.text!, currentPositionsString: positionLabel.text!, userPositionsString: userdefinedPositionLabel.text!)
            pdfManager.openPDF(self)
        }
    }
}
