#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if AWS CLI is installed
if ! command_exists aws; then
    echo "AWS CLI is not installed. Please install it and configure your credentials."
    exit 1
fi

# Get the directory path from the user
read -p "Enter the path of the directory to backup: " dir_path

# Check if the directory exists
if [ ! -d "$dir_path" ]; then
    echo "The provided path does not exist or is not a directory."
    exit 1
fi

# Get the S3 bucket name from the user
read -p "Enter the S3 bucket name: " bucket_name

# Create a backup by copying the directory
backup_dir="${dir_path%/}_backup"
cp -r "$dir_path" "$backup_dir"

# Compress the backup directory
compressed_file="${backup_dir}.tar.gz"
tar -czf "$compressed_file" -C "$(dirname "$backup_dir")" "$(basename "$backup_dir")"

# Upload the compressed file to the S3 bucket
aws s3 cp "$compressed_file" "s3://$bucket_name/"

# Check if the upload was successful
if [ $? -eq 0 ]; then
    echo "Upload successful. File uploaded to s3://$bucket_name/$(basename "$compressed_file")"
else
    echo "Upload failed."
    # Clean up the backup and compressed files in case of failure
    rm -rf "$backup_dir"
    rm -f "$compressed_file"
    exit 1
fi

# Clean up the backup and compressed files after successful upload
rm -rf "$backup_dir"
rm -f "$compressed_file"

echo "Backup, compression, and upload completed successfully."
