#!/bin/bash
# Make sure this script is sourced
if [ "$0" = "$BASH_SOURCE" ]; then
    echo "Error: Script must be sourced"
    exit 1
fi

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export GEM_HOME="${CURRENT_DIR}/.gems"
export PATH="$GEM_HOME/bin:$PATH"
