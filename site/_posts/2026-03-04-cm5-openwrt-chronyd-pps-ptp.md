---
layout: post
title: "Raspberry Pi stratum 0 NTP server + PTP server"
tags: openwrt raspberry ntp ptp
permalink: /pages/cm5-openwrt-chronyd-pps-ptp.html
---

If you think having your own stratum 0 [NTP](/tag/ntp.html) server is not cool enough, why not have a [`PTP`](/tag/ptp.html) server at home?

:x: Well, it looks cool, but the PTP part is currently not working!

## TL ; DR
<asciinema-player src="../data/a/chronyc.jsonl" preload autoplay loop cols="80" rows="23" poster="npt:5.1" font-size="small"></asciinema-player>


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

:warning: I may have ordered the hardware too fast, the CM5 needs kernel >
6.12 [info from here](https://github.com/jclark/rpi-cm4-ptp-guide/blob/76f497332d5ccd35eeb008e935b8fc2b935716a2/os.md?plain=1#L38){:.external},
and OpenWRT ships with kernel 6.6...

So, the PTP functionality will be tested using ubuntu 25.10 sever

## SW - OS and basic settings
0. [`OpenWRT`](tag/openwrt.html) 24.10.5 setup.

  It may be possible to use `rpiboot` to flash the eMMC as a USB mass device,
  but since I can't find any documentation on the mainboard manufacturer's
  site, I used a USB drive to flash the OpenWRT image on `/dev/mmcblk0`. And
  since `rpi-eeprom-config` does not work on OpenWRT, I used Raspberry Pi OS
  Lite on the USB drive.

  * Write the Raspberry Pi OS Lite image on the USB drive, and boot on it.
     If you don't have an official power supply, you may need
     `usb_max_current_enable=1` in your `config.txt`.

  * Configure BOOT_ORDER (see the [doc](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#BOOT_ORDER){:.external}).

      The factory settings is 0xf2461 (SD (eMMC) -> NVMe -> USB -> Network).
      Since the eMMC is soldered (not removable like a SD card), the there
      is no way to boot on something else, once it is configured.

      So let's configure BOOT_ORDER to USB -> NVMe -> SD.
      ```bash
      # Configure BOOT_ORDER to USB -> NVMe -> SD and disable other factory settings
      cat <<EOF >boot.conf
      [all]
      BOOT_UART=0
      POWER_OFF_ON_HALT=0

      # USB -> NVMe -> SD
      BOOT_ORDER=0xf164
      EOF

      sudo rpi-eeprom-config --apply boot.conf

      sudo reboot # Rebooting in the same OS is necessary to write the eeprom
      ```

   * Now install OpenWRT on the eMMC

      :point_up: I find the *squashfs* more stable than the *ext4* one, and will cause less wear on the flash. Feel free to use another image.

      ```bash
      # download OpenWRT
      wget https://downloads.openwrt.org/releases/24.10.5/targets/bcm27xx/bcm2712/openwrt-24.10.5-bcm27xx-bcm2712-rpi-5-squashfs-factory.img.gz

      # verify the dowload
      echo "a3356a692ccc4e22896b9fb57a001d949f7c967d924c534732272fa1745bb00d  openwrt-24.10.5-bcm27xx-bcm2712-rpi-5-squashfs-factory.img.gz" | shasum -c -

      # flash it
      zcat openwrt-24.10.5-bcm27xx-bcm2712-rpi-5-squashfs-factory.img.gz | sudo dd bs=4M of=/dev/mmcblk0


      # edit eMMC/boot/config.txt and eMMC/boot/cmdline.txt
      mkdir /tmp/boot
      sudo mount /dev/mmcblk0p1 /tmp/boot/ -o noatime

      # config.txt setup
      cat <<EOF | sudo tee -a /tmp/boot/config.txt
      [all]
      dtparam=pciex1                # for X1501 ssd
      dtoverlay=pps-gpio,gpiopin=18 # PPS on GPIO 18
      dtparam=uart0=on              # enable /dev/ttyAMA0 for the GPS
      dtparam=watchdog=off          # disable watchdog
      usb_max_current_enable=1
      EOF

      # The GNSS will need the serial port, so don't put a console on it
      sudo sed -i 's/ .*115200//' /tmp/boot/cmdline.txt
      sudo umount /tmp/boot
      ```

   * Remove the USB drive and reboot OpenWRT on the eMMC


0. The raspberry will have the `192.168.1.1` address, but I prefer it to DHCP.
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
   uci set system.@system[0].hostname=pim-ptp
   uci set system.@system[0].timezone='CET-1CEST,M3.5.0,M10.5.0/3'
   uci set system.@system[0].zonename='Europe/Zurich'
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
   /etc/init.d/ntpd disable
   /etc/init.d/ntpd stop
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
   config systemclock 'systemclock'
   ...
   ```
0. Add the GNSS and PPS sources at the end of : `/etc/chrony/chrony.conf`
   ```properties
   ...
   refclock SHM 0 refid GNSS precision 1e-1 offset 0.044 poll 0 filter 8
   refclock PPS /dev/pps0 refid PPS lock GNSS poll 2 trust
   ```

   :point_up: 0.044 didn't fall out of the sky, this is the "Offset field"
   from the GPS given by `chronyc sourcestats` (with offset set at 0.00 in
   chrony.conf) . This time is the time necessary for the GPS data to be
   transmitted and decoded.

0. (Re-) Start `chronyd`
   ```bash
   # Restarting network after chrony configuration will get the NTP servers
   # from the DHCP server
   /etc/init.d/network restart
   /etc/init.d/chronyd restart
   ```

0. Check GPS and PPS functionality :
   ```bash
   chronyc sources
   ```

   ```bash
   MS Name/IP address         Stratum Poll Reach LastRx Last sample               
   ===============================================================================
   #- GNSS                         0   2   377     6    +43ms[  +43ms] +/-  100ms
   #* PPS                          0   1   377     2   -343ns[ -716ns] +/- 2600ns
   ^- redacted1.example.com        1   6   377    22  -3130us[-3128us] +/-   10ms
   ^- redacted2.example.com        1   6   377    22  -3188us[-3187us] +/- 7391us
   ^- redacted3.example.com        2   6   377    21  -5598us[-5597us] +/-   18ms
   ^- redacted4.example.com        2   6   377    20  -3383us[-3382us] +/-   36ms
   ^- router.lan                   2   6   377    15  -3231us[-3231us] +/-   41ms
   ^- pim-ntp.lan                  1   6   377    14    -12us[  -12us] +/-  290us
   ^? pim-ptp.lan                  0   8   377     -     +0ns[   +0ns] +/-    0ns

   ```

## Configure NTP pool DNS and DHCP on a OpenWRT router
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

## :x: ptp (using ubuntu server 25.10) :x:

:x: the PTP server does not work at this time :x:

The complete install will be documented once the required drivers reach OpenWRT.

In brief:
   * install ubuntu server 25.10
   * add the `config.txt` lines into `/boot/firmware/config.txt`
   * remove the serial console from `/boot/firmware/current/cmdline.txt`.
   * reboot
   * install and configure `gpsd` (in `/etc/default/gpsd`)
      ```properties
      # Devices gpsd should collect to at boot time.
      # They need to be read/writeable, either by user gpsd or the group dialout.
      DEVICES="/dev/ttyAMA0"

      # Other options you want to pass to gpsd
      GPSD_OPTIONS="-n -s 115200"

      # Automatically hot add/remove USB GPS devices via gpsdctl
      USBAUTO="true"
      ```
   * install and configure `chrony`
     ```bash
     sudo rm /etc/chrony/sources.d/ubuntu-ntp-pools.sources
     echo "pool 0.ch.pool.ntp.org iburst" | sudo tee /etc/chrony/sources.d/pim.sources
     echo "pool ntp.lan iburst" | sudo tee -a /etc/chrony/sources.d/pim.sources
     echo "refclock SHM 0 refid GNSS precision 1e-1 offset 0.044 poll 0 filter 8" | sudo tee /etc/chrony/conf.d/pim.conf
     echo "refclock PPS /dev/pps0 refid PPS lock GNSS poll 2 trust" | sudo tee -a /etc/chrony/conf.d/pim.conf
     sudo systemctl restart chrony
     ```
   * connect GNSS module PPS pin (GPIO8 or dedicated output) to Ethernet_SYNC_OUT (J2 pin 6)
   * configure Ethernet_SYNC_OUT as a PPS input
      ```bash
      # Configure the pin as input, 1 means input, 0 is the ptp channel 0 (from ethtool -T eth0 | grep 'Hardware timestamp provider index:')
      echo 1 0 | sudo tee /sys/class/ptp/ptp0/pins/SYNC_OUT

      # Enable timestamping (0 is the ptp channel number and 1 is enable
      echo 0 1 | sudo tee /sys/class/ptp/ptp0/extts_enable

      # should display 1 timestamp per second
      # disconnect the cable and the timestamps will stop

      while true; do cat /sys/class/ptp/ptp0/fifo ; done
      ```
   * configure ptp timemaster
      ```bash
      sudo apt install linuxptp
      sudo systemctl disable timemaster.service
      ```

   * Sync PTP hardware clock to PPS
      ```bash
      # we don't use nmea for time of day (gpsd uses the gps data), so sync
      # PTP with the system clock. TAI is 37 seonds ahead of TAI
      sudo phc_ctl eth0 "set;" adj 37 # fixme get it from leap-seconds.list
      # ubuntu is not up to date
      sudo wget -P /etc/linuxptp https://data.iana.org/time-zones/tzdb-2026a/leap-seconds.list
      cat <<EOF | sudo tee -a /etc/linuxptp/ts2phc.conf
      [global]
      leapfile /etc/linuxptp/leap-seconds.list
      step_threshold 0.1
      ts2phc.tod_source generic
      logging_level 7

      [eth0]
      ts2phc.pin_index 0
      EOF

      ts2phc -f /etc/linuxptp/ts2phc.conf -m -q -l 7
      ```
   * Sync chrony with the the PTP hardware clock
      ```bash
      echo "refclock SHM 0 refid GNSS precision 1e-1 offset 0.044 poll 0 filter 8" | sudo tee /etc/chrony/conf.d/pim.conf
      echo "refclock PPS /dev/pps0 refid PPS lock GNSS poll 2" | sudo tee -a /etc/chrony/conf.d/pim.conf
      echo "refclock SHM 2 refid PPSp tai lock GNSS poll 2" | sudo tee -a /etc/chrony/conf.d/pim.conf
      sudo systemctl restart chrony

      # -M2 -> write to SHM 2
      # offset is zero, since it is configured as TAI in chrony
      phc2sys -s eth0 -E ntpshm -O 0 -M 2
      ```
   * ptp master :warning: work in progress

     At this time `ptp4l --serverOnly 1 -i eth0 -l 7 --tx_timestamp_timeout 500` fails with this error:
     ```
     timed out while polling for tx timestamp
     increasing tx_timestamp_timeout or increasing kworker priority may correct this issue, but a driver bug likely causes it
     port 1 (eth0): send sync failed
     port 1 (eth0): MASTER to FAULTY on FAULT_DETECTED (FT_UNSPECIFIED)
     ```
