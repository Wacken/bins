#!/bin/bash

# --- Configuration ---
if [ -z "$1" ]; then
    echo "Usage: $0 <website_url>"
    exit 1
fi
website_url="$1"
# website_url="https://dev.fitbit.com/build/reference/web-api/" # <--- CHANGE THIS to the URL of the website you want to download
downloaded_site_folder="./downloaded_website"   # <--- Folder to save the downloaded website
output_pdf_flat_folder="$downloaded_site_folder/all_pdfs"   # <--- Folder to save all generated individual PDFs

# Generate a sanitized domain name from the URL including subdomains and use it as the final PDF name
sanitized_domain=$(echo "$website_url" | sed -E 's|https?://([^/]+)|\1|' | sed 's/[^a-zA-Z0-9]/_/g')
merged_pdf_path="./${sanitized_domain}.pdf"  # <--- Final merged PDF name

# --- Website Download using HTTrack ---

echo "Starting selective website download from $website_url using HTTrack..."

# Remove the previous download folder if it exists to start fresh
if [ -d "$downloaded_site_folder" ]; then
    echo "Removing existing download folder: $downloaded_site_folder"
    rm -rf "$downloaded_site_folder"
fi

# Extract main domain from the URL for filtering
main_domain=$(echo "$website_url" | sed -E 's|https?://([^/]+)/?.*|\1|')

# Run HTTrack command with more restrictive filters and a different User-Agent
# -O: Output path
# -*: Exclude all external links by default
# +<main_domain>/*: Include links within the main domain
# +*.<main_domain>/*: Include links within any subdomain of the main domain
# -% *.jpg -% *.png -% *.gif -% *.jpeg -% *.svg: Exclude common image file types
# -% *.js: Exclude JavaScript files
# +% *.css: Explicitly include CSS files (important for PDF formatting)
# -r5: Set recursion depth to 5 (adjust if needed)
# --robots=0: Ignore robots.txt (use with caution)
# --quiet: Suppress most messages
# -F "User-Agent: Mozilla/5.0 (compatible; вашей_операционной_системы) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/ вашей_версии_chrome Safari/537.36": Set a custom User-Agent

httrack "$website_url" -O "$downloaded_site_folder" 

# Check if HTTrack command was successful (basic check)
# Note: HTTrack might still report errors for 403 pages, but the download might continue for other pages.
if [ $? -ne 0 ]; then
    echo "HTTrack finished with errors. Some pages might not have been downloaded (possibly due to 403 Forbidden or other issues)."
    # We will not exit here, to allow conversion of successfully downloaded files
fi

echo "Website download complete in '$downloaded_site_folder'."

# --- HTML to PDF Conversion using wkhtmltopdf ---

echo "Starting HTML to PDF conversion..."

# Create the output folder for individual PDFs if it doesn't exist
mkdir -p "$output_pdf_flat_folder"

# Find all HTML files in the downloaded folder and its subfolders
# Use a while loop to handle filenames with spaces or special characters
find "$downloaded_site_folder" -name "*.html" -print0 | while IFS= read -r -d $'\0' html_file; do

    # Get the path relative to the downloaded_site_folder
    relative_path="${html_file#"$downloaded_site_folder/"}"

    # Sanitize the relative path to create a safe filename:
    # Replace all '/' with '_'
    # Remove leading/trailing underscores that might result from paths like ./index.html
    sanitized_name=$(echo "$relative_path" | sed 's/\//_/g' | sed 's/^_//;s/_$//')

    # Construct the unique output PDF filename for individual pages
    # Replace the .html extension with .pdf
    pdf_filename="${sanitized_name%.html}.pdf"

    # Construct the full path for the individual output PDF
    output_pdf_path="$output_pdf_flat_folder/$pdf_filename"

    # Skip conversion if the output file already exists (optional, remove if you want to re-convert)
    # if [ -f "$output_pdf_path" ]; then
    #     echo "Skipping conversion for '$html_file', PDF already exists."
    #     continue
    # fi

    echo "Converting '$html_file' to '$output_pdf_path'..."

    # Run wkhtmltopdf
    # You can add options here, e.g., --footer-center "[page]/[topage]" for page numbers
    # Since we are excluding images and JS, the appearance might be basic,
    # but CSS should help with layout.
    wkhtmltopdf "$html_file" "$output_pdf_path"

    # Check if the conversion was successful
    if [ $? -ne 0 ]; then
        echo "Error converting '$html_file'."
    else
        echo "Successfully converted '$pdf_filename'."
    fi

done

echo "HTML to PDF conversion complete. Individual PDFs are in '$output_pdf_flat_folder'."

# --- Merge all PDFs using pdftk-java ---

echo "Starting PDF merging using pdftk-java..."

# Check if there are any PDF files to merge
if find "$output_pdf_flat_folder" -name "*.pdf" -print -quit | grep -q .; then
    # Use pdftk-java to concatenate all PDF files in the output_pdf_flat_folder
    pdftk "$output_pdf_flat_folder"/*.pdf cat output "$merged_pdf_path"

    # Check if the merging was successful
    if [ $? -ne 0 ]; then
        echo "Error merging PDFs using pdftk-java."
    else
        echo "Successfully merged all PDFs into '$merged_pdf_path'."
    fi
else
    echo "No PDF files found to merge in '$output_pdf_flat_folder'."
fi

# Clean up everything except the merged PDF
# Uncomment the following line to remove individual PDFs after merging
rm -rf "$output_pdf_flat_folder"
rm -rf "$downloaded_site_folder"
# echo "Removed individual PDFs from '$output_pdf_flat_folder'."

echo "Script finished."