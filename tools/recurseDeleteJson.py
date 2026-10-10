import os
import argparse
import sys

def deleteAllJsonFiles(rootDir):
    for folderName, _, fileNames in os.walk(rootDir):
        for fileName in fileNames:
            if fileName.lower().endswith(".json"):
                filePath = os.path.join(folderName, fileName)
                os.remove(filePath)
                print(f"Deleted: {filePath}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Delete all .json files in a specified directory."
    )
    parser.add_argument(
        "directory",
        type=str,
        help="The directory to search for .json files."
    )

    args = parser.parse_args()

    if not os.path.isdir(args.directory):
        print(f"The specified path '{args.directory}' is not a valid directory.")
        sys.exit(1)

    deleteAllJsonFiles(args.directory)
    print("Deletion complete.")
