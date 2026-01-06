---
layout: post
title: "Find a device on the network, knowing it's MAC address"
tags: ubuntu raspberry network
permalink: /pages/find-network-mac.html
---

## TL;DR;

Use **the_hosname*****.local*** as URI, exemple:
```bash
user@host:/anywhere$ ping -c1 pim-checker.local
PING pim-checker.local (X.X.X.95) 56(84) bytes of data.
64 bytes from X.X.X.95: icmp_seq=1 ttl=64 time=1.57 ms

--- pim-checker.local ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.568/1.568/1.568/0.000 ms
user@host:/anywhere$
```

Avahi uses [zeroconf](https://en.wikipedia.org/wiki/Zero-configuration_networking){:.external} (also called [Bonjour](https://en.wikipedia.org/wiki/Bonjour_(software)){:.external} by Apple) to discover hosts. On a minimal
setup, it may not be installed (`sudo apt-get install avahi-daemon`).



## or the good old method

Here is how to find a device IP address on a DHCP network, knowing only it's MAC address, an open TCP port
and our own IP on the network.

 - Look at the device MAC address, here I'm searching for a raspberry PI, so I know it will start with 88:a2:9e[*](#rpi-mac).
 - Put the empty file named ssh on the boot partition of the raspberry PI to enable ssh.
 - Detect a host running ssh on the network:
```bash
nmap -p 22 --open X.X.X.0/24
```
 - Search the know host in the ARP table:
```bash
arp -a | grep 88:a2:9e
? (X.X.X.95) at 88:a2:9e:YY:YY:YY [ether] on br0
```

## Known Rapberry Pi OUIs (Organizationally Unique Identifiers) {#rpi-mac}
Did you say MAC address? Here is how to find all possible

```bash
user@host:/anywhere$ sudo update-ieee-data
...
user@host:/anywhere$ cat /var/lib/ieee-data/oui.txt | grep -i hex | grep -i "Raspberry Pi"
D8-3A-DD   (hex)		Raspberry Pi Trading Ltd
DC-A6-32   (hex)		Raspberry Pi Trading Ltd
E4-5F-01   (hex)		Raspberry Pi Trading Ltd
88-A2-9E   (hex)		Raspberry Pi (Trading) Ltd
28-CD-C1   (hex)		Raspberry Pi Trading Ltd
B8-27-EB   (hex)		Raspberry Pi Foundation
2C-CF-67   (hex)		Raspberry Pi (Trading) Ltd
user@host:/anywhere$
```
