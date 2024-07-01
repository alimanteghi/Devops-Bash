import os
import hashlib
import shutil

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
            changes.append(("new", file_path))
        elif initial_state[file_path] != current_hash:
            changes.append(("modified", file_path))

    # Check for deleted files
    for file_path in initial_state:
        if file_path not in current_state:
            changes.append(("deleted", file_path))

    return changes

def restore_file(file_path):
    """Restore a file to its initial state."""
    original_path = file_path + ".original"
    if os.path.exists(original_path):
        shutil.copy(original_path, file_path)
        print(f"Restored {file_path} to its original state.")
    else:
        print(f"Could not find original state of {file_path}.")

def backup_initial_state(initial_state):
    """Backup the initial state of files by copying them."""
    for file_path in initial_state:
        original_path = file_path + ".original"
        if not os.path.exists(original_path):
            shutil.copy(file_path, original_path)

if __name__ == "__main__":
    # Directory to monitor
    directory_to_monitor = '/path/to/your/directory'

    # Initial scan of the directory
    initial_state = scan_directory(directory_to_monitor)
    backup_initial_state(initial_state)

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
        for change_type, file_path in changes:
            print(f"{change_type.capitalize()} file: {file_path}")
            if change_type in ["modified", "deleted"]:
                restore_file(file_path)
    else:
        print("No changes detected.")
