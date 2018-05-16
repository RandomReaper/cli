#!/bin/bash
type psftp >/dev/null 2>&1 || { echo >&2 "psftp required (sudo apt install putty-tools)."; exit 1; }

WORKINGDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')
CMDFILE=$(mktemp)

cat >"$CMDFILE" <<EOL
cd vhosts/cli.pignat.org/htdocs/
put -r "$WORKINGDIR" .
EOL

pushd site
JEKYLL_ENV=production bundler exec jekyll build --destination "$WORKINGDIR"
popd

psftp 284634@sftp.sd3.gpaas.net -b "$CMDFILE"
exit 0
rm -rf "$WORKINGDIR" $"CMDFILE"
