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
            ["foreground"] = graphics.newImage(graphics.imagePath("weekend1/phillyForeground")),
            ["skybox"] = graphics.newImage(graphics.imagePath("weekend1/phillySkybox")),
            ["foregroundCity"] = graphics.newImage(graphics.imagePath("weekend1/phillyForegroundCity")),
            ["construction"] = graphics.newImage(graphics.imagePath("weekend1/phillyConstruction")),
            ["smog"] = graphics.newImage(graphics.imagePath("weekend1/phillySmog")),
            ["highway"] = graphics.newImage(graphics.imagePath("weekend1/phillyHighway")),
            ["highwayLights"] = graphics.newImage(graphics.imagePath("weekend1/phillyHighwayLights")),
            ["skyline"] = graphics.newImage(graphics.imagePath("weekend1/phillySkyline")),
            ["spraycanPile"] = graphics.newImage(graphics.imagePath("weekend1/SpraycanPile")),
            ["abot"] = graphics.newImage(graphics.imagePath("weekend1/abot")),
            ["abotBack"] = graphics.newImage(graphics.imagePath("weekend1/stereoBG")),
        }

        stageImages["skybox"].x, stageImages["skybox"].y = 351, -300
        stageImages["spraycanPile"].x, stageImages["spraycanPile"].y = -314, 248
        stageImages["highwayLights"].x, stageImages["highwayLights"].y = -272, -459
        stageImages["highway"].x, stageImages["highway"].y = -413, -325
        stageImages["construction"].x, stageImages["construction"].y = 825, -145
        stageImages["smog"].x, stageImages["smog"].y = 0, -140
        stageImages["abot"].x, stageImages["abot"].y = 62, -20
        stageImages["abotBack"].x, stageImages["abotBack"].y = 62, -20
        stageImages["skyline"].x, stageImages["skyline"].y = 100, -227
        stageImages["foregroundCity"].x, stageImages["foregroundCity"].y = -386, 38

        enemy = love.filesystem.load("sprites/weekend1/darnell.lua")()
        boyfriend = love.filesystem.load("sprites/pico-player.lua")()
        -- TODO: Figure out rotated frames offsets.
        girlfriend = love.filesystem.load("sprites/weekend1/nene.lua")()

        enemy.x, enemy.y = -449, 45
        boyfriend.x, boyfriend.y = 646, 106
        girlfriend.x, girlfriend.y = -12, -286

        camera:addPoint("boyfriend", -boyfriend.x + 400, -boyfriend.y + 75)
        camera:addPoint("enemy", -enemy.x - 450, -enemy.y + 75)

        camera.defaultZoom = 0.85
    end,

    load = function()

    end,

    update = function(self, dt)
    end,

    draw = function()
        stageImages["skybox"]:draw()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.2, camera.y * 0.2)
            love.graphics.translate(camera.ex * 0.2, camera.ey * 0.2)

            stageImages["skyline"]:draw()
		love.graphics.pop()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.35, camera.y * 0.35)
            love.graphics.translate(camera.ex * 0.35, camera.ey * 0.35)

            stageImages["foregroundCity"]:draw()
		love.graphics.pop()
        love.graphics.push()
			love.graphics.translate(camera.x * 0.65, camera.y * 0.65)
            love.graphics.translate(camera.ex * 0.65, camera.ey * 0.65)

            stageImages["construction"]:draw()
            stageImages["smog"]:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x, camera.y)
            love.graphics.translate(camera.ex, camera.ey)
			
            stageImages["highwayLights"]:draw()
            stageImages["highway"]:draw()
		love.graphics.pop()
		love.graphics.push()
			love.graphics.translate(camera.x * 1.1, camera.y * 1.1)
            love.graphics.translate(camera.ex * 1.1, camera.ey * 1.1)

            stageImages["foreground"]:draw()
            stageImages["abotBack"]:draw()
            stageImages["abot"]:draw()
            girlfriend:draw()
            enemy:draw()
            boyfriend:draw()
            stageImages["spraycanPile"]:draw()
		love.graphics.pop()
    end,

    leave = function()
        for i, v in pairs(stageImages) do
            v = nil
		end

        graphics.clearCache()
    end
}