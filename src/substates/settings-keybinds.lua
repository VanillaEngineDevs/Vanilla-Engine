local state = {}

local actions = {
    { id = "left",      label = "Menu Left" },
    { id = "down",      label = "Menu Down" },
    { id = "up",        label = "Menu Up" },
    { id = "right",     label = "Menu Right" },
    { id = "confirm",   label = "Confirm" },
    { id = "back",      label = "Back" },
    { id = "pause",     label = "Pause" },

    { id = "gameLeft",  label = "Note Left" },
    { id = "gameDown",  label = "Note Down" },
    { id = "gameUp",    label = "Note Up" },
    { id = "gameRight", label = "Note Right" },
}

local axisThres = 0.5
local axisActive = {}

local menuIndex = 1
local keySlotIndex = 1
local rebinding = false
local suppressInputFrame = false
local flashTimer = 0
local activeDevice = "keyboard"

local invalidKeys = {
    space = " ",
    returnkey = "enter",
}

local function getSlots(action, isJoy)
    local binds = input:getControls()[action] or {}
    local slots = {}

    for i, v in ipairs(binds) do
        if isJoy then
            if v:sub(1, 7) == "button:" or v:sub(1,5) == "axis:" then
                table.insert(slots, { index = i, value = v:match("^%a+:(.+)$") })
            end
        else
            if v:sub(1,4) == "key:" then
                table.insert(slots, { index = i, value = v:sub(5) })
            end
        end
    end

    return slots
end

local function replaceSlot(action, slotIndex, value, isJoy, isAxis)
    local binds = input:getControls()[action] or {}
    local prefix = isJoy and "button:" or "key:"
    if isJoy and isAxis then
        prefix = "axis:"
    end
    binds[slotIndex] = prefix .. value
    input:rebindControl(action, binds)
end

function state:enter()
    menuIndex = 1
    keySlotIndex = 1
    rebinding = false
    flashTimer = 0
    activeDevice = "keyboard"
end

function state:update(dt)
    flashTimer = (flashTimer + dt * 6) % 2

    if suppressInputFrame then
        suppressInputFrame = false
        return
    end

    if rebinding then return end

    local isJoy = activeDevice ~= "keyboard"
    local action = actions[menuIndex].id
    local slots = getSlots(action, isJoy)

    if input:pressed("down") then
        menuIndex = lume.clamp(menuIndex + 1, 1, #actions)
        keySlotIndex = 1

    elseif input:pressed("up") then
        menuIndex = lume.clamp(menuIndex - 1, 1, #actions)
        keySlotIndex = 1

    elseif input:pressed("right") then
        keySlotIndex = lume.clamp(keySlotIndex + 1, 1, math.max(1, #slots))

    elseif input:pressed("left") then
        keySlotIndex = lume.clamp(keySlotIndex - 1, 1, math.max(1, #slots))

    elseif input:pressed("confirm") then
        if #slots > 0 then
            rebinding = true
        end

    elseif input:pressed("back") then
        graphics:fadeOutWipe(0.3, function()
            Gamestate.pop()
        end)
    end
end

function state:keypressed(key)
    if activeDevice ~= "keyboard" then
        activeDevice = "keyboard"
        menuIndex = 1
        keySlotIndex = 1
    end
    if not rebinding then return end
    key = invalidKeys[key] or key

    local action = actions[menuIndex].id
    local slots = getSlots(action, false)
    local slot = slots[keySlotIndex]

    if slot then
        replaceSlot(action, slot.index, key, false)
    end

    rebinding = false
    suppressInputFrame = true
end

function state:gamepadpressed(_, button)
    if activeDevice ~= "joy" then
        activeDevice = "joy"
        menuIndex = 1
        keySlotIndex = 1
    end

    if not rebinding then return end

    local action = actions[menuIndex].id
    local slots = getSlots(action, true)
    local slot = slots[keySlotIndex]

    if slot then
        replaceSlot(action, slot.index, button, true)
    end

    rebinding = false
    suppressInputFrame = true
end

function state:gamepadaxis(_, axis, value)
    if math.abs(value) < axisThres then
        axisActive[axis] = false
        return
    end

    if axisActive[axis] then
        return
    end

    axisActive[axis] = true
    if activeDevice ~= "joy" then
        activeDevice = "joy"
        menuIndex = 1
        keySlotIndex = 1
    end

    if not rebinding then return end

    local action = actions[menuIndex].id
    local slots = getSlots(action, true)
    local slot = slots[keySlotIndex]

    if slot then
        local axisStr = axis .. (value > 0 and "+" or "-")
        replaceSlot(action, slot.index, axisStr, true, true)
    end

    rebinding = false
    suppressInputFrame = true
end

function state:draw()
    love.graphics.push()
    love.graphics.translate(100, 80)

    love.graphics.setFont(uiFontBold)
    love.graphics.setColor(1,1,1)
    love.graphics.print("KEYBINDS", 0, -48, 0, 1.2, 1.2)

    love.graphics.setFont(uiFont)

    local lineHeight = 28
    local startX = 240
    local padding = 14
    local isJoy = activeDevice ~= "keyboard"

    for i, entry in ipairs(actions) do
        local y = (i-1)*lineHeight
        local selectedAction = i == menuIndex

        if selectedAction then
            love.graphics.setColor(0.18,0.55,1)
            love.graphics.rectangle("fill",-12,y+9,560,lineHeight,6,6)
        end

        love.graphics.setColor(1,1,1)
        love.graphics.print(entry.label, 0, y)

        local slots = getSlots(entry.id, isJoy)
        local x = startX

        if #slots == 0 then
            love.graphics.setColor(0.6,0.6,0.6)
            love.graphics.print("<none>", x, y)
        end

        for j, slot in ipairs(slots) do
            local selectedSlot = selectedAction and j == keySlotIndex
            local text = slot.value
            local textWidth = uiFont:getWidth(text)
            local boxWidth = textWidth + padding*2

            if selectedSlot then
                love.graphics.setColor(1,1,1)
                love.graphics.rectangle("line", x-padding, y+10, boxWidth, 26, 4,4)
            end

            if selectedSlot and rebinding and flashTimer < 1 then
                local targetWidth = uiFont:getWidth(text)
                local placeholder = ""
                while uiFont:getWidth(placeholder) < targetWidth do
                    placeholder = placeholder .. "_"
                end
                love.graphics.print(placeholder, x, y)
            else
                love.graphics.print(text, x, y)
            end

            x = x + boxWidth + 10
            love.graphics.setColor(1,1,1)
        end
    end

    love.graphics.pop()
end

function state:leave()
    settings.save(false)
end

return state
