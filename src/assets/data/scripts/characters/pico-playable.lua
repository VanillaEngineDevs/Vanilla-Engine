local deathSpriteNene, deathSpriteRetry
local picoDeathExplosion

function Character:onCreate()
    gameoverSubstate.musicSuffix = "-pico"
    gameoverSubstate.blueBallSuffix = "-pico"

    local imagesToCache = {
        "shared:characters/Pico_Death_Retry",
        "shared:characters/NeneKnifeToss",
        "weekend1:characters/picoExplosionDeath/spritemap1",
        "weekend1:PicoBullet"
    }

    for _, imgPath in ipairs(imagesToCache) do
        local path = EXTEND_LIBRARY(imgPath)
        if imgPath:startsWith("weekend1:") and weeks.metadata.level ~= "weekend1" then
            goto continue
        end

        graphics.cache[path] = love.graphics.newImage(path .. CURRENT_IMAGE_FORMAT)

        ::continue::
    end
end

function Character:postCreate()
    self.data.x = self.data.x + 15
    self.data.y = self.data.y + 30
end

function Character:play(name, forced, loop)
    if name == "burpShit" or name == "burpSmile" or name == "burpSmileLong" then
        if voicesBF then
            voicesBF:setVolume(1)
        end
    end

    if name == "firstDeath" then
        if gameoverSubstate.blueBallSuffix == "-pico-explode" then
        else
            self:createDeathSprites()

            gameoverSubstate:add(deathSpriteRetry)
            gameoverSubstate:add(deathSpriteNene)
            deathSpriteNene:play("throw")
        end
    elseif name == "deathConfirm" then
        if picoDeathExplosion ~= nil then
            -- self:doExplosionConfirm()
        else
            deathSpriteRetry:play("confirm")
            deathSpriteRetry.x = deathSpriteRetry.x - 250
            deathSpriteRetry.y = deathSpriteRetry.y - 200

            return
        end
    end

    self.data:play(name, forced, loop)
end

function Character:createDeathSprites()
    deathSpriteRetry = graphics.newSparrowAtlas()
    deathSpriteRetry:load(EXTEND_LIBRARY("shared:characters/Pico_Death_Retry", false))
    if self.shader then
        deathSpriteRetry.shader = self.shader
    end
    deathSpriteRetry:addAnimByPrefix("idle", "Retry Text Loop0", 24, true)
    deathSpriteRetry:addAnimByPrefix("confirm", "Retry Text Confirm0", 24, false)

    deathSpriteRetry.zIndex = self.data.zIndex + 5
    deathSpriteRetry.visible = false

    deathSpriteNene = graphics.newSparrowAtlas()
    local gf = girlfriend
    deathSpriteNene:load(EXTEND_LIBRARY("shared:characters/NeneKnifeToss", false))
    deathSpriteNene.x = gf.x - 50
    deathSpriteNene.y = gf.y - 180
    deathSpriteNene.zIndex = self.data.zIndex - 5
    deathSpriteNene:addAnimByPrefix("throw", "knife toss0", 24, false)
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
        if deathSpriteRetry ~= nil then
            deathSpriteRetry:play("idle", true, true)
            deathSpriteRetry.visible = true

            deathSpriteRetry.x = self.data.x + 170
            deathSpriteRetry.y = self.data.y - 105
        end

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
