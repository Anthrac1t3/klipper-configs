#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <source_directory>"
    echo ""
    echo "DESCRIPTION:"
    echo "  Creates symbolic links for all .cfg and .conf files from the specified source directory"
    echo "  to the location /home/${USER}/printer_data/config."
    echo ""
    echo "  The symlink names will be identical to the original filenames."
    echo ""
    echo "ARGUMENTS:"
    echo "  source_directory    Path to the directory containing .cfg and .conf files to link"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 /home/user/printer_configs"
    echo "  $0 ./config_files"
    echo "  $0 /path/to/my/configs"
    echo ""
    echo "OUTPUT:"
    echo "  Creates symlinks in /home/${USER}/printer_data/config/ with the same names"
    echo "  as the original .cfg and .conf files, pointing to their respective source locations."
    echo ""
    echo "NOTES:"
    echo "  - Existing symlinks will be skipped with a warning"
    echo "  - Regular files with the same name will cause warnings and be skipped"
    exit 1
}

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Error: Please provide exactly one argument (source directory)"
    usage
fi

# Set the target directory
TARGET_DIR="/home/${USER}/printer_data/config"

# Get the source directory from command line argument
SOURCE_DIR="$1"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist"
    exit 1
fi

# Check if the printer config directory exists
if [ $? -ne 0 ]; then
    echo "Error: '$TARGET_DIR' does not exist. Please review your Klipper instillation"
    exit 1
fi

# Counter for successful symlinks
SUCCESS_COUNT=0
ERROR_COUNT=0

# Find all the conf files in the source directory and iterate over them
find "$SOURCE_DIR" \( -name "*.cfg" -o -name "*.conf" \) -type f | while read -r config_file; do
    # Get just the filename (basename)
    filename=$(basename "$config_file")
    
    # Create the symlink
    symlink_path="$TARGET_DIR/$filename"
    
    # Check if symlink already exists
    if [ -L "$symlink_path" ]; then
        echo "Warning: Symlink '$filename' already exists (linking to: $(readlink "$symlink_path"))"
        continue
    elif [ -e "$symlink_path" ]; then
        echo "Warning: File '$filename' already exists and is not a symlink"
        ERROR_COUNT=$((ERROR_COUNT + 1))
        continue
    fi
    
    # Create the symlink
    ln -s "$config_file" "$symlink_path"
    if [ $? -e 0 ]; then
        echo "Created symlink: $symlink_path -> $config_file"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "Error: Failed to create symlink for $filename"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
done

# Print summary
echo ""
echo "Summary:"
echo "--------"
echo "Successfully created symlinks: $SUCCESS_COUNT"
echo "Errors: $ERROR_COUNT"

# Exit with error code if there were errors
if [ $ERROR_COUNT -gt 0 ]; then
    exit 1
else
    exit 0
fi
