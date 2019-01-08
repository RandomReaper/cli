---
layout: post
title: buspirate and SPI LED strip
tags: ximport ubuntu apa102
permalink: /pages/buspirate-spi-led.html
---

Required material:

 - buspirate v4
 - [APA102](/tag/apa102.html) or similar led strip
 - Optional : a strong power supply for a long strip
 - For playing with 4 leds, the buspirate 5V is sufficient.

Wiring:

|----+----|
| buspirate  | APA102 led strip |
|----+----|
|5V | 5V |
|GND | GND |
|MOSI | DI |
|CLK | CI |

Connect to the buspirate then do the following commands for configuring the SPI:
 - m (mode)
 - 5 (SPI)
 - 4 (1MHz)
 - 1 (clock idle low)
 - 2 (clock active to ilde)
 - 1 (sample middle)
 - 2 (/cs)
 - 2 (normal)
 - W (enable power)

And now some data for the leds:

 - \[0x00,0x00,0x00,0x00\] (sync)
 - \[0xff,0x00,0x00,0xff\] (1st led red)
 - \[[0xff,0x00,0xff,0x00\] (2nd led green)
- \[[0xff,0xff,0x00,0x00\] (3rd led blue)
- \[0x00,0x00,0x00,0x00\] (sync : display now)

fini
