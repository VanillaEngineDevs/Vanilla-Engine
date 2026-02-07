import os
import shutil
import zipfile
import subprocess
import argparse

buildDir = "build"
releaseDir = os.path.join(buildDir, "release")
lovefileName = "funkin-vanilla-engine.love"
blacklistFile = "blacklistCompileFolders.txt"
versionFile = "src/data/version.txt"
compressScript = "compressImages.py"

def getBlacklist():
    if not os.path.exists(blacklistFile):
        return []
    with open(blacklistFile) as f:
        return [line.strip().strip("/") for line in f if line.strip()]

def zipDir(srcDir, zipFile, blacklist=None):
    blacklist = blacklist or []
    normalizedBlacklist = [os.path.normpath(p) for p in blacklist]

    def isBlacklisted(relPath):
        relPath = relPath.replace("\\", "/")
        for bl in normalizedBlacklist:
            bl = bl.replace("\\", "/")
            if bl.endswith("/*"):
                folder = bl[:-2]
                if relPath.startswith(folder + "/"):
                    return True
            elif bl.startswith("*."):  # Extension-based blacklist
                if relPath.lower().endswith(bl[1:].lower()):
                    return True
            elif relPath == bl:
                return True
        return False

    with zipfile.ZipFile(zipFile, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, _, files in os.walk(srcDir):
            for file in files:
                fullPath = os.path.join(root, file)
                relPath = os.path.relpath(fullPath, srcDir)
                if isBlacklisted(relPath):
                    print(f"[SKIP] {relPath} is blacklisted")
                    continue
                zf.write(fullPath, relPath)

def compressAssets(imageFormat, blockSize="10x10"):
    if imageFormat not in ["dxt5", "astc"]:
        return

    print(f"[INFO] Compressing assets to {imageFormat.upper()}...")

    sourceFolder = "src/images"
    sourceFolder2 = "src/assets/"

    try:
        run(f"python {compressScript} {imageFormat} {blockSize} {sourceFolder}")
        run(f"python {compressScript} {imageFormat} {blockSize} {sourceFolder2}")
    except subprocess.CalledProcessError:
        print("[ERROR] Compression failed")

def run(command):
    print(f"[CMD] {command}")
    subprocess.run(command, shell=True, check=True)

def buildLovefile():
    print("[INFO] Building .love file...")
    shutil.copy("LICENSE", "src/LICENSE.txt")
    lovefileDir = os.path.join(buildDir, "lovefile")
    os.makedirs(lovefileDir, exist_ok=True)
    zipPath = os.path.join(lovefileDir, lovefileName)

    srcDir = "src/"
    blacklist = getBlacklist() + videoBlacklist
    if os.path.exists(zipPath):
        os.remove(zipPath)
    zipDir(srcDir, zipPath, blacklist)

    os.makedirs(releaseDir, exist_ok=True)
    releaseZip = os.path.join(releaseDir, "funkin-vanilla-engine-lovefile.zip")
    if os.path.exists(releaseZip):
        os.remove(releaseZip)
    zipDir(lovefileDir, releaseZip)

    os.remove(os.path.join(srcDir, "LICENSE.txt"))

def buildWin64():
    print("[INFO] Building Windows 64-bit package...")
    winDir = os.path.join(buildDir, "win64")
    os.makedirs(winDir, exist_ok=True)
    shutil.copytree("resources/win64_libs", winDir, dirs_exist_ok=True)

    for dll in [
        "OpenAL32.dll", "SDL2.dll", "license.txt", "lua51.dll",
        "mpg123.dll", "love.dll", "msvcp120.dll", "msvcr120.dll"
    ]:
        shutil.copy(f"resources/win64/love/{dll}", winDir)

    exePath = os.path.join(winDir, "funkin-vanilla-engine.exe")
    with open("resources/win64/love/love.exe", "rb") as f1, \
         open(os.path.join(buildDir, "lovefile", lovefileName), "rb") as f2, \
         open(exePath, "wb") as out:
        out.write(f1.read())
        out.write(f2.read())

    releaseZip = os.path.join(releaseDir, "funkin-vanilla-engine-win64.zip")
    if os.path.exists(releaseZip):
        os.remove(releaseZip)
    zipDir(winDir, releaseZip)

def buildMacos():
    print("[INFO] Building macOS package...")
    appName = "Friday Night Funkin' Vanilla Engine.app"
    macDir = os.path.join(buildDir, "macos", appName)
    os.makedirs(macDir, exist_ok=True)
    shutil.copytree("resources/macos/love.app", macDir, dirs_exist_ok=True)

    shutil.copy(
        os.path.join(buildDir, "lovefile", lovefileName),
        os.path.join(macDir, "Contents/Resources", lovefileName)
    )

    releaseZip = os.path.join(releaseDir, "funkin-vanilla-engine-macos.zip")
    if os.path.exists(releaseZip):
        os.remove(releaseZip)
    zipDir(os.path.join(buildDir, "macos"), releaseZip)

def buildSwitch():
    print("[INFO] Building Nintendo Switch package...")
    switchDir = os.path.join(buildDir, "switch")
    nroDir = os.path.join(switchDir, "switch", "funkin-vanilla-engine")
    os.makedirs(nroDir, exist_ok=True)

    version = open(versionFile).read().strip()
    nacpPath = os.path.join(switchDir, "funkin-vanilla-engine.nacp")

    nacpToolPath = os.path.abspath("tools/nt/switch/nacptool.exe") if os.name == "nt" else "nacptool"
    run([
        nacpToolPath,
        "--create", 
        "Friday Night Funkin' Vanilla Engine",
        "VE Devs",
        version,
        nacpPath
    ])

    romfsDir = os.path.join(switchDir, "romfs")
    os.makedirs(romfsDir, exist_ok=True)
    shutil.copy(
        os.path.join(buildDir, "lovefile", lovefileName),
        os.path.join(romfsDir, "game.love")
    )

    elf2nroPath = os.path.abspath("tools/nt/switch/elf2nro.exe") if os.name == "nt" else "elf2nro"
    run([
        elf2nroPath,
        "resources/switch/love.elf",
        f"{nroDir}/funkin-vanilla-engine.nro",
        "--icon=resources/switch/icon.jpg",
        f"--nacp={nacpPath}",
        f"--romfsdir={romfsDir}"
    ])

    shutil.rmtree(romfsDir)
    os.remove(nacpPath)

    releaseZip = os.path.join(releaseDir, "funkin-vanilla-engine-switch.zip")
    if os.path.exists(releaseZip):
        os.remove(releaseZip)
    zipDir(switchDir, releaseZip)

def clean():
    print("[INFO] Cleaning build directory...")
    shutil.rmtree(buildDir, ignore_errors=True)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("target", nargs="?", default="win64", help="Build target: lovefile, win64, macos, switch, all, clean. Default is 'win64'.")
    parser.add_argument("--imageformat", choices=["png", "dxt5", "astc"], default="dxt5", help="Image format to use. Default is 'dxt5'.")
    parser.add_argument("--block", default="10x10", help="Block size for ASTC compression. Default is 10x10 (Mobile devices).")
    parser.add_argument("--videoformat", choices=["mp4", "ogv"], default="ogv", help="Video format to use. Default is 'ogv'.")
    args = parser.parse_args()

    print(f"[INFO] Selected image format: {args.imageformat}")

    curOS = os.name
    print(f"[INFO] Current OS: {curOS}")

    if args.imageformat not in ["png", "dxt5", "astc"]:
        print(f"[ERROR] Invalid image format: {args.imageformat}. Defaulting to 'dxt5'.")

    with open("src/data/IMAGE_FORMAT.txt", "w") as f:
        f.write(args.imageformat)

    videoBlacklist = []
    if args.videoformat == "ogv":
        videoBlacklist.append("*.mp4")
    elif args.videoformat == "mp4":
        videoBlacklist.append("*.ogv")

    compressAssets(args.imageformat, args.block)

    if args.target == "lovefile":
        buildLovefile()
    elif args.target == "win64":
        if args.imageformat == "astc":
            print("[WARNING] ASTC format will most likely not work on majority of Windows systems. Consider using DXT5 instead. Continuing with ASTC build...")
        if args.imageformat != "dxt5":
            print("[WARNING] It is recommended to use DXT5 for Windows builds.")
        buildLovefile()
        buildWin64()
    elif args.target == "macos":
        if args.imageformat == "astc":
            print("[WARNING] ASTC format will most likely not work on macOS. Consider using DXT5 instead. Continuing with ASTC build...")
        if args.imageformat != "dxt5":
            print("[WARNING] It is recommended to use DXT5 for macOS builds.")
        buildLovefile()
        buildMacos()
    elif args.target == "switch":
        if args.imageformat != "dxt5":
            print("[WARNING] It is recommended to use DXT5 for Nintendo Switch builds.")
        buildLovefile()
        buildSwitch()
    #TODO: Android build support? Maybe appimage too? ASTC 10x10 is recommended for mobile devices.
    elif args.target == "all":
        print("[WARNING] It is recommended to build for each platform separately to avoid issues with incompatible formats.")
        print("[INFO] Building all targets... This may take a while.")
        buildLovefile()
        buildWin64()
        buildMacos()
        buildSwitch()
    elif args.target == "clean":
        clean()
    else:
        print(f"[ERROR] Unknown target: {args.target}")

    if args.imageformat in ["dxt5", "astc"]:
        for root, _, files in os.walk("src/images"):
            for file in files:
                if file.lower().endswith((".dds", ".astc")):
                    os.remove(os.path.join(root, file))
                    print(f"[CLEANUP] Removed {file} from {root}")

        for root, _, files in os.walk("src/assets/"):
            for file in files:
                if file.lower().endswith((".dds", ".astc")):
                    os.remove(os.path.join(root, file))
                    print(f"[CLEANUP] Removed {file} from {root}")


    with open("src/data/IMAGE_FORMAT.txt", "w") as f:
        f.write("png")
