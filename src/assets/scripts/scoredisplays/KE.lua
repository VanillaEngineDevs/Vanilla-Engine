local function getWife3Condition(acc)
	if acc >= 99.9935 then return 1 end -- AAAAA
	if acc >= 99.980 then return 2 end -- AAAA:
	if acc >= 99.970 then return 3 end -- AAAA.
	if acc >= 99.955 then return 4 end -- AAAA
	if acc >= 99.90 then return 5 end -- AAA:
	if acc >= 99.80 then return 6 end -- AAA.
	if acc >= 99.70 then return 7 end -- AAA
	if acc >= 99 then return 8 end -- AA:
	if acc >= 96.50 then return 9 end -- AA.
	if acc >= 93 then return 10 end -- AA
	if acc >= 90 then return 11 end -- A:
	if acc >= 85 then return 12 end -- A.
	if acc >= 80 then return 13 end -- A
	if acc >= 70 then return 14 end -- B
	if acc >= 60 then return 15 end -- C

	return 16 -- D rank or worse
end

function Display:draw(hudFade)
    local text = ""
    local ranking = "N/A"
    local states = weeks:getStates()
    if states.missCounter == 0 and states.badCounter == 0 and states.shitCounter == 0 and states.goodCounter == 0 then
        ranking = "(MFC)"
    elseif states.missCounter == 0 and states.badCounter == 0 and states.shitCounter == 0 and states.goodCounter >= 1 then
        ranking = "(GFC)"
    elseif states.missCounter == 0 then
        ranking = "(FC)"
    elseif states.missCounter < 10 then
        ranking = "(SDCB)"
    else
        ranking = "(Clear)"
    end

    -- Wife3 rating
    local condition = getWife3Condition((weeks.ratingPercent or 0)*100)
    if condition == 1 then
        ranking = ranking .. " AAAAA"
    elseif condition == 2 then
        ranking = ranking .. " AAAA:"
    elseif condition == 3 then
        ranking = ranking .. " AAAA."
    elseif condition == 4 then
        ranking = ranking .. " AAAA"
    elseif condition == 5 then
        ranking = ranking .. " AAA:"
    elseif condition == 6 then
        ranking = ranking .. " AAA."
    elseif condition == 7 then
        ranking = ranking .. " AAA"
    elseif condition == 8 then
        ranking = ranking .. " AA:"
    elseif condition == 9 then
        ranking = ranking .. " AA."
    elseif condition == 10 then
        ranking = ranking .. " AA"
    elseif condition == 11 then
        ranking = ranking .. " A:"
    elseif condition == 12 then
        ranking = ranking .. " A."
    elseif condition == 13 then
        ranking = ranking .. " A"
    elseif condition == 14 then
        ranking = ranking .. " B"
    elseif condition == 15 then
        ranking = ranking .. " C"
    else
        ranking = ranking .. " D"
    end

    if (states.ratingPercent or 0) == 0 then
        ranking = "N/A"
    end

    text = "NPS: " .. (#states.nps or 0) .. " (Max " .. ((states.maxNPS or 0) < 0 and 0 or math.floor((states.maxNPS or 0))) .. ") | Score: " .. (states.score < 0 and 0 or math.floor(states.score)) .. " | Combo Breaks: " .. math.floor(states.missCounter) .. " | Accuracy: " .. ((math.floor((states.ratingPercent or 0) * 10000) / 100)) .. "% | " .. ranking

    local x = weeks.healthbar.x - 150
    local y = weeks.healthbar.y + 50

    local lastFont = love.graphics.getFont()
    love.graphics.setFont(scoringFont)
    
    uitextfColored(text, x, y, 1300, "center")

    love.graphics.setFont(lastFont)
end
