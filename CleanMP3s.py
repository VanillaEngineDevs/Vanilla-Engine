# Clean up all the mp3 files in src/assets/ RECURSIVELY

import os, sys

def cleanRecursive(dir) -> None:
    """
    Recursively clean up all mp3 files in the given directory.
    """
    for root, dirs, files in os.walk(dir):
        for file in files:
            if file.endswith('.mp3'):
                file_path = os.path.join(root, file)
                print(f"Removing {file_path}")
                os.remove(file_path)
                
if __name__ == "__main__":
    cleanRecursive("src/assets/")