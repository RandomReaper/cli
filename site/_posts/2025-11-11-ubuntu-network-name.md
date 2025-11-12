---
layout: post
title: Predictable or easy network names
tags: ubuntu 20.04
permalink: /pages/ubuntu-network-if-name.html
---

[Predictable network interface names](https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/){:.external} like `enp4s3`, `enx20251111dead`, `wlp3s0` or `wlx20251111beef` are *predictable* but not really human friendly.

My computer is probably more than happy knowing that `enp4s3` is (see [systemd.net-naming-scheme](https://www.freedesktop.org/software/systemd/man/latest/systemd.net-naming-scheme.html){:.external} for a complete explanation):
  * `en` : Ethernet
  * `p4` : physical PCIe bus 4
  * `s3` : in the slot3

But I will be happy with the old style `eth0` or any name with a human meaning.

## Renaming `wlp3s0` into `wlan0`

0. Find the mac address of `wlp3s0`
  ```
  cat /sys/class/net/wlp3s0/address
  20:25:11:63:6c:69
  ```
0. Create the file `/etc/systemd/network/00-wlan0.link`
  ```
  [Match]
  PermanentMACAddress=20:25:11:63:6c:69
  #
  [Link]
  Name=wlan0
  ```
0. reboot
  I have found no way of applying that change without rebooting, despite this [question on unix.stackexchange](https://unix.stackexchange.com/q/703012/130000){:.external}.
