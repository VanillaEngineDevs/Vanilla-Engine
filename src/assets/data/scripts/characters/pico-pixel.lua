local deathSpriteNene
local picoDeathExplosion

function Character:onCreate()
    gameoverSubstate.musicSuffix = "-pixel-pico"
    gameoverSubstate.blueBallSuffix = "-pixel-pico"

    local imagesToCache = {
        "shared:characters/nenePixel/nenePixelKnifeToss"
    }

    for _, imgPath in ipairs(imagesToCache) do
        local path = EXTEND_LIBRARY(imgPath)
        graphics.cache[path] = love.graphics.newImage(path .. CURRENT_IMAGE_FORMAT)
    end
end

function Character:postCreate()

end

function Character:play(name, forced, loop)
    if name == "firstDeath" then
        self:createDeathSprites()

        gameoverSubstate:add(deathSpriteNene)
        deathSpriteNene:play("throw")
    end

    self.data:play(name, forced, loop)
end

function Character:createDeathSprites()
    deathSpriteNene = graphics.newSparrowAtlas()
    local gf = girlfriend
    deathSpriteNene:load(EXTEND_LIBRARY("shared:characters/nenePixel/nenePixelKnifeToss", false))
    deathSpriteNene.x = gf.x + 170
    deathSpriteNene.y = gf.y + 100
    deathSpriteNene:setAntialiasing(false)
    deathSpriteNene.scale.x = 6
    deathSpriteNene.scale.y = 6
    deathSpriteNene.zIndex = self.data.zIndex - 5
    deathSpriteNene:addAnimByPrefix("throw", "knifetosscolor0", 24, false)
    deathSpriteNene.visible = true
    deathSpriteNene.onAnimationFinished:connect(function(name)
        deathSpriteNene.visible = false
    end)
end

function Character:onSongRetry()
    gameoverSubstate.musicSuffix = "-pico"
    gameoverSubstate.blueBallSuffix = "-pico"
end

local function randomFloat(min, max)
    return min + love.math.random() * (max - min)
end

function Character:onAnimationFrame(name, frameNumber, _)
    if name == "firstDeath" and frameNumber == 36 then
        gameoverSubstate:startDeathMusic(1, false)
        boyfriend:play("deathLoop", true, true)
    end

    if name == "firstDeath" and frameNumber == 21 then
        hapticUtil:vibrate(0, 0.1, 0.1, 1)
    end

    if name == "deathLoop" and ((frameNumber - 1) % 2 == 0) then
        local randomAmplitude = randomFloat(0.1, 0.5)
        local randomDuration = randomFloat(0.1, 0.3)
        hapticUtil:vibrate(0, randomDuration, randomAmplitude)
    end
end

function Character:getDeathQuote()
    local dadID = enemy and enemy._data and enemy.id or "dad"

    if dadID == "tankman" then
        return "assets/week7/sounds/jeffGameover-pico/jeffGameover-" .. love.math.random(1, 10) .. ".ogg"
    else
        return nil
    end
end
