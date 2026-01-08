#!/bin/bash
source env.sh

pushd site || die
bundler exec jekyll clean
popd || die
