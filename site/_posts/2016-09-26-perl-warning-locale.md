---
layout: post
title: "perl: warning: Setting locale failed."
tags: ximport ubuntu
permalink: /pages/perl-warning-locale.html
---

You're connecting through ssh and your remote machine complains about the locale?

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

This is because your local machine is configured with a different locale than the remote and ssh is forwarding those settings.

To find which one you're using, you can use (on the remote machine):

```bash
set | grep ^LC | cut -d "=" -f 2 | sort | uniq
```

then fix the problem by generating the missing locale (still on the remote machine), in my case:

```
sudo locale-gen fr_CH.UTF-8 de_CH.UTF-8
```