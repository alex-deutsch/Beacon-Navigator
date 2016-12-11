//
//  ViewController.swift
//  BeaconNavigator
//
//  Created by Alex Deutsch on 18.05.15.
//  Copyright (c) 2015 Alexander Deutsch. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BeaconManager.sharedInstance
        self.title = "Beacon Navigator"
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        switch indexPath.section {
        case 0:
            cell.imageView?.image = UIImage(named: "icon_map")
            cell.textLabel?.text = "Indoor Navigation"
        case 1:
            cell.imageView?.image = UIImage(named: "beacon_blue")
            cell.textLabel?.text = "Beacon Liste"
        case 2:
            cell.imageView?.image = UIImage(named: "icon_settings")
            cell.textLabel?.text = "Einstellungen"
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "main2maps", sender: self)
        case 1:
            performSegue(withIdentifier: "main2beaconlist", sender: self)
        case 2:
            performSegue(withIdentifier: "main2settings", sender: self)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

}

