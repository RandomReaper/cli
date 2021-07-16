#!/bin/bash
WORKINGDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')
W="$WORKINGDIR/toto"
mkdir "$W"

pushd site
JEKYLL_ENV=production bundler exec jekyll build --destination "$W" || exit -1
popd

ci/publish.sh "$W" ~/.ssh/id_rsa ~/.ssh/known_hosts
rm -rf "$WORKINGDIR"
