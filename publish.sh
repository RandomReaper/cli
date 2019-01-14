#!/bin/bash
WORKINGDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')

pushd site
JEKYLL_ENV=production bundler exec jekyll build --destination "$WORKINGDIR"
popd

ci/publish.sh "$WORKINGDIR" ~/.ssh/id_rsa ~/.ssh/known_hosts
rm -rf "$WORKINGDIR"
