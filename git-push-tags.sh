#!/bin/bash
DATE=$(date -u +'%Y-%m-%dT%H-%M-%S')
echo -n "$DATE" > site/RELEASE
git commit site/RELEASE -m "$DATE"
git tag -a "$DATE" -m "$DATE"
git push --follow-tags
