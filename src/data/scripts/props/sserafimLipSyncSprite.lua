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
    self.assetPath = weeks.stage.directory .. "/images/sserafim-lipsync" .. suffix
    -- does assets/self.assetPath/spritemap1.json exist?
    -- check for Animation.json now
    self.sprite:load("assets/" .. self.assetPath)
    self.sprite:addAnimByPrefix("lipsync", "ssearafim-lipsync", 24, false)
    self.sprite:play("lipsync", true)

    self.x = x
    self.y = y
    self.scroll = {x = 1, y = 1}
end

function sserafimLipSyncSprite:update(dt)
    self.sprite.x, self.sprite.y = self.x, self.y
    self.sprite.scroll = self.scroll
    
    if self.curAnim and self.shouldSing then
        self.sprite.curFrame = math.floor((musicTime / 1000) * 24) % #self.sprite.curAnim.frames + 1
    end
end

return sserafimLipSyncSprite