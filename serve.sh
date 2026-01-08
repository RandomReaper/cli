#!/bin/bash
source env.sh

./clean.sh
pushd site || die
bundler exec jekyll serve --drafts --incremental --livereload --host=0.0.0.0
popd || die
