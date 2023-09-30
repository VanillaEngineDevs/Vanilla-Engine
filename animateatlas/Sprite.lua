local AtlasSprite = Sprite:extend()

local SpriteAnimationLibrary = require("animateatlas.displayobject.SpriteAnimationLibrary")

local utf8 = require("utf8")

function AtlasSprite:new()
    self.super.new(self)
end

function AtlasSprite:construct(path, _excludeArray, noAntialiasing)
    local _excludeArray = _excludeArray or nil
    local noAntialiasing = noAntialiasing or false

    self.frameCollection = {}
    self.frameArray = {}

    if love.filesystem.getInfo("assets/images/" .. path .. "/spritemap1.json") then
        print("Only Spritemaps made with Adobe Animate 2018 are supported.")
        return nil
    end

    print("assets/images/png/" .. path .. "/Animation.json")

    local animationData = json.decode(love.filesystem.read("assets/images/png/" .. path .. "/Animation.json"))
    -- remove The byte order mark
    local atlasData = json.decode(love.filesystem.read("assets/images/png/" .. path .. "/spritemap.json"):sub(4))
    local graphic = Paths.image(path .. "/spritemap")

    local ss = SpriteAnimationLibrary(animationData, atlasData, graphic)
    local t = ss:createAnimation(noAntialiasing)
end

return AtlasSprite