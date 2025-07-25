local splash = {}
splash.cache = {}
splash.spr = nil
splash.image = nil

function splash:setup()
    -- called at the start of each song
    if not pixel then
        self.image = love.graphics.newImage(graphics.imagePath("noteSplashes"))
        self.spr = love.filesystem.load("sprites/noteSplashes.lua")
    else
        self.image = love.graphics.newImage(graphics.imagePath("pixel/pixelSplashes"))
        self.spr = love.filesystem.load("sprites/pixel/pixelSplashes.lua")
    end
end

function splash:new(settings, id)
    local s = {}
    s.anim = settings.anim
    s.posX = settings.posX
    s.posY = settings.posY
    s.sprite = self.spr()
    s.sprite.x = s.posX
    s.sprite.y = s.posY
    s.sprite.id = id
    s.sprite:animate(s.anim)

    table.insert(self.cache, s)
end

function splash:update(dt)
    for i, v in ipairs(self.cache) do
        if not v then break end
        v.sprite:update(dt)

        if not v.sprite:isAnimated() then
            table.remove(self.cache, i)
        end
    end
end

function splash:draw()
    for i, v in ipairs(self.cache) do
        if not v then break end
        graphics.setColor(1,1,1,0.5)
        v.sprite:draw()
        graphics.setColor(1,1,1,1)
    end
end

function splash:udraw(sx, sy)
    for i, v in ipairs(self.cache) do
        if not v then break end
        graphics.setColor(1,1,1,0.5)
        v.sprite:udraw(sx, sy)
        graphics.setColor(1,1,1,1)
    end
end

return splash