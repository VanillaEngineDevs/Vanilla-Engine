import os
import json

def is_valid_lua_identifier(key):
    return key.isidentifier() and not key in {"and", "break", "do", "else", "elseif", "end", "false", "for",
                                              "function", "goto", "if", "in", "local", "nil", "not", "or",
                                              "repeat", "return", "then", "true", "until", "while"}

def lua_escape_string(s):
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'

def json_to_lua(obj, indent=0):
    spacing = '    ' * indent
    next_spacing = '    ' * (indent + 1)

    if isinstance(obj, dict):
        result = '{\n'
        for k, v in obj.items():
            if isinstance(k, str) and is_valid_lua_identifier(k):
                key = k
            else:
                key = f'[{lua_escape_string(str(k))}]'
            result += f'{next_spacing}{key} = {json_to_lua(v, indent + 1)},\n'
        result += spacing + '}'
        return result

    elif isinstance(obj, list):
        result = '{\n'
        for v in obj:
            result += f'{next_spacing}{json_to_lua(v, indent + 1)},\n'
        result += spacing + '}'
        return result

    elif isinstance(obj, str):
        return lua_escape_string(obj)
    elif isinstance(obj, bool):
        return 'true' if obj else 'false'
    elif obj is None:
        return 'nil'
    else:
        return str(obj)

def convert_file(json_path):
    with open(json_path, 'r', encoding='utf-8') as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"Failed to parse {json_path}: {e}")
            return

    lua_data = "return " + json_to_lua(data)
    lua_path = os.path.splitext(json_path)[0] + ".lua"
    with open(lua_path, 'w', encoding='utf-8') as f:
        f.write(lua_data)
    print(f"Converted: {json_path} -> {lua_path}")

def convert_all_json_to_lua(root_dir):
    for foldername, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.lower().endswith('.json'):
                convert_file(os.path.join(foldername, filename))

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Convert all .json files to .lua with proper Lua syntax.")
    parser.add_argument("directory", help="Root directory to search for .json files")
    args = parser.parse_args()

    convert_all_json_to_lua(args.directory)
