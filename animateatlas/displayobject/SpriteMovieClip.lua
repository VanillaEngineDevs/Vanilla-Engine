local SpriteMovieClip = Sprite:extend()

function SpriteMovieClip:new(symbol)
    self.framerate = 24
    self.currentLabel = ""
    self.currentFrame = 1
    self.type = ""
    self.loopMode = ""
    self.symbolName = ""
    self.numLayers = 0
    self.numFrames = 0
    self.layers = {}
    self.members = {}

    self.symbol = symbol
    self._framerate = nil

    self.frameElapsed = 0

    self.super.new(self)

    table.insert(self.members, self.symbol)

    return self
end

function SpriteMovieClip:update(dt)
    local frameDuration = 1000 / self.framerate
    self.frameElapsed = self.frameElapsed + dt

    while self.frameElapsed > frameDuration do
        self.frameElapsed = self.frameElapsed + frameDuration
        symbol:nextFrame()
    end

    while self.frameElapsed < -frameDuration do
        self.frameElapsed = self.frameElapsed - frameDuration
        symbol:prevFrame()
    end
end

function SpriteMovieClip:getFrameLabels()
    return symbol:getFrameLabels()
end

function SpriteMovieClip:getFrame(label)
    return symbol:getFrame(label)
end

return SpriteMovieClip