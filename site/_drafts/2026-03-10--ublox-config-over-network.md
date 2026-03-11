---
layout: post
title: "Fine tune ublox GNSS receiver"
tags: ubuntu ntp openwrt
permalink: /pages/ublox-config-network.html
---

I use a u-blox NEO-M8Q as time source for [NTP](/tag/ntp.html) and I want to
configure it using u-blox's `u-center`, but since `u-center` does not run
OpenWRT and I don't want to disconnect the module, here is how to do it over
the network.

```bash
#stop gpsd
/etc/init.d/gpsd stop

opkg update
opkg install ser2net
cat <<EOF >> /etc/config/ser2net
config proxy
	option enabled 1
	option port 5001
	option protocol raw
	option timeout 0
	option device '/dev/ttyAMA0'
	option baudrate 115200
	option databits 8
	option parity 'none'
	option stopbits 1
	option rtscts false
  option local true
	option xonxoff true
EOF

/etc/init.d/ser2net restart
```

## In `u-center`
* Receiver > Connection > Network connection -> tcp://IP:5001
* UBX-CFG-NAV5
   * Dynamic Model : Stationary
   * Static Hold Threshold : 1 m/s
