#!/usr/bin/env bash

find . -name '* *' -execdir sh -c 'mv -i "$1" $(echo "$1" | tr " " "_")' - '{}' +

# fd '.* .*' -0 |
#     xargs -0 -p -I {} bash -c \
#         'mv "$1" $(echo "$1" | tr " " "_")' - '{}'
