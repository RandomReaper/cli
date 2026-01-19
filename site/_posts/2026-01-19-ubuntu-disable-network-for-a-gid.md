---
layout: post
title: "Disable network access for a group of users"
tags: ubuntu 24.04
permalink: /pages/ubuntu-disable-network-for-a-gid.html
---

It may be needed to prevent network access for some users, for security or while
proctoring students. Here is how this can be achieved.

## Add the user  to the `nonet` group
```bash
# create the nonet group
sudo groupadd -g FREE_GID nonet # If you don't care about the GID : sudo groupadd nonet

# add the user THE_USER to the group
sudo usermod -a -G nonet THE_USER
```

## Create the service file /etc/systemd/system/nonet-for-group-nonet.service
```properties
[Unit]
Description=Disable network for group nonet

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=iptables -A OUTPUT -o lo -p all -m owner --gid-owner nonet --suppl-groups -j ACCEPT
ExecStart=iptables -A OUTPUT -p all -m owner --gid-owner nonet --suppl-groups -j REJECT
ExecStart=ip6tables -A OUTPUT -o lo -p all -m owner --gid-owner nonet --suppl-groups -j ACCEPT
ExecStart=ip6tables -A OUTPUT -p all -m owner --gid-owner nonet --suppl-groups -j REJECT

ExecStop=iptables -D OUTPUT -o lo -p all -m owner --gid-owner nonet --suppl-groups -j ACCEPT
ExecStop=iptables -D OUTPUT -p all -m owner --gid-owner nonet --suppl-groups -j REJECT
ExecStop=ip6tables -D OUTPUT -o lo -p all -m owner --gid-owner nonet --suppl-groups -j ACCEPT
ExecStop=ip6tables -D OUTPUT -p all -m owner --gid-owner nonet --suppl-groups -j REJECT

[Install]
WantedBy=multi-user.target
```

## Reload services
```bash
sudo systemctl daemon-reload
```

## Test network for user THE_USER (SHOULD work fine):

```bash
sudo -u THE_USER curl -I https://cli.pignat.org/pages/ubuntu-disable-network-for-a-gid.html
HTTP/1.1 200 OK
...
```
## Start the service
  * `sudo systemctl start` to disable network access for
  * `sudo systemctl enable` to disable network access at boot
  * `sudo systemctl stop` to allow network access

## Test network for user THE_USER (SHOULD NOT work):
```bash
sudo -u THE_USER curl -I https://cli.pignat.org/pages/ubuntu-disable-network-for-a-gid.html
curl: (7) Failed to connect to cli.pignat.org port 443 after 2 ms: Couldn't connect to server
```

:warning: `ping` will still work because it is installed with `setuid` root on Debian-based distributions.
