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
        stageImages = {
            ["Stage Back"] = graphics.newImage(graphics.imagePath("week1/stage-back")), -- stage-back
		    ["Stage Front"] = graphics.newImage(graphics.imagePath("week1/stage-front")), -- stage-front
		    ["Curtains"] = graphics.newImage(graphics.imagePath("week1/curtains")) -- curtains
        }

        stageImages["Stage Front"].y = 400
        stageImages["Curtains"].y = -100

        enemy = BaseCharacter("sprites/characters/daddy-dearest.lua")

        girlfriend.x, girlfriend.y = 30, -90
        enemy.x, enemy.y = -380, -110
        boyfriend.x, boyfriend.y = 260, 100
    end,

    load = function()

    end,

    update = function(self, dt)
    end,

    draw = function()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.9, camera.y * 0.9)

			stageImages["Stage Back"]:draw()
			stageImages["Stage Front"]:draw()

			girlfriend:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)
			enemy:draw()
			boyfriend:draw()
            graphics.setColor(1,1,1)
            
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x * 1.1, camera.y * 1.1)

			stageImages["Curtains"]:draw()
		love.graphics.pop()
    end,

    leave = function()
        for _, v in pairs(stageImages) do
            v = nil
		end

        graphics.clearCache()
    end
}