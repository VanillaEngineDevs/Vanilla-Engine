-- fastjson.lua - A FAST JSON parser and serializer in pure Lua
-- MIT License - GuglioIsStupid 2026

local sub = string.sub
local byte = string.byte
local tonumber = tonumber
local concat = table.concat
local tostring = tostring
local type = type
local pairs = pairs
local math_huge = math.huge

local json = {}

function json.decode(str)
    local i = 1
    local len = #str

    local function skip()
        while i <= len do
            local c = byte(str, i)
            if c == 32 or c == 9 or c == 10 or c == 13 then -- space, tab, newline, cr
                i = i + 1
            else
                break
            end
        end
    end

    local function parseString()
        local quote = byte(str, i)
        i = i + 1
        local start = i

        while i <= len do
            local c = byte(str, i)
            if c == quote then
                local s = sub(str, start, i - 1)
                i = i + 1
                return s
            elseif c == 92 then -- \
                i = i + 2
            else
                i = i + 1
            end
        end

        error("Unterminated string")
    end

    local function parseNumber()
        local numberStr = str:match("^%-?%d+%.?%d*[eE]?[%-+]?%d*", i) -- lowkey magic
        if not numberStr then
            error("Invalid number at " .. i)
        end
        i = i + #numberStr
        return tonumber(numberStr)
    end

    local parseValue

    local function parseArray()
        i = i + 1
        local arr = {}
        skip()

        if byte(str, i) == 93 then -- ]
            i = i + 1
            return arr
        end

        while true do
            arr[#arr+1] = parseValue()
            skip()

            local c = byte(str, i)
            if c == 44 then -- ,
                i = i + 1
            elseif c == 93 then -- ]
                i = i + 1
                return arr
            else
                error("Expected ',' or ']' at " .. i)
            end
            skip()
        end
    end

    local function parseObject()
        i = i + 1
        local obj = {}
        skip()

        if byte(str, i) == 125 then -- }
            i = i + 1
            return obj
        end

        while true do
            local key = parseString()
            skip()

            if byte(str, i) ~= 58 then -- :
                error("Expected ':' at " .. i)
            end

            i = i + 1
            skip()

            obj[key] = parseValue()
            skip()

            local c = byte(str, i)
            if c == 44 then -- ,
                i = i + 1
            elseif c == 125 then -- }
                i = i + 1
                return obj
            else
                error("Expected ',' or '}' at " .. i)
            end
            skip()
        end
    end

    function parseValue()
        skip()
        local c = byte(str, i)

        if c == 123 then -- {
            return parseObject()
        elseif c == 91 then -- [
            return parseArray()
        elseif c == 34 or c == 39 then -- " or '
            return parseString()
        elseif (c >= 48 and c <= 57) or c == 45 then -- 0-9 or -
            return parseNumber()
        elseif c == 116 and sub(str, i, i+3) == "true" then -- true
            i = i + 4
            return true
        elseif c == 102 and sub(str, i, i+4) == "false" then -- false
            i = i + 5
            return false
        elseif c == 110 and sub(str, i, i+3) == "null" then -- null
            i = i + 4
            return nil
        end

        error("Unexpected character at " .. i)
    end

    local result = parseValue()
    skip()

    if i <= len then
        error("Trailing garbage at " .. i)
    end

    return result
end

function json.encode(value)
    local buffer = {}
    local visited = {}

    local function escapeString(str)
        local start = 1
        buffer[#buffer+1] = '"'

        for i = 1, #str do
            local c = byte(str, i)

            if c == 34 or c == 92 or c < 32 then -- " or \ or control characters
                if i > start then
                    buffer[#buffer+1] = sub(str, start, i-1)
                end

                if c == 34 then -- "
                    buffer[#buffer+1] = '\\"'
                elseif c == 92 then -- \
                    buffer[#buffer+1] = '\\\\'
                elseif c == 8 then -- backspace
                    buffer[#buffer+1] = '\\b'
                elseif c == 12 then -- form feed
                    buffer[#buffer+1] = '\\f'
                elseif c == 10 then -- newline
                    buffer[#buffer+1] = '\\n'
                elseif c == 13 then -- cr
                    buffer[#buffer+1] = '\\r'
                elseif c == 9 then -- tab
                    buffer[#buffer+1] = '\\t'
                else
                    buffer[#buffer+1] = string.format("\\u%04x", c)
                end

                start = i + 1
            end
        end

        if start <= #str then
            buffer[#buffer+1] = sub(str, start)
        end

        buffer[#buffer+1] = '"'
    end

    local function encode(v)
        local tv = type(v)

        if tv == "nil" then
            buffer[#buffer+1] = "null"
        elseif tv == "number" then
            if v ~= v or v == math_huge or v == -math_huge then
                error("Invalid number")
            end
            buffer[#buffer+1] = tostring(v)
        elseif tv == "boolean" then
            buffer[#buffer+1] = v and "true" or "false"
        elseif tv == "string" then
            escapeString(v)
        elseif tv == "table" then
            if visited[v] then
                error("Circular reference")
            end
            visited[v] = true

            local n = #v

            if n > 0 then
                buffer[#buffer+1] = "["
                for i = 1, n do
                    if i > 1 then
                        buffer[#buffer+1] = ","
                    end
                    encode(v[i])
                end
                buffer[#buffer+1] = "]"
            else
                buffer[#buffer+1] = "{"
                local first = true
                for k, val in pairs(v) do
                    if type(k) ~= "string" then
                        error("Object keys must be strings")
                    end
                    if not first then
                        buffer[#buffer+1] = ","
                    end
                    first = false
                    escapeString(k)
                    buffer[#buffer+1] = ":"
                    encode(val)
                end
                buffer[#buffer+1] = "}"
            end

            visited[v] = nil
        else
            error("Unsupported type: " .. tv)
        end
    end

    encode(value)
    return concat(buffer)
end

return json