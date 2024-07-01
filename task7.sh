#!/bin/bash

CONFIG_FILE="/etc/docker/daemon.json"
SERVICE_NAME="docker"

# Function to restart Docker service
restart_docker_service() {
    echo "Detected changes in $CONFIG_FILE. Restarting $SERVICE_NAME service..."
    systemctl restart $SERVICE_NAME
}

# Watch for changes in the Docker daemon config file
echo "Watching $CONFIG_FILE for changes..."
while true; do
    # Use inotifywait to monitor changes
    if inotifywait -e modify,move,create,delete -q $CONFIG_FILE; then
        restart_docker_service
    fi
done
