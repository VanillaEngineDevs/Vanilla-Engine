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
		girlfriend = BaseCharacter("sprites/characters/girlfriend-pixel.lua")
		boyfriend = BaseCharacter("sprites/characters/boyfriend-pixel.lua")
		enemy = BaseCharacter("sprites/characters/senpai.lua")
		enemy.colours = {255,170,111}
		fakeBoyfriend = BaseCharacter("sprites/characters/boyfriend-pixel-dead.lua") -- Used for game over
		if settings.pixelPerfect then
			girlfriend.x, girlfriend.y = 0, 0
			boyfriend.x, boyfriend.y = 50, 30
			fakeBoyfriend.x, fakeBoyfriend.y = 50, 30
			enemy.x, enemy.y = -50, 0
		else
			girlfriend.x, girlfriend.y = 30, -50
			boyfriend.x, boyfriend.y = 300, 190
			fakeBoyfriend.x, fakeBoyfriend.y = 300, 190
			enemy.x, enemy.y = -340, -20
		end
    end,

    load = function(self)
        if song == 3 then
            enemy = BaseCharacter("sprites/characters/spirit.lua")
            stageImages["School"] = love.filesystem.load("sprites/week6/evil-school.lua")()
			enemy.x, enemy.y = -50, 0
        elseif song == 2 then
            enemy = BaseCharacter("sprites/characters/senpai-angry.lua")
			enemy.colours = {255,170,111}
            stageImages["Freaks"]:animate("dissuaded", true)
			enemy.x, enemy.y = -50, 0
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
		if not settings.pixelPerfect then
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
		else
			love.graphics.push()
				love.graphics.translate(camera.x * 0.9, camera.y * 0.9)

				if song ~= 3 then
					stageImages["Sky"]:draw()
				end

				stageImages["School"]:draw()
				if song ~= 3 then
					stageImages["Street"]:draw()
					stageImages["Trees Back"]:draw()

					stageImages["Trees"]:draw()
					stageImages["Petals"]:draw()
					stageImages["Freaks"]:draw()
				end
				girlfriend:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(camera.x, camera.y)

				enemy:draw()
				boyfriend:draw()
			love.graphics.pop()
		end
    end,

    leave = function()
        for _, v in pairs(stageImages) do
			v = nil
		end

		graphics.clearCache()
    end
}