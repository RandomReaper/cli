---
layout: post
title: '`lnav` the log file navigator'
tags: ubuntu 18.04 server
permalink: lnav-1.html
#image: /data/img/wide/www.jpg
---

You may know `tail -f`, but here is a tool  specifically designed to navigate
through log files: `lnav`.

## Viewing a changing log file
`tail -f logfile` will wait for output of a log file, and your favorite editor
may warn you about a file change.

`lnav logfile` will handle log file change.

## logrotate
Most Linux distribution use [`logrotate`](http://manpages.ubuntu.com/manpages/bionic/man8/logrotate.8.html){:.external}
to handle log files rotation. The goal is to rotate logs when they are too big,
or too old. The shortcoming is that it creates multiples log files, in various
formats, with funny names.

`syslog` becomes `syslog.1` then `syslog.1.gz`, `syslog.2.gz`, ...

`lnav -r /var/log/syslog` will open `/var/log/syslog`, and **all rotated files**!

<asciinema-player src="data/a/lnav-logrotate.jsonl" preload xautoplay cols="160" rows="40" poster="npt:5.1" font-size="small"></asciinema-player>


## Multiple log files
`lnav` will display multiple log files in the same view (log entries sorted by time).

Example : `lnav -r /var/log/syslog /var/log/auth.log`

## Shortcuts
A complete list of hotkeys is available [here](https://lnav.readthedocs.io/en/latest/hotkeys.html){:.external},
but here are some I use everyday:

### Navigation

| Key | effect |
| - | - |
| <kbd>Home</kbd> or <kbd>g</kbd>				| Top of the view |
| <kbd>End</kbd> or <kbd>G</kbd>				| Bottom of the view |
| <kbd>PgDn</kbd> or <kbd>space</kbd>			| Down a page |
| <kbd>PgUp</kbd> or <kbd>b</kbd>				| Up a page |
| <kbd>e</kbd>/<kbd>E</kbd>						| Next/previous error |
| <kbd>w</kbd>/<kbd>W</kbd>						| Next/previous warning |
| <kbd>f</kbd>/<kbd>F</kbd>						| Next/previous file |

### Searching

| Key | effect |
| - | - |
| <kbd>/</kbd>									| Search for lines matching a regular expression |
| <kbd>CTRL</kbd>+<kbd>]</kbd>					| Abort |
| <kbd>n</kbd>/<kbd>N</kbd>						| Next/previous hit |

