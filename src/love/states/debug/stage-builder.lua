---@diagnostic disable: param-type-mismatch
local builder = {}

local objects = {}
local curObject = 1
local mxOffset, myOffset = 0, 0
local function sortObjects()
    table.sort(objects, function(a, b)
        return a.z < b.z
    end)
end

local curState = "objects"

local outputStr = ""

local buttons = {
    {
        x = 10,
        y = 10,
        width = 100,
        height = 30,
        text = "staticObjects",
        hovered = false,
        pressed = false,
        action = function()
            curState = "staticObjects"
        end,
        draw = function(self)
            if self.pressed then
                graphics.setColor(0.5, 0.5, 0.5)
            elseif self.hovered then
                graphics.setColor(0.7, 0.7, 0.7)
            else
                graphics.setColor(1, 1, 1)
            end
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
            graphics.setColor(0, 0, 0)
            love.graphics.printf(self.text, self.x, self.y + 5, self.width, "center")
        end
    },
    {
        x = 120,
        y = 10,
        width = 100,
        height = 30,
        text = "create",
        hovered = false,
        pressed = false,
        action = function()
            local obj = graphics.newImage()
            local img = love.image.newImageData(50, 50)
            for x = 0, 49 do
                for y = 0, 49 do
                    img:setPixel(x, y, 1, 1, 1, 1)
                end
            end
            obj:setImage(love.graphics.newImage(img))
            obj.x = 0
            obj.y = 0
            obj.z = #objects
            obj.ver = "staticObjects"
            obj.updates = false
            table.insert(objects, obj)
            sortObjects()
        end,
        draw = function(self)
            if self.pressed then
                graphics.setColor(0.5, 0.5, 0.5)
            elseif self.hovered then
                graphics.setColor(0.7, 0.7, 0.7)
            else
                graphics.setColor(1, 1, 1)
            end
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
            graphics.setColor(0, 0, 0)
            love.graphics.printf(self.text, self.x, self.y + 5, self.width, "center")
        end
    },
    {
        x = 230,
        y = 10,
        width = 100,
        height = 30,
        text = "delete",
        hovered = false,
        pressed = false,
        action = function()
            table.remove(objects, curObject)
            curObject = math.min(curObject, #objects)
            sortObjects()
        end,
        draw = function(self)
            if self.pressed then
                graphics.setColor(0.5, 0.5, 0.5)
            elseif self.hovered then
                graphics.setColor(0.7, 0.7, 0.7)
            else
                graphics.setColor(1, 1, 1)
            end
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
            graphics.setColor(0, 0, 0)
            love.graphics.printf(self.text, self.x, self.y + 5, self.width, "center")
        end
    },
    {
        x = 340,
        y = 10,
        width = 100,
        height = 30,
        text = "export",
        hovered = false,
        pressed = false,
        action = function()
            local enterCode = [[    stageImages = {
]]
            for _, obj in ipairs(objects) do
                if obj.name ~= "boyfriend" and obj.name ~= "girlfriend" and obj.name ~= "enemy" then
                    enterCode = enterCode .. "\n\t\t[\"" .. obj.name .. "\"] = graphics.newImage(graphics.imagePath(\"" .. obj.filename .. "\")),"
                end
            end

            enterCode = enterCode .. [[    }
]]
            for _, obj in ipairs(objects) do
                if obj.name ~= "boyfriend" and obj.name ~= "girlfriend" and obj.name ~= "enemy" then
                    enterCode = enterCode .. "    stageImages[\"" .. obj.name .. "\"].x, stageImages[\"" .. obj.name .. "\"].y = " .. obj.x .. ", " .. obj.y .. "\n"
                    enterCode = enterCode .. "    stageImages[\"" .. obj.name .. "\"].sizeX, stageImages[\"" .. obj.name .. "\"].sizeY = " .. obj.sizeX .. ", " .. obj.sizeY .. "\n"
                    enterCode = enterCode .. "    stageImages[\"" .. obj.name .. "\"].scrollX, stageImages[\"" .. obj.name .. "\"].scrollY = " .. obj.scrollX .. ", " .. obj.scrollY .. "\n"
                else
                    enterCode = enterCode .. "    " .. obj.name .. ".x, " .. obj.name .. ".y = " .. obj.x .. ", " .. obj.y .. "\n"
                    enterCode = enterCode .. "    " .. obj.name .. ".sizeX, " .. obj.name .. ".sizeY = " .. obj.sizeX .. ", " .. obj.sizeY .. "\n"
                    enterCode = enterCode .. "    " .. obj.name .. ".scrollX, " .. obj.name .. ".scrollY = " .. obj.scrollX .. ", " .. obj.scrollY .. "\n"
                end

                enterCode = enterCode .. "\n"
            end

            outputStr = outputStr:gsub("<enter>", enterCode)

            local loadCode = [[]]

            outputStr = outputStr:gsub("<load>", loadCode)

            local updateCode = [[]]

            for _, obj in ipairs(objects) do
                if obj.updates then
                    updateCode = updateCode .. "    " .. obj.name .. ":update(dt)\n"
                end
            end

            outputStr = outputStr:gsub("<update>", updateCode)

            local drawCode = [[]]

            for _, obj in ipairs(objects) do
                if obj.name ~= "boyfriend" and obj.name ~= "girlfriend" and obj.name ~= "enemy" then
                    drawCode = drawCode .. "    drawObj(stageImages[\"" .. obj.name .. "\"])\n"
                else
                    drawCode = drawCode .. "    " .. obj.name .. ":draw()\n"
                end
            end

            outputStr = outputStr:gsub("<draw>", drawCode)

            local leaveCode = [[]]

            outputStr = outputStr:gsub("<leave>", leaveCode)
            love.filesystem.createDirectory("stages")
            love.filesystem.write("stages/stage-" .. os.time() .. ".lua", outputStr)
            local system = love.system.getOS()
            if system == "Windows" then
                os.execute("start " .. love.filesystem.getSaveDirectory() .. "/stages")
            elseif system == "Linux" then
                os.execute("xdg-open " .. love.filesystem.getSaveDirectory() .. "/stages")
            elseif system == "OS X" then
                os.execute("open " .. love.filesystem.getSaveDirectory() .. "/stages")
            end
        end,
        draw = function(self)
            if self.pressed then
                graphics.setColor(0.5, 0.5, 0.5)
            elseif self.hovered then
                graphics.setColor(0.7, 0.7, 0.7)
            else
                graphics.setColor(1, 1, 1)
            end
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
            graphics.setColor(0, 0, 0)
            love.graphics.printf(self.text, self.x, self.y + 5, self.width, "center")
        end
    }
}

local sliders = {
    {
        x = 10,
        y = 50,
        width = 100,
        height = 10,
        value = 0,
        low = -1000,
        high = 1000,
        hovered = false,
        pressed = false,
        action = function(self)
            camera.x = self.value
        end,
        dir = "x",
        display = "CX %d",
        draw = function(self)
            graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
            if self.pressed then
                graphics.setColor(0.3, 0.3, 0.3)
            elseif self.hovered then
                graphics.setColor(0.7, 0.7, 0.7)
            else
                graphics.setColor(1, 1, 1)
            end
            love.graphics.rectangle("fill", self.x + (self.value - self.low) / (self.high - self.low) * self.width, self.y, 10, self.height)

            graphics.setColor(1, 1, 1)
            love.graphics.printf(string.format(self.display, self.value), self.x + 105, self.y - 8, 100, "left")
        end,
        checkForMouse = function(self, x, y)
            if x > self.x and x < self.x + 100 and y > self.y and y < self.y + 10 then
                self.pressed = true
                return true
            end
        end,
        update = function(self)
            if self.pressed then
                local mx, my = love.mouse.getPosition()
                self.value = math.min(self.high, math.max(self.low, (mx - self.x - 5) / self.width * (self.high - self.low) + self.low))
                self.action(self)
            end
        end
    },
    {
        x = 10,
        y = 70,
        width = 100,
        height = 10,
        value = 0,
        low = -1000,
        high = 1000,
        hovered = false,
        pressed = false,
        action = function(self)
            camera.y = self.value
        end,
        dir = "y",
        display = "CY %d",
        draw = function(self)
            graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
            if self.pressed then
                graphics.setColor(0.3, 0.3, 0.3)
            elseif self.hovered then
                graphics.setColor(0.7, 0.7, 0.7)
            else
                graphics.setColor(1, 1, 1)
            end
            love.graphics.rectangle("fill", self.x + (self.value - self.low) / (self.high - self.low) * self.width, self.y, 10, self.height)

            graphics.setColor(1, 1, 1)
            love.graphics.printf(string.format(self.display, self.value), self.x + 105, self.y - 8, 100, "left")
        end,
        checkForMouse = function(self, x, y)
            if x > self.x and x < self.x + 100 and y > self.y and y < self.y + 10 then
                self.pressed = true
                return true
            end
        end,
        update = function(self)
            if self.pressed then
                local mx, my = love.mouse.getPosition()
                self.value = math.min(self.high, math.max(self.low, (my - self.y - 5) / self.height * (self.high - self.low) + self.low))
                self.action(self)
            end
        end
    },
    {
        x = 10,
        y = 90,
        width = 100,
        height = 10,
        value = 1,
        low = 0.1,
        high = 4,
        hovered = false,
        pressed = false,
        action = function(self)
            camera.zoom = self.value
        end,
        dir = "z",
        display = "CZ %.2f",
        draw = function(self)
            graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 5)
            if self.pressed then
                graphics.setColor(0.3, 0.3, 0.3)
            elseif self.hovered then
                graphics.setColor(0.7, 0.7, 0.7)
            else
                graphics.setColor(1, 1, 1)
            end
            love.graphics.rectangle("fill", self.x + (self.value - self.low) / (self.high - self.low) * self.width, self.y, 10, self.height)

            graphics.setColor(1, 1, 1)
            love.graphics.printf(string.format(self.display, self.value), self.x + 105, self.y - 8, 100, "left")
        end,
        checkForMouse = function(self, x, y)
            if x > self.x and x < self.x + 100 and y > self.y and y < self.y + 10 then
                self.pressed = true
                return true
            end
        end,
        update = function(self)
            if self.pressed then
                local mx, my = love.mouse.getPosition()
                self.value = math.min(self.high, math.max(self.low, (mx - self.x - 5) / self.width * (self.high - self.low) + self.low))
                self.action(self)
            end
        end
    }
}

local function create(col)
    local obj = graphics.newImage()
    local img = love.image.newImageData(50, 50)
    for x = 0, 49 do
        for y = 0, 49 do
            img:setPixel(x, y, unpack(col or {1, 1, 1, 1}))
        end
    end
    obj:setImage(love.graphics.newImage(img))
    obj.x = 0
    obj.y = 0
    obj.z = #objects
    obj.ver = "staticObjects"
    obj.name = "object #" .. #objects
    obj.updates = false
    table.insert(objects, obj)
    sortObjects()

    return obj
end
function builder:enter()
    objects = {}
    curObject = 1
    mxOffset, myOffset = 0, 0
    curState = "staticObjects"
    
    local bf = create({0, 0, 1, 1})
    local gf = create({1, 0, 0, 1})
    local enemy = create({0, 1, 0, 1})

    bf.x, bf.y = 222, 69
    enemy.x, enemy.y = -238, 64
    gf.x, gf.y = -19, -25

    bf.name = "boyfriend"
    gf.name = "girlfriend"
    enemy.name = "enemy"


    bf.z = 1000
    enemy.z = 1000
    gf.z = 999

    sortObjects()

    outputStr = [[
local function drawObj(obj)
    love.graphics.push()
        love.graphics.translate(camera.x * obj.scrollX, camera.y * obj.scrollY)
        obj:draw()
    love.graphics.pop()
end
local stage = {}

function stage:enter()
<enter>
end

function stage:load()
<load>
end

function stage:update(dt)
<update>
end

function stage:draw()
<draw>
end

function stage:leave()
    for _, v in pairs(stageImages) do
        v = nil
	end

    graphics.clearCache()
<leave>
end

return stage
]]
end

function builder:filedropped(file)
    local obj = graphics.newImage()
    file:open("r")
    local img = love.graphics.newImage(love.image.newImageData(file:read("data")))
    obj:setImage(img)
    file:close()
    obj.z = #objects
    obj.ver = "staticObjects"
    obj.filename = file:getFilename()
    obj.name = obj.filename:match("(.+)%..+")
    obj.name = obj.name:match(".+\\(.+)")
    obj.filename = obj.filename:match(".+\\(.+)")
    obj.updates = false

    table.insert(objects, obj)

    sortObjects()
end

function builder:mousemoved(x, y)
    for _, obj in ipairs(objects) do
        if obj.dragging then
            obj.x = x - mxOffset
            obj.y = y - myOffset
        end
    end

    for _, btn in ipairs(buttons) do
        if x > btn.x and x < btn.x + 100 and y > btn.y and y < btn.y + 30 then
            btn.hovered = true
        else
            btn.hovered = false
        end
    end
end

function builder:mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do
        if x > btn.x and x < btn.x + 100 and y > btn.y and y < btn.y + 30 then
            btn.pressed = true
            return
        end
    end

    for _, slider in ipairs(sliders) do
        if slider:checkForMouse(x, y) then
            return
        end
    end

    local reveresed = {}
    for i = #objects, 1, -1 do
        table.insert(reveresed, objects[i])
    end

    local obj2
    for i, obj in ipairs(reveresed) do
        local mx, my = x - graphics.getWidth() / 2, y - graphics.getHeight() / 2
        mx, my = mx / camera.zoom, my / camera.zoom
        mx = mx - camera.x
        my = my - camera.y
        if mx > obj.x - (obj:getWidth() / 2) * obj.sizeX and mx < obj.x + (obj:getWidth() / 2) * obj.sizeX and my > obj.y - (obj:getHeight() / 2) * obj.sizeY and my < obj.y + (obj:getHeight() / 2) * obj.sizeY then
            if not obj.ver == curState then
                return
            end
            obj.dragging = true
            mxOffset = x - obj.x
            myOffset = y - obj.y
            obj2 = obj
            break
        end
    end

    for i, obj in ipairs(objects) do
        if obj == obj2 then
            curObject = i
            break
        end
    end
end

function builder:mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do
        if x > btn.x and x < btn.x + 100 and y > btn.y and y < btn.y + 30 then
            btn.pressed = false
            btn.action()
            return
        end
    end
    for _, slider in ipairs(sliders) do
        if slider.pressed then
            slider.pressed = false
            return
        end
    end
    for _, obj in ipairs(objects) do
        obj.dragging = false
    end

    if curState == "staticObjects" then
        sortObjects()
    end
end

function builder:wheelmoved(x, y)
    for _, obj in ipairs(objects) do
        if obj.dragging then
            if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
                if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                    obj.sizeX = obj.sizeX + y * 0.1
                    obj.sizeY = obj.sizeY + y * 0.1
                else
                    obj.sizeX = obj.sizeX + y * 0.05
                    obj.sizeY = obj.sizeY + y * 0.05
                end
            else
                obj.z = obj.z + y
                sortObjects()
            end
        end
    end
end

function builder:update(dt)
    for _, slider in ipairs(sliders) do
        slider:update()
    end
end

function builder:draw()
    love.graphics.push()
        love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
        love.graphics.scale(camera.zoom, camera.zoom)
        
        for _, obj in ipairs(objects) do
            love.graphics.push()
                love.graphics.translate(camera.x * obj.scrollX, camera.y * obj.scrollY)
                obj:draw()
            love.graphics.pop()
        end
    love.graphics.pop()

    if objects[curObject] and curState == "staticObjects" then
        love.graphics.printf("Object " .. curObject, -5, 5, graphics.getWidth(), "right")
        love.graphics.printf("X, Y: " .. objects[curObject].x .. ", " .. objects[curObject].y, -5, 20, graphics.getWidth(), "right")
        love.graphics.printf("ZIndex: " .. objects[curObject].z, -5, 35, graphics.getWidth(), "right")
    end

    for _, btn in ipairs(buttons) do
        btn:draw()
    end

    for _, slider in ipairs(sliders) do
        slider:draw()
    end
end

return builder
