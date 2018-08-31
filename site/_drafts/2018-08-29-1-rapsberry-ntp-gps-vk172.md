---
layout: post
title: 'stratum-1 `ntp` server on raspberry with low-cost GPS receiver'
tags: raspberry ntp gps pps
permalink: raspberry-ntp-gps-vk172.html
#image: /data/img/wide/www.jpg
---

The VK-172 USB GPS receiver, available on ebay for $5.80, has no [PPS](/tag/pps.html) signal.
Fortunately, it's based on the [u-blox UBX-G7020](https://www.u-blox.com/en/product/ubx-g7020-series){:.external} receiver,
which provides a PPS output.

## Parts needed
 * Working Raspberry PI with raspbian installed, tested on stretch
 * VK-172 receiver
 * 1 jumper wire
 * Soldering iron, hot glue gun, ...

## Hardware modification

Here is the VK-172 opened (click for a full-resolution image):

[![VK-172 top](/data/img/vk172/top_mini.jpg)](/data/img/vk172/top.jpg)[![VK-172 bottom](/data/img/vk172/bot_mini.jpg)](/data/img/vk172/bot.jpg)

According to the u-blox UBX-G7020 hardware integration manual (which can be
found easily using your favorite search engine), the PPS pin is the pin 35.
So a wire should be soldered to this little pad.

**Now don't go too fast!**

Another interesting fact is that the VK-172 LED will blink at 1 Hz when the GPS
has a good fix, and while using a magnifier for soldering a new wire on the pin
35, I saw a track coming out of this pad...


[![VK-172 pin 35](/data/img/vk172/pin35_mini.jpg)](/data/img/vk172/pin35.jpg)

The PPS signal drives the LED (LD1) through R1, and soldering a wire on R1 will
be far easier than soldering a wire on the QFN chip.

[![VK-172 r1](/data/img/vk172/r1_mini.jpg)](/data/img/vk172/r1.jpg)

Solder one side of the jumper wire:

[![VK-172 soldered](/data/img/vk172/soldered_mini.jpg)](/data/img/vk172/soldered.jpg)

Add some glue:

[![VK-172 glued](/data/img/vk172/glued_mini.jpg)](/data/img/vk172/glued.jpg)

Put it back into it's case:

[![VK-172 finished](/data/img/vk172/finished_mini.jpg)](/data/img/vk172/finished.jpg)

And now connect the cable to the gpio pin 26

[![pi gpio26](/data/img/vk172/gpio26_mini.jpg)](/data/img/vk172/gpio26.jpg)

## Sofware

### Configuration

Edit `/boot/config.txt` and configure the GPIO for the PPS, I've chosen "BCM 26".
```config
...
dtoverlay=pps-gpio,gpiopin=26
...
```

**Reboot**


```console
sudo apt-get install gpsd gpsd-clients pps-tools ntp
```

Create the `/etc/udev/rules.d/50-pps-ntp.rules` file:
```config
KERNEL=="pps0", OWNER="root", GROUP="dialout", MODE="0660"
```

Reload udev rules:
```
udevadm control --reload-rules && udevadm trigger
```

Now de-plug and re-plug the VK-172!

Edit the `/etc/default/gpsd` file (`sudoedit /etc/default/gpsd`) for changing the
device:
```config
...
DEVICES=`/dev/gps0 /dev/pps0`
...
```

Restart the service:
```console
sudo systemctl restart gpsd
```

### Testing the GPS
The led will blink once a second when there is a fix, but you can use `gpsmon` to get more
information about the fix.

When the led is blinking, use `ppstest` to verify the PPS source (there is no clear time
since the pps-gpio driver only uses the rising edge):
```console
sudo ppstest /dev/pps0
trying PPS source "/dev/pps0"
found PPS source "/dev/pps0"
ok, found 1 source(s), now start fetching data...
source 0 - assert 1535543547.998657695, sequence: 873 - clear  0.000000000, sequence: 0
source 0 - assert 1535543548.998657205, sequence: 874 - clear  0.000000000, sequence: 0
source 0 - assert 1535543549.998657906, sequence: 875 - clear  0.000000000, sequence: 0
source 0 - assert 1535543550.998657925, sequence: 876 - clear  0.000000000, sequence: 0
source 0 - assert 1535543551.998658147, sequence: 877 - clear  0.000000000, sequence: 0
source 0 - assert 1535543552.998657634, sequence: 878 - clear  0.000000000, sequence: 0
^C
```

### Add the GPS and PPS inputs to `ntp`

This is the most complicated part. Most *howto* on the Internet recommend using
the shared memory driver (127.127.28.0) to connect `ntpd` with `gpsd`. After
hours of failure (probably for permission reasons), I tried to use the NMEA driver
(which reads the time from the GPS frames), and here is how:

Give the ntp user access to the gps : 
```
sudo usermod -a -G dialout ntp
```


Edit `/etc/ntp.conf` and add those lines:
```
...
# coarse time ref-clock, based on the GPS messages
server 127.127.20.0 minpoll 4 maxpoll 4 prefer
fudge 127.127.20.0 refid GPS

# precise time ref-clock, based on the GPS PPS pin
server 127.127.22.0 minpoll 4 maxpoll 4
fudge 127.127.22.0  refid PPS

# Prevent high jitter GPS message from getting set as falsticker
tos mindist 0.015
```

Restart the ntp server:

```
sudo systemctl restart ntp
```

### ntp check:


```
ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
...
*GPS_NMEA(0)     .GPS.            0 l    8   16  377    0.000   -2.596  35.202
oPPS(0)          .PPS.            0 l    7   16  377    0.000   65.625  36.040
...
```

 * The '**\***' before **GPS_NMEA(0)** means it's the selected time source
 * The '**o**' before **PPS(0)** means this is used for the PPS

### Standalone check

Delete external routes on the raspberry pi to test for standalone (GPS-only) functionality:
```
ip route del 0/0
```

Then watch the output of `ntpq -p` and verify the server is still working (it will
take some time before remote servers are considered down and no more used).

## References
 * [https://www.satsignal.eu/ntp/Raspberry-Pi-NTP.html](https://www.satsignal.eu/ntp/Raspberry-Pi-NTP.html)
 * [https://www.youtube.com/watch?v=USKGsg82FJI](https://www.youtube.com/watch?v=USKGsg82FJI)