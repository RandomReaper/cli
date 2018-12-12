---
layout: post
title: "`snapper` quotas"
tags: ubuntu 18.04 hw2018 server btrfs snapper
permalink: server-18.04-snapper-quotas.html
image: /data/img/wide/disk.jpg
---

Today I want to test the status of quotas (displaying size of snapshots) using
`snapper`. This feature is available since snapper 0.6, and the [18.04](/tag/18.04.html)
only provides 0.5.4.

# SW setup
```
sudo apt-get remove snapper
sudo mkdir -p /etc/sysconfig/
echo SNAPPER_CONFIGS="root home var-log" | sudo tee /etc/sysconfig/snapper

sudo apt-get install build-essential automake libtool libmount-dev libdbus-1-dev libacl1-dev libxml2-dev libboost-system-dev libboost-thread-dev libext2fs-dev libpam0g-dev xsltproc docbook-xsl gettext
cd && mkdir -p git && cd git && git clone https://github.com/openSUSE/snapper.git
cd snapper
make -f Makefile.repo
make -j9
sudo killall snapperd
sudo make install
```

# `snapper` setup
```
sudo btrfs quota enable /
sudo btrfs quota enable /var/log/
sudo btrfs quota enable /home
```

# Enjoy
```
snapper -c home list
 # | Type   | Pre # | Date                            | User | Used Space | Cleanup  | Description | Userdata
---+--------+-------+---------------------------------+------+------------+----------+-------------+---------
0  | single |       |                                 | root |            |          | current     |         
1  | single |       | Wed 12 Dec 2018 10:17:01 AM CET | root |   4.55 MiB | timeline | timeline    |         
```