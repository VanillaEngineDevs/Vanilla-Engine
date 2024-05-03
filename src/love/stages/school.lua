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
            ["Sky"] = graphics.newImage(graphics.imagePath("week6/sky")), -- sky
			["School"] = graphics.newImage(graphics.imagePath("week6/school")), -- school
			["Street"] = graphics.newImage(graphics.imagePath("week6/street")), -- street
			["Trees Back"] = graphics.newImage(graphics.imagePath("week6/trees-back")), -- trees-back
			["Trees"] = love.filesystem.load("sprites/week6/trees.lua")(), -- trees
			["Petals"] = love.filesystem.load("sprites/week6/petals.lua")(), -- petals
			["Freaks"] = love.filesystem.load("sprites/week6/freaks.lua")() -- freaks
        }
		girlfriend = love.filesystem.load("sprites/pixel/girlfriend.lua")()
		boyfriend = love.filesystem.load("sprites/pixel/boyfriend.lua")()
		enemy = love.filesystem.load("sprites/week6/senpai.lua")()
		enemy.colours = {255,170,111}
		fakeBoyfriend = love.filesystem.load("sprites/pixel/boyfriend-dead.lua")() -- Used for game over
        girlfriend.x, girlfriend.y = 30, -50
		boyfriend.x, boyfriend.y = 300, 190
		fakeBoyfriend.x, fakeBoyfriend.y = 300, 190
		enemy.x, enemy.y = -340, -20

		curEnemy = "senpai"
		curPlayer = "pixelboyfriend"
    end,

    load = function(self)
        if song == 3 then
            enemy = love.filesystem.load("sprites/week6/spirit.lua")()
            stageImages["School"] = love.filesystem.load("sprites/week6/evil-school.lua")()
			enemy.x, enemy.y = -340, -20
			curEnemy = "spirit"
        elseif song == 2 then
            enemy = love.filesystem.load("sprites/week6/senpai-angry.lua")()
			enemy.colours = {255,170,111}
			curEnemy = "senpaiangry"
            stageImages["Freaks"]:animate("dissuaded", true)
			enemy.x, enemy.y = -340, -20
        end
    end,

    update = function(self, dt)
        if song ~= 3 then
			stageImages["Trees"]:update(dt)
			stageImages["Petals"]:update(dt)
			stageImages["Freaks"]:update(dt)
		else
			stageImages["School"]:update(dt)
		end
    end,

    draw = function()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.9, camera.y * 0.9)

			if song ~= 3 then
				stageImages["Sky"]:udraw()
			end

			stageImages["School"]:udraw()
			if song ~= 3 then
				stageImages["Street"]:udraw()
				stageImages["Trees Back"]:udraw()

				stageImages["Trees"]:udraw()
				stageImages["Petals"]:udraw()
				stageImages["Freaks"]:udraw()
			end
			girlfriend:udraw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)

			enemy:udraw()
			boyfriend:udraw()
		love.graphics.pop()
    end,

    leave = function()
        for i, v in pairs(stageImages) do
			v = nil
		end

		graphics.clearCache()
    end
}