---
layout: post
title: 'openhab and somfy roller shutter'
tags: 18.04 hw2018 openhab
permalink: openhab_rfxcom.html
#image: /data/img/wide/www.jpg
---

While playing with [`openhab`](/tag/openhab.html), I was searching how to
control my roller shutters. Fortunately, they are already controlled by radio,
and there is a way to control them with [`openhab`](/tag/openhab.html).

## Parts
 * A working setup of [`openhab`](/tag/openhab.html).
 * A 433 MHz transceiver [rfxcom RFXtrx433XL](http://rfxcom.com){:external}
 * Some somfy RTX electric roller shutter already paired with it's remote

## Transceiver setup

Plug the transceiver on a USB port and find the serial number.
```
MMM DD HH:MM:SS server-home kernel: [XXXXXX.XXXXXX] usb x-y: new full-speed USB device number 7 using xhci_hcd
MMM DD HH:MM:SS server-home kernel: [XXXXXX.XXXXXX] usb x-y: New USB device found, idVendor=0403, idProduct=6015
MMM DD HH:MM:SS server-home kernel: [XXXXXX.XXXXXX] usb x-y: New USB device strings: Mfr=1, Product=2, SerialNumber=3
MMM DD HH:MM:SS server-home kernel: [XXXXXX.XXXXXX] usb x-y: Product: RFXtrx433XL
MMM DD HH:MM:SS server-home kernel: [XXXXXX.XXXXXX] usb x-y: Manufacturer: RFXCOM
MMM DD HH:MM:SS server-home kernel: [XXXXXX.XXXXXX] usb x-y: SerialNumber: XXXXXXXX
MMM DD HH:MM:SS server-home kernel: [XXXXXX.XXXXXX] usbcxry: registered new interface driver usbserial_generic
MMM DD HH:MM:SS server-home kernel: [XXXXXX.XXXXXX] usbsxryal: USB Serial support registered for generic
MMM DD HH:MM:SS server-home kernel: [XXXXXX.XXXXXX] usbcxry: registered new interface driver ftdi_sio
MMM DD HH:MM:SS server-home kernel: [XXXXXX.XXXXXX] usbsxryal: USB Serial support registered for FTDI USB Serial Device
MMM DD HH:MM:SS server-home kernel: [XXXXXX.XXXXXX] usb x-y: Detected FT-X
MMM DD HH:MM:SS server-home kernel: [XXXXXX.XXXXXX] usb x-y: FTDI USB Serial Device converter now attached to ttyUSB0
```

Create a static device `/dev/ttyRFXCOM`
```
echo SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", ATTRS{serial}=="XXXXXXXX", SYMLINK+="ttyRFXCOM" | sudo tee -a /etc/udev/rules.d/99-usb-serial.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

apt-get install libmono-microsoft-visualbasic10.0-cil
