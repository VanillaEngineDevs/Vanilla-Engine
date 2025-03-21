--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Vanilla Engine

Copyright (C) 2024 VanillaEngineDevs & HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

return {
    enter = function()
		sounds = sounds or {}
        winColors = {
			{49, 162, 253}, -- Blue
			{49, 253, 140}, -- Green
			{251, 51, 245}, -- Magenta
			{253, 69, 49}, -- Orange
			{251, 166, 51}, -- Yellow
		}
        winAlpha = 1
		winColor = 1
        
        stageImages = {
            ["Sky"] = graphics.newImage(graphics.imagePath("week3/sky")), -- sky
            ["City"] = graphics.newImage(graphics.imagePath("week3/city")), -- city
            ["City Windows"] = graphics.newImage(graphics.imagePath("week3/city-windows")), -- city-windows
            ["Behind Train"] = graphics.newImage(graphics.imagePath("week3/behind-train")), -- behind-train
            ["Street"] = graphics.newImage(graphics.imagePath("week3/street")), -- street
			["Train"] = graphics.newImage(graphics.imagePath("week3/train")), -- train
        }

        stageImages["Behind Train"].y = -100
		stageImages["Behind Train"].sizeX, stageImages["Behind Train"].sizeY = 1.25, 1.25
		stageImages["Street"].y = -100
		stageImages["Street"].sizeX, stageImages["Street"].sizeY = 1.25, 1.25

		stageImages["Train"].x, stageImages["Train"].y = 3000, -25

		enemy = BaseCharacter("sprites/characters/pico-enemy.lua")
		enemy.flipX = true

		sounds.trainPassing = love.audio.newSource("sounds/week3/train.ogg", "static")

		girlfriend.x, girlfriend.y = -70, -140
		enemy.x, enemy.y = -480, 50
		boyfriend.x, boyfriend.y = 165, 50
		
		daGoofyColours = {
			1, 1, 1, 1
		}

		stageImages["Train"].doShit = true

		function trainReset()
			stageImages["Train"].x = 3000
			stageImages["Train"].moving = false
			trainCars = 8
			stageImages["Train"].finishing = false
			stageImages["Train"].startedMoving = false
		end

		function trainStart()
			stageImages["Train"].moving = true
			audio.playSound(sounds.trainPassing)
		end

		function updateTrainPos(dt)
			if sounds.trainPassing:tell("seconds") > 4.7 and sounds.trainPassing:isPlaying() then
				stageImages["Train"].startedMoving = true
			end
			if stageImages["Train"].startedMoving then
				stageImages["Train"].x = stageImages["Train"].x - 6750 * dt

				if stageImages["Train"].x < -3000 and stageImages["Train"].finishing then
					--trainReset() -- bruh this shit is trying to troll me rn
					-- 			      why does it reset the train then still do it 1 more time
					stageImages["Train"].doShit = false
					stageImages["Train"].moving	= false
					stageImages["Train"].startedMoving = false
					stageImages["Train"].finishing = false
					girlfriend:animate("hair landing", false, function() girlfriend:animate("danceLeft") ; girlfriend.danced = false end)
					print("Train reset")
				end

				if stageImages["Train"].x < -200 and not stageImages["Train"].finishing and stageImages["Train"].doShit then
					if not girlfriend:isAnimated() or util.startsWith(girlfriend:getAnimName(), "dance") and girlfriend:getAnimName() ~= "hair landing" then
						girlfriend:animate("hair blowing")
					end
					stageImages["Train"].x = 375
					trainCars = trainCars - 1

					if trainCars <= 0 then
						stageImages["Train"].finishing = true
						stageImages["Train"].doShit = false
					end
				end
			end

			if not stageImages["Train"].moving then
				trainCooldown = trainCooldown + 1
			end
		end

		trainCooldown = 0
		trainCars = 8
    end,

    load = function()

    end,

    update = function(self, dt)
        if beatHandler.onBeat() and beatHandler.getBeat() % 4 == 0 then
			winColor = winColor + 1

			if winColor > 5 then
				winColor = 1
			end

			winAlpha = 1
		end

		if beatHandler.onBeat() and beatHandler.getBeat() % 8 == 4 and not stageImages["Train"].moving and trainCooldown > 8 and love.math.random(10) == 1 then
			trainCooldown = love.math.random(-4, 0)
			stageImages["Train"].doShit = true
			trainReset()
			print("Train start")
			trainStart()
		end

        if winAlpha > 0 then
            winAlpha = winAlpha - (((bpm or 120)/260) * dt)
        end

		updateTrainPos(dt)
    end,

    draw = function()
        local curWinColor = winColors[winColor]

        love.graphics.push()
			love.graphics.translate(camera.x * 0.25, camera.y * 0.25)

			stageImages["Sky"]:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x * 0.5, camera.y * 0.5)

			stageImages["City"]:draw()
			graphics.setColor(curWinColor[1]/255, curWinColor[2]/255, curWinColor[3]/255, winAlpha)
			stageImages["City Windows"]:draw()
			graphics.setColor(1, 1, 1)
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x * 0.9, camera.y * 0.9)
			stageImages["Behind Train"]:draw()
			stageImages["Train"]:draw()
			stageImages["Street"]:draw()

			girlfriend:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)

			enemy:draw()
			boyfriend:draw()
		love.graphics.pop()
    end,

    leave = function()
        for _, v in pairs(stageImages) do
			v = nil
		end

		graphics.clearCache()
    end
}