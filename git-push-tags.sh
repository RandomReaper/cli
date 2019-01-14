#!/bin/bash
DATE=$(date -u +'%Y-%m-%d-%M-%S')
git tag "$DATE" -m "$DATE"
git push --follow-tags
