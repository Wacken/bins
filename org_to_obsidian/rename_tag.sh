#!/bin/bash

fd --full-path "$1" -e md -x perl -i -pe 's/\@windows_pc/@windows/g' {}
