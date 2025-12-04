#!/bin/bash
type rsync >/dev/null 2>&1 || { echo >&2 "rsync required (sudo apt install rsync)."; exit 1; }

if [ ! $# -eq 3 ]; then
	echo "arguments should be dir private_key known_host_file"
	exit 1
fi

WORKINGDIR=$1
KEYFILE=$2
HOSTFILE=$3

if [ ! -d "$WORKINGDIR" ]; then
	echo "directory $WORKINGDIR not found!"
	exit 1
fi

if [ ! -f "$KEYFILE" ]; then
	echo "file $KEYFILE not found!"
	exit 1
fi

if [ ! -f "$HOSTFILE" ]; then
	echo "file $HOSTFILE not found!"
	exit 1
fi

rsync -Pa --delete --chown=":www-data" -e "ssh -i $KEYFILE -o UserKnownHostsFile=$HOSTFILE" "$WORKINGDIR/" ubuntu@cli.pignat.org:/var/www/cli.pignat.org/
