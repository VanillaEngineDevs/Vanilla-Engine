local ratingScale = 1

local function getRatingName(acc)
	if acc <= 0.2 then
		return "You Suck!"
	elseif acc <= 0.4 then
		return "Shit"
	elseif acc <= 0.5 then
		return "Bad"
	elseif acc <= 0.6 then
		return "Bruh"
	elseif acc <= 0.69 then
		return "Meh"
	elseif acc <= 0.7 then
		return "Nice"
	elseif acc <= 0.8 then
		return "Good"
	elseif acc <= 0.9 then
		return "Great"
	elseif acc <= 1 then
		return "Sick!"
	else
		return "Perfect!!"
	end
end

function Display:onNoteHit(event)
    if event.data ~= "EnemyHit" then
        ratingScale = 1.075
    end
end

function Display:update(dt)
    if ratingScale > 1 then
        ratingScale = ratingScale - 0.1 * dt
        if ratingScale < 1 then ratingScale = 1 end
    end
end

function Display:draw()
    local lastFont = love.graphics.getFont()

    local states = weeks:getStates()
    local x = weeks.healthbar.x - 150
    local y = weeks.healthbar.y + 50

    local phrase = "?"

    if states.missCounter == 0 then
        if states.badCounter > 0 or states.shitCounter > 0 then
            phrase = "FC"
        elseif states.goodCounter > 0 then
            phrase = "GFC"
        elseif states.sickCounter > 0 then
            phrase = "SFC"
        end
    else
        if states.missCounter < 10 then
            phrase = "SDCB"
        else
            phrase = "Clear"
        end
    end

    local ratingStr = getRatingName(states.ratingPercent) .. " (" .. (math.floor(states.ratingPercent * 10000) / 100) .. "%) - " .. phrase

    if phrase == "?" then
        ratingStr = "?"
    end

    local text = "Score: " .. math.floor(states.score) .. " | Misses: " .. math.floor(states.missCounter) .. " | Rating: " .. ratingStr

    love.graphics.setFont(psychScoringFont)

    love.graphics.push()
        local width = 1300
        local height = psychScoringFont:getHeight()

        local centerX = x + width / 2
        local centerY = y + height / 2

        love.graphics.translate(centerX, centerY)
        love.graphics.scale(ratingScale, ratingScale)
        love.graphics.translate(-centerX, -centerY)

        uitextfColored(text, x, y, width, "center")
    love.graphics.pop()

    love.graphics.setFont(lastFont)
end
