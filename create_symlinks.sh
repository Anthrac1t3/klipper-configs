#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <source_directory>"
    echo "Creates symbolic links for all .cfg files from source_directory to /home/${USER}/printer_data/config"
    echo ""
    echo "Example: $0 /path/to/config/files"
    exit 1
}

# Check if argument is provided
if [ $# -ne 1 ]; then
    echo "Error: Please provide exactly one argument (source directory)"
    usage
fi

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

# Find all .cfg files in source directory and create symlinks
find "$SOURCE_DIR" -name "*.cfg" -type f | while read -r cfg_file; do
    # Get just the filename (basename)
    filename=$(basename "$cfg_file")
    
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
    if ln -s "$cfg_file" "$symlink_path"; then
        echo "Created symlink: $filename -> $cfg_file"
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
