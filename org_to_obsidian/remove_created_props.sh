#!/usr/bin/env bash

fd --full-path "$1" -e md -x perl -i -0777 -pe 's/:PROPERTIES:\n:CREATED:.*?\n:END:\n//g' {}
