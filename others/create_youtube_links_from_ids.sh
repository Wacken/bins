#!/usr/bin/env bash
set -euo pipefail

csv_file=$1
txt_output=$2
field_number=${3:-1}

cut -d, -f$field_number "$csv_file"\
    | tail -n +2\
    | sed 's/.*/https:\/\/www.youtube.com\/watch?v=&/'\
    > "$txt_output"
