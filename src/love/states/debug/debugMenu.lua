local choice
return {
    enter = function()
        choice = 1
    end,

    update = function(self, dt)

    end,

    keypressed = function(self, key)
        if key == "up" then
            if choice ~= 1 then
                choice = choice - 1
            else
                choice = 3
            end
        elseif key == "down" then
            if choice ~= 3 then
                choice = choice + 1
            else
                choice = 1
            end
        elseif key == "return" then
            if choice == 1 then
                Gamestate.switch(spriteDebug)
            elseif choice == 2 then
                Gamestate.switch(stageDebug)
            elseif choice == 3 then
                Gamestate.switch(chartDebug)
            end
        end
    end,

    draw = function()
        graphics.setColor(255, 255, 255, 255)
        love.graphics.print("Debug Menu", 10, 10)
        if choice == 1 then
            graphics.setColor(1, 1, 0)
        else
            graphics.setColor(1, 1, 1)
        end
        love.graphics.print("1. Sprite Viewer", 10, 30)
        if choice == 2 then
            graphics.setColor(1, 1, 0)
        else
            graphics.setColor(1, 1, 1)
        end
        love.graphics.print("2. Stage Editor", 10, 50)
        if choice == 3 then
            graphics.setColor(1, 1, 0)
        else
            graphics.setColor(1, 1, 1)
        end
        love.graphics.print("3. Chart Editor", 10, 70)
    end
}