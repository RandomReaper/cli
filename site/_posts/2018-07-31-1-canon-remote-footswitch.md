---
layout: post
title: Canon remote footswitch
tags: canon
permalink: canon-remote-footswitch.html
---

Here is how to trigger a Canon camera with a E3 (2.5 mm jack) trigger.

Hardware:
 * Hama Connection Adapter Cable for Canon "DCCSystem" CA-1 (hama #00005204)
 * Hama Extension Cable for "DCCSystem", 5 m, (hama #00005215)
 * Sparkfun foot pedal switch (sparkfun #COM-11192)

## Canon E3 pinout (2.5mm jack - 3 poles)

 | Pin | Function |
 | --- | --- |
 | 1 (tip) | Trigger |
 | 2 | Focus |
 | 3 | n.c (there is only 3 wires in the cable!) |
 | 4 | GND |

## Hama DCCSystem pinout (2.5mm jack - 4 poles)

 | Pin | Function | Color |
 | --- | --- | --- |
 | 1 (tip) | Trigger | Red |
 | 2 | Focus | Green |
 | 3 | n.c | No wire |
 | 4 | GND | Blue |

## Handwork
0. Open the foot pedal switch, remove the existing cable
0. Cut the extension cable, the interesting part is the female one.
0. Solder the ***green*** and ***red*** wire together then to the first pole of the switch in the pedal.
0. Solder the ***blue*** wire to the other side of the switch.
0. Close the pedal
0. ***Enjoy!***

