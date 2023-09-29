local BackgroundGirls = Sprite:extend()

BackgroundGirls.isPissed = true
BackgroundGirls.danceDir = false

function BackgroundGirls:new(x, y)
    self.isPissed = true
    self.danceDir = false

    self.super.new(self, x, y)

    self:setFrames(Paths.getAtlas("stages/school/bgFreaks", "assets/images/png/stages/school/bgFreaks.xml"))
    self.antialiasing = false
    self:swapDanceType()

    self:setGraphicSize(math.floor(self.width * PlayState.daPixelZoom))

    self.camera = PlayState.camGame
    
    self:play("danceLeft")
end

function BackgroundGirls:swapDanceType()
    self.isPissed = not self.isPissed

    if not self.isPissed then
        self:addByIndices("danceLeft", "BG girls group", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}, 24, false)
        self:addByIndices("danceRight", "BG girls group", {17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30}, 24, false)
    else
        self:addByIndices("danceLeft", "BG fangirls dissuaded", {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}, 24, false)
        self:addByIndices("danceRight", "BG fangirls dissuaded", {17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30}, 24, false)
    end
end

function BackgroundGirls:dance()
    self.danceDir = not self.danceDir

    if self.danceDir then
        self:play("danceRight", true)
    else
        self:play("danceLeft", true)
    end
end

return BackgroundGirls