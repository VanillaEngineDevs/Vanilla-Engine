local baseDirectory = (...):match("(.-)[^%.]+$")
local Classic = require(baseDirectory .. "libs.Classic")

---
--- @class love.animate.SparrowAtlas
---
local SparrowAtlas = Classic:extend()

--[[ local json = require("loveanimate.libs.Json")
local xml = require("loveanimate.libs.Xml")
require("loveanimate.libs.StringUtil") ]]
xml = require(baseDirectory .. "libs.Xml")
require(baseDirectory .. "libs.StringUtil")

local function fileExists(path)
    return love.filesystem.getInfo(path, "file") ~= nil
end

local function getFileContent(path)
    if fileExists(path) then
        local content, _, _, _ = love.filesystem.read("string", path, nil)
        return content --- @type string
    end
    return ""
end

function SparrowAtlas:constructor()
    self.frame = 0
    self.framerate = 24

    self.symbol = ""
    self.playing = false
    self.looping = false

    self.image = nil --- @type love.Image

    --- @protected
    self._frameTimer = 0

    --- @protected
    self._symbols = {} --- @type table[]
end

--- Load the atlas from an image and xml
--- 
--- @param  imageData   love.Image|string  Either a Love2D image instance or an image file path.
--- @param  xmlString   string             Either XML data or an XML file path.
--- @param  framerate?  integer            Framerate of each animation. (This is not specified in the XML, so it must be manually specified) (fallback is 24)
---
function SparrowAtlas:load(imageData, xmlString, framerate)
    if type(imageData) == "string" and fileExists(imageData) then
        imageData = love.graphics.newImage(imageData)
    end
    if fileExists(xmlString) then
        xmlString = getFileContent(xmlString)
    end
    self.image = imageData
    self.framerate = framerate or 24

    local xmlData = xml.parse(xmlString)
    local unsortedSymbols = {}

    for i = 1, #xmlData.TextureAtlas.children do
        local node = xmlData.TextureAtlas.children[i]
        if node.name ~= "SubTexture" then
            goto continue
        end
        local isSparrowV1 = node.att.w ~= nil
        
        local symbolName = node.att.name:sub(1, #node.att.name - 4)
        local frameNumber = tonumber(node.att.name:sub(#node.att.name - 3))

        if not self._symbols[symbolName] then
            local symbol = { frames = {} }
            self._symbols[symbolName] = symbol
            table.insert(unsortedSymbols, symbol)
        end
        local symbolData = self._symbols[symbolName]
        table.insert(symbolData.frames, {
            index = frameNumber,
            quad = love.graphics.newQuad(
                tonumber(node.att.x), tonumber(node.att.y),
                tonumber(isSparrowV1 and node.att.w or node.att.width), tonumber(isSparrowV1 and node.att.h or node.att.height),
                tonumber(imageData:getWidth()), tonumber(imageData:getHeight())
            ),
            offset = {
                x = node.att.frameX ~= nil and -tonumber(node.att.frameX) or 0.0,
                y = node.att.frameY ~= nil and -tonumber(node.att.frameY) or 0.0
            },
            rotated = node.att.rotated ~= nil and node.att.rotated or false
        })
        ::continue::
    end
    for i = 1, #unsortedSymbols do
        local symbol = unsortedSymbols[i]
        table.sort(symbol.frames, function(a, b)
            return a.index < b.index
        end)
    end
end

---
--- @param  symbol   string?
--- @param  looping  boolean?
---
function SparrowAtlas:play(symbol, looping)
    self.frame = 0
    self.symbol = symbol or ""

    self.playing = true
    self._frameTimer = 0.0

    self.looping = looping ~= nil and looping or true
end

function SparrowAtlas:stop()
    self.playing = false
    self._frameTimer = 0.0
end

function SparrowAtlas:resume()
    self.playing = true
end

---
--- @param  symbol  string?
--- @param  frame   integer?
---
--- @return number
---
function SparrowAtlas:getFrameWidth(symbol, frame)
    if not symbol then
        symbol = self.symbol
    end
    if not frame then
        frame = self.frame
    end
    local frameData = self._symbols[symbol].frames[frame + 1]
    local _, _, w, _ = frameData.quad:getViewport()
    return w
end

---
--- @param  symbol  string?
--- @param  frame   integer?
---
--- @return number
---
function SparrowAtlas:getFrameHeight(symbol, frame)
    if not symbol then
        symbol = self.symbol
    end
    if not frame then
        frame = self.frame
    end
    local frameData = self._symbols[symbol].frames[frame + 1]
    local _, _, _, h = frameData.quad:getViewport()
    return h
end

function SparrowAtlas:update(dt)
    if self.framerate <= 0.0 or not self.playing then
        return
    end
    self._frameTimer = self._frameTimer + dt
    if self._frameTimer >= 1.0 / self.framerate then
        local symbol = self._symbols[self.symbol]
        self.frame = self.frame + 1

        if self.frame >= #symbol.frames then
            if self.looping then
                self.frame = 0
            else
                self.frame = #symbol.frames - 1
                self.playing = false
            end
        end
        self._frameTimer = 0.0
    end
end

function SparrowAtlas:draw(x, y, r, sx, sy, ox, oy)
    local symbol = self._symbols[self.symbol]
    local frame = symbol.frames[self.frame + 1]
    
    r = r or 0.0 -- rotation (radians)
    sx = sx or 1.0 -- scale x
    sy = sy or 1.0 -- scale y
    ox = ox or 0.0 -- origin x
    oy = oy or 0.0 -- origin y
    
    local identity = love.math.newTransform()
    identity:translate(x, y)
    
    identity:translate(ox, oy)
    identity:rotate(r)
    identity:scale(sx, sy)
    identity:translate(frame.offset.x, frame.offset.y)
    identity:translate(-ox, -oy)

    love.graphics.draw(self.image, frame.quad, identity)
end

return SparrowAtlas