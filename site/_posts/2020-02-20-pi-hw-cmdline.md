---
layout: post
title: 'Get the Raspberry Pi model from the command line (update #1)'
tags: raspberry
permalink: pi-hw-cmdline.html
---

Don't want to open the case of a Raspberry Pi to find it's model? or are you
connected trough `ssh`? Here is how to identify your Pi from the command line!


## Identification \#

```console
pi@some-random-pi:~$ cat /sys/firmware/devicetree/base/model
Raspberry Pi 3 Model B Rev 1.2
```

*The old version of this post using revision number lies [here](pi-hw-cmdline-v0.html).*
