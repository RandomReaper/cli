#!/bin/bash

pushd site
bundler exec jekyll clean
popd
