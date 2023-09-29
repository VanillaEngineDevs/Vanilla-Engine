-- String functions

function string.startsWith(self, str)
    return self:sub(1, #str) == str
end

function string.endsWith(self, str)
    return self:sub(-#str) == str
end

function string.split(self, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function string.ltrim(self)
    local i, r = #self, 1
    while r <= i and self:find("^%s", r) do r = r + 1 end
    return self:sub(r, i)
end

function string.rtrim(self)
    local i, r = #self, 1
    while i >= r and self:find("^%s", i) do i = i - 1 end
    return self:sub(r, i)
end

function string.trim(self)
    return self:ltrim():rtrim()
end

-- Math functions
function math.round(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end

function math.bound(x, min, max)
    return math.min(math.max(x, min), max)
end

function math.remapToRange(x, inMin, inMax, outMin, outMax)
    return outMin + (x - inMin) * ((outMax - outMin) / (inMax - inMin))
end

-- Table overrides
function table.indexOf(t, object)
    for i = 1, #t do
        if t[i] == object then
            return i
        end
    end
    return nil
end

-- Love functions
function love.math.randomIgnore(min, max, ignore)
    local num = love.math.random(min, max)
    if num == ignore then
        return love.math.randomIgnore(min, max, ignore)
    else
        return num
    end
end

function love.math.randomFloat(min, max)
    return min + love.math.random() * (max - min)
end

-- Misc functions

-- function to try a function, and if it fails, run another function
function TryExcept(func1, func2)
    local status, err = pcall(func1)
    if not status then
        func2(err)
    end
end

-- function to convert either #000000 or 0x000000 to {r, g, b, a}
function hexToColor(hex)
    if type(hex) == "string" then
        hex = hex:gsub("#", "")
        return {tonumber("0x" .. hex:sub(1, 2)) / 255, tonumber("0x" .. hex:sub(3, 4)) / 255, tonumber("0x" .. hex:sub(5, 6)) / 255, 1}
    elseif type(hex) == "number" then
        return {bit.rshift(hex, 16) / 255, bit.band(bit.rshift(hex, 8), 0xFF) / 255, bit.band(hex, 0xFF) / 255, 1}
    end
end