local util = {}

function util.lerp(a, b, t)
    return a + (b - a) * t
end

function util.coolLerp(a, b, t)
    return util.lerp(a, b, t * 60 * love.timer.getDelta())
end

function util.clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end

function util.randomFloat(min, max)
	return min + love.math.random() * (max - min)
end

function util.startsWith(str, start)
    return str:sub(1, #start) == start
end

function util.endsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function util.round(x) 
    return x >= 0 and math.floor(x + .5) or math.ceil(x - .5) 
end

function util.split(str, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function util.bound(x, min, max)
    return math.min(math.max(x, min), max)
end

-- math overrides
-- @param n number
-- @return an approximated sine value
-- A faster but slightly less accurate version of math.sin
-- https://github.com/HaxeFlixel/flixel/blob/dev/flixel/math/FlxMath.hx#L503
function math.fastSin(n)
    n = n * 0.3183098862
    if n > 1 then
        --n -= (Math.ceil(n) >> 1) << 1;
        n = n - bit.rshift(bit.lshift(math.ceil(n), 1), 1) * 2
    elseif n < -1 then
        --n += (Math.ceil(-n) >> 1) << 1;
        n = n + bit.rshift(bit.lshift(math.ceil(-n), 1), 1) * 2
    end

    if n > 0 then
        return n * (3.1 + n * (0.5 + n * (-7.2 + n * 3.6)))
    else
        return n * (3.1 - n * (0.5 + n * (7.2 + n * 3.6)))
    end
end

-- @param n number
-- @return an approximated cosine value
function math.fastCos(n)
    return math.fastSin(n + 1.570796327)
end

function math.roundDecimal(value, precision)
    local power = 10 ^ precision
    return math.floor(value * power + 0.5) / power
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function table.getKey(table, value)
    for k, v in pairs(table) do
        if v == value then
            return k
        end
    end
    return nil
end

function math.remapToRange(value, from1, to1, from2, to2)
    return (value - from1) / (to1 - from1) * (to2 - from2) + from2
end

-- God like coding
--[[
function util.🍰(🥰, 🥵)
    🥰 = 🥰 or 🥵
    🥵 = 🥵 or 🥰
    return 🥰 + 🥵
end

function util.🍩(🥰, 🥵)
    🥰 = 🥰 or 🥵
    🥵 = 🥵 or 🥰
    return 🥰 * 🥵
end

function util.☠️(🥰, 🥵)
    🥰 = 🥰 or 🥵
    🥵 = 🥵 or 🥰
    return 🥰 / 🥵
end

function util.😍(☠️)
    return math.floor(☠️)
end

function util.❓⌚()
    local ⌚️= os.time()

    local 🆕📅 = os.date("*t", ⌚️)

    return 🆕📅
end

function util.📅()
    local 🆕📅 = util.❓⌚()
    return 🆕📅.year .. "-" .. 🆕📅.month .. "-" .. 🆕📅.day
end

print(util.📅())
--]]
return util