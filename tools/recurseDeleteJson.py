import os
import argparse

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Delete all .json files in a specified directory.")
    parser.add_argument('directory', type=str, help='The directory to search for .json files.')
    args = parser.parse_args()

    if not os.path.isdir(args.directory):
        print(f"The specified path '{args.directory}' is not a valid directory.")
        exit(1)

    for foldername, _, filenames in os.walk(args.directory):
        for filename in filenames:
            if filename.lower().endswith('.json'):
                file_path = os.path.join(foldername, filename)
                os.remove(file_path)
                print(f"Deleted: {file_path}")

    print("Deletion complete.")