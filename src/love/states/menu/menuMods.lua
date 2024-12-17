local storedModList = {}
local translate = {x = 0, y = 0}
local toTranslate = {x = 0, y = 0}
return {
    enter = function(self)
        modList = {}
        storedModList = {}

        for i = 1, #importMods.getAllMods() do
            table.insert(modList, importMods.getModFromIndex(i))
        end

        for i = 1, #modList do
            local mod = modList[i]
            local icon = mod.path .. "/icon.png"
            if not love.filesystem.getInfo(icon) then
                icon = "assets/defaultIcon.png"
                if not love.filesystem.getInfo(icon) then
                    icon = nil
                end
            end
            table.insert(storedModList, {
                name = mod.name,
                icon = icon ~= nil and graphics.newImage(icon) or nil,
                description = mod.description,
                creator = mod.creator,
                hovered = false,
                selected = false,
                enabled = mod.enabled,
                x = -graphics.getWidth() / 2 + 10,
                y = -graphics.getHeight() / 2 + 10 + ((i-1) * 85),
                width = graphics.getWidth()/4 - 15,
                height = 80
            })
            if storedModList[#storedModList].icon then
                local icon = storedModList[#storedModList].icon
                icon.x, icon.y = -graphics.getWidth() / 2 + 50, -graphics.getHeight() / 2 + 50 + ((i-1) * 85)
                icon.sizeX, icon.sizeY = 0.5, 0.5
            end
        end

        if #storedModList > 0 then
            storedModList[1].selected = true
        end
        graphics:fadeInWipe(0.6)
    end,

    update = function(self, dt)
        translate.x = util.coolLerp(translate.x, toTranslate.x, 0.1)
        translate.y = util.coolLerp(translate.y, toTranslate.y, 0.1)

        if input:pressed("back") then
            graphics:fadeOutWipe(0.6, function()
                Gamestate.switch(menuSelect)
            end)
        end

        if input:pressed("down") then
            for i = 1, #storedModList do
                if storedModList[i].selected then
                    storedModList[i].selected = false
                    if i == #storedModList then
                        storedModList[1].selected = true
                    else
                        storedModList[i+1].selected = true
                    end
                    break
                end
            end

            if #storedModList * 85 > graphics.getHeight() then
                for i = 1, #storedModList do
                    if storedModList[i].selected then
                        if i == #storedModList then
                            toTranslate.y = -((#storedModList * 85) - graphics.getHeight())
                        elseif i == 1 then
                            toTranslate.y = 0
                        elseif storedModList[i].y - 85 < -graphics.getHeight() / 2 then
                            toTranslate.y = toTranslate.y - 85
                        end
                        break
                    end
                end
            end
        elseif input:pressed("up") then
            for i = 1, #storedModList do
                if storedModList[i].selected then
                    storedModList[i].selected = false
                    if i == 1 then
                        storedModList[#storedModList].selected = true
                    else
                        storedModList[i-1].selected = true
                    end
                    break
                end
            end

            if #storedModList * 85 > graphics.getHeight() then
                for i = 1, #storedModList do
                    if storedModList[i].selected then
                        if i == #storedModList then
                            toTranslate.y = -((#storedModList * 85) - graphics.getHeight())
                        elseif i == 1 then
                            toTranslate.y = 0
                        elseif storedModList[i].y - 85 < -graphics.getHeight() / 2 then
                            toTranslate.y = toTranslate.y + 85
                        end
                        break
                    end
                end
            end
        end

        if input:pressed("confirm") then
            for i = 1, #storedModList do
                if storedModList[i].selected then
                    storedModList[i].enabled = not storedModList[i].enabled
                    break
                end
            end
        end
    end,

    mousemoved = function(self, x, y, dx, dy, istouch)
        local x, y = push.toGame(x, y)
        if type(x) == "boolean" or type(y) == "boolean" then return end
        x, y = x - graphics.getWidth() / 2, y - graphics.getHeight() / 2

        for i = 1, #storedModList do
            local mod = storedModList[i]
            local nx, ny = x - translate.x, y - translate.y

            if nx > mod.x and nx < mod.x + mod.width and ny > mod.y and ny < mod.y + mod.height then
                mod.hovered = true
            else
                mod.hovered = false
            end
        end
    end,

    mousepressed = function(self, x, y, button, istouch, presses)
        local x, y = push.toGame(x, y)
        if type(x) == "boolean" or type(y) == "boolean" then return end
        x, y = x - graphics.getWidth() / 2, y - graphics.getHeight() / 2

        for i = 1, #storedModList do
            local mod = storedModList[i]
            local nx, ny = x - translate.x, y - translate.y

            if nx > mod.x and nx < mod.x + mod.width and ny > mod.y and ny < mod.y + mod.height then
                for i = 1, #storedModList do
                    storedModList[i].selected = false
                end
                mod.selected = true
            end
        end
        
        -- enable/disable button
        local quartWidth = graphics.getWidth() / 4
        local width = quartWidth * 3
        if x > -quartWidth and x < quartWidth*2 and y > graphics.getHeight() / 2 - 50 and y < graphics.getHeight() / 2 - 10 then
            for i = 1, #storedModList do
                if storedModList[i].selected then
                    storedModList[i].enabled = not storedModList[i].enabled
                    break
                end
            end
        end
        --[[ if x > -graphics.getWidth() / 2 and x < -graphics.getWidth() / 2 + graphics.getWidth()/4 and y > graphics.getHeight() / 2 - 50 and y < graphics.getHeight() / 2 - 10 then
            for i = 1, #storedModList do
                if storedModList[i].selected then
                    storedModList[i].enabled = not storedModList[i].enabled
                    break
                end
            end
        end ]]
    end,

    wheelmoved = function(self, x, y)
        toTranslate.y = toTranslate.y + y * 25
        if toTranslate.y > 0 then
            toTranslate.y = 0
        else
            if #storedModList * 85 < graphics.getHeight() then
                toTranslate.y = 0
            elseif toTranslate.y < -((#storedModList * 85) - graphics.getHeight()) then
                toTranslate.y = -((#storedModList * 85) - graphics.getHeight())
            end
        end
    end,

    draw = function(self)
        love.graphics.push()
            love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)

            --[[ for i = 1, #storedModList do
                local mod = storedModList[i]
                if mod.icon then
                    mod.icon:draw()
                end
                love.graphics.print(mod.name, -graphics.getWidth() / 2 + 100, -graphics.getHeight() / 2 + 50 + (i * 100))
                love.graphics.print(mod.description, -graphics.getWidth() / 2 + 100, -graphics.getHeight() / 2 + 50 + (i * 100) + 20)
            end ]]

            love.graphics.push()
                love.graphics.translate(translate.x, translate.y)
                for i = 1, #storedModList do
                    local mod = storedModList[i]
                    
                    -- 0.1 colour if not selected or hovered
                    -- 0.2 colour if hovered
                    -- 0.3 colour if selected
                    if mod.selected then
                        graphics.setColor(0.3, 0.3, 0.3, 1)
                    elseif mod.hovered then
                        graphics.setColor(0.2, 0.2, 0.2, 1)
                    else
                        graphics.setColor(0.1, 0.1, 0.1, 1)
                    end
                    
                    love.graphics.rectangle("fill", mod.x, mod.y, mod.width, mod.height)
                    graphics.setColor(0.8, 0.8, 0.8, 1)
                    love.graphics.rectangle("line", mod.x, mod.y, mod.width, mod.height)
                    graphics.setColor(1, 1, 1, 1)
                    if mod.icon then
                        mod.icon:draw()
                    end

                    local modName = mod.name
                    if font:getWidth(modName) > graphics.getWidth()/4 - 20 then
                        -- replace all chars past the width with ...
                        local newModName = ""
                        for i = 1, #modName do
                            newModName = newModName .. modName:sub(i, i)
                            if font:getWidth(newModName) > graphics.getWidth()/4 - 15 - font:getWidth("...") then
                                newModName = newModName .. "..."
                                break
                            end
                        end

                        modName = newModName
                    end

                    -- graphics.getWidth()/4 is 1/4 of the screen width
                    love.graphics.printf(modName, -graphics.getWidth() / 2 + 90, -graphics.getHeight() / 2 + 15 + ((i-1) * 85), graphics.getWidth()/4 - 50, "left")

                    if mod.selected then
                        love.graphics.push()
                            local quartWidth = graphics.getWidth() / 4
                            love.graphics.translate(quartWidth, 0)

                            local width = quartWidth * 3
                            love.graphics.printf(mod.name, -width / 2-150, -graphics.getHeight() / 2 + 15, width-15, "center")
                            love.graphics.setLineWidth(2)
                            love.graphics.line(-width / 2-150, -graphics.getHeight() / 2 + 65, width / 2-150, -graphics.getHeight() / 2 + 65)
                            love.graphics.setLineWidth(1)
                            -- left align stuff now
                            love.graphics.printf("Created by: " .. mod.creator, -width / 2-150, -graphics.getHeight() / 2 + 75, width-15, "left")
                            love.graphics.printf(mod.description, -width / 2-150, -graphics.getHeight() / 2 + 125, width-15, "left")

                            --[[ love.graphics.printf(mod.description, -width / 2-150, -graphics.getHeight() / 2 + 35, width-15, "center")
                            love.graphics.printf("Created by: " .. mod.creator, -width / 2-150, -graphics.getHeight() / 2 + 55, width-15, "center") ]]

                            -- enable/disable button
                            if mod.enabled then
                                graphics.setColor(0, 1, 0, 1)
                            else
                                graphics.setColor(1, 0, 0, 1)
                            end
                            love.graphics.rectangle("fill", -width / 2-150, graphics.getHeight() / 2 - 50, width-15, 40, 15, 15)
                            graphics.setColor(0, 0, 0, 1)
                            for x = -1, 1 do
                                for y = -1, 1 do
                                    love.graphics.printf(mod.enabled and "Enabled" or "Disabled", -width / 2-150 + x, graphics.getHeight() / 2 - 45 + y, width-15, "center")
                                end
                            end
                            graphics.setColor(1, 1, 1, 1)
                            love.graphics.printf(mod.enabled and "Enabled" or "Disabled", -width / 2-150, graphics.getHeight() / 2 - 45, width-15, "center")
                        love.graphics.pop()
                    end
                end
            love.graphics.pop()

            love.graphics.setLineWidth(5)
            love.graphics.rectangle("line", -graphics.getWidth() / 2, -graphics.getHeight() / 2, graphics.getWidth()/4+5, graphics.getHeight())
            love.graphics.rectangle("line", -graphics.getWidth() / 2, -graphics.getHeight() / 2, graphics.getWidth(), graphics.getHeight())
            love.graphics.setLineWidth(1)
        love.graphics.pop()
    end,

    leave = function()
        importMods.rewriteAllMetas(storedModList)

        importMods.reloadAllMods()
    end
}