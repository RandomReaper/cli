---
layout: post
title: Raspberry Pi 4 boot from network
tags: raspberry wifi
permalink: /pages/rasperry-pi-network-boot.html
---
Network boot will allow to boot a Raspberry Pi without local storage, and will show
it's full power when using several Raspberry Pi.

This post will show how to enable network boot on a Raspberry Pi 4, but I won't talk
about the server setup (I may complete the post if [requested](/about/)).

## First time (client) setup
The Raspberry Pi 4 may come with an EEPROM version that may prevent network booting, and in any case it is not factory activated, so the first step update the boot EEPROM and configure the Pi.

A single SD card may be reused for configuring and updating several Pi. I used `2022-04-04-raspios-bullseye-armhf-lite.img.xz`. For a headless install, you may have a look [here](/pages/rasperry-pi-install-headless.html).

I use `BOOT_ORDER=0xf2` to boot only from network and restart if it fails. See [here](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-4-bootloader-configuration){:.external} for a complete documentation of `BOOT_ORDER`.

Update and configure the Pi:
```
PI_EEPROM_VERSION=pieeprom-2022-04-26
wget https://github.com/raspberrypi/rpi-eeprom/raw/master/firmware/stable/${PI_EEPROM_VERSION}.bin
sudo rpi-eeprom-config ${PI_EEPROM_VERSION}.bin > bootconf.txt
sed -i '/BOOT_ORDER=.*/d' bootconf.txt
echo 'BOOT_ORDER=0xf2' >> bootconf.txt
sudo rpi-eeprom-config --out ${PI_EEPROM_VERSION}-netboot.bin --config bootconf.txt ${PI_EEPROM_VERSION}.bin
sudo rpi-eeprom-update -d -f ./${PI_EEPROM_VERSION}-netboot.bin
```

## Network boot information
After the DHCP succeeds, (the DHCP answer may contain the TFTP server address), the Raspberry Pi will try to fetch the
same files it expects in the on a SD `/boot` partition.
The Raspberry will first try to download files named "SERIAL_NUMBER/filename" then "filename", for instance "12345678/config.txt" and then "config.txt". Using this mechanism, it's possible to choose which Raspberry will load which OS from the network, with a fallback to a default.

Customizing the "SERIAL_NUMBER/cmdline.txt" can be used to provide a different filesystem for each Raspberry Pi on the network.

## Boot logs
Just for the record, here are some boot logs.

### Before DHCP:
```
Raspberry Pi 4 Model B - 8GB
Bootloader: 778c182c 2022/03/10


  board: 123456 1234578 dc:a6:32:XX:XX:XX
   boot: mode NETWORK 2 order f2 retry 0/0 restart 0/-1
     SD: card not detected
   part: 0 mbr [0x00:00000000 0x0:000000000 0x0:000000000 0x0:000000000]
     fw: star.elf fixup.dat
    net: up ip: 0.0.0.0 sn: 0.0.0.0 gw: 0.0.0.0
   tftp: 0.0.0.0 00:00:00:00:00:00

Boot mode: NETWORK (02) order f
Boot mode: NETWORK (02) order f
USB2[1] XXXXXXXX connected
USB2 root HUB port 1 init
```

### After DHCP:

* DHCP server IP : 75.748.86.1
* TFTP server IP : 75.748.86.33
* Pi IP : 75.748.86.91

```
Raspberry Pi 4 Model B - 8GB
Bootloader: 778c182c 2022/03/10


  board: 123456 1234578 dc:a6:32:XX:XX:XX
   boot: mode NETWORK 2 order f2 retry 0/0 restart 0/-1
     SD: card not detected
   part: 0 mbr [0x00:00000000 0x0:000000000 0x0:000000000 0x0:000000000]
     fw: star.elf fixup.dat
    net: up ip: 75.748.86.91 sn: 255.255.255.0 gw: 0.0.0.0
   tftp: 75.748.86.33 00:00:00:00:00:00

Boot mode: NETWORK (02) order f
Boot mode: NETWORK (02) order f
USB2[1] XXXXXXXX connected
USB2 root HUB port 1 init
NET_BOOT dc:a6:32:XX:XX:XX wait for link TFTP: 0.0.0.0
Link ready
DHCP src: XX:XX:XX:XX:XX:XX 75.748.86.1
YI_ADDR: 75.748.86.91
SI_ADDR: 75.748.86.1
[66]: 75.748.86.33
DHCP src: XX:XX:XX:XX:XX:XX 75.748.86.1
YI_ADDR: 75.748.86.91
SI_ADDR: 75.748.86.1
NET 75.748.86.91 255.255.255.0 gw 0.0.0.0 tftp 75.748.86.33
ARP 75.748.86.33 XX:XX:XX:XX:XX:XX
NET 75.748.86.91 255.255.255.0 gw 0.0.0.0 tftp 75.748.86.33
TFTP: 1: File not found
Read 1234578/config.txt bytes     1166 hnd 0x0
...
```
