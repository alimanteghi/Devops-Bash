#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Restic is installed
if ! command_exists restic; then
    echo "Restic is not installed. Please install it."
    exit 1
fi

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

# Get or set the Restic repository password
if [ -z "$RESTIC_PASSWORD" ]; then
    read -sp "Enter the password for the Restic repository: " RESTIC_PASSWORD
    export RESTIC_PASSWORD
    echo
fi

# Initialize the Restic repository if it doesn't exist
restic_repo="s3:s3.amazonaws.com/$bucket_name/restic-repo"

if ! restic -r "$restic_repo" snapshots > /dev/null 2>&1; then
    echo "Initializing Restic repository..."
    restic -r "$restic_repo" init
    if [ $? -ne 0 ]; then
        echo "Failed to initialize Restic repository."
        exit 1
    fi
fi

# Perform the backup
echo "Starting backup..."
restic -r "$restic_repo" backup "$dir_path"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully."
else
    echo "Backup failed."
    exit 1
fi

# Clean up old snapshots if necessary
# Uncomment and adjust the following line to keep the last 7 daily snapshots, for example
# restic -r "$restic_repo" forget --keep-daily 7 --prune

echo "Backup and cleanup (if enabled) completed successfully."
