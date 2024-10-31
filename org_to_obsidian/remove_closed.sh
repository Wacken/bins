#!/bin/bash

fd --full-path "$1" -e md -x perl -i -0777 -pe 's/\nCLOSED: \[(.*?)\]/ \[$1\]/g' {}
