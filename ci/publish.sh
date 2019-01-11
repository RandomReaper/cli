#!/bin/bash
type lftp >/dev/null 2>&1 || { echo >&2 "lftp required (sudo apt install putty-tools)."; exit 1; }

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

CMDFILE=$(mktemp)

cat >"$CMDFILE" <<EOL
set sftp:connect-program "ssh -a -x -i $KEYFILE -o UserKnownHostsFile=$HOSTFILE"
set cmd:interactive false
open -u 284634, sftp://sftp.sd3.gpaas.net
mirror -R "$WORKINGDIR" vhosts/cli.pignat.org/htdocs
exit
EOL

lftp --norc -f "$CMDFILE"
RESULT=$?

rm "$CMDFILE"

exit "$RESULT"