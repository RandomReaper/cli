#!/bin/bash
source env.sh

WORKINGDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')
W="$WORKINGDIR/toto"
mkdir "$W"

pushd site || die
JEKYLL_ENV=production bundler exec jekyll build --destination "$W" || exit 1
popd || die

ci/publish.sh "$W" ~/.ssh/id_ed25519 ~/.ssh/known_hosts
rm -rf "$WORKINGDIR"
