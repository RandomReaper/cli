---
layout: post
title: "`ssh` configuration"
tags: ubuntu ssh
permalink: /pages/ssh-config.html
image: /data/img/wide/tab.jpg
---

[here](ssh-config-v0.html){:.update}

The default `ssh` configuration shipped with your GNU/Linux distribution may not
be ideal. Here are some tweaks I use:

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
or from the server side by editing `/etc/ssh/sshd_config`
```
...
ClientAliveInterval 60
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

Using your local [locale](/tag/locale.html) on a remote system may not be desirable, the remote host may try to use your a non existent locale and display a lot of warnings, for instance:
```bash
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
 LANGUAGE = "en_US:en",
 LC_ALL = (unset),
 LC_TIME = "de_CH.UTF-8",
 LC_MONETARY = "de_CH.UTF-8",
 LC_ADDRESS = "de_CH.UTF-8",
 LC_TELEPHONE = "de_CH.UTF-8",
 LC_NAME = "de_CH.UTF-8",
 LC_MEASUREMENT = "de_CH.UTF-8",
 LC_IDENTIFICATION = "de_CH.UTF-8",
 LC_NUMERIC = "de_CH.UTF-8",
 LC_PAPER = "de_CH.UTF-8",
 LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("en_US.UTF-8").
locale: Cannot set LC_ALL to default locale: No such file or directory
```
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
