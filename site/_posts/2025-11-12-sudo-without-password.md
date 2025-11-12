---
layout: post
title: sudo without password
tags: ubuntu 20.04 server
permalink: /pages/sudo-without-password.html
---

It may be useful to run the `sudo` command without password, maybe you're lazy, maybe your account has no password, or [ssh](/tag/ssh.html) password authentication are not permitted.

## Passwordless login

***⚠ Here may be dragons!***


***⚠ While playing with the `sudoers` system, a small error MAY lock you outside of your system. This can prevent remote AND local logins. Always keep a `tty` connected logged in as root. ⚠***


0. Create the file `/etc/sudoers.d/50-sudonopass-group-passwordless`
```properties
# Users in the 'sudonopass' group don't need passwords
%sudonopass ALL=(ALL) NOPASSWD:ALL
```

0. Create the group `sudonopass`, if you know what a GID is, select a free one and, do that:
```bash
sudo groupadd -g FREE_GID sudonopass
```
or if you don't:
```bash
sudo groupadd sudonopass
```

0. Add the user to the group `sudonopass`
```bash
sudo usermod -a -G sudonopass the_user
```
