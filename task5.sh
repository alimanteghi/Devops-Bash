import os
import hashlib

def hash_file(file_path):
    """Generate SHA-256 hash of a file."""
    hasher = hashlib.sha256()
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b''):
            hasher.update(chunk)
    return hasher.hexdigest()

def scan_directory(directory):
    """Scan a directory recursively and return a dictionary of file paths and their hashes."""
    file_hashes = {}
    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            file_hash = hash_file(file_path)
            file_hashes[file_path] = file_hash
    return file_hashes

def detect_changes(initial_state, current_state):
    """Detect changes between two states of file hashes."""
    changes = []
    # Check for new or modified files
    for file_path, current_hash in current_state.items():
        if file_path not in initial_state:
            changes.append(f"New file detected: {file_path}")
        elif initial_state[file_path] != current_hash:
            changes.append(f"File modified: {file_path}")

    # Check for deleted files
    for file_path in initial_state:
        if file_path not in current_state:
            changes.append(f"File deleted: {file_path}")

    return changes

if __name__ == "__main__":
    # Directory to monitor
    directory_to_monitor = '/path/to/your/directory'

    # Initial scan of the directory
    initial_state = scan_directory(directory_to_monitor)

    # Simulate some changes (for testing purposes)
    # For real-time use, this step would be replaced by actual user actions or external events.
    # For example, modify or delete some files manually.

    # Rescan the directory to capture current state
    current_state = scan_directory(directory_to_monitor)

    # Detect changes between initial and current states
    changes = detect_changes(initial_state, current_state)

    # Print changes detected
    if changes:
        print("Changes detected:")
        for change in changes:
            print(change)
    else:
        print("No changes detected.")
