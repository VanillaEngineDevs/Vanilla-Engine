return {
    imagePath = function(path)
        return graphics.imagePath("icons/icon-" .. (path or "bf"))
    end,
    newIcon = function(path, scale)
        if not graphics.cache[path] then
            graphics.cache[path] = love.graphics.newImage(path)
        end
        local img = graphics.cache[path]
        if path:find("-pixel") then
            img:setFilter("nearest")
        end
        local frameData = {
            {
                x = 0, y = 0, 
                width = img:getWidth()/2, height = img:getHeight(), 
                offsetX = 0, offsetY = 0, 
                offsetWidth = img:getWidth()/2, offsetHeight = img:getHeight(), 
                rotated = false
            },
            {
                x = img:getWidth()/2, y = 0, 
                width = img:getWidth(), height = img:getHeight(), 
                offsetX = 0, offsetY = 0, 
                offsetWidth = img:getWidth()/2, offsetHeight = img:getHeight(), 
                rotated = false
            }
        }
        local image, width, height
        local frames = {}
        local frame
        local anims = {}
        local quads = {}
        for i, frame in ipairs(frameData) do
            quads[i] = love.graphics.newQuad(frame.x, frame.y, frame.width, frame.height, img:getDimensions())
        end
        frame = quads[1]
        local curFrame = 1
        -- 2 frames, width = img:getWidth()/2, height = img:getHeight()
        --{x = 212, y = 0, width = 68, height = 196, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0, rotated = false}, -- <- example frame data

        local object = {
            x = 0,
			y = 0,
			orientation = 0,
			sizeX = 1,
			sizeY = 1,
			offsetX = 0,
			offsetY = 0,
			shearX = 0,
			shearY = 0,
            scale = scale or 1,

			scrollFactor = {x=1,y=1},

            clipRect = nil,
			stencilInfo = nil,

			alpha = 1,

            flipX = false,
            visible = true,

            setFrame = function(self, frameNum)
                curFrame = frameNum
                frame = quads[frameNum]
            end,

            getCurFrame = function(self)
                return curFrame
            end,

            update = function(self, dt)
                
            end,

            draw = function(self)
                if not self.visible then return end

                local ox = frameData[curFrame].offsetWidth/2 + frameData[curFrame].offsetX
                local oy = frameData[curFrame].offsetHeight/2 + frameData[curFrame].offsetY

                love.graphics.draw(img, frame, self.x, self.y, self.orientation, self.sizeX * self.scale, self.sizeY * self.scale, ox, oy)
            end
        }

        return object
    end,
}