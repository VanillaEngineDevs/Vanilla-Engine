local util = {}

function util.lerp(a, b, t)
    return a + (b - a) * t
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