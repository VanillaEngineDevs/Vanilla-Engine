local TankmanBloody = BaseCharacter:extend()

function TankmanBloody:new()
    BaseCharacter.new(self, "sprites/characters/tankmanCaptain.lua")

    self.bloody = false
end

function TankmanBloody:animate(name, ...)
    if self.bloody then
        name = name .. "-bloody"
        self.spr.idlePostfix = "-bloody"
    end

    self.spr:animate(name, ...)

    if name == "redheadsAnim" then
        self.bloody = true
    end
end

return TankmanBloody