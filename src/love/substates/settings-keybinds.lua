-- Coming in a later update
local arrows, sprites, doBindSet, choice
local inputList = {
    "gameLeft",
    "gameDown",
    "gameUp",
    "gameRight"
}
local invalidkeys = {
    ["space"] = " ",
    ["return"] = "enter",
    ["tab"] = "tab",
    ["backspace"] = "backspace",
    ["delete"] = "delete",
    ["insert"] = "insert",
    ["home"] = "home",
    ["end"] = "end",
    ["pageup"] = "pageup",
    ["pagedown"] = "pagedown",
    ["escape"] = "escape",
    ["pause"] = "pause",
    ["numlock"] = "numlock",
    ["capslock"] = "capslock",
    ["scrolllock"] = "scrolllock",
    ["rshift"] = "rshift",
    ["lshift"] = "lshift",
    ["rctrl"] = "rctrl",
    ["lctrl"] = "lctrl",
    ["ralt"] = "ralt",
    ["lalt"] = "lalt",
    ["rsuper"] = "rsuper",
    ["lsuper"] = "lsuper",
    ["menu"] = "menu",
}

return {
    enter = function(self)
        images = {
            notes = love.graphics.newImage(graphics.imagePath("notes")),
        } 
        sprites = {
            leftArrow = love.filesystem.load("sprites/left-arrow.lua"),
		    downArrow = love.filesystem.load("sprites/down-arrow.lua"),
		    upArrow = love.filesystem.load("sprites/up-arrow.lua"),
		    rightArrow = love.filesystem.load("sprites/right-arrow.lua")
        }
        arrows = {
            sprites.leftArrow(),
			sprites.downArrow(),
			sprites.upArrow(),
			sprites.rightArrow()
        }
        for i = 1, 4 do
            arrows[i].x = -165*2 + 165 * i-1 - 50
        end
        doBindSet = false
        choice = 0
    end,
    update = function(self, dt)
        for i = 1, 4 do
            arrows[i]:update(dt)
            if not doBindSet then
                if input:pressed("left") then
                    arrows[1]:animate("confirm", false)
                    choice = 1
                elseif not input:down("left") then
                    arrows[1]:animate("off", false)
                end
                if input:pressed("down") then
                    arrows[2]:animate("confirm", false)
                    choice = 2
                elseif not input:down("down") then
                    arrows[2]:animate("off", false)
                end
                if input:pressed("up") then
                    arrows[3]:animate("confirm", false)
                    choice = 3
                elseif not input:down("up") then
                    arrows[3]:animate("off", false)
                end
                if input:pressed("right") then
                    arrows[4]:animate("confirm", false)
                    choice = 4
                elseif not input:down("right") then
                    arrows[4]:animate("off", false)
                end
            end
        end

        if input:pressed("back") then
            graphics:fadeOutWipe(0.3, function() Gamestate.pop() end)
        end
    end,
    keypressed = function(self, key)
        if key == "return" then
            doBindSet = true
        end
    end,
    textinput = function(self, text)
        if doBindSet then
            if invalidkeys[text] then
                text = invalidkeys[text]
            end
            if choice == 1 then
                customBindLeft = text
            elseif choice == 2 then
                customBindDown = text
            elseif choice == 3 then
                customBindUp = text
            elseif choice == 4 then
                customBindRight = text
            end
            doBindSet = false
        end
    end,
    draw = function(self)
        love.graphics.push()
            love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
            love.graphics.scale(0.7, 0.7)
            for i = 1, 4 do 
                graphics.setColor(0.40, 0.40, 0.40)
                if i == choice then
                    graphics.setColor(1,1,1)
                end
                arrows[i]:draw()
                graphics.setColor(1,1,1)
            end
            love.graphics.print(customBindLeft, -165*2 + 100, 80)
            love.graphics.print(customBindDown, -165 + 100, 80)
            love.graphics.print(customBindUp, 0 + 100, 80)
            love.graphics.print(customBindRight, 165 + 100, 80)
        love.graphics.pop()
    end,
    leave = function(self)
        saveSettings(false)
        if love.system.getOS() == "NX" then
            input:rebindControl("gameLeft", {"axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x", "key:" .. customBindLeft, "key:left"})
            input:rebindControl("gameDown", {"axis:triggerright+", "axis:lefty-", "axis:righty-", "button:dpdown", "button:a", "key:" .. customBindDown, "key:down"})
            input:rebindControl("gameUp", {"axis:lefty+", "axis:righty+", "button:dpup", "button:b", "key:" .. customBindUp, "key:up"})
            input:rebindControl("gameRight", {"axis:leftx+", "axis:rightx+", "button:dpright", "button:y", "key:" .. customBindRight, "key:right"})
        else
            input:rebindControl("gameLeft", {"key:" .. customBindLeft, "key:left", "axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x"})
            input:rebindControl("gameDown", {"key:" .. customBindDown, "key:down", "axis:triggerright+", "axis:lefty-", "axis:righty-", "button:dpdown", "button:a"})
            input:rebindControl("gameUp", {"key:" .. customBindUp, "key:up", "axis:lefty+", "axis:righty+", "button:dpup", "button:b"})
            input:rebindControl("gameRight", {"key:" .. customBindRight, "key:right", "axis:leftx+", "axis:rightx+", "button:dpright", "button:y"})
        end
    end
}