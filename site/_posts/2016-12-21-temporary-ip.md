---
layout: post
title: Add a temporary ip address to an existing interface
tags: ximport ubuntu
permalink: /pages/temporary-ip.html
---

```bash
ip addr add 192.168.1.6/24 dev eth0 label eth0:0
```
Old school version : 

```bash
ifconfig eth0:0 192.168.1.6 up
```