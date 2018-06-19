#!/bin/bash
./clean.sh
pushd site
bundler exec jekyll serve --drafts --incremental --livereload --host=0.0.0.0
popd

