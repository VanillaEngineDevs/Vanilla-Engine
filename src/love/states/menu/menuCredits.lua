local AlphabetImg, AlphabetSpr
local symbols = {"!", "?", ".", ",", "'", "-", "(", ")", ":", ";", "/", "&", "+", "=", "_", "<", ">", "[", "]", "{", "}", "#", "$", "%", "@", "*"}

function CreateText(text, isBold)
    local isLowercase = false
    local isNumber = false
    local o = {
        x = 0,
        y = 0,
        text = {},
        size = 1,
        string = text,

        setup = function(self, text, isBold)
            self.text = {}
            for i = 1, #text do
                local char = text:sub(i, i)
                -- is letter uppercase?
                isLowercase = char:lower() == char
                -- is letter a number?
                isNumber = tonumber(char) ~= nil
                char = char:lower()

                if char ~= " " then
                    table.insert(self.text, Sprite())
                    self.text[#self.text]:setFrames(getSparrow(graphics.imagePath("alphabet")))
                    -- check if its isNumber or in symbols
                    if not isNumber and not table.contains(symbols, char) then
                        self.text[#self.text]:addAnimByPrefix("anim", char .. (isBold and " bold" or (isLowercase and " lowercase" or " uppercase")), 24, true)
                    else
                        print(char .. (isBold and " bold" or " normal"))
                        -- replace lowercase or uppercase with normal
                        self.text[#self.text]:addAnimByPrefix("anim", char .. (isBold and " bold" or " normal"), 24, true)
                    end
                    self.text[#self.text]:play("anim", true)
                    self.text[#self.text]:updateHitbox()
                    self.text[#self.text].x = 15 + (isBold and 60 or 50) * (i-1)
                end
            end
        end,

        update = function(self, dt)
            for i, char in ipairs(self.text) do
                char:update(dt)
            end
        end,

        draw = function(self)
            love.graphics.push()
            love.graphics.scale(self.size, self.size)
            love.graphics.translate(self.x, self.y)
            for i, char in ipairs(self.text) do
                char:draw()
            end
            love.graphics.pop()
        end
    }
    o:setup(text, isBold)
    return o
end

return {
    enter = function(self)
        headingOrder = {"Vanilla Engine", "Funkin Rewritten", "Friday Night Funkin", "Miscellaneous"}
        Headings = {
            ["Vanilla Engine"] = {
                heading = CreateText("Vanilla Engine", true),
                selected = true,
                members = {
                    {name = CreateText("GuglioIsStupid"), desc = "Lead Programmer", selected = false},
                    {name = CreateText("Getsaa"), desc = "Menu Design"},
                    {name = CreateText("clothing hanger"), desc = "Former Programmer", selected = false},
                }
            },
            ["Funkin Rewritten"] = {
                heading = CreateText("Funkin Rewritten", true),
                selected = false,
                members = {
                    {name = CreateText("HTV04"), desc = "Programmer of Funkin Rewritten", selected = false,},
                }
            },
            ["Friday Night Funkin"] = {
                heading = CreateText("Friday Night Funkin", true),
                selected = false,
                members = {
                    {name = CreateText("ninjamuffin99"), desc = "Programmer", selected = false,},
                    {name = CreateText("PhantomArcade"), desc = "Artist", selected = false,},
                    {name = CreateText("Evilsk8r"), desc = "Artist", selected = false,},
                    {name = CreateText("Kawaisprite"), desc = "Musician", selected = false,},
                    {name = CreateText("And all the contributors"), desc = "Contributors", selected = false,},
                }
            },
            ["Miscellaneous"] = {
                heading = CreateText("Miscellaneous", true),
                selected = false,
                members = {
                    {name = CreateText("PhantomClo"), desc = "Pixel note splashes", selected = false,},
                    {name = CreateText("Keoki"), desc = "Note splashes", selected = false,},
                    {name = CreateText("P-sam"), desc = "Developing LOVE-NX (The framework the depracted Switch port uses)", selected = false,},
                    {name = CreateText("The developers of the LOVE framework"), desc = "LÖVE", selected = false,},
                    {name = CreateText("RiverOaken"), desc = "Psych Engine credits button", selected = false,},
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
                    for i, v in ipairs(member.name.text) do
                        v.alpha = 0.65
                    end
                else
                    for i, v in ipairs(member.name.text) do
                        v.alpha = 1
                    end
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
        newY = (curSelected - 1) * 75 + extraSpaces * 75

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