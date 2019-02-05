---
layout: post
title: Custom service using `screen`
tags: ubuntu 18.04 hw2018 systemd screen
permalink: server-18.04-custom-services-screen.html
image: /data/img/wide/tab.jpg
---

Here is how to start a systemd service running attached to a console (inside [screen](https://linux.die.net/man/1/screen){:.external}).

User services MUST be enabled before (see this post : [custom services](/server-18.04-custom-services.html)).

## A simple script
```bash
#!/bin/bash

while true
do
	echo "$0 pid:$$ ppid:$PPID user:$(id -un) group:$(id -g) parameters:'$@'"
	sleep 10
done
```
Saved in `~/bin/testservice-stdout`, and executable.

## The user service
```config
[Unit]
Description=myscript
After=network.target

[Service]
Type=forking
Restart=always
RestartSec=3
ExecStart=/usr/bin/screen -L -dmS testservice-screen %h/bin/testservice-stdout hello inside screen

[Install]
WantedBy=default.target
```
Saved in `~/.config/systemd/user/testservice-screen.service`

Then
```console
systemctl --user daemon-reload && systemctl --user start testservice-screen.service
```

And connect to `screen`:
```console
screen -R testservice-screen
...
/home/pim/bin/testservice-stdout pid:13329 ppid:13328 user:pim group:1000 parameters:'hello inside screen'
/home/pim/bin/testservice-stdout pid:13329 ppid:13328 user:pim group:1000 parameters:'hello inside screen'
...
```
