#!/usr/bin/env python3

import csv
import os

# Path to your exported Goodreads CSV file
csv_file_path = 'goodreads_library_export.csv'

# Directory to save the Markdown files
output_dir = 'books_markdown'
os.makedirs(output_dir, exist_ok=True)

# Read the CSV file
with open(csv_file_path, mode='r', encoding='utf-8') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        title = row['Title']

        # Create a filename-safe version of the title
        filename = f"{title.replace(' ', '_').replace('/', '_')}.md"
        file_path = os.path.join(output_dir, filename)

        title = title.split(':')[0]
        # Write the frontmatter to a Markdown file
        with open(file_path, mode='w', encoding='utf-8') as md_file:
            md_file.write(f"---\n")
            md_file.write(f"title: {title}\n")
            md_file.write(f"---\n")

print(f"Markdown files have been created in the '{output_dir}' directory.")
