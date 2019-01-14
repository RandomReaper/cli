#!/bin/bash
DATE=$(date -u +'%Y-%m-%d-%M-%S')
echo date > site/RELEASE
git commit site/RELEASE -m "$DATE"
git tag "$DATE" -m "$DATE"
git push --follow-tags
