#!/bin/bash
source env.sh

mkdir -p "$GEM_HOME"
gem update
gem install bundler
pushd site || exit
bundler install
popd || exit
