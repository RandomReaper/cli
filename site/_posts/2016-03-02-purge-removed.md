---
layout: post
title: Purge removed packages
tags: ximport ubuntu apt
permalink: /pages/deb-purge-removed.html
---

`apt-get remove` does not remove all files, packages must be purged.

 - using `aptitude`:
```
sudo aptitude purge '~c'
```
 - without `aptitude`:
```
sudo dpkg -P $(dpkg -l | awk '/^rc/ { print($2) }')
```