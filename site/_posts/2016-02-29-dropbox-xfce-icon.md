---
layout: post
title: Dropbox icon and ubuntu 15.10
tags: ximport ubuntu 15.10 16.04 18.04 xfce dropbox syncthing
permalink: /pages/usb-bad-install-disk.html
---

***This page is about dropbox, but as you may have noticed this page has the flag*** [syncthing](/tag/syncthing.html){:.set-1}***, because syncthing is an interesting [FOSS](https://en.wikipedia.org/wiki/Free_and_open-source_software){:.external} alternative.***

***EDIT: This issue has been fixed in [18.04](/tag/18.04.html)***

No more dropbox icon?

Stop Dropbox:
```
dropbox stop
```

edit ~/.dropbox-dist/dropboxd and add `export DBUS_SESSION_BUS_ADDRESS=""` the line after `#!/bin/sh`:

```
#!/bin/sh
export DBUS_SESSION_BUS_ADDRESS=""
PAR=$(dirname "$(readlink -f "$0")")
exec "$PAR/dropbox-lnx.x86_64-49.4.69/dropboxd" "$@"
```

Then restart dropbox:
```
dropbox start
```