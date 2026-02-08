local spraycan = Object:extend()

local STATE_ARCING = 2
local STATE_SHOT = 3
local STATE_IMPACTED = 4
--[[ local CURRENT_STATE = STATE_ARCING ]]

function spraycan:new(x, y)
    suffix = suffix or ""
    self.sprite = graphics.newTextureAtlas()
    self.assetPath = "weekend1/images/spraycanAtlas"

    self.sprite:load("assets/" .. self.assetPath)

    self.sprite.scale.x = 0.4
    self.sprite.scale.y = 0.4
    self.sprite:updateHitbox()

    self.sprite.onAnimationFinished:connect(function(name)
        if name == "Can Start" then
            self:playHitPico()
        elseif name == "Can Shot" then
            self.visible = false
        elseif name == "Hit Pico" then
            self:playHitExplosion()
            self.visible = false
        end
    end)

    self.x = x
    self.y = y
    self.sprite.x = x
    self.sprite.y = y
    self.scroll = {x = 1, y = 1}
    self.offsets = {0, 0}
    self.angle = 0
    self.visible = true

    self.currentState = STATE_ARCING
end

function spraycan:update(dt)
    self.sprite.x = self.x + self.offsets[1]
    self.sprite.y = self.y + self.offsets[2]
    self.sprite.flipX = self.flipX
    self.sprite.flipY = self.flipY
    self.sprite.angle = self.angle
    self.sprite.scroll = self.scroll
    self.sprite.visible = self.visible

    self.sprite:update(dt)
end

function spraycan:playHitExplosion()
    local explodeEZ = graphics.newSparrowAtlas()
    explodeEZ:load("assets/weekend1/images/spraypaionExplosionEZ")
    explodeEZ.x, explodeEZ.y = self.x + 1050, self.y + 150
    explodeEZ:addAnimByPrefix("idle", "explosion round 1 short0", 24, false)
    explodeEZ:play("idle")

    weeks:add(explodeEZ)
    explodeEZ.onAnimationFinished:connect(function()
        explodeEZ.visible = false
    end)
end

function spraycan:playCanStart()
    self.sprite:play("Can Start")
end

function spraycan:playCanShot()
    self.sprite:play("Can Shot")
end

function spraycan:playHitPico()
    self.sprite:play("Hit Pico")
end

return spraycan