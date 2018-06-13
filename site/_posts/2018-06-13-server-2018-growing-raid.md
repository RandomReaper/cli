---
layout: post
title: Growing RAID+LVM+filesystem
tags: ubuntu 18.04 hw2018 server raid-lvm
permalink: server-18.04-growing-raid-lvm.html
image: /data/img/wide/disk.jpg
---
My `/` partition is too small, fortunately it is on LVM+RAID, and it's possible to
resize it without downtime!

# Background
In the first [post](ubuntu-18.04-server-install-snapper.html) of this series 
about the [server](/tag/server.html), I thought 4GB will be enough for `/` on my
virtual test server, and I was wrong.

```console
cli@server:~$ df -h /
Filesystem             Size  Used Avail Use% Mounted on
/dev/mapper/root-root  3.9G  3.5G  334M  92% /
```

# Zero downtime
As always, I assume the [backup](/tag/backup.html) is working fine and is
up-to-date. Since my hardware and software is hot-plug capable, let's do it:

## Let's get some information about the system.

`df` has shown the device name `/dev/mapper/root-root`, `pvdisplay` will show
the *VG* (*volume group*) :
```console
sudo lvdisplay /dev/mapper/root-root
  --- Logical volume ---
  LV Path                /dev/root/root
  LV Name                root
  VG Name                root
  LV UUID                5DQ9sX-Uha0-CwGk-ETDw-ZKRX-31Ky-rQynrY
  LV Write Access        read/write
  LV Creation host, time server-test-setup, 2018-05-18 14:16:52 +0200
  LV Status              available
  # open                 1
  LV Size                <3.88 GiB
  Current LE             992
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     2048
  Block device           253:0
```
The *VG* is named **root**, and `vgdisplay` will show the *PV* (*physical volume*)
behind it:
```
sudo pvdisplay
  --- Physical volume ---
  PV Name               /dev/md1
  VG Name               data
  PV Size               3.99 GiB / not usable 2.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              1022
  Free PE               0
  Allocated PE          1022
  PV UUID               p6S3mh-bIzz-ZJdJ-cLTr-4zdv-z2wY-cl8Me1
   
  --- Physical volume ---
  PV Name               /dev/md0
  VG Name               root
  PV Size               <3.88 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              992
  Free PE               0
  Allocated PE          992
  PV UUID               McyzmG-C5jE-7Wsx-D131-1Lfz-oytN-h3K7jE
```
So `/dev/mapper/root-root` is physically on `/dev/md0`

Let's identify the disks used by `/dev/md0`, and make sure it is ***clean***:
```console
sudo mdadm --detail /dev/md0
/dev/md0:
        Version : 1.2
  Creation Time : Fri May 18 14:10:27 2018
     Raid Level : raid10
     Array Size : 4066304 (3.88 GiB 4.16 GB)
  Used Dev Size : 4066304 (3.88 GiB 4.16 GB)
   Raid Devices : 2
  Total Devices : 2
    Persistence : Superblock is persistent

    Update Time : Wed Jun 13 08:44:49 2018
          State : clean 
 Active Devices : 2
Working Devices : 2
 Failed Devices : 0
  Spare Devices : 0

         Layout : near=2
     Chunk Size : 512K

           Name : server-test-setup:0  (local to host server-test-setup)
           UUID : 2e89326f:5563e3a6:8c6b552b:e62c4dbf
         Events : 129

    Number   Major   Minor   RaidDevice State
       2     252        2        0      active sync set-A   /dev/vda2
       1     252       18        1      active sync set-B   /dev/vdb2
```
The array is clean and composed of *vda2* and *vdb2*, let's see if those disks
are in use for anything else:
```
mount | grep 'vda\|vdb'
/dev/vdb1 on /boot/efi type vfat (rw,relatime,fmask=0077,dmask=0077,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro)
```

Since my UEFI partition is on `/dev/vdb` it **MUST** be handled carefully.

## Let's do it
Summary:
 * `/` is full
 * `/` is on /dev/mapper/root-root
 * `/dev/mapper/root-root` is on `/dev/md0`
 * `/dev/md0` is ***clean***
 * `/dev/md0` is on `/dev/vda2` and `/dev/vdb2`
 * `/dev/vdb1` is used as UEFI partition (with a backup on `/dev/vda1`)

### Growing the RAID array

#### Replace the first disk
* Since the array is clean and `/dev/vdb` holds the UEFI partition, let's remove
`/dev/vda` from the array:
```console
sudo mdadm /dev/md0 --fail /dev/vda2
sudo mdadm /dev/md0 --remove /dev/vda2
```
* Remove the disk and put a new one, since I'm in a virtual machine the new disk
is still *vda*, but it may change, see `lsblk` for more info.
* Copy the partition scheme and grow the RAID partition on the new disk
```console
sudo apt-get install gdisk
sudo sgdisk /dev/vdb -R /dev/vda
echo ", +" | sudo sfdisk -N 2 /dev/vda
sudo mdadm /dev/md0 --add /dev/vda2
```
* Copy UEFI partition : 
```
sudo dd if=/dev/vdb1 of=/dev/vda1
```
* Wait for the array to rebuild
```
sudo mdadm --wait /dev/md0
```

#### Replace the second disk
* umount the uefi partition
```
sudo umount /dev/vdb1
```
* remove the `/dev/vdb` from the array
```console
sudo mdadm /dev/md0 --fail /dev/vdb2
sudo mdadm /dev/md0 --remove /dev/vdb2
```
* Remove the disk and put a new one, since I'm in a virtual machine the new disk
is still *vdb*, but it may change, see `lsblk` for more info.
* Copy the partition scheme
```console
sudo sgdisk /dev/vda -R /dev/vdb
sudo mdadm /dev/md0 --add /dev/vdb2
```
* Copy UEFI partition : 
```console
sudo dd if=/dev/vda1 of=/dev/vdb1
```
* Remount it
```console
sudo mount -a
```

* Wait for the array to rebuild
```console
sudo mdadm --wait /dev/md0
```
* Grow the array:
```console
sudo mdadm /dev/md0 --grow --size=max
```
* Wait for the array to rebuild
```console
sudo mdadm --wait /dev/md0
```

### Growing the LVM partition
* Grow the PV
```console
sudo pvresize /dev/md0
  Physical volume "/dev/md0" changed
  1 physical volume(s) resized / 0 physical volume(s) not resized
```
* Grow the LV
```console
sudo lvresize -l +100%FREE /dev/mapper/root-root
  Size of logical volume root/root changed from <3.88 GiB (992 extents) to <7.88 GiB (2016 extents).
  Logical volume root/root successfully resized.
```

### Growing the filesystem
* Grow the filesystem
```
sudo btrfs filesystem resize max /
Resize '/' of 'max'
```
* Verification:
```console
Filesystem             Size  Used Avail Use% Mounted on
/dev/mapper/root-root  7.9G  3.7G  4.2G  48% /
```

# Final verification
Since we've changed the disk holding the boot (UEFI) partition, it's now a good
idea to check if our system can still boot (and on both disks), see [this post](/server-18.04-playing-with-raid.html#uefi-boot).