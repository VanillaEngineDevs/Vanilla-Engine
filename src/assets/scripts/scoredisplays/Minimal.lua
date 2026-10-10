function Display:draw()
    local x = weeks.healthbar.x - 150
    local y = weeks.healthbar.y + 50

    local states = weeks:getStates()
    local ratingStr = "N/A"
    if states.ratingPercent > 0 then
        ratingStr = math.floor(states.ratingPercent * 10000) / 100 .. "%"
    end

    local text = math.floor(states.score) .. " | " .. math.floor(states.missCounter) .. " | " .. ratingStr

    local lastFont = love.graphics.getFont()
    love.graphics.setFont(scoringFont)

    uitextfColored(text, x, y, 1300, "center")

    love.graphics.setFont(lastFont)
end
