---
layout: post
title: "Raspberry Pi stratum 0 NTP server + PTP server"
tags: openwrt raspberry ntp ptp
permalink: /pages/cm5-openwrt-chronyd-pps-ptp.html
---

If you think having your own stratum 0 [NTP](tag/ntp.html) server is not cool enough, why not have a [`PTP`](tag/ptp.html) server at home?

## HW
* Raspberry Pi CM5 (CM5102016 - 2GB RAM, 16 GB eMMC, Wifi)
  * The SYNC input for the PTP is only available on CM4 and CM5 (i.e. not available on the RPi 4 and 5).
  * N.B. Wifi is not necessary, but this will become my router in the near future
* Mainboard: SupTronics X1501
  * Dual ethernet, did I already tell this board will become my router?
* GPS: Waveshare MAX-M8Q GNSS HAT for Raspberry Pi
  * Because it has a PPS output

  * Can be replaced by the NEO-M8T HAT, which is especially designed for timing
  applications, but is 3.5x more expensive.
* Battery: ML1220 to store settings on the NEO-M8T HAT
* Case: SupTronics X15-C1
* Passive cooler: SC1752
* PSU: USB-C (27W recommended by SupTronics)

## SW - OS and basic settings
0. Download [`OpenWRT`](tag/openwrt.html) 24.10.5 [openwrt-24.10.5-bcm27xx-bcm2712-rpi-5-squashfs-factory.img.gz](https://downloads.openwrt.org/releases/24.10.5/targets/bcm27xx/bcm2712/openwrt-24.10.5-bcm27xx-bcm2712-rpi-5-squashfs-factory.img.gz), flash it on the eMMC.
   * It is possible to use `rpiboot` to flash the eMMC, but I booted the module on a USB drive and flashed `/dev/mmcblk0`

   :point_up: I find the *squashfs* more stable than the *ext4* one, and it will cause less wear on the flash.
0. Assemble all the HW, and boot. The raspberry will have the `192.168.1.1` address, but I prefer it to DHCP.
   ```bash
   uci set network.lan.proto=dhcp
   uci commit
   /etc/init.d/network restart
   ```
0. Modify the `/boot/config.txt` (`config.txt` in the `boot` partition):
   ```properties
   ...
   [all]
   # Place your custom settings here.
   dtparam=pciex1                # for X1501 ssd
   dtoverlay=pps-gpio,gpiopin=18 # PPS on GPIO 18
   dtparam=uart0=on              # enable /dev/ttyAMA0 for the GPS
   ...
   ```
0. Disable the serial console (we need the serial port for the GPS) in `/boot/cmdline.txt`
   ```properties
   console=tty1 root=PARTUUID=c8dca970-02 rootfstype=squashfs,ext4 rootwait
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
   uci set system.@system[0].hostname=pim-ptp
   uci commit
   echo pim-ptp > /proc/sys/kernel/hostname
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
   #- GPS                           0   2   377     6    +43ms[  +43ms] +/-  100ms
   #* PPS                           0   1   377     2   -343ns[ -716ns] +/- 2600ns
   ^- redacted1.example.com        1   6   377    22  -3130us[-3128us] +/-   10ms
   ^- redacted2.example.com        1   6   377    22  -3188us[-3187us] +/- 7391us
   ^- redacted3.example.com        2   6   377    21  -5598us[-5597us] +/-   18ms
   ^- redacted4.example.com        2   6   377    20  -3383us[-3382us] +/-   36ms
   ^- router.lan                   2   6   377    15  -3231us[-3231us] +/-   41ms
   ^- pim-ntp.lan                  1   6   377    14    -12us[  -12us] +/-  290us
   ^? pim-ntp2.lan                 0   8     0     -     +0ns[   +0ns] +/-    0ns

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
       option ip 'XXX.XXX.XXX.YYY' # address of the ntp server (from our older post)

   config domain
       option name 'ntp'
       option ip 'XXX.XXX.XXX.YYY' # address of the ntp+ptp server (from this post)
   ...
   ```
0. Setup the DHCP to announce NTP servers:
   ```bash
   uci add_list dhcp.lan.dhcp_option='42,XXX.XXX.XXX.XXX,XXX.XXX.XXX.YYY,XXX.XXX.XXX.ZZZ'
   uci commit
   ```
0. Restart `dnsmasq`
   ```bash
   /etc/init.d/dnsmasq restart
   ```

## Result

A small animation :  `watch chronyc sources` (`opkg install procps-ng-watch`)
<asciinema-player src="../data/a/chronyc.jsonl" preload autoplay loop cols="80" rows="11" poster="npt:5.1" font-size="small"></asciinema-player>

## (Optional) Optimisation for timing

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
