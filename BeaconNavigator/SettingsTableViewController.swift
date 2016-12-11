//
//  SettingsTableViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 15.07.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit

let BeaconSettingsLocationMethod = "BeaconSettingsLocationMethod"
let BeaconSettingsDistanceType = "BeaconSettingsDistanceType"
let BeaconSettingsBeaconNumber = "BeaconSettingsBeaconNumber"
let BeaconSettingsBeaconDistance = "BeaconSettingsBeaconDistance"
let BeaconSettingsBeaconRSSI = "BeaconSettingsBeaconRSSI"

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch section {
        case 0:
            return 3
        case 1:
            return 4
        case 2:
            return 7
        case 3:
            return 3
        case 4:
            return 2
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 

        // Configure the cell...
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Trilateration"
            case 1:
                cell.textLabel?.text = "Least Squares (LSQ)"
            case 2:
                cell.textLabel?.text = "Non Linear Least Squares (NLSQ)"
            default:
                break
            }
            cell.accessoryType = UserDefaults.standard.integer(forKey: BeaconSettingsLocationMethod) == indexPath.row ? .checkmark : .none
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Beacon Accuracy"
            case 1:
                cell.textLabel?.text = "Accuracy calculated by Log-Normal Path Distance Model"
            case 2:
                cell.textLabel?.text = "Accuracy calculated by RSSI Curve Fitting"
            case 3:
                cell.textLabel?.text = "Accuracy calculated by Third Party"
            default:
                break
            }
            cell.accessoryType = UserDefaults.standard.integer(forKey: BeaconSettingsDistanceType) == indexPath.row ? .checkmark : .none
        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "No Filter"
            case 1:
                cell.textLabel?.text = "Only 3 closest Beacons"
            case 2:
                cell.textLabel?.text = "Only 4 closest Beacons"
            case 3:
                cell.textLabel?.text = "Only 5 closest Beacons"
            case 4:
                cell.textLabel?.text = "Only 6 closest Beacons"
            case 5:
                cell.textLabel?.text = "Only 7 closest Beacons"
            case 6:
                cell.textLabel?.text = "Only 8 closest Beacons"
            default:
                break
            }
            cell.accessoryType = UserDefaults.standard.integer(forKey: BeaconSettingsBeaconNumber) == indexPath.row ? .checkmark : .none
        case 3:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "No Filter"
            case 1:
                cell.textLabel?.text = "Only Beacons in Range of < 3m"
            case 2:
                cell.textLabel?.text = "Only Beacons in Range of < 5m"
            default:
                break
            }
            cell.accessoryType = UserDefaults.standard.integer(forKey: BeaconSettingsBeaconDistance) == indexPath.row ? .checkmark : .none
        case 4:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Standard RSSI"
            case 1:
                cell.textLabel?.text = "Flattened RSSI"
            default:
                break
            }
            cell.accessoryType = UserDefaults.standard.integer(forKey: BeaconSettingsBeaconRSSI) == indexPath.row ? .checkmark : .none
        default:
            break
        }

        return cell
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        NSLog("selected ROW: \(indexPath.row)")
        switch indexPath.section {
        case 0:
            UserDefaults.standard.set(indexPath.row, forKey: BeaconSettingsLocationMethod)
        case 1:
            UserDefaults.standard.set(indexPath.row, forKey: BeaconSettingsDistanceType)
        case 2:
            UserDefaults.standard.set(indexPath.row, forKey: BeaconSettingsBeaconNumber)
        case 3:
            UserDefaults.standard.set(indexPath.row, forKey: BeaconSettingsBeaconDistance)
        case 4:
            UserDefaults.standard.set(indexPath.row, forKey: BeaconSettingsBeaconRSSI)
        default:
            break
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Location Method"
        case 1:
            return "Distance Type"
        case 2:
            return "Number Of Beacons"
        case 3:
            return "Range of Beacons"
        case 4:
            return "Beacon RSSI"
        default:
            break
        }
        return nil
    }
}
