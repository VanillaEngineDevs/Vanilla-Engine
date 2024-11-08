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

local curStageStyle = "dark"
return {
    enter = function()
        stageImages = {
            bg_light = graphics.newImage(graphics.imagePath("week2.erect/bgLight")),
			bg_dark = graphics.newImage(graphics.imagePath("week2.erect/bgDark")),
			stairs_light = graphics.newImage(graphics.imagePath("week2.erect/stairsLight")),
			stairs_dark = graphics.newImage(graphics.imagePath("week2.erect/stairsDark")),
        }
        
		enemy = BaseCharacter("sprites/characters/skid-and-pump.lua")
		boyfriend = BFDarkCharacter()
		girlfriend = GFDarkCharacter()	

		girlfriend.x, girlfriend.y = 134, 12
		enemy.x, enemy.y = -337, 140
		boyfriend.x, boyfriend.y = 482, 207

		stageImages.stairs_dark.x = 658
		stageImages.stairs_light.x = 658
    end,

    load = function()
    end,

    update = function(self, dt)
        
    end,

    draw = function()
        love.graphics.push()
			love.graphics.translate(camera.x, camera.y)
			stageImages["bg_" .. curStageStyle]:draw()
			
			girlfriend:draw()
			enemy:draw()
			boyfriend:draw()

			stageImages["stairs_" .. curStageStyle]:draw()
		love.graphics.pop()
    end,

    leave = function()
        for _, v in pairs(stageImages) do
			v = nil
		end

		graphics.clearCache()
    end
}