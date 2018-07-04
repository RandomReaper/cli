---
layout: post
title: Offline notification
tags: ubuntu 18.04 16.04 raspberry openwrt server telegram
permalink: telegram-offline-notification.html
---

As we've seen in the [last post](/server-18.04-zabbix-grafana.html),
[zabbix](/tag/zabbix.html) is now monitoring our system, and sends alerts as
emails but what if the zabbix server crashes or loose internet connectivity?
Here comes [@PimOnlineBot](https://telegram.me/PimOnlineBot){:.external}.

# PimOnlineBot
[@PimOnlineBot](https://telegram.me/PimOnlineBot){:.external} is a
[telegram](/tag/telegram.html) bot that will send you a message when your host
is offline.

I have written PimOnlineBot since I could not find any other service like that,
the sources are [here](https://github.com/RandomReaper/OnlineBot){:.external},
and like the sources, the bot is free to use.

## Principle of Operation
Using `cron` and `wget`, the host periodically tells the bot that it is online.
Using that information, the bot will send a message when there is a problem.

Since the resources are not unlimited on this server, messages are only sent for
host updating once every 5 minutes or less often.

## Setup for one host
- Install and activate telegram on your phone.
- Open a chat with [@PimOnlineBot](https://telegram.me/PimOnlineBot){:.external}.
- Click the `/start` button.
- Ask for `/help`.

## Setup for monitoring the zabbix server
- Login the zabbix's web UI
- Configuration > hosts > zabbix server > Web scenario > Create web scenario
  - Scenario tab:
  	- Name : PimOnlineBot
  	- Application : General
  	- Update interval : 5m
  - Steps tab:
  	- Add (a new step)
  		- Name : update status
  		- URL : copy the https URL from the `/help` cron job
  		- ***Parse***
  		- Required status codes : 200
  		- Add (the step)
  	- Add (the web scenario)

## Setup for non-zabbix server
This one works on any Linux connected to the internet with cron and wget with
support for https, tested on [raspberry](/tag/raspberry.html),
[openwrt](/tag/openwrt.html)(may require some setup for wget+https),
[ubuntu](/tag/ubuntu.html), ... and even on a [Lorix One LoraWAN antenna](){:.external}.

- Log into your Linux
Add the line cron job from the `/help` command:
```
5 * * * * wget -q https://pimonlinebot.pignat.org/index.php?uid=UID_FROM_HELP -O /dev/null
```

## Registering the machine
Run this command in the [@PimOnlineBot](https://telegram.me/PimOnlineBot){:.external} chat,
using the uuid from the `/help` command and your server name:

```
/register UID_FROM_HELP server-test-setup
```

If the response is `error: server 'XXX' not found`, wait for your update command
to be run at least once.

The normal reply should be :
```
success: host server-test-setup (XXX) registered
```

The `/list` list the host you've registered :
```
Host server-test-setup (XXX) is up. (update interval : 300 seconds, age : 187 seconds).
Host another-host (YYY) is down (last update : 429613 seconds ago).
```

## Testing (zabbix server version)
On the zabbix web UI:
* Configuration > hosts > zabbix server > Web scenario > PimOnlineBot > click
on "enable" to disable
* wait 6 minutes
* receive this message on telegram:
```
error: Host server-test-setup is offline
```
* Configuration > hosts > zabbix server > Web scenario > PimOnlineBot > click on
"disable" to re-enable.
* receive this message on telegram:
```
info: Host server-test-setup is online
```

## Testing (non-zabbix version)
* Edit the crontab, put a # at the beginning of the PimOnlineBot cron job line.
* wait 6 minutes
* receive this message on telegram:
```
error: Host server-test-setup is offline
```
* Edit the crontab, remove the # at the beginning of the PimOnlineBot cron job
line.
* receive this message on telegram:
```
info: Host server-test-setup is online
```

