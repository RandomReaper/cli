---
layout: post
title: ubuntu root on LVM over RAID1 degraded boot
tags: ubuntu 16.04 18.04 ximport raid-lvm
permalink: /pages/lvm-raid-degraded-boot.html
---

## `BOOT_DEGRADED` has no effect when using LVM
It seems that using LVM over RAID will always try to boot, no matter how `BOOT_DEGRADED` is configured.
Removing a disk from the running system will put the array in degraded state, and a reboot at this point will work fine, even if this is somehow risky to boot on a degraded array.

## Disk cold-remove
Removing the disk when the machine is not powered will prevent boot, at least on [18.04](/tag/18.04.html), dumping to the shell in the initramfs.

Array inspection (with `mdadm --detail /dev/mdX`) will show the degraded array, **as expected**.

Rebooting at this point will dump to the initramfs shell again.
For forcing the boot on the degraded array:  run `mdadm --readwrite /dev/mdX then reboot`.
To fix the array, plug a new disk, add it with `mdadm --manage /dev/mdX --add /dev/sdXy`, then wait the sync to finish, then reboot.

A new disk may require a partition table, and this partition table can be copied from another active member of the array: `dd if=/dev/used_disk of=/dev/new_disk count=4096`