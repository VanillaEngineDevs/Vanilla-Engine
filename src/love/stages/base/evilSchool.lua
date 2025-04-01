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
		pixel = true
		love.graphics.setDefaultFilter("nearest")
        stageImages = {
			["Evil SchoolFG"] = graphics.newImage(graphics.imagePath("week6/evilSchoolFG")),
			["Evil SchoolBG"] = graphics.newImage(graphics.imagePath("week6/evilSchoolBG"))
        }
        enemy = BaseCharacter("sprites/characters/spirit.lua")
		enemy.x, enemy.y = -340, -20

        girlfriend.x, girlfriend.y = 30, -50
		boyfriend.x, boyfriend.y = 300, 190
		fakeBoyfriend.x, fakeBoyfriend.y = 300, 190

		--shaders["wiggle"]:send("effectType", 0)
		shaders["wiggle"]:send("uSpeed", 2)
		shaders["wiggle"]:send("uFrequency", 4)
		shaders["wiggle"]:send("uWaveAmplitude", 0.017)
    end,

    load = function(self)
        
    end,

    update = function(self, dt)
		shaders["wiggle"]:send("uTime", love.timer.getTime())
    end,

    draw = function()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.9, camera.y * 0.9)

			local lastShader = love.graphics.getShader()
			love.graphics.setShader(shaders["wiggle"])
			stageImages["Evil SchoolBG"]:udraw()
			love.graphics.setShader(lastShader)
			stageImages["Evil SchoolFG"]:udraw()

			girlfriend:udraw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)

			enemy:udraw()
			boyfriend:udraw()
		love.graphics.pop()
    end,

    leave = function()
        for _, v in pairs(stageImages) do
			v = nil
		end

		graphics.clearCache()
    end
}