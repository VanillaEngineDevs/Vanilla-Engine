import os
import subprocess
import argparse
import platform

validFormats = ["dxt5", "astc"]
inputExtensions = [".png"]
blacklistFile = "blacklistFiles.txt"

def getBlacklist():
    folders = set()
    files = set()
    if not os.path.exists(blacklistFile):
        return folders, files
    with open(blacklistFile) as f:
        for line in f:
            line = line.strip().replace("\\", "/")
            if not line:
                continue
            if line.endswith("/*"):
                folders.add(os.path.normpath(line[:-2]))
            else:
                files.add(os.path.normpath(line))
    return folders, files

def isBlacklisted(path, folders, files):
    path = os.path.normpath(path)
    for folder in folders:
        if path.startswith(folder):
            return True
    if path in files:
        return True
    return False

def compressDxt5(inputPath, outputPath):
    if platform.system() == "Windows":
        cmd = [
            "tools/nt/texconv/texconv.exe",
            "-f", "DXT5",
            "-y",
            "-o", os.path.dirname(outputPath),
            inputPath
        ]
    else:
        cmd = [
            "mogrify",
            "-define", "dds:cluster-fit=true",
            "-define", "dds:compression=dxt5",
            "-define", "dds:mipmaps=0",
            "-format", "dds",
            "-path", os.path.dirname(outputPath),
            inputPath
        ]
    subprocess.run(cmd, check=True)
    print(f"[DXT5] {inputPath} → {outputPath}")

def compressAstc(inputPath, block="10x10", outputPath=None):
    encoder = "astcenc-avx2" if platform.system() != "Windows" else "tools/nt/astcenc/astcenc-avx2.exe"
    cmd = [
        encoder,
        "-cs",
        inputPath,
        outputPath,
        block,
        "-medium"
    ]
    subprocess.run(cmd, check=True)
    print(f"[ASTC] {inputPath} -> {outputPath}")

def compressImages(baseDir, formatType, blockSize="10x10"):
    if formatType not in validFormats:
        raise ValueError(f"Unsupported format: {formatType}")

    blacklistFolders, blacklistFiles = getBlacklist()

    for root, _, files in os.walk(baseDir):
        for file in files:
            if not any(file.lower().endswith(ext) for ext in inputExtensions):
                continue

            fullPath = os.path.normpath(os.path.join(root, file))

            relPath = os.path.relpath(fullPath).replace("\\", "/")
            if isBlacklisted(relPath, blacklistFolders, blacklistFiles):
                print(f"[SKIP] {relPath} is blacklisted")
                continue

            base = os.path.splitext(file)[0]
            outputExt = ".dds" if formatType == "dxt5" else ".astc"
            outputPath = os.path.join(root, base + outputExt)

            try:
                if formatType == "dxt5":
                    compressDxt5(fullPath, outputPath)
                elif formatType == "astc":
                    compressAstc(fullPath, blockSize, outputPath)
            except subprocess.CalledProcessError:
                print(f"[ERROR] Compression failed: {fullPath}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("format", choices=validFormats, help="Compression format: dxt5 or astc")
    parser.add_argument("block", nargs="?", default="10x10", help="Block size for ASTC compression (default: 10x10)")
    parser.add_argument("source", help="Directory to process recursively")
    args = parser.parse_args()

    compressImages(args.source, args.format, args.block)
