---
layout: post
title: Raspberry pi and SPI LED strip
tags: ximport raspberry APA102
permalink: /pages/raspberry-spi-led.html
---

Required material:

 - raspberry pi (tested on 2b and 3b+)
 - [APA102](/tag/APA102.html) or similar led strip
 - Optional : a good power supply for the strip
 - For playing with 3 leds, the raspberry 5V is sufficient.

Wiring:

|----+----|
|Raspberry |	APA102 led strip |
|----+----|
|2 |	5V |
|6 |	GND|
|19|	DI|
|23|	CI|

Enable the SPI functionality using `raspi-config` then reboot

Turn led 1 in red, led 2 in green led 3 in blue:

```bash
echo "00000000 ff0000ff ff00ff00 ffff0000 00000000 00000000" | xxd -r -p > /dev/spidev0.0
```
And since *A picture is worth a thousand words*:
![Raspberry pi + APA102 strip](/data/img/raspi_apa102.jpg)