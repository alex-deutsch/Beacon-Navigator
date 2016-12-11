# Beacon-Navigator
Indoor Navigation using iBeacon / Bluetooth Technologie and Trilateration algorithms,

You can choose between simple trilateration, non linear least squares or linear least squares method

The App is experimental and not finished, optimized or bug free. Just wanted to share my work as far as i got with it.

Updated for Swift3 but not improved for it.

## Usage

- use plist Files to create BeaconMap as examples given, values as meters
- In BeaconMapManager add the BeaconMap which you created as plist in the Maps array
- Now you can choose the Map within the Map
- The App uses Estimote Beacons as Standard, you can change that in BeaconManager
