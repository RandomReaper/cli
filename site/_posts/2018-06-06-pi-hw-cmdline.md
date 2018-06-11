---
layout: post
title: Identifying a Raspberry PI version from the command line
tags: raspberry
permalink: pi-hw-cmdline.html
---

# Getting the revision \#

```console
pi@some-random-pi:~$ cat /proc/cpuinfo | grep Revision
Revision	: a01041
```

# Revision list
(from [here](https://www.raspberrypi.org/documentation/hardware/raspberrypi/revision-codes/README.md){:.external})

|Code	|Model |	Revision |	RAM	| Manufacturer |
|-|-|-|-|
|0002	|B					|1.0	|256 MB	|Egoman |
|0003	|B					|1.0	|256 MB	|Egoman |
|0004	|B					|2.0	|256 MB	|Sony UK |
|0005	|B					|2.0	|256 MB	|Qisda |
|0006	|B					|2.0	|256 MB	|Egoman |
|0007	|A					|2.0	|256 MB	|Egoman |
|0008	|A					|2.0	|256 MB	|Sony UK |
|0009	|A					|2.0	|256 MB	|Qisda |
|000d	|B					|2.0	|512 MB	|Egoman |
|000e	|B					|2.0	|512 MB	|Sony UK |
|000f	|B					|2.0	|512 MB	|Egoman |
|0010	|B+					|1.0	|512 MB	|Sony UK |
|0011	|CM1				|1.0	|512 MB	|Sony UK |
|0012	|A+					|1.1	|256 MB	|Sony UK |
|0013	|B+					|1.2	|512 MB	|Embest |
|0014	|CM1				|1.0	|512 MB	|Embest |
|0015	|A+					|1.1	|256 MB / 512 MB	|Embest |
|900021	|A+					|1.1	|512 MB	|Sony UK |
|900032	|B+					|1.2	|512 MB	|Sony UK |
|900092	|Zero				|1.2	|512 MB	|Sony UK |
|900093	|Zero				|1.3	|512 MB	|Sony UK |
|9000c1	|Zero W				|1.1	|512 MB	|Sony UK |
|920093	|Zero				|1.3	|512 MB	|Embest |
|a01040	|2B					|1.0	|1 GB	|Sony UK |
|a01041	|2B					|1.1	|1 GB	|Sony UK |
|a02082	|3B					|1.2	|1 GB	|Sony UK |
|a020a0	|CM3				|1.0	|1 GB	|Sony UK |
|a21041	|2B					|1.1	|1 GB	|Embest |
|a22042	|2B (with BCM2837)	|1.2	|1 GB 	| Embest |
|a22082	|3B					|1.2	|1 GB	|Embest |
|a32082	|3B					|1.2	|1 GB	|Sony Japan |
|a52082	|3B					|1.2	|1 GB	|Stadium |
|a020d3	|3B+				|1.3	|1 GB	|Sony UK |	