local SpriteSymbol = Sprite:extend()

function SpriteSymbol:new(data, library, texture)
    self.currentLabel = ""
    self.currentFrame = 1
    self.type = "symbol"
    self.loopMode = ""
    self.symbolName = ""
    self.numLayers = 0
    self.numFrames = 0

    self._data = nil
    self._library = nil
    self._symbolName = ""
    self._type = ""
    self._loopMode = ""

    self._currentFrame = 1
    self._composedFrame = 1
    self._members = {} -- all sprites are added here, to then to all be drawn
    self._numFrames = 0
    self._numLayers = 0
    self._frameLabels = {}
    self._layers = {}
    self._texture = nil
    self._tempRect = {x=0, y=0, w=0, h=0}
    self._zeroPoint = {x=0, y=0}
    self.smoothing = true

    self.sMatrix = love.math.newTransform()

    self.super.new(self)
    self._data = data
    self._library = library
    self._composedFrame = -1
    self._numLayers = #data.TIMELINE.LAYERS 
    self._numFrames = self:getNumFrames()
    self._symbolName = data.SYMBOL_name
    self._type = "graphic"
    self._loopMode = true
    self._texture = texture

    self:createLayers()

    for i, layer in ipairs(data.TIMELINE.LAYERS) do
        if not Layer.FrameMap then
            return
        end

        local map = {}

        for i = 1, #layer.Frames do
            local frame = layer.Frames[i]
            for j = 1, frame.duration do
                table.insert(map, i+j, frame)
            end
        end 

        layer.FrameMap = map
    end

    return self
end

function SpriteSymbol:reset()
    self.transform.matrix = love.math.newTransform()
    self.alpha = 1
    self._currentFrame = 1
    self._composedFrame = -1
end

function SpriteSymbol:nextFrame()
    if self.loopMode ~= "SINGLE_FRAME" then
        self.currentFrame = self.currentFrame + 1
    end

    self:moveMovieclip_MovieClips(1)
end

function SpriteSymbol:prevFrame()
    if self.loopMode ~= "SINGLE_FRAME" then
        self.currentFrame = self.currentFrame - 1
    end

    self:moveMovieclip_MovieClips(-1)
end

function SpriteSymbol:moveMovieclip_MovieClips(direction)
    local direction = direction or 1

    if self._type == "MOVIE_CLIP" then
        self.currentFrame = self.currentFrame + direction
    end

    for l = 1, self._numLayers do
        self layer = getLayer(1)
        local numElements = later.numChildren

        for e = 1, numElements do
            TryExcept(
                function()
                    layer.members[e]:moveMovieclip_MovieClips(direction)
                end,
                function()

                end
            )
        end
    end
end

function SpriteSymbol:update()
    for i = 1, self._numLayers do
        self:updateLayer(i)
    end 

    self._composedFrame = self.currentFrame
end

function SpriteSymbol:updateLayer(layerIndex)

end