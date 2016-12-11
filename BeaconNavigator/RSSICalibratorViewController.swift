//
//  RSSICalibratorViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 08.10.15.
//  Copyright © 2015 Alexander Deutsch. All rights reserved.
//

import UIKit
import CoreLocation


class RSSICalibratorViewController: UIViewController {
    

    
    @IBOutlet weak var currentRSSValue: UILabel!
    @IBOutlet weak var MeasureSlider: UISlider!
    @IBOutlet weak var resultOfNValue: UILabel!
    @IBOutlet weak var addMeasureButton: UIButton!
    
    var measureValuesN : [NSNumber:NSNumber] = [:]
    var measureValuesRSSI : [NSNumber:NSNumber] = [:]
    
    var beacon : CLBeacon?

    @IBOutlet weak var currentDistance: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: Selector(("didUpdateBeacons:")), name: NSNotification.Name(rawValue: BeaconManagerDidUpdateAvailableBeacons), object: nil)
        // Do any additional setup after loading the view.
        currentDistance.text = "RSSI Reference Distance \(MeasureSlider.value) m"
    }
    
    func didUpdateBeacons(notification : NSNotification) {
        
        if let beacons = notification.userInfo!["beacons"] as? [CLBeacon] {
            for currentBeacon in beacons {
                if currentBeacon.minor == beacon?.minor {
                    self.beacon = currentBeacon
                    currentRSSValue?.text = "Current RSSI: \(currentBeacon.rssi)"
                }
            }
        }
    }

    
    func calculateN(d0 : Float, d : Float, rssi0 : Int, rssiD : Int) -> Float {
        let n = (Float(rssi0) - Float(rssiD)) / (10 * log10(d / d0))
        NSLog("Calculated N = \(n)")
        return n
    }
    
    func leastSquareLinear(values : [NSNumber:NSNumber]) -> Float {
        var sumXY : Float = 0
        var sumX : Float = 0
        for (key,value) in values {
            sumXY += key.floatValue * value.floatValue
            sumX += value.floatValue * value.floatValue
        }
        return sumXY / sumX
    }
    
    
    
    @IBAction func addMeasureValueClicked(sender: AnyObject) {
        
        guard let beacon = beacon else { return }
        
        measureValuesN[MeasureSlider.value as NSNumber] = calculateN(d0: ReferenceDistance, d: MeasureSlider.value, rssi0: RSSIAtReferenceDistance, rssiD: beacon.rssi) as NSNumber?
        measureValuesRSSI[MeasureSlider.value as NSNumber] = beacon.rssi as NSNumber?
    }
    @IBAction func calculateFinalN(sender: AnyObject) {

        guard let beacon = beacon else { return }
        let n = leastSquareLinear(values: measureValuesN)
        guard let values = BeaconCalculus.curveFitting(measureValuesRSSI) as [AnyObject]? else { return }
        resultOfNValue.text = "Result N= \(n)"
        
        UserDefaults.standard.set(n, forKey: beacon.keyForEnvVar(ENVVARNKEY))
        UserDefaults.standard.set((values[0]).floatValue, forKey: beacon.keyForEnvVar(ENVVARNKEY0))
        UserDefaults.standard.set((values[1]).floatValue, forKey: beacon.keyForEnvVar(ENVVARNKEY1))
        UserDefaults.standard.set((values[2]).floatValue, forKey: beacon.keyForEnvVar(ENVVARNKEY2))
    }


    @IBAction func measureValueSliderChanged(slider: UISlider) {
        //let roundedValue = Int(slider.value)
        //MeasureSlider.setValue(Float(roundedValue), animated: false)
        currentDistance.text = "RSSI Reference Distance \(MeasureSlider.value) m"
    }
}
