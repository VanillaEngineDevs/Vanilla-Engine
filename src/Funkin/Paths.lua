--- Full asset path formatting
---@class Paths
local Paths = {}

--- The current level
---@type (string | nil)
Paths.currentLevel = nil

---@param level string current level
--- Sets the current level
---@return nil
function Paths.setCurrentLevel(level)
    Paths.currentLevel = string.lower(level)
end

---@param file string file path
---@param library? string library
---@return string the path to the file
--- Retuns the path to the file 
function Paths.getPath(file, library)
    --[[ return "assets/" .. file ]]

    if library ~= nil then
        return Paths.getLibraryPath(file, library)
    end

    if Paths.currentLevel ~= nil then
        local levelPath = Paths.getLibraryPathForce(file, Paths.currentLevel)
        if love.filesystem.getInfo(levelPath) then
            return levelPath
        end
    end

    local levelPath = Paths.getLibraryPath(file, "shared")

    if love.filesystem.getInfo(levelPath) then
        return levelPath
    end

    return "assets/" .. file
end

---@param file string file path
---@param library string library
---@return string the path
function Paths.getLibraryPath(file, library)
    return ((library == "preload" or library == "default") and "assets/" .. file) or Paths.getLibraryPathForce(file, library)
end

---@param file string file path
---@param library string library
---@return string the path
function Paths.getLibraryPathForce(file, library)
    return "assets/" .. library .. "/" .. file
end

---@param file string file path
---@return string the path to the file
--- Returns the path to the file
function Paths.file(file)
    --[[ return "assets/" .. file ]]
    return Paths.getPath(file)
end

---@param key string txt file
---@return string the path to the txt file
--- Returns the path to the txt file
function Paths.txt(key)
    return Paths.getPath("data/" .. key .. ".txt")
end

---@param key string frag file
---@return string the path to the frag file
--- Returns the path to the frag file
function Paths.frag(key)
    return Paths.getPath("shaders/" .. key .. ".frag")
end

---@param key string vert file
---@return string the path to the vert file
--- Returns the path to the vert file
function Paths.vert(key)
    return Paths.getPath("shaders/" .. key .. ".vert")
end

---@param key string xml file
---@return string the path to the xml file
--- Returns the path to the xml file
function Paths.xml(key)
    return Paths.getPath("data/" .. key .. ".xml")
end

---@param key string json file
---@return string the path to the json file
--- Returns the path to the json file
function Paths.json(key)
    return Paths.getPath("data/" .. key .. ".json")
end

---@param key string sound file
---@return string the path to the sound file
--- Returns the path to the sound file
function Paths.sound(key)
    return Paths.getPath("sounds/" .. key .. ".ogg")
end

---@param key string sound file
---@return string the path to the sound file
--- Returns the path to the sound file
function Paths.music(key)
    return Paths.getPath("music/" .. key .. ".ogg")
end

---@param song string song name
---@param suffix string suffix
---@return string the path to the inst file
function Paths.inst(song, suffix)
    local ext = Constants.EXT_SOUND
    return Paths.getPath("songs/" .. string.lower(song) .. "/Inst" .. suffix .. "." .. ext)
end

---@param song string song name
---@param suffix string suffix
---@return string the path to the voices file
function Paths.voices(song, suffix)
    local ext = Constants.EXT_SOUND
    return Paths.getPath("songs/" .. string.lower(song) .. "/Voices" .. suffix .. "." .. ext)
end

---@param key string image path
---@return string the path to the image file
--- Returns the path to the image file
function Paths.image(key)
    return Paths.getPath("images/" .. key .. ".png")
end

---@param key string sound file
---@param min integer min value
---@param max integer max value
---@return string the path to the sound file
--- Returns the path to the random sound file
function Paths.soundRandom(key, min, max)
    return Paths.getPath("sounds/" .. key .. love.math.random(min, max) .. ".ogg")
end

---@param key string path to image/xmlsheet
---@return ({frames: table<frame>, graphic: love.Drawable} | nil)
function Paths.getSparrowAtlas(key)
    local graphicPath, xmlPath = Paths.image(key), Paths.file("images/" .. key .. ".xml")
    local graphic = Graphic:getGraphic(graphicPath)
    local obj = {frames = {}, graphic = graphic}
    if graphic and love.filesystem.getInfo(xmlPath) then
        local sw, sh = graphic:getDimensions()
        ---@diagnostic disable-next-line: empty-block, param-type-mismatch
        for _, child in ipairs(Xml.parse(love.filesystem.read(xmlPath))) do
            if child.tag == "SubTexture" then
                table.insert(obj.frames, Sprite.CreateFrame(
                    child.attr.name,
                    tonumber(child.attr.x), tonumber(child.attr.y),
                    tonumber(child.attr.width), tonumber(child.attr.height),
                    sw, sh,
                    tonumber(child.attr.frameX), tonumber(child.attr.frameY),
                    tonumber(child.attr.frameWidth), tonumber(child.attr.frameHeight)
                ))
            end
        end
    end

    return obj
end

return Paths