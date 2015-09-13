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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        case 2:
            return 7
        case 2:
            return 2
        default:
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 

        // Configure the cell...
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Trilateration"
            case 1:
                cell.textLabel?.text = "Trilateration 2"
            case 2:
                cell.textLabel?.text = "Least Squares"
            default:
                break
            }
            cell.accessoryType = NSUserDefaults.standardUserDefaults().integerForKey(BeaconSettingsLocationMethod) == indexPath.row ? .Checkmark : .None
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Beacon Accuracy"
            case 1:
                cell.textLabel?.text = "Accuracy calculated by RSSI"
            default:
                break
            }
            cell.accessoryType = NSUserDefaults.standardUserDefaults().integerForKey(BeaconSettingsDistanceType) == indexPath.row ? .Checkmark : .None
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
            cell.accessoryType = NSUserDefaults.standardUserDefaults().integerForKey(BeaconSettingsBeaconNumber) == indexPath.row ? .Checkmark : .None
        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "No Filter"
            case 1:
                cell.textLabel?.text = "Only Beacons in Range of < 3m"
            default:
                break
            }
            cell.accessoryType = NSUserDefaults.standardUserDefaults().integerForKey(BeaconSettingsBeaconDistance) == indexPath.row ? .Checkmark : .None
        default:
            break
        }

        return cell
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            NSUserDefaults.standardUserDefaults().setInteger(indexPath.row, forKey: BeaconSettingsLocationMethod)
        case 1:
            NSUserDefaults.standardUserDefaults().setInteger(indexPath.row, forKey: BeaconSettingsDistanceType)
        case 2:
            NSUserDefaults.standardUserDefaults().setInteger(indexPath.row, forKey: BeaconSettingsBeaconNumber)
        case 3:
            NSUserDefaults.standardUserDefaults().setInteger(indexPath.row, forKey: BeaconSettingsBeaconDistance)
        default:
            break
        }
        tableView.reloadData()
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Location Method"
        case 1:
            return "Distance Type"
        case 2:
            return "Number Of Beacons"
        case 3:
            return "Range of Beacons"
        default:
            break
        }
        return nil
    }
}
