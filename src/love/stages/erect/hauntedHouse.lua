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

local lightningStrikeBeat = 0
local lightningStrikeOffset = 8

local curStageStyle = "dark"
return {
    enter = function()
		lightningStrikeBeat = 0
		lightningStrikeOffset = 8
        stageImages = {
            bg_light = graphics.newImage(graphics.imagePath("week2.erect/bgLight")),
			bg_dark = graphics.newImage(graphics.imagePath("week2.erect/bgDark")),
			treesSprite = love.filesystem.load("sprites/week2.erect/bgtrees.lua")(),
			trees = graphics.newCanvas(600, 400),
			stairs_light = graphics.newImage(graphics.imagePath("week2.erect/stairsLight")),
			stairs_dark = graphics.newImage(graphics.imagePath("week2.erect/stairsDark")),
        }
        
		enemy = SpookyDarkCharacter()
		boyfriend = BFDarkCharacter()
		girlfriend = GFDarkCharacter()

		girlfriend.x, girlfriend.y = 134, 12
		enemy.x, enemy.y = -337, 140
		boyfriend.x, boyfriend.y = 482, 207

		stageImages.stairs_dark.x = 658
		stageImages.stairs_light.x = 658
		stageImages.treesSprite.x, stageImages.treesSprite.y = -224, -158

		stageImages.stairs_light.alpha = 0
		stageImages.bg_light.alpha = 0

		if love.system.getOS() ~= "NX" then 
			shaders["rain"]:send("uIntensity", 0.4)
			shaders["rain"]:send("uScale", 720 / 200 * 2)
		end
    end,

    load = function()
    end,

    update = function(self, dt)
		stageImages["treesSprite"]:update(dt)

		if love.system.getOS() ~= "NX" then
			shaders["rain"]:send("uTime", love.timer.getTime())
		end

		if love.math.random(10) == 10 and Conductor.curBeat > (lightningStrikeBeat + lightningStrikeOffset) then
			self:doLightningStrike(true, Conductor.curBeat)
		end
    end,
	
	doLightningStrike = function(self, playSound, beat)
		if playSound then
			audio.playSound(sounds["thunder"][love.math.random(2)])
		end

		stageImages["bg_light"].alpha = 1
		stageImages["stairs_light"].alpha = 1

		boyfriend.alpha = 0
		girlfriend.alpha = 0
		enemy.alpha = 0

		Timer.after(0.06, function()
			stageImages["bg_light"].alpha = 0
			stageImages["stairs_light"].alpha = 0

			boyfriend.alpha = 1
			girlfriend.alpha = 1
			enemy.alpha = 1
		end)

		Timer.after(0.12, function()
			stageImages["bg_light"].alpha = 1
			stageImages["stairs_light"].alpha = 1

			boyfriend.alpha = 0
			girlfriend.alpha = 0
			enemy.alpha = 0

			Timer.tween(1.5, stageImages["bg_light"], {alpha = 0}, "linear")
			Timer.tween(1.5, stageImages["stairs_light"], {alpha = 0}, "linear")
			Timer.tween(1.5, boyfriend, {alpha = 1}, "linear")
			Timer.tween(1.5, girlfriend, {alpha = 1}, "linear")
			Timer.tween(1.5, enemy, {alpha = 1}, "linear")
		end)

		lightningStrikeBeat = beat
		lightningStrikeOffset = love.math.random(8, 24)

		boyfriend:animate("shaking")
		girlfriend:animate("fear", false, function() girlfriend:animate("danceLeft", false) end)
	end,

    draw = function()
		--[[ stageImages["trees"]:renderTo(function()
			love.graphics.clear()
			love.graphics.translate(stageImages["trees"]:getWidth() / 2, stageImages["trees"]:getHeight() / 2)
			stageImages["treesSprite"]:draw()
		end) ]]
		love.graphics.push()
			--[[ if love.system.getOS() ~= "NX" then 
				love.graphics.setShader(shaders["rain"])
			end ]]
			love.graphics.translate(camera.x * 0.8, camera.y * 0.8)
			stageImages[--[[ "trees" ]]"treesSprite"]:draw()
			--[[ love.graphics.setShader() ]]
		-- look. buddy. i don't like you.
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)
			stageImages["bg_dark"]:draw()
			stageImages["bg_light"]:draw()
			
			girlfriend:draw()
			enemy:draw()
			boyfriend:draw()

			stageImages["stairs_dark"]:draw()
			stageImages["stairs_light"]:draw()
		love.graphics.pop()
    end,

    leave = function()
        for _, v in pairs(stageImages) do
			v = nil
		end

		graphics.clearCache()
    end
}