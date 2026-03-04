---
layout: post
title: "Raspberry Pi stratum 0 NTP server"
tags: openwrt raspberry ntp
permalink: /pages/raspberry-openwrt-ntpd-pps.html
---

## HW
* Raspberry Pi 3
* SD card (200MB will do, yes, 200**MB**!)
* Waveshare MAX-M8Q GNSS HAT for Raspberry Pi
* Raspberry Pi official case for 3B+

## SW - OS and basic settings
0. Download OpenWRT 24.10.5 [openwrt-24.10.5-bcm27xx-bcm2710-rpi-3-squashfs-factory.img.gz](https://downloads.openwrt.org/releases/24.10.5/targets/bcm27xx/bcm2710/openwrt-24.10.5-bcm27xx-bcm2710-rpi-3-squashfs-factory.img.gz), flash it on the flash.

   :point_up: I find the *squashfs* more stable than the *ext4* one, and it will cause less wear on the SD card.
0. Modify the `/boot/config.txt` (`config.txt` in the `boot` partition):
   ```properties
   ...
   [all]
   # Place your custom settings here.
   dtoverlay=pps-gpio,gpiopin=18
   ...
   ```
0. Disable the serial console (we need the serial port for the GPS) in `/boot/dline.txt`
   ```properties
   console=tty1 root=PARTUUID=c8dca970-02 rootfstype=squashfs,ext4 rootwait
   ```
0. Assemble all the HW, and boot. The raspberry will have the `192.168.1.1` address, t I prefer it to DHCP.
   ```bash
   uci set network.lan.proto=dhcp
   uci commit
   /etc/init.d/network restart
   ```
0. Since this machine is not a router :
   ```
   /etc/init.d/firewall disable
   /etc/init.d/odhcpd disable
   /etc/init.d/dnsmasq disable
   reboot
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
   opkg install chrony kmod-pps-gpio gpsd gpsd-clients \
   nano rsync umdns coreutils-who zabbix-agentd python3-light kmod-usb-net-rtl8152
   /etc/init.d/chronyd enable
   ```
## SW - GPSD, chrony and PPS
0. Configure gpsd
   ```bash
   uci set gpsd.core.device='/dev/ttyAMA0'
   uci set gpsd.core.enabled='1'
   uci commit
   /etc/init.d/gpsd enable
   /etc/init.d/gpsd start
   ```
0. Check GPS connectivity : `cgps -s -u m` should show `Status 3D FIX`
0. Configure `chronyd` for using country specific servers in `/etc/config/chrony`:
   ```properties
   config pool
   	       option hostname '0.ch.pool.ntp.org'
           option iburst 'yes'
   ...
   ```
0. Add the GPS and PPS sources at the end of : `/etc/chrony/chrony.conf`
   ```properties
   ...
   refclock SHM 0 refid GPS precision 1e-1 offset 0.044 poll 2
   refclock SHM 1 refid PPS precision 1e-7 poll 1
   ```

   :point_up: 0.044 didn't fall out of the sky, this is the "Offset field"
   from the GPS given by `chronyc sourcestats` (with offset set at 0.00 in
   chrony.conf) . This time is the time necessary for the GPS data to be
   transmitted and decoded.

0. (Re-) Start `chronyd`
   ```bash
   /etc/init.d/chronyd restart
   ```
0. Check GPS and PPS functionality :
   ```bash
   chronyc sources
   ```

   ```bash
   MS Name/IP address         Stratum Poll Reach LastRx Last sample               
   ===============================================================================
   #- GPS                           0   2   377     4  +1157us[+1157us] +/-  100ms
   #* PPS                           0   1   377     1   -114ns[ -209ns] +/-  669ns
   ^- redacted1.example.com         3  10   377  1028  -9345us[-9381us] +/-   52ms
   ^- redacted2.example.com         2  10   377   824  -4990us[-5019us] +/-   11ms
   ^- redacted3.example.com         2  10   377   174  -3748us[-3755us] +/-   35ms
   ^- redacted4.example.com         1  10   377  1023  -3986us[-4022us] +/- 8996us
   ^- router.lan                    2   6   377    33  -3157us[-3157us] +/-   40ms
   ^? pim-ntp.lan                   0   8     0     -     +0ns[   +0ns] +/-    0ns
   ```
## Configure NTP pool and DHCP on a OpenWRT router
0. Setup all your NTP servers in a DNS pool (`/etc/config/dhc`)
   ```properties
   ...
   config domain
       option name 'ntp'
       option ip 'XXX.XXX.XXX.XXX' # address of the router with a NTP server

   config domain
       option name 'ntp'
       option ip 'XXX.XXX.XXX.YYY' # address of the ntp server (from this post)
   ...
   ```
0. Setup the DHCP to announce NTP servers:
   ```bash
   uci add_list dhcp.lan.dhcp_option='42,XXX.XXX.XXX.XXX,XXX.XXX.XXX.YYY'
   uci commit
   ```
0. Restart `dnsmasq`
   ```bash
   /etc/init.d/dnsmasq restart
   ```
## Result

   A small animation :  `watch chronyc sources` (`opkg install procps-ng-watch`)
  <asciinema-player src="../data/a/chronyc.jsonl" preload autoplay loop cols="80" rows="11" poster="npt:5.1" font-size="small"></asciinema-player>

   0. (Optional) Optimisation for timing

      :point_up: The backup battery on the Waveshare MAX-M8Q GNSS HAT is mandatory.
      Whitout it, the module will lose it's configuration every power loss. The
      symptom will be `NO FIX`, since the module will go back to 9600 bauds.

      * set jumpers on A
      * connect to your favorite Linux host using the USB cable
      * start gpsd on the usb port
         ```bash
         ubxtool -s 9600 -S 115200
         ubxtool -p MODEL,2
         ubxtool -p CFG-PMS,0
         ubxtool -p SAVE
         ubxtool -p COLDBOOT # validate the settings are OK
         ```
      * re-set jumpers on B
      * configure 11500 bauds using `-s 115200` in `/etc/init.d/gpsd`:
         ```bash
         ...
         [ "$enabled" = "0" ] && return 1

    	    procd_open_instance
    	    procd_set_param command "$PROG" -N -n -s 115200

    	    [ "$listen_globally" -ne 0 ] && procd_append_param command -G
    	    procd_append_param command -S "$port"
         ...
         ```
