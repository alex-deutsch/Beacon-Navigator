# Beacon-Navigator
Indoor Navigation using iBeacon / Bluetooth technologie and trilateration algorithms,

You can choose between simple trilateration, non linear least squares or linear least squares method

- The App is experimental and not finished, optimized or bug free. Just wanted to share my work as far as i got with it.

- Updated for Swift3 but not improved for it.

## Usage

- use plist Files to create BeaconMap and enter the coordinates of the Beacons as examples given, values as meters
- In the BeaconMapManager class add the BeaconMap String Name which you created as plist and put it in the Maps array
- Now you can choose the Map within the App
- The App uses Estimote Beacons as Standard, you can change the UUID and use other Kind of Beacon in the class BeaconManager
