#!/bin/bash

# Define the port to listen on
PORT=8080
# File to store user data
USER_FILE="users.txt"

# Ensure user file exists
touch "$USER_FILE"

# Function to handle incoming requests
handle_request() {
    # Read the HTTP request from netcat
    while IFS= read -r line; do
        # Check for end of HTTP request (blank line)
        if [[ "$line" = $'\r' ]]; then
            break
        fi
        request_header+="$line"$'\n'
    done

    # Log the request (optional)
    echo "Received request:"
    echo "$request_header"

    # Extract the HTTP method and path
    http_method=$(echo "$request_header" | head -n 1 | cut -d ' ' -f 1)
    request_path=$(echo "$request_header" | head -n 1 | cut -d ' ' -f 2)

    # Prepare HTTP response
    if [[ "$request_path" = "/" ]]; then
        # Index page response
        response_body="<html><body><h1>Welcome to the index page!</h1></body></html>"
        content_length=${#response_body}
        http_response="HTTP/1.1 200 OK\r\nServer: bash\r\nContent-Length: $content_length\r\nContent-Type: text/html\r\n\r\n$response_body"
    elif [[ "$request_path" = "/health" ]]; then
        # Health check response
        response_body="OK"
        content_length=${#response_body}
        http_response="HTTP/1.1 200 OK\r\nServer: bash\r\nContent-Length: $content_length\r\nContent-Type: text/plain\r\n\r\n$response_body"
    elif [[ "$request_path" = "/api/v1/users" ]]; then
        # API endpoint for managing users
        case $http_method in
            "GET")
                # Get all users
                response_body=$(cat "$USER_FILE")
                content_length=${#response_body}
                http_response="HTTP/1.1 200 OK\r\nServer: bash\r\nContent-Length: $content_length\r\nContent-Type: application/json\r\n\r\n$response_body"
                ;;
            "POST")
                # Create a new user
                user_data=$(tail -n 1 "$USER_FILE")
                if [ -z "$user_data" ]; then
                    user_id=1
                else
                    user_id=$(echo "$user_data" | awk -F '|' '{print $1 + 1}')
                fi

                # Extract user details from request body
                user_details=$(echo "$request_header" | tail -n 1)
                echo "$user_id|$user_details" >> "$USER_FILE"

                response_body="{\"message\": \"User created successfully\", \"user_id\": $user_id}"
                content_length=${#response_body}
                http_response="HTTP/1.1 201 Created\r\nServer: bash\r\nContent-Length: $content_length\r\nContent-Type: application/json\r\n\r\n$response_body"
                ;;
            "PUT")
                # Update user details
                user_id=$(echo "$request_path" | cut -d '/' -f 5)
                if grep -q "^$user_id|" "$USER_FILE"; then
                    user_details=$(echo "$request_header" | tail -n 1)
                    sed -i "s/^$user_id|.*/$user_id|$user_details/" "$USER_FILE"
                    response_body="{\"message\": \"User updated successfully\", \"user_id\": $user_id}"
                    content_length=${#response_body}
                    http_response="HTTP/1.1 200 OK\r\nServer: bash\r\nContent-Length: $content_length\r\nContent-Type: application/json\r\n\r\n$response_body"
                else
                    response_body="{\"error\": \"User not found with ID $user_id\"}"
                    content_length=${#response_body}
                    http_response="HTTP/1.1 404 Not Found\r\nServer: bash\r\nContent-Length: $content_length\r\nContent-Type: application/json\r\n\r\n$response_body"
                fi
                ;;
            "DELETE")
                # Delete user
                user_id=$(echo "$request_path" | cut -d '/' -f 5)
                if grep -q "^$user_id|" "$USER_FILE"; then
                    sed -i "/^$user_id|/d" "$USER_FILE"
                    response_body="{\"message\": \"User deleted successfully\", \"user_id\": $user_id}"
                    content_length=${#response_body}
                    http_response="HTTP/1.1 200 OK\r\nServer: bash\r\nContent-Length: $content_length\r\nContent-Type: application/json\r\n\r\n$response_body"
                else
                    response_body="{\"error\": \"User not found with ID $user_id\"}"
                    content_length=${#response_body}
                    http_response="HTTP/1.1 404 Not Found\r\nServer: bash\r\nContent-Length: $content_length\r\nContent-Type: application/json\r\n\r\n$response_body"
                fi
                ;;
            *)
                # Method not allowed
                response_body="{\"error\": \"Method not allowed\"}"
                content_length=${#response_body}
                http_response="HTTP/1.1 405 Method Not Allowed\r\nServer: bash\r\nContent-Length: $content_length\r\nContent-Type: application/json\r\n\r\n$response_body"
                ;;
        esac
    else
        # 404 Not Found response for other paths
        http_response="HTTP/1.1 404 Not Found\r\nServer: bash\r\nContent-Length: 0\r\n\r\n"
    fi

    # Send the HTTP response
    echo -ne "$http_response" | nc -q 0 -l -p "$PORT"

    # Log response (optional)
    echo "Response sent:"
    echo -ne "$http_response"
}

# Main loop to continuously handle incoming connections
while true; do
    handle_request
done
