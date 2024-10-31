#!/usr/bin/env python3

import re
import os

def process_file(file_path):
    with open(file_path, 'r') as file:
        content = file.read()

    # Replace [[Text and More]] with [[text_and_more]]
    new_content = re.sub(r'\[\[([^\]]+)\]\]', lambda m: '[[' + m.group(1).replace(' ', '_').lower() + ']]', content)

    with open(file_path, 'w') as file:
        file.write(new_content)

# Walk through the directory and process .md files
for root, dirs, files in os.walk('.'):
    for file in files:
        if file.endswith('.md'):
            process_file(os.path.join(root, file))
