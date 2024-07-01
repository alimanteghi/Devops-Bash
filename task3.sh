#!/bin/bash

# Define the port to listen on
PORT=8080

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
    else
        # 404 Not Found response
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
