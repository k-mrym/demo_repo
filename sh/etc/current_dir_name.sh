#!/bin/bash

DIR=$(dirname "$0")
CURRENT=$(pwd "$DIR")
echo "$CURRENT"

DIR_NAME=$(echo "$CURRENT" | sed -e 's/.*\/\([^\/]*\)$/\1/')
echo "$DIR_NAME"
