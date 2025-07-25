return {
    enter = function(self)
        headingOrder = {"Vanilla Engine", "Funkin Rewritten", "Friday Night Funkin", "Miscellaneous"}
        Headings = {
            ["Vanilla Engine"] = {
                heading = CreateText("Vanilla Engine", true),
                selected = true,
                members = {
                    {name = CreateText("GuglioIsStupid"), desc = "Lead Programmer", selected = false, callback = function() love.system.openURL("https://ilovefemboys.org") end},
                    {name = CreateText("Getsaa"), desc = "Menu Design", selected = false, callback = function() love.system.openURL("https://twitter.com/GetsaaNG") end},
                    {name = CreateText("c l o t h i n g h a n g e r"), desc = "Former Programmer", selected = false, callback = function() love.system.openURL("https://twitter.com/clothinghanger6") end},
                }
            },
            ["Funkin Rewritten"] = {
                heading = CreateText("Funkin Rewritten", true),
                selected = false,
                members = {
                    {name = CreateText("HTV04"), desc = "Programmer of Funkin Rewritten", selected = false, callback = function() love.system.openURL("https://twitter.com/HTV04_") end},
                }
            },
            ["Friday Night Funkin"] = {
                heading = CreateText("Friday Night Funkin", true),
                selected = false,
                members = {
                    {name = CreateText("ninjamuffin99"), desc = "Programmer", selected = false, callback = function() love.system.openURL("https://twitter.com/ninja_muffin99") end},
                    {name = CreateText("PhantomArcade"), desc = "Artist", selected = false, callback = function() love.system.openURL("https://twitter.com/phantomarcade3k") end},
                    {name = CreateText("Evilsk8r"), desc = "Artist", selected = false, callback = function() love.system.openURL("https://twitter.com/evilsk8r") end},
                    {name = CreateText("Kawaisprite"), desc = "Musician", selected = false, callback = function() love.system.openURL("https://twitter.com/kawaisprite") end},
                    {name = CreateText("And all the contributors"), desc = "Contributors", selected = false, callback = function() love.system.openURL("https://github.com/FunkinCrew/Funkin/graphs/contributors") end},
                }
            },
            ["Miscellaneous"] = {
                heading = CreateText("Miscellaneous", true),
                selected = false,
                members = {
                    {name = CreateText("MarioG9421"), desc = "Asset Optimizations", selected = false, callback = function() love.system.openURL("https://twitter.com/MarioG9421exdi") end},
                    {name = CreateText("PhantomClo"), desc = "Pixel note splashes", selected = false},
                    {name = CreateText("Keoki"), desc = "Note splashes", selected = false},
                    {name = CreateText("P-sam"), desc = "Developing LOVE-NX (The framework the Switch port uses)", selected = false, callback = function() love.system.openURL("https://github.com/retronx-team/love-nx") end},
                    {name = CreateText("TurtleP"), desc = "Developing LovePotion (The framework the depracted Switch port uses)", selected = false, callback = function() love.system.openURL("https://github.com/lovebrew/lovepotion") end},
                    {name = CreateText("The developers of the LOVE framework"), desc = "LÖVE", selected = false, callback = function() love.system.openURL("https://love2d.org") end},
                    {name = CreateText("Psych Engine Contributers"), desc = "Helping create Psych Engine, which some parts of this engine is based off of.", selected = false, callback = function() love.system.openURL("https://github.com/ShadowMario/FNF-PsychEngine/graphs/contributors") end},
                }
            }
        }

        -- change all y positions of the headings (starting from 15), set y in order
        local y = 15
        for i, heading in ipairs(headingOrder) do
            Headings[heading].heading.y = y
            y = y + 75
            -- depending on how many members, set their y pos
            for j, member in ipairs(Headings[heading].members) do
                member.name.y = y
                y = y + 75
            end
            y = y + 75
        end

        options = {}
        extraSpaceIndexes = {4, 5, 10} -- if curOption is at these, add an extra 75 to yOffset

        -- add options (heading names and member names) in order
        for i, heading in ipairs(headingOrder) do
            for j, member in ipairs(Headings[heading].members) do
                table.insert(options, member.name.string)
            end
        end

        curSelected = 1

        yOffset = 0
        curDesc = ""

        bg = graphics.newImage(graphics.imagePath("menu/menuBG"))
    end,

    update = function(self, dt)
        --- for pairs
        for i, heading in pairs(Headings) do
            heading.heading:update(dt)
            -- if selected is false, and none of the members are selected, make the alpha 0.85
            for j, member in ipairs(heading.members) do
                if not member.selected then
                    member.name.alpha = 0.65
                else
                    member.name.alpha = 1
                end
                member.name:update(dt)
            end
        end

        -- set the selected member to true
        -- all things in options are the member names
        for i, heading in ipairs(headingOrder) do
            for j, member in ipairs(Headings[heading].members) do
                if options[curSelected] == member.name.string then
                    member.selected = true
                    curDesc = member.desc
                else
                    member.selected = false
                end
            end
        end

        -- if up is pressed, go up
        if input:pressed("up") then
            curSelected = curSelected - 1
            if curSelected < 1 then
                curSelected = #options
            end
        end
        -- if down is pressed, go down
        if input:pressed("down") then
            curSelected = curSelected + 1
            if curSelected > #options then
                curSelected = 1
            end
        end

        if input:pressed("confirm") then
            -- go to the callback of the selected member
            for i, heading in ipairs(headingOrder) do
                for j, member in ipairs(Headings[heading].members) do
                    if options[curSelected] == member.name.string then
                        if member.callback then
                            member.callback()
                        end
                    end
                end
            end
        end

        if input:pressed("gameBack") then
            graphics:fadeOutWipe(0.5,
            function()
                Gamestate.switch(menuSelect)
            end)
        end

        -- util.coolLerp to new yOffset
        local newY = 0
        -- extraSpaceIndexes = {3, 5, 10}
        -- determine how many extra spaces are needed from curSelected
        local extraSpaces = 0
        for i, v in ipairs(extraSpaceIndexes) do
            if curSelected >= v then
                extraSpaces = extraSpaces + 1
            end
        end

        -- newY starts from 0, and adds 75 for each selection index
        newY = (curSelected - 2) * 75 + extraSpaces * 150

        yOffset = util.coolLerp(yOffset, newY, 0.1)
    end,

    draw = function(self)
        love.graphics.push()
            love.graphics.push()
                love.graphics.translate(graphics.getWidth()/2, graphics.getHeight()/2)
                graphics.setColor(0.5, 0, 0.5, 1)
                bg:draw()
                graphics.setColor(1, 1, 1, 1)
            love.graphics.pop()
            love.graphics.translate(0, -yOffset)
            -- draw in order
            for i, heading in ipairs(headingOrder) do
                Headings[heading].heading:draw()
                for j, member in ipairs(Headings[heading].members) do
                    member.name:draw()
                end
            end
        love.graphics.pop()

        -- draw a rectangle that is push width and 35 height displaying currently selected option desc
        love.graphics.setColor(0, 0, 0, 0.85)
        love.graphics.rectangle("fill", 0, graphics.getHeight() - 35, graphics.getWidth(), 35)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(font)
        love.graphics.printf(curDesc, 0, graphics.getHeight() - 30, graphics.getWidth(), "center")
    end,

    leave = function(self)

    end
}