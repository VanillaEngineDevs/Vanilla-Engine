local Paths = {}

Paths.imageType = "dds"

function Paths.image(path)
    local path_ = "assets/images/" .. Paths.imageType .. "/" .. path .. "." .. Paths.imageType
    -- does file or cache exist? if not, replace dds with png
    if not love.filesystem.getInfo(path_) or not Cache.members.image[path] then
        path_ = "assets/images/png/" .. path .. ".png"
    end
    if Cache.members.image[path] then
        return Cache.members.image[path]
    else
        Cache.members.image[path] = love.graphics.newImage(path_)
        return Cache.members.image[path]
    end
end

function Paths.sound(path)
    if Cache.members.sound[path] then
        return Cache.members.sound[path]
    else
        Cache.members.sound[path] = love.audio.newSource(path, "static")
        return Cache.members.sound[path]
    end
end

function Paths.font(path, size)
    if Cache.members.font[path] then
        return Cache.members.font[path]
    else
        Cache.members.font[path] = love.graphics.newFont(path, size)
        return Cache.members.font[path]
    end
end

function Paths.shader(path)
    if Cache.members.shader[path] then
        return Cache.members.shader[path]
    else
        Cache.members.shader[path] = love.graphics.newShader(path)
        return Cache.members.shader[path]
    end
end

function Paths.getSparrowAtlas(graphic, xmldata)
    if type(graphic) == "string" then
        graphic = Paths.image(graphic)
    end

    local frames = {graphic = graphic, frames = {}}
    local sw, sh = graphic:getDimensions()

    for i, child in ipairs(xml.parse(xmldata)) do
        if child.tag == "SubTexture" then
            table.insert(frames.frames, Sprite.NewFrame(
                child.attr.name,
                tonumber(child.attr.x), tonumber(child.attr.y),
                tonumber(child.attr.width), tonumber(child.attr.height),
                sw, sh,
                tonumber(child.attr.frameX), tonumber(child.attr.frameY),
                tonumber(child.attr.frameWidth), tonumber(child.attr.frameHeight)
            ))
        end
    end

    return frames
end

function Paths.formatToSongPath(path)
    local invalidChars = "[~&\\;:<>#]"
    local hideChars = "[.,'\"%?!]"
    local path = path:gsub(" ", "-"):gsub(invalidChars, "-"):gsub(hideChars, ""):lower()
    return path
end

return Paths