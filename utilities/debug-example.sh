#!/usr/bin/env bash

echo "This got executed"
v=$1
if [[ -z "${v}" ]]; then
 echo "\$v is empty"
fi
