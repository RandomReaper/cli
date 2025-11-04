---
layout: post
title: Raspberry PI OS headless install
tags: raspberry wifi
permalink: /pages/rasperry-pi-install-headless.html
---
  - Get Raspberry PI OS (I prefer the 64 bit-light).
  - Flash it (see [install guide](https://www.raspberrypi.org/documentation/installation/installing-images/README.md){:.external})
  - Mount the `/boot` partition, for instance in `/tmp/boot`, then run (with the username and password you want) :

  ```
  cd /tmp/boot
  touch ssh
  echo 'mypassword' | openssl passwd -6 -stdin | sed -e 's/^/username:/' > userconf
  ```
  - For wifi, put the file `wpa_supplicant.conf` in `/boot`, containing:

```
network={
    ssid="YOUR_SSID"
    psk="YOUR_PASSWORD"
    key_mgmt=WPA-PSK
}
```
