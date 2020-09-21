---
layout: post
title: "Zabbix : store history and trends into `influxdb`"
tags: zabbix grafana influxdb 20.04 18.04 16.04
permalink: /pages/zabbix-history-influxdb.html
---

I'm not particularly fond of [`influxdb`](/tag/influxdb.html), but since I know
it already and since any time-series database should work better than a standard SQL
database for time-series, let's try to store zabbix history into [`influxdb`](/tag/influxdb.html).

## Setup
0. Install [zabbix](/tag/zabbix.html).
0. Install [grafana](/tag/grafana.html).
0. Install [influxdb](/tag/influxdb.html) and configure authentication.
0. Install `go` and `pwgen`:
```bash
sudo apt-get install golang-go pwgen
```
0. Follow the chapter about your SQL database on [https://github.com/zensqlmonitor/influxdb-zabbix](https://github.com/zensqlmonitor/influxdb-zabbix){:.external}.
0. Connect to influx, create the `zabbix` database, with the `zabbix` user for writing and `zabbix_ro` user for read-only access (from grafana).
```bash
CREATE database zabbix
CREATE USER zabbix WITH PASSWORD 'use pwgen for that field and take a note'
CREATE USER zabbix_ro WITH PASSWORD 'use pwgen for that field and take another note'
GRANT ALL ON zabbix TO zabbix
GRANT READ on zabbix TO zabbix_ro
```

0. Create a user `zabbix-influx`
```bash
sudo useradd -g zabbix -d /var/lib/zabbix-influx zabbix-influx
sudo chown -R zabbix-influx:zabbix /var/lib/zabbix-influx
```
0. Using the `zabbix-influx` user, install `github.com/zensqlmonitor/influxdb-zabbix`
```bash
sudo -u zabbix-influx go get github.com/zensqlmonitor/influxdb-zabbix
sudo -u zabbix-influx cp go/src/github.com/zensqlmonitor/influxdb-zabbix/influxdb-zabbix.conf .
```
0. Configure influx credentials, and SQL access using `sudoedit /var/lib/zabbix-influx/influxdb-zabbix.conf`, make sure to configure influx and mysql URLs, databases, users and password.

## Testing
0. This command will run the influxd-zabbix in foreground:
```bash
sudo -u zabbix-influx -i
go build github.com/zensqlmonitor/influxdb-zabbix
go install github.com/zensqlmonitor/influxdb-zabbix
./go/bin/influxdb-zabbix
```
In fact, it will take all zabbix history and trends and put then into influx.
0. Go to grafana, configure a new source using influxdb, database:zabbix, user:zabbix_ro, ...
0. Still in grafana, create a new dashboard and test the new data source.
0. When all is working, kill `influxdb-zabbix` using <kbd>CTRL-C</kbd>.

## Service
Now that the zabbix to influx bridge is working, make sur it runs in background,
so data are pushed into influx as soon as they are in zabbix.

0. Reduce the verbosity and disable coloring for syslog: `sudoedit /var/lib/zabbix-influx/influxdb-zabbix.conf` and change:
```config
levelconsole="Warn"
formatting=false
```

0. Create the service file, using `sudoedit /etc/systemd/system/zabbix-influx.service` with the following content:
```
[Unit]
Description=zabbix to influx data pusher
#
[Service]
Type=simple
Restart=always
RestartSec=5s
ExecStart=/var/lib/zabbix-influx/go/bin/influxdb-zabbix
User=zabbix-influx
Group=zabbix
WorkingDirectory=~
#
[Install]
WantedBy=multi-user.target
```

0. Update systemd services
```
sudo systemctl daemon-reload
```

0. Enable and start the service
```
sudo systemctl enable zabbix-influx
sudo systemctl start zabbix-influx
```

0. Check
```
systemctl status zabbix-influx.service
```
Should be **Active (running)**.

0. Have a break, then return to grafana and check if data are up-to date.
