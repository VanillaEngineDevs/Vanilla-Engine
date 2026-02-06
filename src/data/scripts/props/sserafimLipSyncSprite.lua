local sserafimLipSyncSprite = Object:extend()

function sserafimLipSyncSprite:set_shouldSing(v)
    self.shouldSing = v
    if not v then
        self.sprite.curFrame = 1
    end
end

function sserafimLipSyncSprite:new(x, y, suffix)
    suffix = suffix or ""
    self.sprite = graphics.newTextureAtlas()
    self.assetPath = "sserafim/images/sserafim-lipsync" .. suffix

    self.sprite:load("assets/" .. self.assetPath)
    self.sprite:addAnimBySymbol("mouth default", "mouth yunjin", 24, false)
    self.sprite:play("lipsync", true)

    self.x = x
    self.y = y
    self.sprite.x = x
    self.sprite.y = y
    self.scroll = {x = 1, y = 1}
    self.offsets = {0, 0}
    self.angle = 0
    self.shouldSing = false
    self.active = true
end

function sserafimLipSyncSprite:update(dt)
    self.sprite.x = self.x + self.offsets[1]
    self.sprite.y = self.y + self.offsets[2]
    self.sprite.flipX = self.flipX
    self.sprite.flipY = self.flipY
    self.sprite.angle = self.angle
    self.sprite.scroll = self.scroll
    self.sprite:pause()

    if self.sprite.curAnim and self.shouldSing then
        self.sprite.frame = math.floor((musicTime / 1000) * 24) % self.sprite.frameCount
    end
    self.sprite:update(dt)
end

return sserafimLipSyncSprite