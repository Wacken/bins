import os

def transform_metadata_to_frontmatter(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    print(file_path)

    # Find the index of the '# Metadata' line
    #
    metadata_index = next((i for i, line in enumerate(lines) if line.startswith('# Metadata')), None)

    # Extract metadata lines if '# Metadata' is found
    metadata_lines = []
    if metadata_index is not None:
        for line in lines[metadata_index + 1:]:
            if line.startswith('#') or line.strip() == '':
                break
            metadata_lines.append(line.strip())

    # Parse the metadata lines into a dictionary
    metadata_dict = {}
    for line in metadata_lines:
        key, value = line.split('::')
        key = key.strip()
        _, key = key.split(' ')
        values = [v.strip() for v in value.split(',')]
        metadata_dict[key] = values


    # Remove the '# Metadata' line and the metadata lines
    if metadata_index is not None:
        lines = lines[:metadata_index] + lines[metadata_index + 1 + len(metadata_lines):]

    # Format the metadata for frontmatter
    frontmatter = ['---\n']
    for key, values in metadata_dict.items():
        frontmatter.append(f'{key}:\n')
        for value in values:
            frontmatter.append(f'- {value}\n')
    frontmatter.append('---\n')

    # Insert the frontmatter at the top of the file
    new_lines = frontmatter + lines

    md_file_path = os.path.splitext(file_path)[0] + ".md"

    with open(md_file_path, 'w') as file:
        file.writelines(new_lines)


def process_folder(folder_path):
    for root, _, files in os.walk(folder_path):
        for filename in files:
            if filename.endswith('.org'):
                transform_metadata_to_frontmatter(os.path.join(root, filename))

# Replace 'your_folder_path' with the path to your folder
process_folder('./Org_Bak/')
