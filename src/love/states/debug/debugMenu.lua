local choice, options
return {
    enter = function()
        choice = 1
        options = {
            {
                text = "Sprite Viewer",
                state = spriteDebug
            },
            {
                text = "Stage Editor",
                state = stageDebug
            },
            {
                text = "Frame Offset Viewer",
                state = frameDebug
            }
        }
        settings.lastDEBUGOption = settings.showDebug
        settings.showDebug = false
    end,
    
    keypressed = function(self, key)
        if key == "up" then
            choice = choice < 1 and #options or choice - 1
        elseif key == "down" then
            choice = choice > #options and 1 or choice + 1
        elseif key == "return" then
            Gamestate.switch(options[choice].state)
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
    end
}