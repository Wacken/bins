#!/bin/bash

find "$1" -type f -name "*.org" -exec perl -p -i -e "s/\[\[(.*?)\]\[(.*?)\]\]/[\2](\1)/g" {} \;
