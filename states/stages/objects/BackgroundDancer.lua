local BackgroundDancer = Sprite:extend()

function BackgroundDancer:new(x, y)
    self.super.new(self, x, y)

    self:setFrames(Paths.getAtlas("stages/limo/limoDancer", "assets/images/png/stages/limo/limoDancer.xml"))
    self:addByIndices("danceLeft", "bg dancer sketch PINK", {1,2,3,4,5,6,7,8,9,10,11,12,13,14}, 24, false)
    self:addByIndices("danceRight", "bg dancer sketch PINK", {15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30}, 24, false)
    self:play("danceLeft")

    self.dancedir = false
end

BackgroundDancer.danceDir = false

function BackgroundDancer:dance()
    if self.danceDir then
        self:play("danceRight")
    else
        self:play("danceLeft")
    end
end

return BackgroundDancer