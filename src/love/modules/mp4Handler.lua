---@diagnostic disable: undefined-global
--https://github.com/semyon422/aqua/blob/27ae6a4ab6ae40c0bd68d94b3f14a88607fe0120/video/video.lua
-- CURRENTLY ONLY SUPPORTS WINDOWS x64. PLEASE USE LOVE2D'S BUILT-IN .ogv SUPPORT FOR NOW.
-- ALSO ITS NOT EVEN ADDED YET LMFAO
if love.system.getOS() == "Windows" then
    Try(
        function()
            mp4Handler = require("video")
        end,
        function()
            mp4Handler = nil
            print("Couldn't load video.")
        end
    )
end

---@class Video
---@diagnostic disable-next-line: assign-type-mismatch
local Video = Object:extend()

function Video:new(fileData)
    if not mp4Handler then return nil, "Couldn't load video." end
    local vid = mp4Handler.open(fileData:getPointer(), fileData:getSize())
    if not vid then return nil, "Couldn't open video." end

    self.video = vid
    self.fileData = fileData
    self.imageData = love.image.newImageData(vid:getDimensions())
    self.image = love.graphics.newImage(self.imageData)

    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.time = 0
    self.lastFrameTime = 0

    return self
end

function Video:update(dt)
    self.time = self.time + dt
    self:play(self.time)
end

function Video:release()
    self.video:close()
    self.imageData:release()
    self.image:release()
end

function Video:rewind()
    local vid = self.video
    vid:seek(0)
    vid:read(self.imageData:getPointer())
end

function Video:play(time)
    local time = time or 0
    local vid = self.video
    
    while time >= vid:tell() do
        if not vid:read(self.imageData:getPointer()) then
            break
        end
    end
    self.image:replacePixels(self.imageData)
end

function Video:getWidth()
    return self.width
end

function Video:getHeight()
    return self.height
end

function Video:getDimensions()
    return self.width, self.height
end

function Video:isDone()
end

return Video