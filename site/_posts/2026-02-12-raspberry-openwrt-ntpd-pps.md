---
layout: post
title: "Raspberry pi stratum 0 NTP server"
tags: openwrt raspberry
permalink: /pages/raspberry-openwrt-ntpd-pps.html
---

## Raspberry pi stratum 0 NTP server

### HW
* Raspberry Pi 3
* SD card (200MB will do, yes, 200**MB**!)
* Waveshare MAX-M8Q GNSS HAT for Raspberry Pi
* Raspberry Pi official case for 3B+

### SW
0. Download OpenWRT 24.10.5 [openwrt-24.10.5-bcm27xx-bcm2710-rpi-3-squashfs-factory.img.gz](https://downloads.openwrt.org/releases/24.10.5/targets/bcm27xx/bcm2710/openwrt-24.10.5-bcm27xx-bcm2710-rpi-3-squashfs-factory.img.gz), flash it on the SD card.

   :point_up: I find the *squashfs* more stable than the *ext4* one, and it will cause less wear on the SD card.
0. Modify the `/boot/config.txt` (`config.txt` in the `boot` partition):
   ```properties
   ...
   [all]
   # Place your custom settings here.
   dtoverlay=pps-gpio,gpiopin=18
   ...
   ```
0. Disable the serial console (we need the serial port for the GPS) in `/boot/cmdline.txt`
   ```properties
   console=tty1 root=PARTUUID=c8dca970-02 rootfstype=squashfs,ext4 rootwait
   ```

0. Assemble all the HW, and boot. The raspberry will have the `192.168.1.1` address, but I prefer it to DHCP.
   ```bash
   uci set network.lan.proto=dhcp
   uci commit
   /etc/init.d/network restart
   ```
0. Setup a root password
   ```bash
   root@OpenWrt:~# passwd
   Changing password for root
   New password:
   Bad password: too weak
   Retype password:
   passwd: password for root changed by root
   ```
0. Setup `authorized_keys` and disable root password login

0. Configure `hostname`
   ```bash
   uci set system.@system[0].hostname=pim-ntp
   uci commit
   echo pim-ntp > /proc/sys/kernel/hostname
   ```

0. Install the tools
   ```bash
   opkg update
   uci set system.ntp.enable='0'
   uci commit
   /etc/init.d/sysntpd disable
   /etc/init.d/sysntpd stop
   opkg install ntpd ntp-utils ntpd kmod-pps-gpio gpsd gpsd-clients \
   rsync nano coreutils-who zabbix-agentd python3-light
   /etc/init.d/ntpd enable
   ```

0. Configure gpsd
   ```bash
   uci set gpsd.core.device='/dev/ttyAMA0'
   uci set gpsd.core.enabled='1'
   uci commit
   /etc/init.d/gpsd enable
   /etc/init.d/gpsd start
   ```
0. Check GPS connectivity : `cgps -s -u m` should show `Status 3D FIX`
0. Configure ntp for using country specific servers:
   ```bash
   uci delete system.ntp.server
   uci add_list system.ntp.server='0.ch.pool.ntp.org'
   uci add_list system.ntp.server='1.ch.pool.ntp.org'
   uci add_list system.ntp.server='2.ch.pool.ntp.org'
   uci add_list system.ntp.server='3.ch.pool.ntp.org'
   ```
0. Configure ntpd : `/etc/ntpd.d/gps.conf`
   ```properties
   # GPS Serial data reference
   server 127.127.28.0 minpoll 4 maxpoll 4
   fudge 127.127.28.0 time1 0.0 refid GPS
   # GPS PPS reference
   server 127.127.28.1 minpoll 4 maxpoll 4 prefer
   fudge 127.127.28.1 refid PPS
   ```
0. (Re-) Start `ntpd`
   ```bash
   /etc/init.d/ntpd restart
   ```
0. Check GPS and PPS functionality :
   ```bash
   root@pim-ntp:~# ntpq -p
        remote           refid      st t when poll reach   delay   offset  jitter
   ==============================================================================
   +SHM(0)          .GPS.            0 l   13   16  377    0.000   +0.117   0.537
   *SHM(1)          .PPS.            0 l   12   16  377    0.000  +143.77   0.081
    ch1.ntp.ynnk.de 210.65.119.71    2 u    4   64    1   14.490  +148.66   1.090
   -ntp03.maillink. .PPS.            1 u   27   64    1   18.667  +146.12   4.040
   +time.hb9gun.ch  .DTS.            1 u   35   64    1   16.882  +148.64   1.001
    i7.isp.theswiss .PPS.            1 u    5   64    1   16.474  +205.98   0.983
   ```

0. A small animation :  `watch ntpq -p` (`opkg install procps-ng-watch`)
   <asciinema-player src="../data/a/pps.jsonl" preload autoplay loop cols="80" rows="11" poster="npt:5.1" font-size="small"></asciinema-player>
