#!/bin/bash

echo "What file extension should be used"
read -r wanted_extension

echo "What prefix should the file have"
read -r wanted_prefix

if [ -n "$wanted_prefix" ]; then
	prefix="$wanted_prefix"
else
	prefix=$(date +"%F")
fi

for file in *."$wanted_extension"; do
	new_file="$prefix-$file"
	printf "%-30s %s\n" "the original file name is" "$file"
	printf "%-30s %s\n" "the new file name is" "$new_file"
	mv "$file" "$new_file"
done
