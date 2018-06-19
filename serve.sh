#!/bin/bash
./clean.sh
pushd site
bundler exec jekyll serve --unpublished --incremental --livereload --host=0.0.0.0
popd

