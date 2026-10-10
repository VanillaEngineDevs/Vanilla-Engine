local choice, options
return {
    enter = function()
        choice = 1
        options = {
            {
                text = "Sprite Viewer",
                state = spriteDebug
            }
        }
        settings.lastDEBUGOption = settings.showDebug
        settings.showDebug = false

        graphics.setFade(1)
        
        love.audio.stop()
    end,
    
    keypressed = function(self, key)
        if key == "up" then
            choice = choice < 1 and #options or choice - 1
        elseif key == "down" then
            choice = choice > #options and 1 or choice + 1
        elseif key == "return" then
            Gamestate.switch(options[choice].state)
        elseif key == "escape" then
            settings.showDebug = settings.lastDEBUGOption
            graphics:fadeOutWipe(0.7, function()
                Gamestate.switch(menu)
                input:pop()
            end)
        end
    end,

    draw = function()
        graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Debug Menu", 10, 10)
        for i, option in ipairs(options) do
            if choice == i then
                graphics.setColor(1, 1, 0)
            else
                graphics.setColor(1, 1, 1)
            end
            love.graphics.print(i .. ". " .. option.text, 10, 30 + 20 * i)
        end
        graphics.setColor(1, 1, 1, 1)
    end,

    leave = function()
        graphics.setFade(1)
        love.keyboard.setKeyRepeat(false)
    end
}