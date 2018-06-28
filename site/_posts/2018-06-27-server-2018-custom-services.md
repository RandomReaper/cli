---
layout: post
title: Custom services
tags: ubuntu 18.04 hw2018 systemd
permalink: server-18.04-custom-services.html
#image: /data/img/wide/www.jpg
---

They are many ways to start a program at boot time without user intervention,
let's have a look at it.

# A sample program
This program will write periodically to syslog it's name, parameters, user,
group, pid and parent pid. Let's save it in `/bin/testservice`

```
#!/bin/bash

while true
do
	logger "$0 pid:$$ ppid:$PPID user:$(id -un) group:$(id -g) parameters:'$@'"
	sleep 60
done
```
and make it executable
`sudo chmod +x /bin/testservice`

# Watching the result
```console
tail -f /var/log/syslog
```

## Manual testing
```console
pim@server:~$ testservice just testing the command line
CTRL-C
```

Result on syslog:
```
Jun 26 17:33:44 server pim: /bin/testservice pid:20232 ppid:1525 user:pim group:1000 parameters:'testing the command line'
```

<br /><br /><br />
## Using `/etc/rc.local` (**deprecated**)
Even though [ubuntu](/tag/ubuntu.html) switched to [`systemd`](/tag/systemd.html)
years ago, it's still possible to use `/etc/rc.local` to start a program at boot.

Edit (create) `/etc/rc.local`
```
#!/bin/sh -e
testservice from /etc/rc.local &

exit 0
```

Make it executable `sudo chmod +x /etc/rc.local` and reboot, result in syslog:
```
Jun 26 17:44:28 server root: /bin/testservice pid:938 ppid:1 user:root group:0 parameters:'from /etc/rc.local'
```
### Stopping
Find the pid using `ps ax | grep testservice`, then `sudo kill NUMBER`

### Disabling the script (won't stop it)
Remove the `/etc/rc.local` file.

<br /><br /><br />
## Using `cron @reboot`
Edit the crontab using `crontab -e`, the script will be run with the current user.

```config
# Edit this file to introduce tasks to be run by cron.
# 
# ...
# 
# m h  dom mon dow   command
@reboot testservice from crontab @reboot &
```
Reboot to test, result in syslog:

```
Jun 26 18:00:03 server pim: /bin/testservice pid:893 ppid:1 user:pim group:1000 parameters:'from crontab @reboot'
```
### Stopping
Find the pid using `ps ax | grep testservice`, then `sudo kill NUMBER`

### Disabling the script (won't stop it)
Remove the line using `crontab -e`.

<br /><br /><br />
## Using a systemd (system) service
Create the `/etc/systemd/system/testservice.service` file :
```config
[Unit]
Description=testservice 

[Service]
ExecStart=/bin/testservice from a systemd service

[Install]
WantedBy=multi-user.target
```

After each edit, tell `systemd` to reload the file : `sudo systemctl daemon-reload`,
then enable and start the service:`sudo systemctl enable testservice --now`

Result in syslog:
```
Jun 26 18:19:40 server root: /bin/testservice pid:1513 ppid:1 user:root group:0 parameters:'from a systemd service'
```

### Stopping
`sudo sytemctl stop testservice`

### Disabling the script (won't stop it)
`sudo sytemctl disable testservice`

### Disabling and stopping the script
`sudo sytemctl disable testservice --now`

### Running as a user
```
[Unit]
Description=testservice

[Service]
ExecStart=/bin/testservice from a systemd service testing as a user
User=pim
Group=pim

[Install]
WantedBy=multi-user.target
```

Testing : `sudo systemctl daemon-reload && sudo systemctl restart testservice`,
result in syslog:
```
Jun 26 18:26:17 server pim: /bin/testservice pid:1662 ppid:1 user:pim group:1000 parameters:'from a systemd service as a user'
```

[`systemd`](/tag/systemd.html) provides a lot of options like automatic restart
in case of crash, onehsot service, and a lot more, see [`man systemd.service`](http://manpages.ubuntu.com/manpages/bionic/en/man5/systemd.service.5.html){:.external}.

<br /><br /><br />
## Using a systemd (user) service

Enable the systemd service for the user : `sudo loginctl enable-linger pim`

Create the directory `mkdir -p ~/.config/systemd/user` then the file `~/.config/systemd/user/testservice.service` file :
```config
[Unit]
Description=testservice 

[Service]
ExecStart=/bin/testservice from a systemd user service

[Install]
WantedBy=default.target
```
Test it : `systemctl --user daemon-reload && systemctl --user enable testservice --now`, result in syslog:
```
Jun 26 19:15:17 server pim: /bin/testservice pid:2033 ppid:1077 user:pim group:1000 parameters:'from a systemd user service'
```

### Starting/Stopping/...
The standard `systemctl` command can be used, without `sudo` but with `--user`.

<br /><br /><br />
# Pros and cons of each method

| Method | Pros | Cons |
| - | - | - |
| /etc/rc.local | Simple | No simple way to start/stop/restart the service <br /> **Deprecated**|
| crontab @reboot | Simple <br /> No superuser action required <br /> | No simple way to start/stop/restart the service |
| systemd system service | Standard (simple) start/stop/restart/status/... | Complexity |
| systemd system service | Standard (simple) start/stop/restart/status/... <br /> Superuser action only required once (for loginctl enable-linger) | Complexity |