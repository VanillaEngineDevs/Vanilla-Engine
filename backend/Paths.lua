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
    elseif Cache.members.preload.image[path] then
        return Cache.members.preload.image[path]
    else
        Cache.members.image[path] = love.graphics.newImage(path_)
        return Cache.members.image[path]
    end
end

function Paths.sound(path)
    if Cache.members.sound[path] then
        return Cache.members.sound[path]
    elseif Cache.members.preload.sound[path] then
        return Cache.members.preload.sound[path]
    else
        Cache.members.sound[path] = love.audio.newSource(path, "static")
        return Cache.members.sound[path]
    end
end

function Paths.font(path, size)
    if Cache.members.font[path .. size] then
        return Cache.members.font[path .. size]
    elseif Cache.members.preload.font[path .. size] then
        return Cache.members.preload.font[path .. size]
    else
        Cache.members.font[path .. size] = love.graphics.newFont(path, size)
        return Cache.members.font[path .. size]
    end
end

function Paths.shader(path)
    if Cache.members.shader[path] then
        return Cache.members.shader[path]
    elseif Cache.members.preload.shader[path] then
        return Cache.members.preload.shader[path]
    else
        Cache.members.shader[path] = love.graphics.newShader(path)
        return Cache.members.shader[path]
    end
end

function Paths.getPathFromGraphic(graphic)
    -- returns the full path of the graphic (without extension)
    -- look through Cache.members.image
    for path, image in pairs(Cache.members.image) do
        if image == graphic then
            return path
        end
    end
    
    -- look through Cache.members.preload.image
    for path, image in pairs(Cache.members.preload.image) do
        if image == graphic then
            return path
        end
    end
    
    return nil

end

function Paths.getAtlas(graphic, data) -- either packer or sparrow
    if not data then 
        if type(graphic) == "string" then
            data = graphic
        else
            data = Paths.getPathFromGraphic(graphic)
        end
    end
    -- is extensions included?
    if not data:find(".xml") and not data:find(".txt") then
        -- check if xml exists
        if love.filesystem.getInfo(data .. ".xml") then
            return Paths.getSparrowAtlas(graphic, love.filesystem.read(data .. ".xml"))
        elseif love.filesystem.getInfo(data .. ".txt") then
            return Paths.getPackerAtlas(graphic, data .. ".txt")
        else
            return nil
        end
    end
    if data:find(".xml") then
        return Paths.getSparrowAtlas(graphic, love.filesystem.read(data))
    else
        return Paths.getPackerAtlas(graphic, data)
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

function Paths.getPackerAtlas(graphic, data)
    if type(graphic) == "string" then
        graphic = Paths.image(graphic)
    end

    local frames = {graphic = graphic, frames = {}}
    local sw, sh = graphic:getDimensions()

    local pack = data:trim() -- remove all extra whitespace
    for line in love.filesystem.lines(data) do
        local frameData = line:split("=")
        local name = frameData[1]:trim()
        local frameDimensions = frameData[2]:split(" ")

        table.insert(frames.frames, Sprite.NewFrame(
            name, tonumber(frameDimensions[1]), tonumber(frameDimensions[2]),
            tonumber(frameDimensions[3]), tonumber(frameDimensions[4]),
            sw, sh
        ))
    end

    return frames
end

function Paths.preloadDirectoryImages(path)
    local path_ = "assets/images/" .. Paths.imageType .. "/" .. path
    local imgType = Paths.imageType
    -- does file or cache exist? if not, replace dds with png
    if not love.filesystem.getInfo(path_) or not Cache.members.preload.image[path] then
        path_ = "assets/images/png/" .. path
        imgType = "png"
    end
    
    local files = love.filesystem.getDirectoryItems(path_)
    -- if theres no files, check png's directory
    for i, file in ipairs(files) do
        -- does file end with dds?
        if file:endsWith("." .. imgType) then
            local file_ = file:sub(1, file:len() - 4)
            if not Cache.members.preload.image[path .. "/" .. file_] then
                Cache.members.preload.image[path .. "/" .. file_] = love.graphics.newImage(path_ .. "/" .. file)
            end
        end
    end
end

function Paths.clearPreload()
    -- go through and release all caches, then reset the table
    for path, image in pairs(Cache.members.preload.image) do
        image:release()
    end
    Cache.members.preload.image = {}
    
    for path, sound in pairs(Cache.members.preload.sound) do
        sound:release()
    end
    Cache.members.preload.sound = {}

    for path, font in pairs(Cache.members.preload.font) do
        font:release()
    end
    Cache.members.preload.font = {}

    for path, shader in pairs(Cache.members.preload.shader) do
        shader:release()
    end
    Cache.members.preload.shader = {}

    collectgarbage()
end

function Paths.clearFullCache()
    -- wipe everything
    for path, image in pairs(Cache.members.image) do
        image:release()
    end
    Cache.members.image = {}

    for path, sound in pairs(Cache.members.sound) do
        sound:release()
    end
    Cache.members.sound = {}

    for path, font in pairs(Cache.members.font) do
        font:release()
    end
    Cache.members.font = {}

    for path, shader in pairs(Cache.members.shader) do
        shader:release()
    end
    Cache.members.shader = {}

    collectgarbage()

    Paths.clearPreload()

    Cache.members = {
        image = {},
        sound = {},
        font = {},
        shader = {},
        preload = {
            image = {},
            sound = {},
            font = {},
            shader = {}
        }
    }
end


function Paths.formatToSongPath(path)
    local invalidChars = "[~&\\;:<>#]"
    local hideChars = "[.,'\"%?!]"
    local path = path:gsub(" ", "-"):gsub(invalidChars, "-"):gsub(hideChars, ""):lower()
    return path
end

return Paths