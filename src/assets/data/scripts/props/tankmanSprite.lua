local tankmanSprite = Object:extend()

function tankmanSprite:new(x, y)
    suffix = suffix or ""
    self.sprite = graphics.newTextureAtlas()
    self.assetPath = "week7/images/tankman_stress"

    self.sprite:load("assets/" .. self.assetPath)
    self.sprite:addAnimBySymbol("run", "Running", 24, true)
    self.sprite:addAnimBySymbol("shot", "Shot " .. love.math.random(1, 2), 24, false)

    self.sprite.scale.x = 0.4
    self.sprite.scale.y = 0.4
    self.sprite:updateHitbox()

    self.x = x
    self.y = y
    self.sprite.x = x
    self.sprite.y = y
    self.scroll = {x = 1, y = 1}
    self.offsets = {0, 0}
    self.angle = 0
    self.active = true

    self.sprite:play("run", true, true)

    self.endingOffset = 0
    self.runSpeed = 0
    self.strumTime = 0
    self.goingRight = false
end

function tankmanSprite:update(dt)
    self.sprite.x = self.x + self.offsets[1]
    self.sprite.y = self.y + self.offsets[2]
    self.sprite.flipX = self.flipX
    self.sprite.flipY = self.flipY
    self.sprite.angle = self.angle
    self.sprite.scroll = self.scroll

    self.sprite:update(dt)

    if self.sprite.curAnim.name == "run" then
        local runFactor = ((weeks.conductor.musicTime - self.strumTime) * self.runSpeed)
        if not self.goingRight then
            self.sprite.x = (1280 * 0.02 - self.endingOffset) + runFactor
        else
            self.sprite.x = (1280 * 0.74 + self.endingOffset) - runFactor
        end
    end
end

function tankmanSprite:clone()
    return clone
end

return tankmanSprite