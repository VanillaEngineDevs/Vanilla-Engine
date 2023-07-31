local Alphabet = {}
Alphabet.newLines = {}
Alphabet.letters = {}
Alphabet.image = love.graphics.newImage(graphics.imagePath("Alphabet"))
Alphabet.sprite = love.filesystem.load("sprites/Alphabet.lua")
Alphabet.y = 0

function Alphabet:setText(text)
    local letters = {}
    for i = 1, #text do
        local letter = text:sub(i, i)
        
        -- Check if letter is a new line
        if letter == "\n" then
            -- get the position of the current letter (i)
            table.insert(self.newLines, {i})
        else
            table.insert(letters, letter)
        end
    end

    local x = graphics.getWidth() / 2
    -- for all letters, create a new sprite in Alphabet.letters
    for i, letter in ipairs(letters) do
        local sprite = self.sprite()
        sprite:animate(letter, true)
        table.insert(self.letters, sprite)
    end

    -- center the text
    local width = 0
    for i, letter in ipairs(self.letters) do
        width = width + letter:getFrameWidth()
    end
    x = x - width / 2

    -- set the position of each letter
    for i, letter in ipairs(self.letters) do
        letter.x = x
        x = x + letter:getFrameWidth() + 10
    end

    print(#self.newLines, self.newLines[#self.newLines][1])
end

function Alphabet:update(dt)
    for i, letter in ipairs(self.letters) do
        letter:update(dt)
    end
end

function Alphabet:draw()
    love.graphics.push()
    -- if the letter is after a new line, move it down
    local newLines = 0
    love.graphics.translate(0, self.y)
    for i, letter in ipairs(self.letters) do
        for j, newLine in ipairs(self.newLines) do
            if i == newLine[1] then
                newLines = newLines + 1
            end
        end
        letter.y = newLines * 80

        -- recalculate x pos
        local x = graphics.getWidth() / 2
        for j = 1, i - 1 do
            x = x + self.letters[j]:getFrameWidth() + 10
        end
        letter.x = x
        
        letter:draw()
        -- print current x and y pos of screen
        --print(love.graphics.transformPoint(0, 0))
    end
    love.graphics.pop()
end

return Alphabet