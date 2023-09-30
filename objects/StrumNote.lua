local StrumNote = Sprite:extend()

StrumNote.resetAnim = 0
StrumNote.noteData = 0
StrumNote.direction = 90
StrumNote.downScroll = false
StrumNote.sustainReduce = true
StrumNote.player = 0

StrumNote.graphic = nil

function StrumNote:new(x, y, leData, player)
    self.super.new(self, x, y)
    self.noteData = leData
    self.player = player

    self.skin = PlayState.currentNoteSkin or Note.defaultNoteSkin

    if PlayState.isPixelStage then
        local graphic = Paths.image("pixel/pixelUI/NOTE_assets")
        self:load(graphic, true, graphic:getWidth() / 4, graphic:getHeight() / 5) -- 4 rows, 5 columns

        self.antialiasing = false
        self:setGraphicSize(math.floor(self.width * PlayState.daPixelZoom))

        self:addByTiles("green", {7})
        self:addByTiles("red", {8})
        self:addByTiles("blue", {6})
        self:addByTiles("purple", {5})

        local c = math.abs(self.noteData) % 4

        if c == 0 then
            self:addByTiles("static", {1})
            self:addByTiles("pressed", {5, 9}, 12, false)
            self:addByTiles("confirm", {13, 17}, 24, false)
        elseif c == 1 then
            self:addByTiles("static", {2})
            self:addByTiles("pressed", {6, 10}, 12, false)
            self:addByTiles("confirm", {14, 18}, 24, false)
        elseif c == 2 then
            self:addByTiles("static", {3})
            self:addByTiles("pressed", {7, 11}, 12, false)
            self:addByTiles("confirm", {15, 19}, 24, false)
        elseif c == 3 then
            self:addByTiles("static", {4})
            self:addByTiles("pressed", {8, 12}, 12, false)
            self:addByTiles("confirm", {16, 20}, 24, false)
        end

        self:updateHitbox()
    else
        self:setFrames(Paths.getAtlas(self.skin, "assets/images/png/" .. self.skin .. ".xml"))

        local c = math.abs(self.noteData) % 4

        if c == 0 then
            self:addByPrefix("static", "arrow static instance 1", 24, false)
            self:addByPrefix("pressed", "left press instance 1", 24, false)
            self:addByPrefix("confirm", "left confirm instance 1", 24, false)
        elseif c == 1 then
            self:addByPrefix("static", "arrow static instance 2", 24, false)
            self:addByPrefix("pressed", "down press instance 1", 24, false)
            self:addByPrefix("confirm", "down confirm instance 1", 24, false)
        elseif c == 2 then
            self:addByPrefix("static", "arrow static instance 4", 24, false)
            self:addByPrefix("pressed", "up press instance 1", 24, false)
            self:addByPrefix("confirm", "up confirm instance 1", 24, false)
        elseif c == 3 then
            self:addByPrefix("static", "arrow static instance 3", 24, false)
            self:addByPrefix("pressed", "right press instance 1", 24, false)
            self:addByPrefix("confirm", "right confirm instance 1", 24, false)
        end
        self:updateHitbox()

        self:setGraphicSize(math.floor(self.width * 0.7))
    end
end

function StrumNote:update(dt)
    if self.resetAnim > 0 then
        self.resetAnim = self.resetAnim - dt
        if self.resetAnim <= 0 then
            self:playAnim("static", true)
        end
    end
    self.super.update(self, dt)
end

function StrumNote:postAddedToGroup()
    self:playAnim("static", true)
    self.x = self.x + Note.swagWidth * (self.noteData)
    self.x = self.x + 25
    self.x = self.x + ((push.getWidth()/2) * self.player)
    self.ID = self.noteData

    --print(self.x, self.ID)
end

function StrumNote:playAnim(anim, force)
    self:play(anim, force)
    if self.curAnim then
        self:centerOffsets()
        self:centerOrigin()
    end
end

return StrumNote