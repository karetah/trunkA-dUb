# trunkA-dUb
wireless

- wireless transparent L2 tunnel between two MikroTik wireless RoS 6 devices.
- Usage: reset your configuration with run-after-reset. place this file in root/flash/ or root/ 
- - two copy of this file for two points named trunkX-YYY.rsc where X is A for one wireless point and B is for another. YYY - is three (3) symbols-digits for SSID name
- - you must place only one filename beginning with trunk to the filesystem where you run this run-after-reset .
- - you can change the type of the tunnel to eoip (default vpls)
