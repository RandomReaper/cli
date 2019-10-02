---
layout: post
title: "Find a device on the network, knowing it's MAC address"
tags: ximport ubuntu raspberry network
permalink: /pages/find-network-mac.html
---

Here is how to find a device IP address on a DHCP network, knowing only it's MAC address, an open TCP port
and our own IP on the network.

 - Look at the device MAC address, here I'm searching for a raspberry PI, so I know it will start with b8:27:eb.
 - Put the empty file named ssh on the boot partition of the raspberry PI to enable ssh.
 - Detect a host running ssh on the network : 
```bash
nmap -p 22 --open X.X.X.0/24
```
 - Search the know host in the ARP table:
```bash
arp -a | grep b8:27:eb
? (X.X.X.95) at b8:27:eb:YY:YY:YY [ether] on br0
```
