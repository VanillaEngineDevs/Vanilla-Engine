local DadBattleFog = Group:extend()

function DadBattleFog:new()
    self.super.new(self)

    self.alpha = 0
    self.visible = false

    local offsetX = 200

    local smoke = BGSprite("stages/stage/smoke", -1550 + offsetX, 660 + love.math.random(-20, 20), 1.2, 1.05)
    smoke:setGraphicSize(math.floor(smoke.width * love.math.random(1.1, 1.22)))
    smoke:updateHitbox()
    smoke.velocity.x = love.math.random(15, 22)
    smoke.active = true
    smoke.blend = "add"
    self:add(smoke)

    local smoke = BGSprite("stages/stage/smoke", 1550 + offsetX, 660 + love.math.random(-20, 20), 1.2, 1.05)
    smoke:setGraphicSize(math.floor(smoke.width * love.math.random(1.1, 1.22)))
    smoke:updateHitbox()
    smoke.velocity.x = -love.math.random(15, 22)
    smoke.active = true
    smoke.flipX = true
    smoke.blend = "add"
    self:add(smoke)
end

function DadBattleFog:draw()
    -- instead of calling the super, just draw members here cuz we gotta modify some vars and shits
    if not self.visible then return end

    for _, member in ipairs(self.members) do
        if member.visible then
            member.alpha = self.alpha
            member:draw()
        end
    end
end

return DadBattleFog