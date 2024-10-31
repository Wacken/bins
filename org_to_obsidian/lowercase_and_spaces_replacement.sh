#!/usr/bin/env bash

fd '.*[:upper:].*' -0 |
    xargs -0 -p -I {} bash -c \
        'mv "$1" $(echo "$1" | tr " " "_" | tr "[:upper:]" "[:lower:]")' - '{}'
