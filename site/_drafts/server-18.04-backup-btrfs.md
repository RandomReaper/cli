---
layout: post
title: ubuntu 18.04 server btrfs backup
tags: ubuntu 18.04 hw2018 server backup btrfs snapper
permalink: server-18.04-backup-btrfs.html
image: /data/img/wide/disk.jpg
---

While writing the previous posts, I ***lied***. Backup are OK at home, but not
on my virtual server that I use for writing this blog.

So while [growing my RAID](/server-18.04-growing-raid-lvm.html), I removed one
disk from the array using `mdadm` and I physically removed the other. That one
that was expected to stay in the array...

So I had a look at all my post about the [server](/tag/server.html) and I have
redone the full install.

# Tools
Those tools have been especially designed to play well with [snapper](/tag/snapper.html).

## [buttersink](https://github.com/AmesCornish/buttersink)
Works but because of [issue #50](https://github.com/AmesCornish/buttersink/issues/50)
about wrong orders of snapshots, btrfs can not benefit of the [CoW](https://en.wikipedia.org/wiki/Copy-on-write){:.external}
feature, and thus use a lot of space. **Unusable**.

## [snapsync](https://github.com/doudou/snapsync)
```console
sudo /opt/snapsync/bin/snapsync auto-sync
/opt/snapsync/bundle/ruby/2.5.0/gems/ruby-dbus-0.11.2/lib/dbus/marshall.rb:301: warning: constant ::Fixnum is deprecated
Traceback (most recent call last):
	10: from /opt/snapsync/bin/snapsync:14:in `<main>'
	 9: from /opt/snapsync/bin/snapsync:14:in `load'
	 8: from /opt/snapsync/bundle/ruby/2.5.0/gems/snapsync-0.3.8/bin/snapsync:4:in `<top (required)>'
	 7: from /opt/snapsync/bundle/ruby/2.5.0/gems/thor-0.19.4/lib/thor/base.rb:444:in `start'
	 6: from /opt/snapsync/bundle/ruby/2.5.0/gems/thor-0.19.4/lib/thor.rb:369:in `dispatch'
	 5: from /opt/snapsync/bundle/ruby/2.5.0/gems/thor-0.19.4/lib/thor/invocation.rb:126:in `invoke_command'
	 4: from /opt/snapsync/bundle/ruby/2.5.0/gems/thor-0.19.4/lib/thor/command.rb:27:in `run'
	 3: from /opt/snapsync/bundle/ruby/2.5.0/gems/snapsync-0.3.8/lib/snapsync/cli.rb:296:in `auto_sync'
	 2: from /opt/snapsync/bundle/ruby/2.5.0/gems/snapsync-0.3.8/lib/snapsync/auto_sync.rb:29:in `load_config'
	 1: from /opt/snapsync/bundle/ruby/2.5.0/gems/snapsync-0.3.8/lib/snapsync/auto_sync.rb:29:in `read'
/opt/snapsync/bundle/ruby/2.5.0/gems/snapsync-0.3.8/lib/snapsync/auto_sync.rb:29:in `read': No such file or directory @ rb_sysopen - /etc/snapsync.conf (Errno::ENOENT)
```
**Unusable.**

## [snap-sync](https://github.com/wesbarnett/snap-sync)
My last candidate. It should test it some day, but in the meantime, I will take
a real backup using the good old `rsync`.

# My own backup script

## First backup
Take an empty disk, then create one partition on it:
```console
sudo apt-get install gdisk
sudo sgdisk -Z /dev/vdg
sudo sgdisk -p /dev/vdg
sudo sgdisk -n1 /dev/vdg
```
Create a btrfs filessytem on it : 
```console
sudo mkfs.btrfs /dev/vdg1
```

Mount it:
```console
sudo mkdir -p /mnt/backup
sudo mount /dev/vdg1 /mnt/backup -o noatime
```

Initialize backup for all snapper targets:

```console
/opt/snapsync/bin/snapsync init /mnt/backup/
```
