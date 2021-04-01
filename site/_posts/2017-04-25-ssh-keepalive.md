---
layout: post
title: ssh keepalive
tags: ximport ubuntu ssh xsuperseded
permalink: /pages/ssh-keepalive.html
---

**This post has been included in a more [recent one](/pages/ssh-config.html).**

The remote ssh server may disconnect a idle connection. To prevent that, it's possible to send keepalive from
the client site, by editing `/etc/ssh/ssh_config` or `~/ssh/config`:

```
Host *
ServerAliveInterval 240
```
