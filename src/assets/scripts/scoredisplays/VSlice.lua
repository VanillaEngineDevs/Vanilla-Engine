local function commaFormat(n)
    local str = tostring(n)
    local x = str:find("%.")

    if x then
        str = str:sub(1, x - 1) .. str:sub(x)
    end

    return str:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

function Display:draw(hudfade)
    local text = string.format("Score: %s", commaFormat(math.floor(weeks.score)))

    local x = 300 - 100
    local y = 400 + 50

    if settings.downscroll then
        y = y - 800
    else
        y = y - 60
    end

    local lastFont = love.graphics.getFont()
    love.graphics.setFont(scoringFont)

    uitextfColored(text, x, y, 1300, "left")

    love.graphics.setFont(lastFont)
end
