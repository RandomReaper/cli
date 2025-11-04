---
layout: post
title: "`ssh` configuration"
tags: ubuntu ssh xsuperseded
permalink: /pages/ssh-config-v0.html
image: /data/img/wide/tab.jpg
---

The default `ssh` configuration shipped with your distribution may not be ideal.
Here are some tweaks I use:

## Idle connection

The remote ssh server (or a router/firewall in-between) may disconnect an idle
connection. To prevent that, it's possible to send keep-alive from
the client site, by editing `/etc/ssh/ssh_config` or `~/ssh/config`:

```
Host *
...
ServerAliveInterval 240
...
```

## `known_host` and changing IP
IP addresses may be re-used on some networks, and storing the server fingerprint with the IP address
can be disabled.
```
Host *
...
CheckHostIP no
...
```

## Locales

Using your local [locale](/tag/locale.html) on a remote system may not be desirable.
To prevent your host from sending the locale edit `/etc/ssh/ssh_config` (or your user's `~/.ssh/config`)
and and remove LANG and LC_* from the sent variables :
```
#SendEnv LANG LC_*
```

To prevent the remote machine form accepting the locale edit `/etc/ssh/sshd_config` (dont' forget the **d**)
and remove LANG and LC_* from the accepted environment variable:
```
#AcceptEnv LANG LC_*
```
