#!/usr/bin/env sh

import os

def transform_metadata_to_frontmatter(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    print(file_path)

    # Find and remove the ':ROAM_ALIASES:' line
    aliases = []
    tags = []
    new_lines = []
    for line in lines:
        if line.startswith(':ROAM_ALIASES:'):
            alias_value = line.split(':ROAM_ALIASES:')[1].strip().strip('"')
            aliases.append(alias_value)
        elif line.startswith('#+filetags: :'):
            tag_values_raw = line.split('#+filetags: :')[1].strip().strip('"')
            tag_values = [v.strip() for v in tag_values_raw.split(':')]
            for tag in tag_values:
                if tag != '':
                    tags.append(tag)
        else:
            new_lines.append(line)
    print(tags)
    print(aliases)
    # Find the index of the '# Metadata' line
    #
    metadata_index = next((i for i, line in enumerate(new_lines) if line.startswith('* Metadata')), None)

    if metadata_index is not None:
        new_line_append = [
            f"- aliases :: {','.join(aliases)}\n", f"- tags :: {','.join(tags)}\n"]
        new_lines[metadata_index+1:metadata_index+1] = new_line_append

    with open(file_path, 'w') as file:
        file.writelines(new_lines)

def process_folder(folder_path):
    for root, _, files in os.walk(folder_path):
        for filename in files:
            if filename.endswith('.org'):
                transform_metadata_to_frontmatter(os.path.join(root, filename))

# Replace 'your_folder_path' with the path to your folder
process_folder('./Org_Bak')
