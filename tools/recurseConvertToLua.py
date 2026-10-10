import os
import json

LUA_KEYWORDS = {
    "and", "break", "do", "else", "elseif", "end", "false", "for",
    "function", "goto", "if", "in", "local", "nil", "not", "or",
    "repeat", "return", "then", "true", "until", "while"
}

def isValidLuaIdentifier(key):
    return key.isidentifier() and key not in LUA_KEYWORDS

def luaEscapeString(value):
    return '"' + value.replace('\\', '\\\\').replace('"', '\\"') + '"'

def jsonToLua(obj, indent=0):
    spacing = "    " * indent
    nextSpacing = "    " * (indent + 1)

    if isinstance(obj, dict):
        result = "{\n"
        for key, value in obj.items():
            if isinstance(key, str) and isValidLuaIdentifier(key):
                luaKey = key
            else:
                luaKey = f"[{luaEscapeString(str(key))}]"

            result += f"{nextSpacing}{luaKey} = {jsonToLua(value, indent + 1)},\n"

        result += spacing + "}"
        return result

    if isinstance(obj, list):
        result = "{\n"
        for value in obj:
            result += f"{nextSpacing}{jsonToLua(value, indent + 1)},\n"
        result += spacing + "}"
        return result

    if isinstance(obj, str):
        return luaEscapeString(obj)

    if isinstance(obj, bool):
        return "true" if obj else "false"

    if obj is None:
        return "nil"

    return str(obj)

def convertFile(jsonPath):
    try:
        with open(jsonPath, "r", encoding="utf-8") as file:
            data = json.load(file)
    except json.JSONDecodeError as error:
        print(f"Failed to parse {jsonPath}: {error}")
        return

    luaData = "return " + jsonToLua(data)
    luaPath = os.path.splitext(jsonPath)[0] + ".lua"

    with open(luaPath, "w", encoding="utf-8") as file:
        file.write(luaData)

    print(f"Converted: {jsonPath} -> {luaPath}")

def convertAllJsonToLua(rootDir):
    for folderName, _, fileNames in os.walk(rootDir):
        for fileName in fileNames:
            if fileName.lower().endswith(".json"):
                convertFile(os.path.join(folderName, fileName))

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Convert all .json files to .lua with proper Lua syntax."
    )
    parser.add_argument(
        "directory",
        help="Root directory to search for .json files"
    )

    args = parser.parse_args()
    convertAllJsonToLua(args.directory)
