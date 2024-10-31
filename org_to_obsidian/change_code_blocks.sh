#!/usr/bin/env bash

fd --full-path "$1" -e md -x perl -i -0777 -pe 's/#\+end_src/```/g' {}
fd --full-path "$1" -e md -x perl -i -0777 -pe 's/#\+begin_src/```/g' {}
