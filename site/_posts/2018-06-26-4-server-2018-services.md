---
layout: post
title: Services
tags: ubuntu 18.04 hw2018 systemd
permalink: server-18.04-services.html
#image: /data/img/wide/www.jpg
---

Services are programs that can be run without user intervention. On ubuntu, they
are managed by [`systemd`](/tag/systemd.html).

[`systemd`](/tag/systemd.html) provides a standardized way to manage (start,
stop, getting status, ...) services.

Most services are provided by their installation pacakges, but it's possible to
create custom services, as explained in [this post](/server-18.04-custom-services.html).

## `systemctl` ([man page](https://www.freedesktop.org/software/systemd/man/systemctl.html){:.external})
`systemctl` is the tool to manage services. It is typically used when `service`
or `/etc/init.d/SERVICENAME` was used in [`sysvinit`](https://en.wikipedia.org/wiki/Init){:.external}
based systems.

## Getting the status
Example for the ssh service:
```
● ssh.service - OpenBSD Secure Shell server
   Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2018-06-26 19:28:22 CEST; 17min ago
 Main PID: 950 (sshd)
    Tasks: 1 (limit: 4630)
   CGroup: /system.slice/ssh.service
           └─950 /usr/sbin/sshd -D

Jun 26 19:28:22 server systemd[1]: Starting OpenBSD Secure Shell server...
Jun 26 19:28:22 server sshd[950]: Server listening on 0.0.0.0 port 22.
Jun 26 19:28:22 server sshd[950]: Server listening on :: port 22.
Jun 26 19:28:22 server systemd[1]: Started OpenBSD Secure Shell server.
Jun 26 19:28:55 server sshd[1182]: Accepted publickey for pim from X.X.X.X port X ssh2: RSA SHA256:X/X
Jun 26 19:28:55 server sshd[1182]: pam_unix(sshd:session): session opened for user pim by (uid=0)
```

## Start/stop/enable/disable/...

| Command | Effect |
| - | - |
| `sudo systemctl daemon-reload` | Reload systemd configuration, MUST be done after each `.service` file change |
| `sudo systemctl start SERVICE` | Start a service |
| `sudo systemctl stop SERVICE` | Stop a service |
| `sudo systemctl enable SERVICE` | Enable a service, the service will be automatically started |
| `sudo systemctl disable SERVICE` | Disable a service |
| `sudo systemctl enable SERVICE --now` | Enable and start a service, the service will be automatically started |
| `sudo systemctl disable SERVICE --now` | Disable and stop a service |
| `sudo systemctl restart SERVICE --now` | Restart a service |
| `sudo systemctl reload SERVICE --now` | Reload a service (only if reload is implemented) |
| `sudo systemctl reload-or-restart SERVICE --now` | Reload a service if reload is implemented, restart otherwise |

## Listing services
```console
systemctl list-units --type=service
 UNIT                       LOAD   ACTIVE SUB     DESCRIPTION                                                                  
  accounts-daemon.service   loaded active running Accounts Service                                                             
  apparmor.service          loaded active exited  AppArmor initialization                                                      
  apport.service            loaded active exited  LSB: automatic crash report generation                                       
  atd.service               loaded active running Deferred execution scheduler                                                 
  blk-availability.service  loaded active exited  Availability of block devices              
...
```

## Listing enabled services
```
systemctl list-units --type=service --state=active
UNIT                        LOAD   ACTIVE SUB     DESCRIPTION                                                                  
accounts-daemon.service     loaded active running Accounts Service                                                             
apparmor.service            loaded active exited  AppArmor initialization                                                      
apport.service              loaded active exited  LSB: automatic crash report generation                                       
atd.service                 loaded active running Deferred execution scheduler                                                 
blk-availability.service    loaded active exited  Availability of block devices                                                
...
```

## Listing running services
```
systemctl list-units --type=service --state=running
UNIT                        LOAD   ACTIVE SUB     DESCRIPTION                                 
accounts-daemon.service     loaded active running Accounts Service                            
atd.service                 loaded active running Deferred execution scheduler                
cron.service                loaded active running Regular background program processing daemon
dbus.service                loaded active running D-Bus System Message Bus                    
...
```

The next post is about [custom services](/server-18.04-custom-services.html).
