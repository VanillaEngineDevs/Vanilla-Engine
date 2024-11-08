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

function table.find(table, element)
    for i, value in ipairs(table) do
        if value == element then
            return i
        end
    end
    return nil
end

function math.remap(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

function table.mergeValues(t1, t2)
    -- add numbers together, concatenate strings
    for k, v in pairs(t2) do
        if type(v) == "number" then
            t1[k] = (t1[k] or 0) + v
        elseif type(v) == "string" then
            t1[k] = (t1[k] or "") .. v
        end
    end
    return t1
end

function table.shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = love.math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end

    return tbl
end

function util.tryExcept(try, except)
    local status, err = pcall(try)
    if not status and except then
        except(err)
    end
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