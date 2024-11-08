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
        if song ~= 3 then
            stageImages = {
                ["Walls"] = graphics.newImage(graphics.imagePath("week5/walls")), -- walls
			    ["Escalator"] = graphics.newImage(graphics.imagePath("week5/escalator")), -- escalator
			    ["Christmas Tree"] = graphics.newImage(graphics.imagePath("week5/christmas-tree")), -- christmas tree
			    ["Snow"] = graphics.newImage(graphics.imagePath("week5/snow")) -- snow
            }

			stageImages["Escalator"].x = 125
			stageImages["Christmas Tree"].x = 75
			stageImages["Snow"].y = 850
			stageImages["Snow"].sizeX, stageImages["Snow"].sizeY = 2, 2

			stageImages["Top Bop"] = love.filesystem.load("sprites/week5/top-bop.lua")() -- top-bop
			stageImages["Bottom Bop"] = love.filesystem.load("sprites/week5/bottom-bop.lua")() -- bottom-bop
			stageImages["Santa"] = love.filesystem.load("sprites/week5/santa.lua")() -- santa

			stageImages["Top Bop"].x, stageImages["Top Bop"].y = 60, -250
			stageImages["Bottom Bop"].x, stageImages["Bottom Bop"].y = -75, 375
			stageImages["Santa"].x, stageImages["Santa"].y = -1350, 410
		end
        girlfriend = BaseCharacter("sprites/characters/girlfriend-christmas.lua")
		enemy = BaseCharacter("sprites/characters/dearest-duo.lua")
		boyfriend = BaseCharacter("sprites/characters/boyfriend-christmas.lua")
		fakeBoyfriend = BaseCharacter("sprites/characters/boyfriend.lua") -- Used for game over

		camera.defaultZoom = 0.9

		girlfriend.x, girlfriend.y = -50, 410
		enemy.x, enemy.y = -780, 410
		boyfriend.x, boyfriend.y = 300, 620
		fakeBoyfriend.x, fakeBoyfriend.y = 300, 620
    end,

    load = function(self)
        if song == 3 then
            camera.defaultZoom = 0.9
    
            if __scaryIntro then
                camera.x, camera.y = -150, 750
                camera.zoom = 2.5
    
                graphics.setFade(1)
            else
                camera.zoom = 0.9 
            end
    
            stageImages["Walls"] = graphics.newImage(graphics.imagePath("week5/evil-bg")) -- evil-bg
            stageImages["Christmas Tree"] = graphics.newImage(graphics.imagePath("week5/evil-tree")) -- evil-tree
            stageImages["Snow"] = graphics.newImage(graphics.imagePath("week5/evil-snow")) -- evil-snow
    
            stageImages["Walls"].y = -250
            stageImages["Christmas Tree"].x = 75
            stageImages["Christmas Tree"].sizeX, stageImages["Christmas Tree"].sizeY = 0.5, 0.5
            stageImages["Snow"].x, stageImages["Snow"].y = -50, 770
    
        end
    end,

    update = function(self, dt)
        if song ~= 3 then
            stageImages["Top Bop"]:update(dt)
            stageImages["Bottom Bop"]:update(dt)
            stageImages["Santa"]:update(dt)

            if beatHandler.onBeat() then
				stageImages["Top Bop"]:animate("anim", false)
				stageImages["Bottom Bop"]:animate("anim", false)
				stageImages["Santa"]:animate("anim", false)
			end
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

			if song ~= 3 then
				stageImages["Bottom Bop"]:draw()
			end

			stageImages["Snow"]:draw()

			girlfriend:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)

			if song ~= 3 then
				stageImages["Santa"]:draw()
			end
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