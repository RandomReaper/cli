---
layout: post
title: ubuntu 16.04 server serial install
tags: ximport ubuntu raspberry wifi
permalink: /pages/rasperry-pi-install-headless.html
---
  - Get raspbian lite
  - Flash it (see [install guide](https://www.raspberrypi.org/documentation/installation/installing-images/README.md){:.external})
  - Add an empty file named `ssh` on the boot partition (the one that contains config.txt).
  - For wifi, put the file `wpa_supplicant.conf` on the same partition, containing:

```
network={
    ssid="YOUR_SSID"
    psk="YOUR_PASSWORD"
    key_mgmt=WPA-PSK
}
```