#!/bin/bash
type psftp >/dev/null 2>&1 || { echo >&2 "psftp required (sudo apt install putty-tools)."; exit 1; }

WORKINGDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')
CMDFILE=$(mktemp)

cat >"$CMDFILE" <<EOL
cd vhosts/cli.pignat.org/htdocs/
put -r "$WORKINGDIR" .
EOL

JEKYLL_ENV=production jekyll build --source site --destination "$WORKINGDIR"
psftp 284634@sftp.sd3.gpaas.net -b "$CMDFILE"
exit 0
rm -rf "$WORKINGDIR" $"CMDFILE"
