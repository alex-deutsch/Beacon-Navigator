//
//  BeaconMapViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 12.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconMapViewController : UIViewController, UIScrollViewDelegate, BeaconMapViewDelegate {
    
    @IBOutlet weak var mapScrollView : UIScrollView!
    @IBOutlet var beaconMapView : BeaconMapView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var userdefinedPositionLabel: UILabel!
    @IBOutlet weak var devationLabel : UILabel!
    @IBOutlet var rightBarButtonItem : UIBarButtonItem!
    
    var trackPositions = false {
        didSet {
            if trackPositions == false {
                resetTracking()
            }
        }
    }
    
    var trackedPositions : [CGPoint] = [] {
        didSet {
            //self.logTextView.text = "\(trackedPositions.map { $0.formatedString() })"
            self.beaconMapView.trackedPositions = trackedPositions
            
            // calculate variance
            self.calculateDeviation()
        }
    }
    
    var deviation : CGFloat = 0 {
        didSet {

            self.devationLabel.text = String.localizedStringWithFormat("R: \(self.trackedPositions.count) D %.2f DMIN %.2f DMAX %.2f ", Double(deviation), Double(distanceMin), Double(distanceMax))
        }
    }
    
    var distanceMin : CGFloat = 1000
    
    var distanceMax : CGFloat = 0

    var beaconMap : BeaconMap?
    
    // logged beaconPosition
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userdefinedPositionLabel.textColor = userDefpositionPointColor
        positionLabel.textColor = positionPointColor
        beaconMapView.delegate = self
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
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func didUpdateBeacons(notification : NSNotification) {
        
        if let beacons = notification.userInfo!["beacons"] as? [CLBeacon] {
            
            let enabledBeacons = beacons.filter { return !beaconMapView.disabledBeacons.contains($0.minor.integerValue) }
            
            
            // Update map with available Beacons
            if let beaconMap = beaconMap {
                
                // Remove disabled Beacons
                
                
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
                let locationMethod : LocationMethod = LocationMethod(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(BeaconSettingsLocationMethod))!
                BeaconLocationController.sharedInstance.locateUsingBeacons(enabledBeacons,usingBeaconMap: beaconMap, locationMethod : locationMethod, completionBlock: { (error, coordinates, usedBeacons) -> Void in
                    if let error = error {
                        NSLog("Error Trilaterating: \(error.localizedDescription)")
                    }
                    else if let coordinates = coordinates {
                        if coordinates.x == 0 && coordinates.y == 0 {
                            // Don't update Zero Coordinates
                            return
                        }
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
                
                // print logs
                printAccuracyComparison()
            }
            
        }
    }
    
    // Mark: UIScrollViewDelegate
    
    // TODO: Adjust beaconMapView to be sharper after zoom
    func scrollViewDidZoom(scrollView: UIScrollView) {
        //NSLog("scrollView.contentScaleFactor \(scrollView.contentScaleFactor)")
        //beaconMapView.frame = CGRectMake(0, 0, 320 * scrollView.zoomScale, 400 * scrollView.zoomScale)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        //beaconMapView.frame = CGRectMake(0, 0, 320 * scrollView.zoomScale, 400 * scrollView.zoomScale)
        return beaconMapView
    }
    
    // Notifications
    func mapViewDidUpdateUserDefinedPosition(notification : NSNotification) {
        if let position = beaconMapView.userdefinedPosition {
            userdefinedPositionLabel.text = String.localizedStringWithFormat("userDef P: \(position.formatedString())")
        }
        
        // Reset tracked Points
        resetTracking()
    }
    
    @IBAction func rightBarButtonItemClicked() {
        trackPositions = !trackPositions
        rightBarButtonItem.title = trackPositions ? "untrack" : "track"
    }
    
    @IBAction func generatePDFClicked() {
        if let beaconName = beaconMap?.name {
            let pdfManager = BeaconMapPDFCreator(name: beaconName)
            pdfManager.generatePDF(beaconMapView, loggedPositionsString: devationLabel.text!, currentPositionsString: positionLabel.text!, userPositionsString: userdefinedPositionLabel.text!)
            pdfManager.openPDF(self)
        }
    }
    
    
    // internal funcs
    

    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if #available(iOS 9.0, *) {
            NSLog("touch force: \(touch?.force)")
            if touch?.force > 3 {
                self.performSegueWithIdentifier("map2Settings", sender: self)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    internal func calculateDeviation() {
        deviation = 0

        guard let userPosition = self.beaconMapView.userdefinedPosition else { return }
        for var i = 1; i <= trackedPositions.count; i++ {
            let distance = trackedPositions[i-1].distanceToPoint(userPosition)
            deviation += distance
            if distanceMin > distance {
                distanceMin = distance
            }
            if distanceMax < distance {
                distanceMax = distance
            }
        }
        deviation /= CGFloat(trackedPositions.count)
        
    }
    
    func printAccuracyComparison() {
        for beacon in BeaconManager.sharedInstance.currentAvailableBeacons {
            guard let beaconMap = beaconMap, let userPos = beaconMapView.userdefinedPosition, let beaconCoord = beaconMap.coordinateForBeacon(beacon) else { break }
            let distance = BeaconLocationController.sharedInstance.DistanceBetweenPoints(beaconCoord, pointB: userPos)
            print(String.localizedStringWithFormat("Minor: \(beacon.minor) Distance %.2f DistanceAcc %.2f DistanceLogN %.2f \n", Double(distance), Double(beacon.accuracy), Double(beacon.getAccuracyCalculatedByUsingLogNormal())))
        }
        
    }
    
    func resetTracking() {
        trackedPositions.removeAll(keepCapacity: false)
        deviation = 0
        distanceMin = 1000
        distanceMax = 0
    }
    
    func toggleBeacon(beacon: Int) {
        if beaconMapView.disabledBeacons.contains(beacon) {
            beaconMapView.disabledBeacons.removeAtIndex(beaconMapView.disabledBeacons.indexOf(beacon)!)
        }
        else {
            beaconMapView.disabledBeacons.append(beacon)
        }
    }
    
}
