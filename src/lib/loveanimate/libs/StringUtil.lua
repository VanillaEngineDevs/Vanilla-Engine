--[[
    chip.lua: a simple 2D game framework built off of Love2D
    Copyright (C) 2024  swordcube

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local tblInsert = table.insert

---
--- Splits a `string` at each occurrence of `delimiter`.
---
--- @param self      string  The string to split.
--- @param delimiter string  The delimiter to split the string by.
---
function string.split(self, delimiter)
    local result = {}
    local regex = ("([^%s]+)"):format(delimiter)
    for each in self:gmatch(regex) do
        tblInsert(result, each)
    end
    return result
end

---
--- Trims the left and right ends of this `string`
--- to remove invalid characters.
---
--- @param  self  string  The string to trim.
---
function string.trim(self)
    return self:gsub("^%s*(.-)%s*$", "%1")
end

---
--- Returns if the contents of a `string` contains the
--- contents of another `string`. 
---
--- @param self    string  The string to check.
--- @param value  string  What `string` should contain.
---
function string.contains(self, value)
    return self:find(value, 1, true) ~= nil
end

---
--- Returns the index of the first occurrence of `value` in `str`.
---
--- @param self    string  The string to search.
--- @param value  string  What to search for.
---
--- @return integer
---
function string.indexOf(self, value)
    local idx = self:find(value, 1, true)
    return idx or -1
end


---
--- Returns if the contents of a `string` starts with the
--- contents of another `string`. 
---
--- @param self   string  The string to check.
--- @param start  string  What `string` should start with.
---
function string.startsWith(self, start)
    return self:sub(1, #start) == start
end

--- Returns if the contents of a `string` ends with the
--- contents of another `string`. 
---
--- @param self    string  The string to check.
--- @param ending string  What `string` should end with.
---
function string.endsWith(self, ending)
    return ending == "" or self:sub(-#ending) == ending
end

---
--- Gets the last occurrence of `sub` in the string of `str`
--- and returns the index of it.
---
--- @param self  string  The main string in which you want to find the last index of the `sub`.
--- @param sub   string  The substring for which you want to find the last index in the `str`.
---
function string.lastIndexOf(self, sub)
    local subStringLength = #sub
    local lastIndex = -1

    for i = 1, #str - subStringLength + 1 do
        local currentSubstring = self:sub(i, i + subStringLength - 1)
        if currentSubstring == sub then
            lastIndex = i
        end
    end

    return lastIndex
end

--- Replaces all occurrences of `from` in a `string` with
--- the contents of `to`.
---
--- @param self    string  The string to check.
--- @param from   string  The content to be replaced with `to`.
--- @param to     string  The content to replace `from` with.
---
function string.replace(self, from, to)
    local searchStartIdx = 1

    while true do
        local startIdx, endIdx = self:find(from, searchStartIdx, true)
        if (not startIdx) then
            break
        end

        local postfix = self:sub(endIdx + 1)
        str = self:sub(1, (startIdx - 1)) .. to .. postfix

        searchStartIdx = -1 * postfix:len()
    end

    return str
end

---
--- Inserts any given string into another `string`
--- starting at a given character position.
---
--- @param self    string   The string to have content inserted into.
--- @param pos    integer  The character position to insert the new content.
--- @param text   string   The content to insert.
---
function string.insert(self, pos, text)
    return self:sub(1, pos - 1) .. text .. self:sub(pos)
end

---
--- Returns the character of a given string
--- at a certain position of said string.
---
--- @param self string   The string to get this character from.
--- @param pos integer  The position of the character to get.
---
function string.charAt(self, pos)
    return string.sub(self, pos, pos)
end

---
--- Similar to `string.charAt()` but it returns the raw character
--- code of the returned character.
---
--- @param self string   The string to get this character code from.
--- @param pos integer  The position of the character code to get.
---
function string.charCodeAt(self, pos)
    return string.byte(string.charAt(self, pos))
end

--- Pads a given string with a given character
--- (default: whitespace) up to a certain length
--- on the left side of the string.
---
--- @param  str     string   The string to pad.
--- @param  length  integer  The length to pad the string to.
--- @param  char    string   The character to pad the string with. (default: whitespace)
---
function string.lpad(self, length, char)
    return string.rep(char or ' ', length - #self) .. self
end

--- Pads a given string with a given character
--- (default: whitespace) up to a certain length
--- on the right side of the string.
---
--- @param  str     string   The string to pad.
--- @param  length  integer  The length to pad the string to.
--- @param  char    string   The character to pad the string with. (default: whitespace)
---
function string.rpad(self, length, char)
    return self .. string.rep(char or ' ', length - #self)
end