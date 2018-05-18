---
layout: post
title: ssh keepalive
tags: ximport ubuntu ssh
permalink: /pages/ssh-keepalive.html
---
The remote ssh server may disconnect a idle connection. To prevent that, it's possible to send keepalive from
the client site, by editing `/etc/ssh/ssh_config` or `~/ssh/config`:

```
Host *
ServerAliveInterval 240
```