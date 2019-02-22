---
layout: post
title: 'rsync over ssh to Android'
tags: ubuntu 18.04 android rsync ssh
permalink: server-18.04-apache.html
#image: /data/img/wide/www.jpg
---

I have tried many ways to sync my music collection to my Android phone, and here
is the most comfortable way I could find : the good old `rsync`.

## Setup
 - Install Paul Lutus's `SSHelper`, from the [android play store](){:.external},
   or directly from the [homepage](https://arachnoid.com/android/SSHelper/index.html){:.external}.
 - Run it
   - Follow the instructions to enable write access to the Android device.
   - Set a password
   - Optional:
     - Disable all unneeded options (log display server, clipboard server, ..)
   - Note that the default port is **2222**.
 - Copy your ssh key from your host, let's suppose `phone` is the DNS name or the
   IP of your phone, this time it will ask for a password.

   There is no need to set the `ssh` username, `SSHelper` will ignore it.
   ```
   ssh-copy-id phone -p 2222
   ```
 - Test that password-less login are ok:
    ```
    ssh phone -p 2222
    ```
 - Disable password logins in `SSHelper`.

## Optional : data access for removable SD card.
 - Stop `SSHelper`
 - Eject the SD card (Settings > Storage > Eject).
 - Get the card on your computer and create the directory `/Android/data/com.arachnoid.sshelper/`
 - Put the card back into the Android device.
 - Start `SSHelper`
 - Find the external SD card mount point:
```
ssh phone -p 2222
asdf@phone:~$ ls /media
SoMeRaNdOM_NaMe # <- this is the mount point
emulated
self
asdf@phone:~$ exit
```

## Copying/updating files
 - Start `SSHelper`
 - Run :
    ```
    #!/bin/bash
    RPATH="phone:/storage/SoMeRaNdOM_NaMe/Android/data/com.arachnoid.sshelper"
    OPTIONS=()
    OPTIONS+=("--modify-window=2")
    OPTIONS+=("--update")
    OPTIONS+=("--times")
    OPTIONS+=("--size-only")
    OPTIONS+=("--delete-before")

    rsync -av "${OPTIONS[@]}" -e "ssh -p 2222" /somewhere/mp3-from-flac "$RPATH"
    rsync -av "${OPTIONS[@]}" -e "ssh -p 2222" /somewhere/mp3 "$RPATH"
    ```

## mp3-from-flac
Did you notice the `mp3-from-flac` directory? Since I don't need losless
quality on my phone (and in my car), I generate `mp3` from `flac` files,
using this script : [`flac2mp3.sh`](https://github.com/RandomReaper/scripts/blob/master/flac2mp3/flac2mp3.sh){:.external} (conversion in parallel and only when needed).
