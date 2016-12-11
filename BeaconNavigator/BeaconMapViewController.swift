//
//  BeaconMapViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 12.06.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit
import CoreLocation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = beaconMap?.name
        
        // Register for Beacon updates
        NotificationCenter.default.addObserver(self, selector: #selector(BeaconMapViewController.didUpdateBeacons(_:)), name: NSNotification.Name(rawValue: BeaconManagerDidUpdateAvailableBeacons), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BeaconMapViewController.mapViewDidUpdateUserDefinedPosition(_:)), name: NSNotification.Name(rawValue: UserDefinedPositionSetNotification), object: beaconMapView)
        
        // Set Beacon Map Size to draw it
        if let beaconMap = beaconMap {
            beaconMapView.edgePoints = beaconMap.edgeCoordinates
        }
        mapScrollView.minimumZoomScale = 1.0
        mapScrollView.maximumZoomScale = 5.0
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func didUpdateBeacons(_ notification : Notification) {
        
        if let beacons = notification.userInfo!["beacons"] as? [CLBeacon] {
            
            let enabledBeacons = beacons.filter { return !beaconMapView.disabledBeacons.contains($0.minor.intValue) }
            
            
            // Update map with available Beacons
            if let beaconMap = beaconMap {
                
                // Remove disabled Beacons
                
                
                // Try to map all Beacons to the map
                var beaconMinorPosition : [Int:CGPoint] = [:]
                for beacon in beacons {
                    beaconMinorPosition[beacon.minor.intValue] = beaconMap.coordinateForBeacon(beacon)
                    
                    // Apply a distance for the beacon if there is a useful one
                    if beacon.getDistance() > 0 {
                        beaconMapView.beaconDistances[beacon.minor.intValue] = CGFloat(beacon.getDistance())
                    }
                }
                
                // All beacons which are on the map
                beaconMapView.beaconPoints = beaconMinorPosition
                
                // Calculate Position
                let locationMethod : LocationMethod = LocationMethod(rawValue: UserDefaults.standard.integer(forKey: BeaconSettingsLocationMethod))!
                BeaconLocationController.sharedInstance.locateUsingBeacons(enabledBeacons,usingBeaconMap: beaconMap, locationMethod : locationMethod, completionBlock: { (error, coordinates, usedBeacons) -> Void in
                    if let error = error {
                        NSLog("Error Trilaterating: \(error.localizedDescription)")
                    }
                    else if let coordinates = coordinates {
                        if coordinates.x == 0 && coordinates.y == 0 {
                            // Don't update Zero Coordinates
                            return
                        }
                        let positionPoint = CGPoint(x: coordinates.x, y: coordinates.y)
                        //NSLog("received current position: \(positionPoint)")
                        self.beaconMapView.currentPosition = positionPoint
                        self.beaconMapView.usedBeacons = usedBeacons.map { $0.minor.intValue }
                        
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
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //NSLog("scrollView.contentScaleFactor \(scrollView.contentScaleFactor)")
        //beaconMapView.frame = CGRectMake(0, 0, 320 * scrollView.zoomScale, 400 * scrollView.zoomScale)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //beaconMapView.frame = CGRectMake(0, 0, 320 * scrollView.zoomScale, 400 * scrollView.zoomScale)
        return beaconMapView
    }
    
    // Notifications
    func mapViewDidUpdateUserDefinedPosition(_ notification : Notification) {
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
            pdfManager.generatePDF(mapView: beaconMapView, loggedPositionsString: devationLabel.text!, currentPositionsString: positionLabel.text!, userPositionsString: userdefinedPositionLabel.text!)
            pdfManager.openPDF(baseViewController: self)
        }
    }
    
    
    // internal funcs
    

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if #available(iOS 9.0, *) {
            NSLog("touch force: \(touch?.force)")
            if touch?.force > 3 {
                self.performSegue(withIdentifier: "map2Settings", sender: self)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    internal func calculateDeviation() {
        deviation = 0

        guard let userPosition = self.beaconMapView.userdefinedPosition else { return }
        for _ in 1..<trackedPositions.count+2 {
            let distance = trackedPositions[N-1].distanceToPoint(userPosition)
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
        trackedPositions.removeAll(keepingCapacity: false)
        deviation = 0
        distanceMin = 1000
        distanceMax = 0
    }
    
    func toggleBeacon(_ beacon: Int) {
        if beaconMapView.disabledBeacons.contains(beacon) {
            beaconMapView.disabledBeacons.remove(at: beaconMapView.disabledBeacons.index(of: beacon)!)
        }
        else {
            beaconMapView.disabledBeacons.append(beacon)
        }
    }
    
}
