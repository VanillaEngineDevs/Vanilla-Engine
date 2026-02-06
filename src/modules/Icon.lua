return {
    imagePath = function(path)
        return graphics.imagePath("icons/icon-" .. (path or "bf"))
    end,
    newIcon = function(path, scale, dontCalculateColour)
        if not graphics.cache[path .. "imgdata"] then
            local newPath = path:gsub("/dds/", "/png/")
            newPath = newPath:gsub(".dds$", ".png")
            graphics.cache[path .. "imgdata"] = love.image.newImageData(newPath)
        end
        if not graphics.cache[path] then
            graphics.cache[path] = love.graphics.newImage(graphics.cache[path .. "imgdata"])
        end
        local imgdata = graphics.cache[path .. "imgdata"]
        local img = graphics.cache[path]
        if path:find("pixel") then
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
            mostCommonColour = {1, 1, 1, 1},

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

        if dontCalculateColour then return object end
        
        -- find the most common colour
        local data = {}
        for i = 0, img:getWidth() - 1 do
            for j = 0, img:getHeight() - 1 do
                local r, g, b, a = imgdata:getPixel(i, j)
                if a > 0 and (r > 0 or g > 0 or b > 0) then
                    local key = string.format("%d,%d,%d", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
                    data[key] = (data[key] or 0) + 1
                end
            end
        end

        local maxCount = 0
        local maxKey = nil
        for key, count in pairs(data) do
            if count > maxCount then
                maxCount = count
                maxKey = key
            end
        end

        if maxKey then
            local r, g, b = maxKey:match("(%d+),(%d+),(%d+)")
            r = tonumber(r) / 255
            g = tonumber(g) / 255
            b = tonumber(b) / 255
            object.mostCommonColour = {r, g, b, 1}
        end

        return object
    end,
}