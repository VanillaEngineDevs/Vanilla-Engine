local f = {}

local list = {}
local animsList = {}

local scrollY = 0
local current = 1

local character
local clone
local background = love.graphics.newCanvas(1280, 720)

local state = 0

function f:enter()
    list = {}
    for _, file in ipairs(love.filesystem.getDirectoryItems("assets/data/characters/")) do
        if file:sub(-5) == ".json" then
            table.insert(list, file:sub(1, -6))
        end
    end

    print("Loaded " .. #list .. " character files.")
    scrollY = 0
    current = 1

    local totalCellsX = 16
    local totalCellsY = 10
    local cellSizeX = background:getWidth() / totalCellsX
    local cellSizeY = background:getHeight() / totalCellsY
    background:renderTo(function()
        love.graphics.clear(0.1, 0.1, 0.1)
        local w, h = background:getDimensions()
        for i = 0, totalCellsX - 1 do
            for j = 0, totalCellsY - 1 do
                if (i + j) % 2 == 0 then
                    love.graphics.setColor(0.15, 0.15, 0.15)
                else
                    love.graphics.setColor(0.2, 0.2, 0.2)
                end
                love.graphics.rectangle("fill", i * cellSizeX, j * cellSizeY, cellSizeX, cellSizeY)
            end
        end
    end)

    love.keyboard.setKeyRepeat(true)

    state = 1
end

function f:keypressed(k)
    if state == 1 then
        if k == "down" then
            current = math.min(current + 1, #list)
            if current * 20 - scrollY > 720 - 40 then
                scrollY = scrollY + 20
            end
        elseif k == "up" then
            current = math.max(current - 1, 1)
            if (current - 1) * 20 < scrollY then
                scrollY = math.max(scrollY - 20, 0)
            end
        elseif k == "return" then
            local charName = list[current]
            local char = Character.getCharacter(charName)
            local cloneChar = Character.getCharacter(charName)
            if char then
                character = char
                character:dance(true)
                character:updateHitbox()
                character.x = character.x - character.width / 2
                character.y = character.y - character.height / 2

                clone = cloneChar
                clone:dance(true)
                clone:updateHitbox()
                clone.x = clone.x - clone.width / 2
                clone.y = clone.y - clone.height / 2

                state = 2
                current = 1
                scrollY = 0
                animsList = character:getAllAnimations()
            else
                print("Failed to load character: " .. charName)
            end
        elseif k == "escape" then
            settings.showDebug = settings.lastDEBUGOption
            graphics:fadeOutWipe(0.7, function()
                Gamestate.switch(menu)
                input:pop()
            end)
        end
    elseif state == 2 then
        if k == "down" then
            current = math.min(current + 1, #animsList)
            if current * 20 - scrollY > 720 - 40 then
                scrollY = scrollY + 20
            end
        elseif k == "up" then
            current = math.max(current - 1, 1)
            if (current - 1) * 20 < scrollY then
                scrollY = math.max(scrollY - 20, 0)
            end
        elseif k == "return" then
            local animName = animsList[current]
            if not weeks.conductor then
                weeks.conductor = Conductor.new()
            end
            character:play(animName, true)
        elseif k == "escape" then
            state = 1
            current = 1
            scrollY = 0
            character = nil
            clone = nil
        end
    end
end

local isMouseDown = false

function f:mousepressed(x, y, button)
    if state == 2 and button == 1 then
        isMouseDown = true
    end
end

function f:mousereleased(x, y, button)
    if state == 2 and button == 1 then
        isMouseDown = false
    end
end

function f:mousemoved(x, y, dx, dy)
    if state == 2 and isMouseDown then
        character.x = character.x + dx
        character.y = character.y + dy
    end
end

--[[ function f:wheelmoved(x, y)
    camera.zoom = camera.zoom + y / 10
end ]]

function f:update(dt)
    if state == 2 then
        character:update(dt)
        clone:update(dt)
    end
end

function f:draw()
    love.graphics.push()
        if state == 1 then
            love.graphics.translate(0, -scrollY)

            for i, name in ipairs(list) do
                if i == current then
                    love.graphics.setColor(1, 1, 0)
                else
                    love.graphics.setColor(1, 1, 1)
                end
                love.graphics.print(name, 10, (i - 1) * 20)
            end
        elseif state == 2 then
            love.graphics.draw(background, 0, 0)

            love.graphics.push()
                love.graphics.translate(640, 360)
                if character then
                    love.graphics.setColor(0.1, 0.1, 0.1)
                    clone:draw()
                    love.graphics.setColor(1, 1, 1, 0.5)
                    character:draw()
                else
                    love.graphics.setColor(1, 0, 0)
                    love.graphics.print("Failed to load character.", 10, 10)
                end
            love.graphics.pop()

            for i, name in ipairs(animsList) do
                if i == current then
                    love.graphics.setColor(1, 1, 0)
                else
                    love.graphics.setColor(1, 1, 1)
                end
                love.graphics.print(name, 10, (i - 1) * 20)
            end

            if character and clone then
                love.graphics.setColor(1, 1, 1)
                love.graphics.print("Character Position: (" .. math.floor(character.x) .. ", " .. math.floor(character.y) .. ")", 800, 10)
                love.graphics.print("Clone Position: (" .. math.floor(clone.x) .. ", " .. math.floor(clone.y) .. ")", 800, 30)
                love.graphics.print("Offset: (" .. -math.floor((character.x - clone.x) / character.scale.x) .. ", " .. -math.floor((character.y - clone.y) / character.scale.y) .. ")", 800, 50)
            end
        end
    love.graphics.pop()
end

function f:leave()
    love.keyboard.setKeyRepeat(false)
    graphics.setFade(1)
end

return f