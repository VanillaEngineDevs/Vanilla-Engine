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
    enter = function(self, songExt)
		stageImages = {
			["Walls"] = graphics.newImage(graphics.imagePath("week5.erect/bgWalls")), -- walls
			["Escalator"] = graphics.newImage(graphics.imagePath("week5.erect/bgEscalator")), -- escalator
			["Christmas Tree"] = graphics.newImage(graphics.imagePath("week5.erect/christmasTree")), -- christmas tree
			["Snow"] = graphics.newImage(graphics.imagePath("week5/snow")), -- snow
			["White"] = graphics.newImage(graphics.imagePath("week5.erect/white")),
		}

		stageImages["Escalator"].x, stageImages["Escalator"].y = -205, -53
		stageImages["Christmas Tree"].x = 75
		stageImages["Snow"].y = 850
		stageImages["Snow"].sizeX, stageImages["Snow"].sizeY = 2, 2

		stageImages["Top Bop"] = love.filesystem.load("sprites/week5.erect/upperBop.lua")() -- top-bop
		stageImages["Bottom Bop"] = love.filesystem.load("sprites/week5.erect/bottomBop.lua")() -- bottom-bop
		stageImages["Santa"] = love.filesystem.load("sprites/week5/santa.lua")() -- santa

		stageImages["Top Bop"].x, stageImages["Top Bop"].y = 60, -250
		stageImages["Bottom Bop"].x, stageImages["Bottom Bop"].y = -75, 375
		stageImages["Santa"].x, stageImages["Santa"].y = -1350, 410
        girlfriend = BaseCharacter("sprites/characters/girlfriend-christmas.lua")
		enemy = BaseCharacter("sprites/characters/dearest-duo.lua")
		if songExt == "-pico" then
			boyfriend = BaseCharacter("sprites/characters/picoChristmas.lua")
			girlfriend = NeneCharacter("christmas")
			girlfriend.y = -80
		else
			boyfriend = BaseCharacter("sprites/characters/boyfriend-christmas.lua")
		end
		fakeBoyfriend = BaseCharacter("sprites/characters/boyfriend.lua") -- Used for game over

		camera.defaultZoom = 0.9

		girlfriend.x, girlfriend.y = -50, girlfriend.y + 410
		enemy.x, enemy.y = -780, 410
		boyfriend.x, boyfriend.y = 300, 620
		fakeBoyfriend.x, fakeBoyfriend.y = 300, 620

		local colorShader = love.graphics.newShader("shaders/adjustColor.glsl")
		colorShader:send("hue", 5)
		colorShader:send("saturation", 20)

		boyfriend.shader = colorShader
		girlfriend.shader = colorShader
		enemy.shader = colorShader
		stageImages["Santa"].shader = colorShader
    end,

    load = function(self)
    end,

    update = function(self, dt)
		stageImages["Top Bop"]:update(dt)
		stageImages["Bottom Bop"]:update(dt)
		stageImages["Santa"]:update(dt)

		if beatHandler.onBeat() then
			stageImages["Top Bop"]:animate("anim", false)
			stageImages["Bottom Bop"]:animate("anim", false)
			stageImages["Santa"]:animate("anim", false)
		end
    end,

    draw = function()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.5, camera.y * 0.5)

			stageImages["Walls"]:draw()
			if song ~= 3 then
				stageImages["Top Bop"]:draw()
				stageImages["Escalator"]:draw()
			end
			stageImages["Christmas Tree"]:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x * 0.9, camera.y * 0.9)

			stageImages["Bottom Bop"]:draw()

			stageImages["Snow"]:draw()

			girlfriend:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)

			stageImages["Santa"]:draw()
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