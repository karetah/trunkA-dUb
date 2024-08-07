# https://github.com/karetah/trunkA-dUb
# wireless transparent L2 tunnel between two MikroTik wireless RoS 6 devices.
# Usage: reset your configuration with run-after-reset. place this file in root/flash/ or root/ 
# two copy of this file for two points named trunkX-YYY.rsc where X is A for one wireless point and B is for another. YYY - is three (3) symbols-digits for SSID name
# you must place only one filename beginning with trunk to the filesystem where you run this run-after-reset .
# you can change the type of the tunnel to eoip (default vpls)
:global identMe;
:global wificount [/interface wireless print count-only ];
:global model [ /system resource get board-name ];
:put [/log info message=$model];
:global hwtype;
:global trunkName;
:global trunkMode;
:global identMe;
:global netoctet;
:global peerAddress;
:global transportAddress;
:global wlanAddress;
:global wlanNetwork;
:global wlanInterface;
:global wlanBand;
:global wlanProto;
:global wlanSSID;
:global wlanCountry;
:global wlanFM;
:global wlanChanWidth;
:global wlanNoiceImm;
:global wlanFreq;
:global brName;
:global tunnelName;
:global etherName;
:global tunnelProto;
:global wlanNstreme
:global nv2PSK;
:global wpaPSK;
:global wlanMGMT;
# eoip / vpls
:set tunnelProto "vpls";
:set tunnelName "tunnel1";
:set brName br1;
:set etherName ether1;
:set wlanFreq "auto";
:set wlanFM "regulatory-domain";
:set wlanCountry "russia3";
# 802.11  any  nstreme  nv2  nv2-nstreme  nv2-nstreme-802.11  unspecified
:set wlanProto "802.11";
# 20/40/80/160mhz-Ceeeeeee  20/40/80/160mhz-eeCeeeee  20/40/80/160mhz-eeeeeCee
# 20/40/80/160mhz-XXXXXXXX  20/40/80/160mhz-eeeCeeee  20/40/80/160mhz-eeeeeeCe
# 20/40/80/160mhz-eCeeeeee  20/40/80/160mhz-eeeeCeee  20/40/80/160mhz-eeeeeeeC
# 20/40/80mhz-Ceee  20/40/80mhz-eCee  20/40/80mhz-eeeC
# 20/40/80mhz-XXXX  20/40/80mhz-eeCe  
# 20/40mhz-Ce  20/40mhz-XX  20/40mhz-eC
# 20mhz 10mhz 5mhz 40mhz-turbo
:set wlanChanWidth "20mhz";
:set nv2PSK "some0nv2presharedkey00";
:set wlanMGMT "managment00key";
:set wpaPSK "some0wpa0pre0shared0key";


:if ($wificount = 2) do={ :set $wlanInterface wlan2; }
:if ($wificount = 1) do={ :set $wlanInterface wlan1; }

:if (($wlanProto = "nstreme" ) || ($wlanProto = "nv2" ) || ($wlanProto = "nv2-nstreme" )) do={ :set $wlanNstreme true; } else={ :set $wlanNstreme false; }
:put $wlanNstreme;

:if (($model = "hAP ac" ) || ($model = "wAP ac" ) || ($model = "hAP ac lite" ) || ($model = "hAP ac^2") || ($model = "SXT Lite5 ac") || ($model = "SXTsq 5 ac")) do={ :set $wlanBand 5ghz-a/n/ac; } else={ :set $wlanBand 2ghz-b/g/n; }
:if (($model = "hAP ac" ) || ($model = "wAP ac" ) || ($model = "hAP ac lite" ) || ($model = "hAP ac^2") || ($model = "SXT Lite5 ac") || ($model = "SXTsq 5 ac") || ($model = "SXTsq 2 ac") || ($model = "SXT 2") || ($model = "hAP")) do={ :set $hwtype "flash" } else={ :set $hwtype "flat" }

:if ($hwtype = "flash") do={ \ 
:set trunkName [/file get value-name=name [/file find name~"flash/trunk*"]];
:set identMe [:pick $trunkName 11 12];
:set wlanSSID [:pick $trunkName 13 16];\
} else={ \
:set trunkName [/file get value-name=name [/file find name~"trunk*"]];
:set identMe [:pick $trunkName 6 7]; 
:set wlanSSID [:pick $trunkName 8 11];\
}

:set wlanNetwork 172.31.254.0; 
:if ($identMe = "A") do={ \ 
:set trunkMode bridge;
:set wlanNoiceImm "ap-and-client-mode";
:set transportAddress 172.31.254.1;
:set wlanAddress 172.31.254.1/30;
:set peerAddress 172.31.254.2; \
} else={ \
:set trunkMode station;
:set wlanNoiceImm "client-mode";
:set transportAddress 172.31.254.2;
:set wlanAddress 172.31.254.2/30;
:set peerAddress 172.31.254.1; \
}


/system identity set name=($identMe . "-" . $wlanSSID);
/interface bridge add name=$brName

/ip address add address=$wlanAddress interface=$wlanInterface network=$wlanNetwork

/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
add authentication-types=wpa2-psk disable-pmkid=yes eap-methods="" \
    management-protection=required management-protection-key=$wlanMGMT mode=\
    dynamic-keys name=T1 wpa2-pre-shared-key=$wpaPSK
    
:if ($wlanNstreme = true) do={ :put [/interface wireless nstreme set $wlanInterface disable-csma=yes enable-nstreme=yes]; }


/interface wireless
set [ find default-name=$wlanInterface ] \
    band=$wlanBand country=$wlanCountry disabled=no frequency=$wlanFreq \
    frequency-mode=$wlanFM mode=$trunkMode nv2-preshared-key=$nv2PSK \
    nv2-security=enabled security-profile=T1 ssid=$wlanSSID \
    wireless-protocol=$wlanProto wps-mode=disabled adaptive-noise-immunity=$wlanNoiceImm channel-width=$wlanChanWidth


:if ($tunnelProto = "eoip") do={ \ 
/interface eoip add name=$tunnelName remote-address=$peerAddress tunnel-id=0 clamp-tcp-mss=yes; \
} 
:if ($tunnelProto = "vpls") do={ \
/interface vpls add disabled=no l2mtu=1500 name=$tunnelName remote-peer=$peerAddress vpls-id=1:1;
# https://help.mikrotik.com/docs/display/ROS/MTU+in+RouterOS
/mpls interface set [ find default=yes ] mpls-mtu=1526;
/mpls ldp set enabled=yes lsr-id=$transportAddress transport-address=$transportAddress;
/mpls ldp interface add interface=$wlanInterface; \
}


/ip neighbor discovery-settings set discover-interface-list=all
/interface bridge port
add bridge=$brName interface=$tunnelName;
add bridge=$brName interface=$etherName;
