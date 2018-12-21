---
layout: post
title: "`gpg` encrypt/decrypt with a passphrase"
tags: ubuntu gpg rfc2119
permalink: gpg-private-key.html
#image: /data/img/wide/disk.jpg
---

Sometimes you've got some files that you don't want to lose, for instance
private keys (think of [`gpg`](/tag/gpg.html) and Google authenticator), so I store them in
multiple places (to be sure that I won't lose the file) and **encrypted** since
I can't keep an eye on every place I put my files.

## HW setup
0. Put your favorite security conscious live Linux distribution on a USB key.
0. Put your keys.tar.gz.gpg on it (if you have already done this HOWTO once).
0. Boot this key on a computer you trust. It should have no network
(Ethernet/Wifi/4G/Bluetooth) connection, and ideally no local storage.

## First time
0. Boot on your trusted computer with your trusted boot media.
0. Create a directory.
```
mkdir keys
```
0. Put your keys into it (your command line [MAY](/tag/rfc2119.html) differ a bit).
```
echo "Happy holidays" > keys/key1.txt
```
0. Encrypt all your keys. `gpg` will ask you a passphrase twice, **don't forget it**!
```
tar cvzf - keys | gpg --cipher-algo AES256 -c -o keys.tar.gz.gpg
keys/
keys/key1.txt
```
0. Destroy the unencrypted keys:
```
rm keys -rf
```
0. Now store `keys.tar.gz.gpg`.

## Key recovery or update
0. Boot on your trusted computer with your trusted boot media.
0. Recover you keys, `gpg` will ask for your passphrase
```
gpg -d < keys.tar.gz.gpg | tar xvzf -
keys/
keys/key1.txt
```
0. Use/update/... your keys
```
cat keys/key1.txt
Happy holidays
```
0. Encrypt all your keys. `gpg` will ask you a passphrase twice, **don't forget it**!
```
tar cvzf - keys | gpg --cipher-algo AES256 -c -o keys.tar.gz.gpg
keys/
keys/key1.txt
```
0. Destroy the unencrypted keys:
```
rm keys -rf
```
0. Now store `keys.tar.gz.gpg`.