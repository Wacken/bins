#!/bin/bash

if [ -n "$1" ]
then
    for file in "$1"/*
    do
        if [ -f "$file" ]
        then
            headline=$(head -n 1 "$file" )
            echo "$headline"
            if [[ $headline == \#!/bin/* ]]
            then
                basename "$file"
            fi
        fi
    done
else
    echo could not find argument
fi
echo finished
